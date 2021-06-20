<!-- ******************************************************
		＜部品構成展開変数定義＞
		File Name :plmult_var_utf8.jsp
		呼出元：　drinfoapv_inp.jsp
		       drinfompapv_upd.jsp
		       partmp_dsp.jsp
		       ploptset_upl.jsp
		       plupl_set.jsp 
		Auther	:k-mizuno
		Date	:2006-09-05
		         2016-03-19 kaneshi 内容点検
		         　文字コードがＵＴＦ－８とWindows-31Jでファイルをわけた
*********************************************************** -->
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<%
//******注）以下の変数は呼出Programで定義が必要*******
//strMultTopPartNo(展開PartNo)
//strMultSetDate(展開期日)
//strMultSpread(展開M:マルチ S:シングル E:製品)
//strMultDir(展開F:順展開 B:逆展開)

String strMultAllSeqNo="";
String strMultIniTopPartNo="";
String strMultEfc="";
String strMultPartNoList="";
String strMultElmPartNoList="";
String strMultSeqNoList="";
String strMultQtySumList="";
String strMultLevelList="";
String strMultQuery="";
//int intEcoIniPlMaxCnt=intEcoPlMaxCnt;
int intEcoIniPlMaxCnt=50;
int intMultCnt=0;
int intMultLevel=0;
int intMultMaxLevel=0;
int intMultSpread=15;
int intMultPlCnt=0;
double dblMultTopQty=1;
double dblMultQty=1;
%>

<!-- ***************************** End of plmult_var_utf8.jsp **************************** -->