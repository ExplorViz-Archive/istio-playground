#!/bin/bash

CHECKMARK="\xE2\x9C\x94"
CROSS="\xE2\x9D\x8C"

sleep_with_progressbar() {
    printf "$1["
    printf ' %.0s' {1..50}
    printf "]\r$1["
    x=$(echo "scale=1 ; $2 / 50" | bc)
    for i in {1..50}; do
        printf "|"
        sleep $x
    done
    printf "]$CHECKMARK\n"
}
