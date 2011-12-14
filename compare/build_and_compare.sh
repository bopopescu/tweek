#!/bin/bash

folder=$1
folder=${folder:0:8}

elastic-mapreduce --create \
      --name build_comp_$1 \
      --num-instances 4 \
      --bootstrap-action s3n://twtr-scripts/new_bootstrap.sh \
      --json build_and_compare.json \
      --param FOLDER=$folder \
      --param FILE=$1

exit

