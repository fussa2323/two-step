#!/usr/bin/perl

$cndir = "make_data/new_comp_cn";
$tmp = "data.tmp";
$model = "ContextModel/Semmodel_csjnrd";

#open(TMP,">$tmp");

$outfile = $ARGV[0];
$outfile_name = $outfile;
$outfile_name =~ s/out\///; #単純にファイル名が欲しかった

$cnfile = "$cndir/$outfile_name";
$cnfile =~ s/txt/cn/;
print "$outfile <-- $cnfile\n";

$line_cnt = 1; #次に見るのは($line_cnt)行目
#ファイルの行数カウント
open(CNTFILE,"$outfile") or die "Can't open the file! \n";
1 for <CNTFILE>;
$line_num = $.; #ファイルの行数
close(CNTFILE);

while($line_num >= $line_cnt){
	print "$line_cnt ";
	open(TMP,">$tmp");
	open(OUTFILE,"$outfile") or die "Can't open the file!\n";
	$cnt = $line_cnt - 1;
	while(<OUTFILE>){
		$line = $_;
		@feature = split(/\t/,$line);
		$feature[6] =~ s/\n//;

		#今のCS中のヌル遷移を保存しておく
		@null = ();

		#すでに正しいor訂正した行は無視しますよ
		if($cnt > 0){
			$cnt--;
			if($line eq "\n"){
				print TMP "\n";
				next;
			}
			print TMP "$feature[0]\t$feature[1]\t$feature[2]\t$feature[3]\t$feature[4]\t$feature[5]\n";
			next;
		}

		#ここからはまだ見てないところ，($line_cnt)行目以降
		if($line eq "\n"){ #改行のときはそのまま改行
			print TMP "\n";
			$line_cnt++;
			fill_rest($line_cnt);
			close(TMP);
			last;
		}
		elsif($feature[6] eq "C"){ #Cラベルが付いてる単語もCラベルはがしてそのまま
			#訂正してないんだから、意味スコアは離散化されているはず
			print TMP "$feature[0]\t$feature[1]\t$feature[2]\t$feature[3]\t$feature[4]\t$feature[5]\n";
			$line_cnt++;
			fill_rest($line_cnt);
			close(TMP);
			last;
		}
		else{ #Eラベルのものについて
			$cn = &match_cn("$cnfile",$line_cnt);
			@cnsets = split(/\t/,$cn);
			$next = &next_elem($feature[0],$cn);
			@next_elem = split(/\//,$next);
			#ヌル遷移があれば保存しておく
			if($next_elem[0] eq "-"){
				@null = @next_elem;
			}
			if($next_elem[0] eq "NULL"){
				@first = split(/\//,$cnsets[0]);
				$first[6] =~ s/\n//;
				if($first[3] ne "*"){
					$first[3] = int($first[3] * 10);
					$first[4] = int($first[4] * 10);
					$first[5] = int($first[5]);
					print TMP "$first[0]\t$first[1]\t$first[3]\t$first[4]\t$first[5]\t$first[6]\n";
				}
				#正解が見つからなくて、かつCS中にヌル遷移があったらそれで置き換える
				elsif($null[0] eq "-"){
					print TMP "$null[0]\t$null[1]\t$null[3]\t$null[4]\t$null[5]\t$null[6]\n";
				}
				#正解が見つからなくて、かつCS中にヌル遷移もなかったら第一候補で置き換える
				else{
					print TMP "$first[0]\t$first[1]\t$first[3]\t$first[4]\t$first[5]\t$first[6]\n";
				}
				$line_cnt++;
				#置き換えた単語以降は元ファイルからコピペでcrf_test
				fill_rest($line_cnt);
				close(TMP);
				`../CRF/bin/crf_test -m $model $tmp > $outfile`;
				last;
			}
			else{
				$next_elem[6] =~ s/\n//;
				print TMP "$next_elem[0]\t$next_elem[1]\t$next_elem[3]\t$next_elem[4]\t$next_elem[5]\t$next_elem[6]\n";
				#置き換えた単語以降は元ファイルからコピペでcrf_test
				fill_rest($line_cnt + 1);
				close(TMP);
				`../CRF/bin/crf_test -m $model $tmp > $outfile`;
				last;
			}
		}
	}
	close(OUTFILE);
}


#CNのファイルと行数を与え、その行(Confusin Set)を返す
sub match_cn{
	$i = 0;
	#ローカルで定義
	my $cnfile = $_[0];	#引数１：CNのファイル
	my $linecnt = $_[1]; #引数２：欲しい行
	open(CNFILE,"$cnfile");
	while(<CNFILE>){
		$cn = $_;
		$i++;
		if($i >= $linecnt){
			close(CNFILE);
			return $cn;
		}
	}
	#見つからなかったらERROEを返す
	close(CNFILE);
	return "ERROR1\n";
}

#単語とConfusion Setを与え、信頼度が次に高いCN_elemを返す
sub next_elem{
	$i = 0;
	#ローカルで定義
	my $word = $_[0];	#引数１：単語
	my $cn_set = $_[1]; #引数２：Confusion Set
	my $next_flag = 0;
	@cn_elem = split(/\t/,$cn_set);
	foreach(@cn_elem){
		$element = $_;
		@element = split(/\//,$element);
		if($next_flag == 1){
			if($element[3] ne "*"){
				$element[3] = int($element[3] * 10);
				$element[4] = int($element[4] * 10);
				$element[5] = int($element[5]);
				return "$element[0]/$element[1]/$element[2]/$element[3]/$element[4]/$element[5]/$element[6]";
			}
			else{return $element;}
		}
		if($word eq $element[0]){
			$next_flag = 1;
		}
	}
	#見つからなかったらERROEを返す
	if($next_flag == 1){return "NULL";}
	else{return "ERROR2"}
}

sub fill_rest{
	my $cnt = $_[0]; #何行目以降埋めるのか
	my $i = $cnt - 1;
	open(FILE,"$outfile") or die "Can't open the file! \n";
	while(<FILE>){
		my $line = $_;
		my @elems = split(/\t/,$line);
		if($i > 0){
			$i--;
			next; #すでに正しいor訂正した行は無視しますよ
		}
		$elems[5] =~ s/\n//;
		if($line eq "\n"){
			print TMP "\n";
			next;
		}
		if($elem[3] ne "*"){
			$elem[3] = int($elem[3] * 10);
			$elem[4] = int($elem[4] * 10);
			$elem[5] = int($elem[5]);
		}
		print TMP "$elems[0]\t$elems[1]\t$elems[2]\t$elems[3]\t$elems[4]\t$elems[5]\n";
	}
	close(FILE)
}
