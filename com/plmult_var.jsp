<!----------------------------------------------------------
	システム事業部
	みえるっち
		＜部品構成展開変数定義＞
		File Name :plmult_var.jsp
		Auther	:k-mizuno
		Date	:2006-09-05
----------------------------------------------------------->

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
int intEcoIniPlMaxCnt=intEcoPlMaxCnt;
int intMultCnt=0;
int intMultLevel=0;
int intMultMaxLevel=0;
int intMultSpread=15;
int intMultPlCnt=0;
double dblMultTopQty=1;
double dblMultQty=1;
%>

<!------------------------------ End of plmult_var.jsp ------------------------------>