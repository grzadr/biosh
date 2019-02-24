#!/bin/bash

mawk '
BEGIN {
  OFS="\t"
  last_id = 0
  id_counter = 0
  $1 = "id_variant"
  $2 = "db_snp"
  $3 = "chrom"
  $4 = "first"
  $5 = "last"
  $6 = "ref"
  $7 = "ann"
  last_line = ""

  header = $0
}
function filter_ann(ann){
  split(ann, data, ",")

  result = ""

  for (i = 1; i in data; i++){
    ele = data[i]
    if (ele ~ /(\|HIGH\||\|MODERATE\|)/)
      result = result "," ele
  }

  if (length(result))
    return substr(result, 2)
  else
    return "NA"
}
{
  if ($1 != last_id) {
    if (id_counter == 1) print header
    if (id_counter > 0) print last_line
    id_counter++
    last_id = $1
    last_line = $1 "\t" $9 "\t" $2 "\t" $3 "\t" $4 "\t" $7 "\t" filter_ann($8) "\t" $6
  } else {
    last_line = last_line "\t" $6
  }

  if (id_counter == 1){
    header = header "\t" $5
  }

}
END {
  print last_line
}
'
