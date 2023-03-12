// journalctl -b -o short-monotonic _COMM=logger > /tmp/log.txt
const fs = require("fs");

const lines = [];

const main = () => {
  const filePath = process.argv[2];
  const fileContent = fs.readFileSync(filePath, "utf8");

  fileContent.split("\n").forEach((line, lineIndex) => {
    const time = line.match(/\[(.*?)\]/);
    if (!time) return null;
    const timeNum = Number(time[1].trim());
    lines.push(timeNum);
    const timeElapsed = timeNum - (lines[lineIndex - 1] || 0);
    console.log(`[${timeElapsed}]`, line);
  });
};

main();
