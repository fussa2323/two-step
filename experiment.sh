#!/bin/sh
# cd make_data
# ./make_label.pl
# ./utf8.pl
# #ここで文脈を計算する必要は無いが、プログラムを再利用するために形式を合わせている
# ./make_semdata.pl
# ./mk_comp.pl
# cd ../
# ./make_testdata.pl
#./NgramDetection.pl
#./all_correct.pl
#cd make_data
#./make_newcn.pl
#./make_newsemdata.pl
#./mk_newcomp.pl
#cd ../
#./make_newtestdata.pl
./SemDetection.pl
./all_correct2.pl
./make_hyp.pl
./all_wer.pl