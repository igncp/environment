# VM Issue Debugging

When having an issue in a VM the recommended approach is:

- Clean the provision script as much as possible
- Create a new VM with just the basic provision to replicate the issue and debug fast
- Once fixed, automate in the provision files
- Push to a branch in the repo
- Create a last instance to confirm it is working
