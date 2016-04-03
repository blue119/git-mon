#!/usr/bin/env bash

TMP_DIR=/tmp/$$
MY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CFG_DIR=${HOME}/.gen_diff_page
LAST_TS_F=${CFG_DIR}/LAST_TS

[ ! -d ${CFG_DIR} ] && mkdir -p ${CFG_DIR} && echo "`date --iso-8601=seconds`" > ${LAST_TS_F}
[ -a ${TMP_DIR} ] && rm -rf ${TMP_DIR}
mkdir -p ${TMP_DIR}

INTERESTED_FILE+=('*/toolset/*')

while [ 1 = 1 ];
do
    echo "===== Git Pull ====="
    git pull
    echo ""

    NOW_TS=`git log -n1 --pretty="%aI"`
    LAST_TS=`cat ${LAST_TS_F}`
    CDIFF_MERGE_LIST=
    echo "NOW_TS=${NOW_TS}"
    echo "LAST_TS=${LAST_TS}"
    if [ ! ${NOW_TS} = ${LAST_TS} ]; then
        for c in `git log --no-merges --before="${NOW_TS}" --after="${LAST_TS}" --pretty="%H" -- ${INTERESTED_FILE[@]}
        do
            git log -n 1 -p $c > ${TMP_DIR}/$c.patch
            pygmentize -f html -O noclasses -l diff -o ${TMP_DIR}/$c.html ${TMP_DIR}/$c.patch
            SUBJECT=`git log -n 1 --pretty=format:'%an - %s (%cI)' --abbrev-commit $c`
            echo "${TMP_DIR}/$c.html"
            python ${MY_DIR}/send_mail.py "[git-mon] $SUBJECT" ${TMP_DIR}/$c.html
        done
    fi

    # echo ${TMP_DIR}
    # echo ${CDIFF_MERGE_LIST[@]}
    echo -n ${NOW_TS} > ${LAST_TS_F}

    echo -e "Sleep 300 Sec.\n"
    sleep 300
done
