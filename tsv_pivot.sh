#!/bin/bash

mawk '
BEGIN {
  FS="\t"
  OFS="\t"
  last_id = 0
  id_counter = 0
  name_counter=0
  last_line = ""
  split("", names)

}
NR == 1 {
  if (NF < 3){
    print "Not enough columns" > "/dev/stderr"
    exit 1
  }

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
function init_record(){
  name_counter=1
  last_id = $id_column
  last_line = $1
  for (i=2; i <= shared_columns; ++i)
    last_line = last_line OFS $i

  last_line = last_line OFS $value_column
}
NR == 2 {

}
function verify_name(expected, detected){
  if (expected != detected){
    print "Expected \"" expected \
          "\" detected \"" detected \
          "\" on line " NR > "/dev/stderr"
    exit 1
  }
}
{
  if ($id_column != last_id) {
    if (id_counter == 1) print header
    if (name_counter != length(names)){
      print "Expected " length(names) \
            " samples, but detected " \
            name_counter > "/dev/stderr"
    }
    print last_line
    id_counter++
    last_id = $id_column
    last_line = $1

    name_counter=1
    verify_name(names[name_counter],
                $name_column)

    for (i=2; i <= shared_columns; ++i)
      last_line = last_line OFS $i

    last_line = last_line OFS $value_column

  } else {
    verify_name(names[++name_counter],
                $name_column)
    last_line = last_line OFS $value_column
  }

  if (id_counter == 1){
    names[++name_counter] = $name_column
    header = header OFS $name_column
  }
}
END {
  print last_line
}
'
