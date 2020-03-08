# Performance

General steps for improving the machine performance while developing.

## VM

- 3/4 Memory
- CPUs 3/4 (when using 4/4 it is much slower beacuse host doesn't have enough)
- Fixed size disk
- Stop docker, lightdm and other services when not using them
- Upgrade to NodeJS 12 (and other libraries) when possible
- No secondary display if possible
- `cat 'vm.swappiness=10' >> /etc/sysctl.conf` if enough memory
- Restart VM to check if there are memory leaks

## Mac

- Quit messaging apps and minimize Chrome tabs
- Quit Docker for desktop when using it in VM
- Quit Activity Monitor when finished monitoring
- Quit cloud file manager unless changing something
- Close Finder windows
- Dock preferences, remove animation
- Dont put disks to sleep - Battery settings
- In accessibility settings, reduce transparency and animation
- Connect charger

## App

- Build a smaller section of the app by commenting routes and disabling optimizations / checks
- If files still being watched, selectively delete files
- Fix socket for live update
- Stop daemons like `eslint_d`

## Editor

- While developing, disable plugins like: TypeScript, ESLint
- Check snapshots with `TopMemory` and `TopCPU`
