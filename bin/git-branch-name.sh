#! /usr/bin/env bash

git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'

# It's an interesting question whether we can get this output directly from git.

# git branch --format='%(objectname) SPC %(objecttype) TAB %(refname)'
# git branch --format='%(objectname) SPC %(objecttype) TAB %(refname) %(HEAD)'
# https://stackoverflow.com/questions/21256861/what-are-valid-fields-for-the-format-option-of-git-for-each-ref
# https://github.com/git/git/blob/v2.17.0/ref-filter.c

# git-branches-by-commit-date.sh
# https://gist.github.com/jasonrudolph/1810768
