#!/usr/bin/sh

grep 'Serial data: .*' $1 \
| sed 's/Serial data: //' \
| sed "s/ 10/'\\\n'/" \
| sed "s/'//" \
| perl -pe "s/'\n//" \
| perl -pe "s/\\\n/\n/g" \
> $2
