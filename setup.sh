#!/bin/bash

set -e
die () {
    echo >&2 "$@"
    exit 1
}

BASE=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)

# ensure submodules are here
git submodule update --init --recursive
[[ ! -f ${BASE}/epa-ng/Dockerfile ]] && die "epa-ng submodule not found"
[[ ! -f ${BASE}/PEWO/INSTALL.sh ]] && die "PEWO submodule not found"

# build epa-ng/-serial
cd ${BASE}/epa-ng
EPA_SERIAL=1 make -j $(nproc)
mv bin/epa-ng bin/epa-ng-serial
make update -j $(nproc)
cd -

# change the %LOCATION% text in the snakemake/pewo yaml files to the full current path
for f in ${BASE}/configs/*.yaml
do
	sed -i "s,%LOCATION%,$BASE,g" $f
done

# unpack but keep relevant packed reference files
for f in ${BASE}/datasets/*/reference.fasta.gz
do
	gunzip --force --keep $f
done
