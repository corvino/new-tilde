#!/usr/bin/env bash

dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
backup="$dir/BACKUP"

files="bin .bash_profile .bashrc .bash_lib .gitconfig .gitexclude"

# Create the "backup" directory for existing files; but only if there
# are existing files that aren't already symlinked appropriately. Fail
# if a backup is called for but one already exists. There is no
# "merging" of backups!

for file in $files; do
    # We have to test -e and -L, because a symbolic link that points to
    # a nonexistent file returns false.
    if [[ (-e ~/$file || -L ~/$file) && ! (-L ~/$file && $dir/$file == `readlink ~/$file`) ]]; then
        echo "BACKUP!!!!"
        if [ -e $backup ]; then
            echo "$backup already exists; can't move files out of the way."
            exit -1
        else
            echo "Create $backup"
            mkdir -p $backup
            break
        fi
    fi
done

# Run through the files, moving and symlinking as necessary. If nothing
# needs to be done, will simply output a list of the files checked.

echo "Move existing files to $backup and symlink from ~ to $dir (as necessary):"

for file in $files; do
    echo -n "  "
    if [[ -e ~/$file || -L ~/$file ]]; then
        if [[ -L ~/$file && $dir/$file == `readlink ~/$file` ]]; then
            # All done!!
            echo -n "   "
        else
            echo -n "m+l"
            mv ~/$file $backup/
            ln -s $dir/$file ~/$file
        fi
    else
        echo -n "  l"
        ln -s $dir/$file ~/$file
    fi
    echo "  $file"
done

# These symlinks are handy, in part because these directores are
# relatively hard to find.
if [[ $OSTYPE == "darwin"* ]]; then
    echo "Creating symlinks for macOS"

    # These can be nice to have ...
    # ln -sfh ~/Library/Application\ Support/Code/User ~/vscode-settings
    # ln -sfh ~/Library/Mobile\ Documents/com~apple~CloudDocs ~/drive
fi
