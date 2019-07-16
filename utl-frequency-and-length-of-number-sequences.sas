Frequency-and-length-of-number-sequences

Assumptions

  Sequences start with 1.
  Consider sequences of length 2 or more


github
https://github.com/rogerjdeangelis/utl-frequency-and-length-of-number-sequences

stackoverflow
https://tinyurl.com/y5whs7xw
https://stackoverflow.com/questions/57004272/is-there-an-r-function-or-sql-solution-for-grouping-the-all-the-same-numbers-rep

Could not replace the two views with a DOW loop?

*_                   _
(_)_ __  _ __  _   _| |_
| | '_ \| '_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
;

data have;
 input seq @@;
cards4;
0 0 1 2 3 1 2 3 2 1 2 1 2 1 2 1
;;;;
run;quit;


 WORK.HAVE total obs=16

              |  Rules
              |
Obs    SEQ    |
              |
  1     0     |
  2     0     |
              |
  3     1     |  1st sequence of 3
  4     2     |
  5     3     |
              |
  6     1     |
  7     2     |
  8     3     |  2nd sequence of 3      2 sequences of length 3
              |
  9     2     |
              |
 10     1     |  1st sequence of 2
 11     2     |
              |
 12     1     |
 13     2     |  2nd sequence of 2
              |
 14     1     |
 15     2     |  3rd sequence of 2      3sequences of length 2
              |
 16     1     |

 *            _               _
  ___  _   _| |_ _ __  _   _| |_
 / _ \| | | | __| '_ \| | | | __|
| (_) | |_| | |_| |_) | |_| | |_
 \___/ \__,_|\__| .__/ \__,_|\__|
                |_|
;

WORK.WANT total obs=2

  SEQUENCE_    NUMBER_OF_
    LENGTH      SEQUENCES    PERCENT

      2             3           60
      3             2           40


 *          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;


data hav1st/view=hav1st;
     retain grp 0;
     set have;
     if seq=1 or dif(seq)<0 then grp=grp+1;
run;quit;

/*
WORK.HAV1ST total obs=16

       SEQ   GRP

        0     1       GROUPED
        0     1

        1     2
        2     2
        3     2

        1     3
        2     3
        3     3

        2     4

        1     5
        2     5

        1     6
        2     6

        1     7
        2     7

        1     8
*/


data hav2nd/view=hav2nd;
    set hav1st;
    by grp;
    if last.grp and not first.grp and seq ne 0 then output;
    keep seq;
run;quit;

/*
WORK.HAV2ND total obs=5

     SEQ

      3
      3    2 sequences of length 3

      2
      2
      2    3 sequences of length 2
*/

proc freq data=hav2nd;
    tables seq /out=want(rename=(seq=sequence_length count=number_of_sequences));
run;quit;



