#!/bin/bash

mawk '
function join(array, sep, start, end, result, i)
{
  if (sep == "") sep = " "

  if (start = "") start = 1
  result = array[start]

  if (end = "") end = length

  for (i = start + 1; i <= end; ++i)
    result = result sep array[i]
  return result
}
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

    species = substr(record[2], 1, index(record[2], ".") - 1)
    chrom = substr(record[2], index(record[2], ".") + 1)

    first = record[3]
    match_len = record[4]
    strand = record[5]
    chrom_len = record[6]

    if (strand == "+") {
      start = first + 1
      end = start + match_len
    } else if (strand == "-") {
      end = chrom_len - start
      start = end - match_len + 1
    } else {
      print "Unknown strand format" > "/dev/stderr"
      print $0 > "/dev/stderr"
      exit 1
    }

    result[result_n] = species "\t" chrom "\t" start "\t" end "\t" strand "\t" match_len
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
    if (ref_seq_split[i] == query_seq_split[i]) {
      ref_seq = ref_seq "1"
      query_seq = query_seq "1"
    } else {
      ref_seq = ref_seq (ref_seq_split[i] == "-" ? "" : "0")
      query_seq = query_seq (query_seq_split[i] == "-" ? "" : "0")
    }
  }

  print result[1] "\t" ref_seq "\t" result[2] "\t" query_seq

}
'
