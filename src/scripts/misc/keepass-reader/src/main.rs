use std::fs::File;
use std::io::Read;

fn main() -> Result<(), String> {
    let path = std::env::args()
        .nth(1)
        .expect("Usage: keepass-reader <file.kdbx>");

    let mut kdbx = KdbxFile::new(path);
    kdbx.read_version()?;
    match kdbx.version {
        Some((major, minor, raw)) => {
            println!("KDBX version: {}.{} (raw=0x{:08x})", major, minor, raw);
        }
        None => {
            eprintln!("Version information not available.");
            std::process::exit(1);
        }
    }

    Ok(())
}

struct KdbxFile {
    path: String,
    version: Option<(u16, u16, u32)>,
}

impl KdbxFile {
    fn new(path: String) -> Self {
        KdbxFile {
            path,
            version: None,
        }
    }

    fn read_version(&mut self) -> Result<(), String> {
        let mut file = File::open(self.path.clone())
            .or_else(|e| Err(format!("Failed to open file: {}", e)))?;

        // Read first 12 bytes (signatures + version)
        let mut header = [0u8; 12];
        file.read_exact(&mut header)
            .or_else(|e| Err(format!("Failed to read file header: {}", e)))?;

        // Verify signatures (little-endian)
        let sig1 = u32::from_le_bytes([header[0], header[1], header[2], header[3]]);
        let sig2 = u32::from_le_bytes([header[4], header[5], header[6], header[7]]);

        const KDBX_SIG1: u32 = 0x9AA2D903; // as read in LE
        const KDBX_SIG2: u32 = 0xB54BFB67; // as read in LE

        if sig1 != KDBX_SIG1 || sig2 != KDBX_SIG2 {
            return Err(format!(
                "Invalid file signatures: got 0x{sig1:08x}, 0x{sig2:08x}. Not a KDBX file."
            ));
        }

        // Version is a 32-bit value: (major << 16) | minor
        let version_raw = u32::from_le_bytes([header[8], header[9], header[10], header[11]]);
        let major = (version_raw >> 16) as u16;
        let minor = (version_raw & 0xFFFF) as u16;

        self.version = Some((major, minor, version_raw));

        Ok(())
    }
}
