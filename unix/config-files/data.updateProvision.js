const PROVISION_DIR = process.env.HOME + "/project/provision";
const ENVIRONMENT_DIR = process.env.HOME + "/development/environment";

const items = [
  ["top", "unix/provision/top.sh"],
  ["arch-beginning", "unix/os/arch-linux/provision/arch-beginning.sh"],
  ["zsh", "unix/provision/zsh.sh"],
  ["general", "unix/provision/general.sh"],
  ["linux", "unix/provision/linux.sh"],
  ["python", "unix/provision/python.sh"],
  ["vim-base", "unix/provision/vim-base.sh"],
  ["vim-extra", "unix/provision/vim-extra.sh"],
  ["vim-root", "unix/provision/vim-root.sh"],
  ["js", "unix/provision/js.sh"],
  ["ts", "unix/provision/ts.sh"],
  ["gui-base", "unix/provision/gui-base.sh"],
  ["gui-i3", "unix/provision/gui-i3.sh"],
  ["gui-common", "unix/provision/gui-common.sh"],
  ["arch-gui", "unix/os/arch-linux/provision/arch-gui.sh"],
  ["android", "unix/provision/android.sh"],
  ["cli-tools", "unix/provision/cli-tools.sh"],
  ["docker", "unix/provision/docker.sh"],
  ["vscode", "unix/provision/vscode.sh"],
  // ...
];

module.exports = {
  ENVIRONMENT_DIR,
  PROVISION_DIR,
  items,
};
