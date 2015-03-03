#!/usr/bin/perl

#CRF++を使って、テスト

$testdir = "test_data";
$outdir = "out_back";

$model = "ContextModel/Semmodel_csjnrd";

opendir(TESTDIR,"$testdir");
@testfile = readdir(TESTDIR);
closedir(TESTDIR);

foreach(@testfile){
	if($_ =~ /.cn/){
		$file = "$testdir/$_";
		$out = "$outdir/$_";
		$out =~ s/cn/txt/;
		print "make $out\n";
		`../CRF_0.57/bin/crf_test -m $model $file > $out`;
		$out2 = $out;
		$out2 =~ s/_back//;
		`cp $out $out2`;
	}
}

