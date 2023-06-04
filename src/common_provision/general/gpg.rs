use crate::base::Context;

pub fn setup_gpg(context: &mut Context) {
    // GnuPG https://wiki.archlinux.org/title/GnuPG
    context.system.install_system_package("gnupg", Some("gpg"));

    context.files.append(
        &context.system.get_home_path(".shell_aliases"),
        r###"
alias GPGCreateKey='gpg --full-gen-key'
alias GPGDecryptSymmetric='gpg --decrypt --no-symkey-cache' # just passphrase
alias GPGDecryptSymmetricSudo='sudo gpg --decrypt --no-symkey-cache --pinentry-mode=loopback' # just passphrase
alias GPGDetachSign='gpg --detach-sign --armor'
alias GPGEditKey='gpg --edit-key' # type `help` for a list of commands
alias GPGEncryptSymmetric='gpg --armor --symmetric --no-symkey-cache' # just passphrase
alias GPGEncryptSymmetricSudo='sudo gpg --pinentry-mode=loopback --armor --symmetric --no-symkey-cache' # just passphrase
alias GPGExportASCIIKey='gpg --export-secret-keys --armor'
alias GPGExportPublic='gpg --export --armor --export-options export-minimal'
alias GPGImportKey='gpg --import' # e.g. GPGImportKey public.key
alias GPGInfo='gpg --version '
alias GPGListKeys='gpg --list-keys'
alias GPGListSecretKeys='gpg --list-secret-keys'
alias GPGReloadAgent='gpg-connect-agent reloadagent /bye'
alias GPGSignature='gpg --clearsign'
alias GPGVerify='gpg --verify'
    "###);
}
