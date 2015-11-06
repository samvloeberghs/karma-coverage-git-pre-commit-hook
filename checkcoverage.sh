#!/bin/bash

FILE=$1
if [ $# -lt 1 ]; then
    FILE="test/coverage/coverage.txt"
fi

LIMIT=$2
if [ $# -lt 2 ]; then
    LIMIT=80
fi

STRICT=0
STRICTVALUE=1
if [ $# -gt 2 ]; then
    STRICT=1
fi

echo $FILE
echo $LIMIT
echo $STRICT

while IFS='' read -r line || [[ -n "$line" ]]; do

    IFS='|' read -a mylinearray <<< "$line"

    file="$(echo -e "${mylinearray[0]}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    stmts=${mylinearray[1]%.*}
    branch=${mylinearray[2]%.*}
    func=${mylinearray[3]%.*}
    lines=${mylinearray[4]%.*}
    unc=${mylinearray[5]}

    file_nesp="$(echo -e "${file}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

    if [[ $file_nesp =~ ^.*\.(js)$ ]]  && [[ ! $file_nesp =~ ^.*\.(spec\.js)$ ]]; then

        if [[ $lines -lt $LIMIT || ( $STRICT -ge $STRICTVALUE  && ( $branch -lt $LIMIT || $func -lt $LIMIT || $stmts -lt $LIMIT ) ) ]]; then
            echo "-------------"
            echo "${file_nesp}:"
            echo "-------------"
        fi

        if [[ $lines -lt $LIMIT ]]; then
            echo "Line coverage:       ${lines}%"
            echo "Lines not covered:   ${unc}"
        fi

        if [[ $STRICT -ge $STRICTVALUE ]]; then

            if [[ $stmts -lt $LIMIT ]]; then
                echo "Statement coverage:  ${stmts}%"
            fi

            if [[ $branch -lt $LIMIT ]]; then
                echo "Branch coverage:     ${branch}%"
            fi

            if [[ $func -lt $LIMIT ]]; then
                echo "Function coverage:   ${func}%"
            fi

        fi

    fi

done < "$FILE"
