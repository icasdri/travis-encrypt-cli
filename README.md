# travis-encrypt-cli
A lightweight alternative to the official Travis Ruby CLI that only does env var encryption

It's just a basic (hopefully portable) shell script, `travis-encrypt.sh`. Simply download and run it. A POSIX shell `sh` (`bash`, `ksh`, etc. should all do), `openssl`, and `sed` are required.

**Examples**:

    # Outputs encrypted result to stdout
    ./travis-encrypt.sh username/repo MYVAR=supersecret

    # Outputs (via redirect) encrypted result to a file
    ./travis-encrypt.sh username/repo MYVAR=supersecret > encrypted_secure.txt
