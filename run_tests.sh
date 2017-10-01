#!/bin/bash

TEST_DIR=test/
IN=$TEST_DIR/in/
OUT=$TEST_DIR/out/
ERROR=$TEST_DIR/error/
EXEC_NAME=./tp1
for case in $(ls $ERROR); do
    rm $ERROR/$case
done

for case in $(ls $IN); do
  ERRORS=false
  if [ -e run.out ]; then 
      rm run.out
  fi
  if [ -e stdout.tmp ]; then
      rm stdout.tmp
  fi
  filename=$(basename ${case%%.*}) 
  printf "Executing $filename... ";
  $EXEC_NAME $(cat $IN/$case) >> stdout.tmp 
  if [ -e run.out ]; then
    diff run.out $OUT/$filename.out >> tmp;
    if [ $? -ne 0 ]; then
      ERRORS=true
    fi
  fi
  diff stdout.tmp $OUT/$filename.stdout >> tmp;
  if [ $? -eq 0 ]; then
    echo "OK"
  else
     ERRORS=true
  fi
  
  if $ERRORS; then
    echo "ERROR"
    cat tmp
    cp stdout.tmp $ERROR/$filename.error.stdout
    if [ -e run.out ]; then
      cp run.out $ERROR/$filename.error
    fi
  fi    
done

if [ -e tmp ]; then
    rm tmp
fi
if [ -e stdout.tmp ]; then
    rm stdout.tmp
fi

