use crate::base::{config::Config, system::System, Context};

const CONFIG_FILE_NAME: &str = ".config/disk-on-volume";

// This default config requires around 40GB of disk space
// Tweak that for your volume
const DISKS: [(&str, &str); 6] = [
    ("/usr", "10G"),
    ("/var", "5G"),
    ("/root", "2G"),
    ("/home", "10G"),
    ("/etc", "4G"),
    ("/opt", "2G"),
];

pub fn sync_fstab(context: &mut Context) {
    if !context.system.is_linux() || !Config::has_config_file(&context.system, CONFIG_FILE_NAME) {
        return;
    }

    let sda_num = DISKS.iter().position(|(path, _)| path == &"/etc").unwrap() + 1;

    System::run_bash_command(&format!(
        r###"
cp /etc/fstab /tmp/fstab
umount /etc
cp /tmp/fstab /etc/fstab
mount /dev/sda{sda_num} /etc
"###,
    ));
}

// https://superuser.com/questions/332252/how-to-create-and-format-a-partition-using-a-bash-script
pub fn setup_disk_on_volume(context: &mut Context) {
    if !context.system.is_linux() || !Config::has_config_file(&context.system, CONFIG_FILE_NAME) {
        return;
    }

    let sda1_size = DISKS[0].1;
    let sda2_size = DISKS[1].1;
    let sda3_size = DISKS[2].1;
    let sda4_size = DISKS[3].1;
    let sda5_size = DISKS[4].1;
    let sda6_size = DISKS[5].1;

    System::run_bash_command(&format!(
        r###"
# The sed script strips off all the comments so that we can
# document what we're doing in-line with the actual commands.
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/sda
  g # clear the in memory partition table
  n # new partition
  p # primary partition
  1 # partition number 1
    # default - start at beginning of disk
  +{sda1_size} #
  n #
  p #
  2 #
    # default
  +{sda2_size} #
  n #
  p #
  3 #
    # default
  +{sda3_size} #
  n #
  p #
  4 #
    # default
  +{sda4_size} #
  n #
  p #
  5 #
    # default
  +{sda5_size} #
  n #
  p #
  6 #
    # default
  +{sda6_size} #
  w # write the partition table
  q
EOF

umount -a || true
fsck -y /dev/sda1 || true
sleep 5

mkdir -p /mnt/usr /mnt/var /mnt/root /mnt/home /mnt/etc /mnt/opt

mkfs.ext4 -F /dev/sda1
mkfs.ext4 -F /dev/sda2
mkfs.ext4 -F /dev/sda3
mkfs.ext4 -F /dev/sda4
mkfs.ext4 -F /dev/sda5
mkfs.ext4 -F /dev/sda6

mount /dev/sda1 /mnt/usr
mount /dev/sda2 /mnt/var
mount /dev/sda3 /mnt/root
mount /dev/sda4 /mnt/home
mount /dev/sda5 /mnt/etc
mount /dev/sda6 /mnt/opt

echo "Copying dirs in quiet mode"
rsync -rha --delete /usr/ /mnt/usr/
rsync -rha --delete /var/ /mnt/var/
rsync -rha --delete /root/ /mnt/root/
rsync -rha --delete /home/ /mnt/home/
rsync -rha --delete /etc/ /mnt/etc/
rsync -rha --delete /opt/ /mnt/opt/
echo "Dirs copied"

umount /mnt/usr
umount /mnt/var
umount /mnt/root
umount /mnt/home
umount /mnt/etc
umount /mnt/opt

mount /dev/sda1 /usr
mount /dev/sda2 /var
mount /dev/sda3 /root
mount /dev/sda4 /home
mount /dev/sda5 /etc
mount /dev/sda6 /opt

if [ -z $(grep 'disk_on_volume' /etc/fstab || true) ]; then
    genfstab -U / | grep UUID | grep '\/[a-z]' >> /etc/fstab
    echo '# disk_on_volume setup' >> /etc/fstab
fi
"###,
    ));

    sync_fstab(context);
}
