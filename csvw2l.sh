#!/bin/bash

set -eu

NAME="${1}"
COL=${2:-+1}

awk -v name=$NAME -v col="$COL" '
BEGIN {
  FS="\t"
  OFS="\t"
  split("", ids)
}
NR == 1 {
  if (NF < 3) {
    print "Not enoguht columns"
    exit 1
  }

  #print col > "/dev/stderr"
  i = 1
  printf $(i++)

  if (col > 1){
    for (i = 2; i <= col; ++i){
      printf "\t%s" $i
    }
  }

  print "\t" name

  for (;i <= NF; ++i){
    ids[i] = $i
  }

  for (i in ids){
    print i " " ids[i] > "/dev/stderr"
  }

  next
}
{
  prefix = $1
  if (col > 1){
    for (i = 2; i <= col; ++i){
      prefix = "\t" $i
    }
  }

  for (i = col + 1; i <= NF; ++i){
    print prefix "\t" $i

  }
}

'
