# Convert the given file to a pdf file of 3D barcodes.

qrencode() {
    local file="$1"

    workdir_make

    local dir="$(pwd)"
    cp "$file" "$WORKDIR"
    cd "$WORKDIR"
    local filename=$(basename "$file")

    split -d -l 30 $filename $filename.
    for f in $filename.*; do
        cat $f | $(which qrencode) -o $f.png
    done

    cat <<-_EOF > readme.txt
This is a QR encoded version of the ascii file: $filename
which can be printed and stored on paper.

You can scan and convert it back to ascii using a webcam and a barcode reader
like http://zbar.sourceforge.net/ . For example:
    zbarcam --raw > $filename
_EOF
    cp $filename file.txt
    convert readme.txt $filename.*.png file.txt $filename.pdf

    cd "$dir"
    mv "$WORKDIR"/$filename.pdf "$(dirname "$file")/"
}

#
# This file is part of EasyGnuPG.  EasyGnuPG is a wrapper around GnuPG
# to simplify its operations.  Copyright (C) 2016 Dashamir Hoxha
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see http://www.gnu.org/licenses/
#
