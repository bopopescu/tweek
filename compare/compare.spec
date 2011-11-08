Method 0:
- first, lets try to compare on a single, local machine and see how long it takes

Method 1:

- input location is output location of build_index
  - contains multiple files (part-00000, part-00001, etc.)
- added argument is cache file which is reference file
  - this is raw tweet file
- mapper reads each document statistic and compares to reference file
  - outputs similarity index
- reducer aggregates all similarity indices and outputs the most similar documents

Method 2:

- set environment variable that points to reference file
