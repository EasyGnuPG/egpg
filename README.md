**egpg** is set of shell scripts to try to simplify what can be the
very confusing process of using GnuPG.

In order to simplify things, it is opinionated about the "right" way
to use GnuPG.

There are scads of options presented by OpenPGP, which are all part of
making it the flexible and powerful an encryption framework that it
is. But it's extremely complicated to get started with, and that quite
reasonably puts people off.

The philosophic goals here are these:

1. Make PGP as easy to use as possible. The more people using strong
   encryption, the better for everyone. One of the big hang ups right
   now is that the PGP tools are difficult to use - moreso than they
   strictly have to be.

2. Make the interface itself auditable. This is why this is presented
   as shell scripts rather than a web service or a GUI. If you're
   concerned about what **egpg** does, open up the files and read
   them, or have someone you trust read them.

3. Build a guide forward. The simplified interface provided here
   should be good to get started with, and with luck many users will
   find they never need anything beyond what **egpg** provides. If you
   find that you need to do something more, though, the goal is that
   you have a foundation to start with, and some direction on how to
   proceed.


## Requirements

 - You'll need `gpg2` installed. Most Linux distros have some variant
   of

   `apt-get install gnupg`

   Mac OS X users with [homebrew][1] installed can do

   `brew install gnupg2`

   Or else install the full [GPGTools][2] suite.

   Whatever package you install will need to include `gpg` and
   `gpgconf`.

 - You'll also need [haveged][3] which will improve greatly the speed
   of generating new gpg keys. In Debian based distros it can be
   installed with:

   `apt-get install haveged`

 - It is also nice to have [parcimonie][4] installed (although not required):

   `apt-get install parcimonie`


## Usage:

**egpg* presents a series of subcommands. At present there are:

```
./egpg help
./egpg key-gen <email> [<name>]
./egpg fingerprint
./egpg revoke [<revocation-certificate>]
./egpg seal <file> [<recipient>+]
./egpg open <file>
```

Those are the day to day "sign-encrypt" and "decrypt-verify"
operations.

Planned are:

```
./egpg configure
./egpg trust <users key>
```

These should be the minimal set required to use GPG effectively.

Any suggestions or discussions about supported operations, simplified
terminology, etc. is wellcome.


[1]: http://brew.sh/
[2]: https://gpgtools.org/
[3]: http://www.issihosts.com/haveged/
[4]: https://gaffer.ptitcanardnoir.org/intrigeri/code/parcimonie/
