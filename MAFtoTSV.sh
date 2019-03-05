#!/bin/bash

mawk '
BEGIN {RS=""; FS="\n"}
{
  if ($1 != "a") {
    print "Record doesnt start with a"
    print $0
    exit 1
  }

  ref_n=split($2, ref, " ")

  if (ref_n != 7) {
    print "Number of fields is different from 7"
    print $0
    exit 1
  }

  if (ref[1] != "s") {
    print "Not s block"
    print $2
    exit 1
  }

  split(ref[2], ref_name, ".")

  ref_species = ref_name[1]
  ref_chr = ref_name[2]

  ref_first = ref[3]
  ref_length = ref[4]
  ref_strand = ref[5]
  ref_chr_len = ref[6]

  if (ref_strand == "+") {
    ref_start = ref_first - 1
    ref_end = ref_start + ref_length
  } else if (ref_strand == "-") {
    ref_end = ref_chr_len - ref_start
    ref_start = ref_end - ref_length + 1
  } else {
    print $0
    exit 1
  }

  query_n=split($3, query, " ")

  if (query_n != 7) {
    print "Number of fields is different from 7"
    print $0
    exit 1
  }

  if (query[1] != "s") {
    print "Not s block"
    print $3
    exit 1
  }

  split(query[2], query_name, ".")

  query_species = query_name[1]
  query_chr = query_name[2]

  query_first = query[3]
  query_length = query[4]
  query_strand = query[5]
  query_chr_len = query[6]

  if (query_strand == "+") {
    query_start = query_first + 1
    query_end = query_start + query_length
  } else if (query_strand == "-") {
    query_end = query_chr_len - query_first
    query_start = query_end - query_length + 1
  } else {
    print $0
    exit 1
  }

  split(tolower(ref[7]), ref_seq_split, "")
  split(tolower(query[7]), query_seq_split, "")

  ref_seq=""
  query_seq=""

    for (i=1; i in ref_seq_split; ++i){
      if (ref_seq_split[i] == query_seq_split[i]) {
        ref_seq = ref_seq "1"
        query_seq = query_seq "1"
      } else {
        ref_seq = ref_seq (ref_seq_split[i] == "-" ? "" : "0")
        query_seq = query_seq (query_seq_split[i] == "-" ? "" : "0")
      }
  }

  print \
    ref_species "\t" \
    ref_chr "\t" \
    ref_start "\t" \
    ref_end "\t" \
    ref_strand "\t" \
    ref_length "\t" \
    ref_seq "\t" \
    query_species "\t" \
    query_chr "\t" \
    query_start "\t" \
    query_end "\t" \
    query_strand "\t" \
    query_length "\t" \
    query_seq

}
'
