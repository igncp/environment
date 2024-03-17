# CLI Tools

These are some notes about new found ways to use CLI tools. When used for a
while and learnt they would be remove from here.

## `dasel`

- Convert from json to yml: `cat FILE  | dasel -r json -w yaml`

## `etcdctl`

- Save a snapshot: `etcdctl snapshot save snapshot.db`
    - More info: https://etcd.io/docs/v3.3/op-guide/recovery/
- Print all keys: `etcdctl get "" --prefix --keys-only`

## `dust`

- Used in similar cases of  `du` and `ncdu`, although it doesn't seem to have an interactive mode
- Show the size grouped by the file type: `dust -t .`

## `entr`

- Run command clearing the screen: `echo /tmp/foo.sql | PAGER='' PGPASSWORD=postgres entr -c psql -h 0.0.0.0 -U postgres -d postgres -f /_`
- For waiting until the first change on the file use: `-p`

## `kafka`

- 列出主題: `kafka-topics --bootstrap-server http://localhost:9092 --list`
- 描述一個主題: `kafka-topics --bootstrap-server http://localhost:9092 --describe --topic TOPIC_NAME`

## `psql`

- To output in a CSV format can use the `--csv` flag
- To not print the columns headers can pass the `-t` command
- Describe a table (including indexes): `\d+ TABLE_NAME` (`\dt` lists tables)

## `pstree`

- It can check a string, for example: `pstree -s node`
