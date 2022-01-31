const fs = require("fs");
const path = require("path");

const {
  ENVIRONMENT_DIR,
  PROVISION_DIR,
  items,
} = require("./data.updateProvision");

if (PROVISION_DIR.slice(-3) === ".sh") {
  consol.log("PROVISION_DIR should be a directory");
  process.exit(1);
}

let provisionFileContent = fs.readFileSync(
  path.join(PROVISION_DIR, "/provision.sh"),
  "utf-8"
);

const updateItem = ([name, itemPath]) => {
  // it should fail on unexpected dir
  let toUpdateContent = fs.readFileSync(
    path.join(ENVIRONMENT_DIR, itemPath),
    "utf-8"
  );

  if (!itemPath.includes(name)) {
    console.log("Unexpected path, does not contain name: ", name, itemPath);
    process.exit(1);
  }

  if (name === "top") {
    toUpdateContent = toUpdateContent.replace("#!/usr/bin/env bash\n\n", "");
  }

  const regexpStr = "# " + name + " START(.|\n)*# " + name + " END";

  provisionFileContent = provisionFileContent.replace(
    new RegExp(regexpStr, "m"),
    () => {
      return toUpdateContent.trim();
    }
  );

  console.log("Updated: " + name);
};

items.forEach(updateItem);

const TMP_PROVISION_DIR = "/tmp/provision";
const RESULT_PROVISION = path.join(TMP_PROVISION_DIR, "/provision.sh");
const DIFF_FILE_PATH = "/tmp/diff_provision.sh";

if (!fs.existsSync(TMP_PROVISION_DIR)) {
  fs.mkdirSync(TMP_PROVISION_DIR);
}

fs.writeFileSync(RESULT_PROVISION, provisionFileContent);

const configurationFiles = fs.readdirSync(
  path.join(ENVIRONMENT_DIR, "/unix/config-files")
);

fs.readdirSync(PROVISION_DIR)
  .filter((file) => {
    return configurationFiles.includes(file);
  })
  .forEach((file) => {
    fs.copyFileSync(
      path.join(ENVIRONMENT_DIR, "/unix/config-files/", file),
      path.join(TMP_PROVISION_DIR, file)
    );
  });

const diffCommand =
  "diff --color=always -r " +
  "-x data.updateProvision.js " + // this file should be different per project
  PROVISION_DIR +
  " " +
  TMP_PROVISION_DIR +
  " | sed 's/\\x1b[[36;]*m//g'" +
  " | less -R"; // it is important to use -R (and not -r) for diffs

fs.writeFileSync(DIFF_FILE_PATH, diffCommand);

console.log("Created files in: " + TMP_PROVISION_DIR);
console.log("Check the diff by: `sh " + DIFF_FILE_PATH + "`");
