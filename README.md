There are scads of options presented by GnuPG, which are all part of
making it the flexible and powerful an encryption framework that it
is. But it's extremely complicated to get started with, and that quite
reasonably puts people off.

**egpg** is a wrapper script that tries to simplify the process of
using GnuPG. In order to simplify things, it is opinionated about the
"right" way to use GnuPG.

The philosophic goals here are these:

1. Make GPG as easy to use as possible. The more people using strong
   encryption, the better for everyone. One of the big hang ups right
   now is that the GPG tools are difficult to use - moreso than they
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


## Installation

    git clone --branch gnupg-2.1 https://github.com/dashohoxha/egpg
    cd egpg/
    sudo make install

## Usage:

**egpg** presents a series of subcommands:

    egpg init

    egpg key gen [<email> <name>]
    egpg key ls

    egpg contact search <name>
    egpg contact ls

    egpg sign <file>
    egpg verify <file.signature>

    egpg seal <file> [<recipient>+]
    egpg open <file.sealed>

    egpg help
    egpg key help
    egpg contact help
    egpg ext help

For more details see the manual page: [http://dashohoxha.github.io/egpg/gnupg-2.1/man/][6]

These should be the minimal set required to use GPG effectively.

Any suggestions or discussions about supported operations, simplified
terminology, etc. is wellcome.


## Requirements

 - You'll need `gpg2` installed. Most Linux distros have some variant
   of:

        apt-get install gnupg

   Mac OS X users with [homebrew][1] installed can do:

        brew install gnupg2

   Or else install the full [GPGTools][2] suite.

 - You'll also need [haveged][3] which will improve greatly the speed
   of generating new gpg keys. In Debian based distros it can be
   installed with:

        apt-get install haveged

 - For spliting the key and using a dongle you will need [libgfshare][4].
   In Debian based distros it can be installed with:

        apt-get install libgfshare-bin

 - It is also nice to have [parcimonie][5] installed (although not
   required):

        apt-get install parcimonie

 - For barcodes and pdf backups, these are also needed:

        apt-get install qrencode imagemagick zbar-tools


[1]: http://brew.sh/
[2]: https://gpgtools.org/
[3]: http://www.issihosts.com/haveged/
[4]: http://www.digital-scurf.org/software/libgfshare
[5]: https://gaffer.ptitcanardnoir.org/intrigeri/code/parcimonie/
[6]: http://dashohoxha.github.io/egpg/gnupg-2.1/man/
