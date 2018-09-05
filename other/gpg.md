# GPG

- [Generating a new GPG key](https://help.github.com/articles/generating-a-new-gpg-key/#platform-linux)
- [Telling Git about your GPG key](https://help.github.com/articles/telling-git-about-your-gpg-key/)

- Create keys: `gpg2 --full-generate-key`
- List existing keys: `gpg2 --list-secret-keys --keyid-format LONG` where `LONG` doesn't need to be replaced
- Delete keys: `gpg2 --delete-secret-keys USER_NAME` where `USER_NAME` is the User ID
- Display key in armor format: `gpg2 --armor --export KEY_ID` where `KEY_ID` needs to be replaced
