#!/bin/bash

mawk_tsv.sh '
/^#/{print $0}
function reduce_ann(field){
  split(substr(field, 5), data, ",")
  result=""
  for (i = 1; i in data; i++){
    ele = data[i]
    if (ele ~ /protein_coding/ && ele ~ /(HIGH|MODERATE|LOW)/)
      result = result "," ele
  }

  if (!length(result))
    return "ANN_SHORT="
  else
    return "ANN_SHORT=" substr(result, 2)
}
function modify_field(field){
  split(field, data, ";")
  for (i = 1; i in data; i++){
    ele = data[i]
    if (ele ~ /^ANN=/)
      return field ";" reduce_ann(ele)
  }

  return field
}
!/^#/{
  $8 = modify_field($8)
  $0 = $0
  print $0
}
'

