#!/bin/bash

awk '
BEGIN {
  FS="\t"
  OFS="\t"
  last_id = 0
  id_counter = 0
  last_line = ""

}
NR == 1 {
  if (NF < 3){
    print "Not enough columns"
    exit 1
  }

  print NF -2

  shared_columns = NF - 2
  id_column=1
  name_column = NF - 1
  value_column = NF

  header = ""

  if (shared_columns > 0){
    header = $1
    for (i=2; i <= shared_columns; ++i)
      header = header OFS $i
  }

  next
}
{
  if ($id_column != last_id) {
    if (id_counter == 1) print header
    if (id_counter > 0) print last_line
    id_counter++
    last_id = $id_column
    last_line = $1

    for (i=2; i <= shared_columns; ++i)
      last_line = last_line OFS $i

    last_line = last_line OFS $value_column

  } else {
    last_line = last_line OFS $value_column
  }

  if (id_counter == 1){
    header = header OFS $name_column
  }
}
END {
  print last_line
}
'
