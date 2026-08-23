# Skull-stripping tutorial files

The tutorial source files are stored as OpenSSL-encrypted, Base64-armoured files. The repository does not contain the passphrase or plaintext copies.

## Decrypt a file

Use OpenSSL 3.x (or a compatible version):

```bash
openssl enc -d -aes-256-cbc -salt -pbkdf2 -iter 600000 -md sha256 -a -A \
  -in bet_xsection.sh.enc -out bet_xsection.sh
```

OpenSSL will prompt for the passphrase. Substitute the corresponding input and output names for the other two files.

## Integrity hashes

```text
2bae059c8e7930f5e7af0dd4e90b1be50bab8e7c5b5f9f8a8911bb346109d4cb  bet_xsection.sh.enc
7b95c1e71ea260306add18801114387826a63f94c46d11b7b07cd008cd65d219  qc_index.html.enc
485d3999558c692cef42a98b56d070e0f6a4317c7a2a8b38daa3c6d2a58ea40d  synthstrip_extraction.sh.enc
```

These SHA-256 hashes detect accidental or unauthorized changes to the encrypted files; they do not replace encryption.
