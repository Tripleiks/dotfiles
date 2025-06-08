# Age Encryption Tool

This directory contains configuration and helper scripts for the [age](https://github.com/FiloSottile/age) encryption tool.

## Usage

### Generate a key pair

```bash
age-keygen -o ~/.ssh/age_key
```

### Encrypt a file

```bash
# Using a public key
age -r age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p -o encrypted.txt.age file.txt

# Using a passphrase
age -p -o encrypted.txt.age file.txt
```

### Decrypt a file

```bash
# Using a private key
age -d -i ~/.ssh/age_key -o decrypted.txt encrypted.txt.age

# Using a passphrase
age -d -o decrypted.txt encrypted.txt.age
```

### Encrypt for multiple recipients

```bash
age -r key1 -r key2 -o encrypted.txt.age file.txt
```

## Integration with Git

You can use age to encrypt sensitive files in your Git repository. Create a `.gitattributes` file with:

```gitattributes
*.age filter=age diff=age
```

And set up the filter in your Git config:

```bash
git config --global filter.age.smudge "age -d -i ~/.ssh/age_key"
git config --global filter.age.clean "age -r age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p"
```

## Security Notes

- Store your private keys securely
- Consider using a password manager for your age passphrases
- Backup your private keys - if lost, encrypted data cannot be recovered
