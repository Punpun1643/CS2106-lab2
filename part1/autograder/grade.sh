#!/bin/bash

# Check if we have enough arguments
if [[ $# -ne 1 ]]; then
  echo "Usage: ./grade.sh <filename>"
  exit 1
fi

# Delete temporary files
rm -f *.tmp

# Compile the reference program
gcc ref/*.c -o $1

# Delete all output reference files (*.out) in ref/
for i in ref/*.out; do
  rm -f $i
done

# Generate reference output files
for i in ref/*.in; do
  ./$1 < $i > $i.out
done

# Now mark submissions

#
# Note: See Lab02Qn.pdf for format of output file. Marks will be deducted for missing elements.
#

# Remove existing result.out
rm -f results.out

echo -e "Test date and time: $(date +%A), $(date +%d) $(date +%B) $(date +%Y), $(date +%T)\n" > results.out
# Iterate over every submission directory

totalFilesMarked=0
for i in subs/*; do
  let totalFilesMarked=totalFilesMarked+1
  # Compile C code
  gcc $i/*.c -o $i/$1 2>/dev/null

  # Print compile error message to output file
  if [[ $? -ne 0 ]]; then
    echo "Directory $(basename $i) has a compile error." >> results.out
  fi

  # Generate output from C code using *.in files in ref
  if [[ -e $i/$1 ]]; then
    for j in ref/*.in; do
      # Check if executable exists
      $i/$1 < $j > $i/$(basename $j).out
    done
  fi
  
  studentScore=0
  totalScore=0
  # Compare with reference output files  and award 1 mark if they are identical
  for k in ref/*.out; do
    if [[ -e $i/$(basename $k) ]]; then
      diffResult=$(diff $k $i/$(basename $k))
      if [[ -z $diffResult ]]; then
        let studentScore=studentScore+1
      fi
    fi
    let totalScore=totalScore+1
  done
  # print score for student
  echo "Directory $(basename $i) score $studentScore / $totalScore" >> results.out
done
# print total files marked.
echo -e "\nProcessed $totalFilesMarked files." >> results.out
