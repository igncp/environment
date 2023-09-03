# CLI Tools

These are some notes about new found ways to use CLI tools. When used for a
while and learnt they would be remove from here.

## `dasel`

- Convert from json to yml: `cat FILE  | dasel -r json -w yaml`

## `entr`

- Run command clearing the screen: `echo /tmp/foo.sql | PAGER='' PGPASSWORD=postgres entr -c psql -h 0.0.0.0 -U postgres -d postgres -f /_`
- For waiting until the first change on the file use: `-p`

## `psql`

- Run query file: `PGPASSWORD=postgres psql -h 0.0.0.0 -U postgres -d postgres -f /tmp/foo.sql | less -S`
- To output in a CSV format can use the `--csv` flag

## `sad`

- Replace without confirmation: `fd . -type f | sad -k 'foo' 'bar'`
