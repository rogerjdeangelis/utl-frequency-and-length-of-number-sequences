# utl-frequency-and-length-of-number-sequences
    Frequency-and-length-of-number-sequences

    Assumptions

      Sequences start with 1.
      Consider sequences of length 2 or more

      Three Solutions and a generization

           a. One datastep amd proc freq
              Keintz, Mark
              mkeintz@wharton.upenn.edu

           b. Two datasteps and a proc freq

           c. More general solution (HASH)
              Bartosz Jablonski
              yabwon@gmail.com


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
      3     1     |
      4     2     |
      5     3     |  1st sequence of 3
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
     15     2     |  3rd sequence of 2      3s equences of length 2
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
    *           __  __            _
      __ _     |  \/  | __ _ _ __| | __
     / _` |    | |\/| |/ _` | '__| |/ /
    | (_| |_   | |  | | (_| | |  |   <
     \__,_(_)  |_|  |_|\__,_|_|  |_|\_\

    ;


    data have;
     input seq @@;
    cards4;
    0 0 1 2 3 1 2 3 2 1 2 1 2 1 2 1
    ;;;;
    run;quit;


    It looks like a lot of fun, but “firstobs=2” and the “rename=” data set name parameter,
    offers a more prosaic, yet “forward looking” solution:


    data want_pre (keep=size where=(size>1));
      do size=1 by 1 until (seqnext<seq);
        merge have
              have (firstobs=2 keep=seq rename=(seq=seqnext));
        if seq=0 then size=size-1;
      end;
    run;

    proc freq data=want_pre;
    tables size / out=want(rename=(seq=sequence_length count=number_of_sequences));
    run;quit;

    *_         ____
    | |__     |  _ \ ___   __ _  ___ _ __
    | '_ \    | |_) / _ \ / _` |/ _ \ '__|
    | |_) |   |  _ < (_) | (_| |  __/ |
    |_.__(_)  |_| \_\___/ \__, |\___|_|
                          |___/
    ;

    data have;
     input seq @@;
    cards4;
    0 0 1 2 3 1 2 3 2 1 2 1 2 1 2 1
    ;;;;
    run;quit;


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

    *          ____             _
      ___     | __ )  __ _ _ __| |_
     / __|    |  _ \ / _` | '__| __|
    | (__ _   | |_) | (_| | |  | |_
     \___(_)  |____/ \__,_|_|   \__|

    ;



    Hi Roger,

    if sequence doesn't have to be "continuous" (e.g. 1 3 5 is ok)
    than I think following code will do the job too.

    all the best
    Bart

    data have;
     input seq @@;
    cards4;
    0 0 1 2 3 1 2 3 2 1 2 1 2 1 2 1
    ;;;;
    run;quit;

    /* test cases:
    0 0 1 2 3 2 3 4 2 0 1 2 1 2 1 2 0 0 1 2 3 4 5 7 9 11 0 0 4 5 0 1 2 2 0 0 21 22 23 22 23 24 0

    0 1 0 1

    1 2 3 4
    */

    data want;

      /* Temp = keep track of current sequence */
      declare hash H(ordered:"A");
      H.defineKey("seq");
      H.defineData("seq");
      H.defineDone();
      declare hiter I("H");

      /* Collector = collects data about all sequences */
      length seqL seqCNT 8; seqCNT = 0;
      declare hash SEQS(ordered:"A");
      SEQS.defineKey("seqL");
      SEQS.defineData("seqL","seqCNT");
      SEQS.defineDone();
      declare hiter SEQI("SEQS");

      do until(EOF);
        set have end=EOF;
        seqORG = seq;

        _RClast_ = I.last(); _RCnext_ = I.next();

        /* if what you have is greater than last one and not zero, and you aren't in the last obs... */
        if ( seqORG > seq >= 0 ) and not EOF then _RC_ = H.add(key:seqORG,data:seqORG); /* ...just add new element to the Temp */
        else
          do; /* otherwise */
            /* add last obs if it satisfy conditions */
            if EOF and ( seqORG > seq >= 0 ) then _RC_ = H.add(key:seqORG,data:seqORG);

            seqL = H.num_items; /* get the seq length */
            /* add it to the Collector */
            if SEQS.find() then _RC_ = SEQS.add(key:seqL,data:seqL,data:1);
                           else _RC_ = SEQS.replace(key:seqL,data:seqL,data:seqCNT+1);

            if seqL > 1 then seqCNTall + 1; /* denominator for percents */

            /* recreate Temp, starting with current observation's value  */
            /* for testing: */
            /*_I_ + 1; if seqL then _RC_ = H.output(dataset:cats('Temp',_I_));*/
            _RC_ = H.clear();
            if seqORG > 0 then _RC_ = H.add(key:seqORG,data:seqORG);
          end;
      end;

      /* unload the data from the Collector */
      do while(SEQI.next() = 0);
        if not (seqL > 1) then continue; /* ignore sequences shorter than 2 */
        percent = (seqCNT / seqCNTall) * 100;
        keep seqL seqCNT percent;
        put (seqL seqCNT percent) (=);
        output;
      end;

    stop;
    run;

    SEQL=2 SEQCNT=3 PERCENT=60
    SEQL=3 SEQCNT=2 PERCENT=40



