# Charts Scripts

Charts rendered using plotly to see serving the html files with a server (e.g. http-server)

## Example:

`seq 0 10 | sed -r "s|(.+)|\1,\1|" | scatter-chart /tmp/img1.html`

```
find ./src -type f | xargs wc -l | sort -nr | sed -r \
  "s|^[ ]+([0-9]+)[ ](.+)$|\"\2\", \1|" | tail -n +2 \
  | scatter-chart /tmp/img2.html
```

`cat data_file | scatter-chart /tmp/img3.html`
