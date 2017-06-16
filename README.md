# travis-encrypt-cli
A lightweight alternative to the official Travis Ruby CLI that only does env var encryption

**`travis-encrypt.sh`** is just a basic (hopefully portable) shell script. Simply download and run it, making sure you have a POSIX `sh` (`bash`, `ksh`, `tcsh`, `zsh`, etc.), `openssl`, `curl`, and `sed`.

**Examples**:

    # Outputs encrypted result to stdout
    ./travis-encrypt.sh username/repo MYVAR=supersecret

    # Outputs (via redirect) encrypted result to a file
    ./travis-encrypt.sh username/repo MYVAR=supersecret > encrypted_secure.txt
