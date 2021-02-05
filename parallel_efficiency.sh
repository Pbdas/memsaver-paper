#!/bin/bash

set -e
die () {
    echo >&2 "$@"
    exit 1
}

# run various combinations of datasets, memory limitations,
# using an increasing number of threads

BASE=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)
# BASE=$(pwd)
OUTDIR=${BASE}/runs_par
EPANG=${BASE}/epa-ng/bin/epa-ng
EPANG_SERIAL=${BASE}/epa-ng/bin/epa-ng-serial
T="/usr/bin/time -f '%e' --quiet"
DATA=${BASE}/datasets

[[ ! -f ${EPANG} ]] && die "epa-ng executable not there - did you run setup.sh yet?"
[[ ! -f ${EPANG_SERIAL} ]] && die "epa-ng-serial executable not there - did you run setup.sh yet?"

outfile=${OUTDIR}/parallel.csv
[[ -f ${outfile} ]] && die "outfile already exists!"
mkdir -p ${OUTDIR}

datasets=(serratus neotrop pro_ref)
#datasets=(pro_ref)
memsave=(off full maxmem)
threads=(0 1 2 4 8 16 32 48)

let total=${#datasets[@]}
let total*=${#memsave[@]}
let total*=${#threads[@]}
let total*=5

echo "dataset,memsave,threads,replicate,time" > ${outfile}

i=1
for ds in ${datasets[@]}; do
	dat=${DATA}/${ds}
for ms in ${memsave[@]}; do
for ts in ${threads[@]}; do
for rs in {0..4}; do
	echo "$i / $total"

	cur_dir=${OUTDIR}/${ds}/${ms}/${ts}/${rs}
	timefile=${cur_dir}/timeres
	TT="${T} -o ${timefile}"
	# rm -f ${cur_dir}
	mkdir -p ${cur_dir}
	cd ${cur_dir}

	common_cmd="--tree ${dat}/tree.newick --msa ${dat}/reference.fasta.gz --model ${dat}/model "
	common_cmd+="--query ${dat}/query.fasta.gz --redo --verbose --memsave ${ms}"

	if [ "$ts" == "0" ]; then
	    eval "${TT} ${EPANG_SERIAL} ${common_cmd}" > /dev/null
	else
	    eval "${TT} ${EPANG} ${common_cmd} --threads ${ts}" > /dev/null
	fi

	cd - > /dev/null

	echo "${ds},${ms},${ts},${rs},$(<${timefile})" >> ${outfile}

	let i+=1
done
done
done
done

# call the visualisation script
