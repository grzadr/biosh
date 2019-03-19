#!/bin/bash

mawk '
BEGIN {RS=""; FS="\n"}
{
  if ($1 !~ /^a/) {
    print "Record doesnt start with a"
    print $0
    exit 1
  }

  result_n = 0
  split("", result, ":") # init an empty array "result"
  split("", result_reqs, ":") # init an empty array "result_seqs"

  for (i = 1; i <= NF; ++i){
    if ($i !~ /^s\ /) {
      continue
    }

    ++result_n;

    record_n = split($i, record, " ")

    if (record_n != 7) {
      print "Number of fields " record_n "is different from 7" > "/dev/stderr"
      print $i > "/dev/stderr"
      print "\nFrom record\n" > "/dev/stderr"
      print $0 > "/dev/stderr"
      exit 1
    }

    record_species = substr(record[2], 1, index(record[2], ".") - 1)
    record_chrom = substr(record[2], index(record[2], ".") + 1)

    record_first = record[3]
    record_match_len = record[4]
    record_strand = record[5]
    record_chrom_len = record[6]

    if (record_strand == "+") {
      record_start = record_first + 1
      record_end = record_start + record_match_len - 1
    } else if (record_strand == "-") {
      record_end = record_chrom_len - record_first
      record_start = record_end - record_match_len + 1
    } else {
      print "Unknown strand format" > "/dev/stderr"
      print $0 > "/dev/stderr"
      exit 1
    }

    result[result_n] = record_species "\t" record_chrom "\t" record_start "\t" record_end "\t" record_strand "\t" record_match_len
    result_seqs[result_n] = tolower(record[7])

  }

  if (result_n != 2){
    print "More than two records" > "/dev/stderr"
    print $0 > "/dev/stderr"
    exit 1
  }

  ref_seq_split_n = split(result_seqs[1], ref_seq_split, "")
  query_seq_split_n = split(result_seqs[2], query_seq_split, "")

  if (ref_seq_split_n != query_seq_split_n){
    print "Sequences have different lengths" > "/dev/stderr"
    print ref_seq_split_n " != " query_seq_split_n > "/dev/stderr"
    print $0 > "/dev/stderr"
    exit 1
  }

  ref_seq=""
  query_seq=""

  for (i=1; i in ref_seq_split; ++i){
    ref_pos = ref_seq_split[i]
    query_pos = query_seq_split[i]
    if (ref_pos == query_pos) {
      ref_seq = ref_seq "1"
      query_seq = query_seq "1"
    } else {
      ref_seq = ref_seq (ref_pos == "-" ? "-" : "0")
      query_seq = query_seq (query_pos == "-" ? "-" : "0")
    }
  }

  print result[1] "\t" ref_seq "\t" result[2] "\t" query_seq

}
'
