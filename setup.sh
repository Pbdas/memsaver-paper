#!/bin/bash

set -e
die () {
    echo >&2 "$@"
    exit 1
}

BASE=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)

# ensure epa-ng is here and properly cloned

# same for PEWO

# build epa-ng/-serial


# change the %LOCATION% text in the snakemake/pewo yaml files to the full current path
for f in ${BASE}/configs/*.yaml
do
	sed -i "s,%LOCATION%,$BASE,g" $f
done

# unpack but keep relevant packed reference files
