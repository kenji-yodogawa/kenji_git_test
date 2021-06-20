<!-- ******************************************************************
	＜県名選択＞ in みえるっち
	File Name :pref_link.jsp
	 (あいうえおテーブルに並んだ県名から複数選択し親画面へもどす処理)
	Author	:k-mizuno
	Date	:2007-01-31
	 呼出元　design/entrybase_inp.jsp　（←opt_folderから）
　　　　　　　　　/entryopt_inp.jsp
　　　　　　seikan/checkitem_inp.jsp　(←mpprocess_folder）

		Update 
	2014-05-09 kaneshi ソートで並べた表にしたい。テーブルに地域をつけたい。。
	2014-05-31 kaneshi CSSを外部化
	2014-01-05 kaneshi sql select * カラム指定
	　　　　　　　　　ResultSetを読んだらすぐ閉じる
	2015-04-02 kaneshi StringBuilder とString#concatで高速化
	2016-01-02 kaneshi var d = document.all を使用
	2016-09-22 kaneshi StringBuilder化徹底　indexOf内
	2017-06-15 kaneshi 総合組立品対応
	2017-06-20 kaneshi コード整理
	2017-08-02 kaneshi totalassygrp_inp からよばれたら、
	　　　　　　　　　　　　　　　　オーダーエントリーのヘッダで設定された県にあらかじめしぼること　
	　　　　　　　　　　　　　　　　そのデータはどこにあるのだ？　entrybase_inp.jsp
	
				select prefCdList from entryopt
				where topsign='YES'
				and ((latest='YES' and apvnow='YES') 
				     or verno=(select max(verNo)-1
				                from entryopt as e1 
				                where optnam='TSC-3000' --SCIDET
				                and designpart='EQP' )
				    )
				and optnam ='TSC-3000'
				and designpart='EQP'
				and invalid=''


      　【課題】 地域別に並んだテーブルからセットすべきだ。
　　　　　　　　（名前をprefmult_link とすべきだ）
  	【課題】　国内ＡＬＬ　選択ボタン、海外ＡＬＬ　選択ボタン、クリアボタン　　　　　　　　
  	　　　　　　の３つのボタンをつけるべし。
		      　　　
************************************************************************** -->

<%@ page contentType="text/html;charset=UTF-8"
	import="java.sql.*,java.io.*,java.net.*, java.util.*,java.text.*"%>

<% String strRight=""; %>
<%@ include file="../header_utf8.jsp"%>

<%
String strPrefCustomerCdList=request.getParameter("PrefCustomerCdList");
if(strPrefCustomerCdList==null|| strPrefCustomerCdList.equals("null")){
	strPrefCustomerCdList="";
}

String strPrefCdList=request.getParameter("PrefCdList");
if(strPrefCdList==null|| strPrefCdList.equals("null")){
	strPrefCdList="";
};


String strGlobalAreaList=request.getParameter("GlobalAreaList");
if(strGlobalAreaList==null|| strGlobalAreaList.equals("null")){
	strGlobalAreaList="";
}

String strGlobalAreaExclude=request.getParameter("GlobalAreaExclude");
if(strGlobalAreaExclude==null|| strGlobalAreaExclude.equals("null")){
	strGlobalAreaExclude="";
}

String strEqpClass=request.getParameter("EqpClass");// 型名大分類
if(strEqpClass==null|| strEqpClass.equals("null")){
	strEqpClass="";
}

%>
<html>
<head>
<title>県名選択</title>
<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
<link href="../com/mierucchics.css" rel="stylesheet" type="text/css">
</head>

<body onBlur="focus()">
<table class="header">
<tr><th>県名選択</th></tr>
</table>

<br style="line-height:0.6em">
<form name="pref_link" action="pref_link.jsp" method="POST">
<div align="center">

<%
StringBuilder sbTmp=new StringBuilder();

if(!strGlobalAreaList.equals("")){ 
	StringTokenizer gaTkn=new StringTokenizer(strGlobalAreaList,",");
%>
	<table class="basetable"><tr><th>国際地域</th>
	<td>
	<%
	String strGlobalAreaNam="";
	StringTokenizer ga0Tkn=new StringTokenizer(strGlobalAreaList,",");
	
	while(ga0Tkn.hasMoreTokens()){
		ResultSet rsGlobalAreaNam=objSql.executeQuery(sbTmp
			.append("select globalAreaNam from globalArea ")
			.append("  where globalAreaKey='") .append(ga0Tkn.nextToken()) .append("'")
			.toString());sbTmp.delete(0,sbTmp.length());
		rsGlobalAreaNam.next();
		if(strGlobalAreaNam.equals("")){
			strGlobalAreaNam=rsGlobalAreaNam.getString("globalAreaNam");
		}else{
			strGlobalAreaNam+="," .concat(rsGlobalAreaNam.getString("globalAreaNam"));
		}
		rsGlobalAreaNam.getString("globalAreaNam");
		rsGlobalAreaNam.close();
	} %>
	<%=strGlobalAreaNam %>
	<%if(strGlobalAreaExclude.equals("EXCLUDE")){ %>
		(を除外)
	<%} %>
	</td>
	</tr>
	<tr><th>型名大分類</th>
	<td><%=strEqpClass %></td>
	</tr>
	</table>
	<br style="line-height:0.6em">
<%} %>

<table class="baselist">
<tr>
<th>あ</th>
<th>か</th>
<th>さ</th>
<th>た</th>
<th>な</th>
<th>は</th>
<th>ま</th>
<th>や</th>
<th>ら</th>
<th>わ</th>
</tr>

<%
String[][] aryPrefCd=new String[20][10];
String[][] aryPrefNam=new String[20][10];
String[][] aryPrefKana=new String[20][10];
String[][] aryCustomerCd=new String[20][10];

for(int i=0; i<20; i++){
	for(int j=0; j<10; j++){
		aryPrefCd[i][j]="";
		aryPrefNam[i][j]="";
	}
}

String[] aryJpn=new String[10];
aryJpn[0]="ア,イ,ウ,エ,オ";
aryJpn[1]="カ,ガ,キ,ギ,ク,グ,ケ,ゲ,コ,ゴ";
aryJpn[2]="サ,ザ,シ,ジ,ス,ズ,セ,ゼ,ソ,ゾ";
aryJpn[3]="タ,ダ,チ,ヂ,ツ,ヅ,テ,デ,ト,ド";
aryJpn[4]="ナ,ニ,ヌ,ネ,ノ";
aryJpn[5]="ハ,パ,ヒ,ピ,フ,プ,ヘ,ペ,ホ,ポ";
aryJpn[6]="マ,ミ,ム,メ,モ";
aryJpn[7]="ヤ,ユ,ヨ";
aryJpn[8]="ラ,リ,ル,レ,ロ";
aryJpn[9]="ワ,ヲ,ン";
int intJpnCnt=0;
int intMaxCnt=0;

StringBuilder sbQry = new StringBuilder();
StringBuilder sbTmp1 = new StringBuilder();

for(int i=0; i<10; i++){
	StringTokenizer hdTkn=new StringTokenizer(aryJpn[i],",");

	while(hdTkn.hasMoreTokens()){
		String hd = hdTkn.nextToken();	//20111121
		if(sbQry.length()==0){
			sbQry.append(" where (");
		}else{
			sbQry.append(" or ");
		}

		sbQry
		.append("(PrefKana like '") .append(hd) .append("%'")
		.append(" or PrefKana like '%-") .append(hd) .append("%') \n");
	}
	sbQry.append(" ) ");
			
	StringBuilder sbGaList = new StringBuilder();	
	if(!strGlobalAreaList.equals("")){
		StringTokenizer gaTkn = new StringTokenizer(strGlobalAreaList,",");
		while(gaTkn.hasMoreTokens()){
			if(sbGaList.length()!=0){
				sbGaList .append(",");
			}
			sbGaList 
			.append("'") .append(gaTkn.nextToken()) .append("'") ;
		}
	}
	
	StringBuilder sbGaSql = new StringBuilder();
	
	if(sbGaList.length()!=0){	
		if(strGlobalAreaExclude.equals("EXCLUDE")){
			sbGaSql
			.append(" and globalarea not in (") .append(sbGaList) .append(")");
		}else if(strGlobalAreaExclude.equals("")){
			sbGaSql
			.append(" and globalarea in (") .append(sbGaList) .append(")");		
		}
	}
	
	sbTmp
	.append(" select prefcd,prefnam,prefkana,customerCd \n") 
	.append(" from preftb \n")
	.append(sbQry) .append("\n")
	.append(sbGaSql) .append("\n")
	.append(" order by Domain desc,PrefKana")
	;

	sbQry.delete(0,sbQry.length());
	//System.out.println(sbTmp);
	ResultSet rsPref=objSql.executeQuery(sbTmp.toString());

	sbTmp.delete(0,sbTmp.length());

	intCnt=0;

	while(rsPref.next()){
		aryPrefCd[intCnt][i]  =rsPref.getString("PrefCd");
		aryPrefNam[intCnt][i] =rsPref.getString("PrefNam");
		aryPrefKana[intCnt][i]=rsPref.getString("PrefKana");
		aryCustomerCd[intCnt][i]=rsPref.getString("CustomerCd");

		intCnt++;
	}
	rsPref.close();

	if(intCnt>intMaxCnt){
		intMaxCnt=intCnt;
	}
}
%>

<%for(int i=0; i<intMaxCnt; i++){%>
<tr>
	<%for(int j=0; j<10; j++){
		String strChecked="";
		String strBGColor="";

		if(strPrefCustomerCdList!=null
				&& !strPrefCustomerCdList.equals("")
				&& aryCustomerCd[i][j]!=null
				&& strPrefCustomerCdList.indexOf(aryCustomerCd[i][j])>=0){
			strChecked=" checked ";
			strBGColor="background-color:Khaki;";
		}
	%>
	<td style='<%=strBGColor%>' id="PrefCdTd<%=i%>-<%=j%>">
		<input name="CustomerCd<%=i%>-<%=j%>" type="hidden" value="<%=aryCustomerCd[i][j]%>">
		<%if(!aryPrefNam[i][j].equals("")){
		%>
		<input name="PrefCd<%=i%>-<%=j%>"  id="PrefCd<%=i%>-<%=j%>" type="checkbox" 
				value="<%=aryPrefCd[i][j]%>"
			<%
			sbTmp .append(",") .append(request.getParameter("PrefCd")) .append(",");
			sbTmp1 .append(",").append(aryPrefCd[i][j]) .append(",");
			
			// チェックされたら背景色をかえる
			if(sbTmp .indexOf(sbTmp1.toString())>=0){%> checked <%}%>
			onClick="chg_bgcolor(this,'<%=i%>','<%=j%>');"
			<%=strChecked%>>
			
			<%}
			sbTmp.delete(0,sbTmp.length());
			sbTmp1.delete(0,sbTmp1.length());
			%>
			<input name="PrefNam<%=i%>-<%=j%>" type="hidden" value="<%=aryPrefNam[i][j]%>">		
			   <%=aryPrefNam[i][j]%>&nbsp;<br>
			   <%aryPrefNam[i][j]=null;%>
	</td>
<%}%>
</tr>
<%}%>
</table>
<br style="line-height:0.3em;">

<input type="button" value=" S E T " onClick="pref_set();">

<input name="PrefCdList" type="hidden" value="<%=strPrefCdList%>">
<input name="strPrefCustomerCdList" type="hidden" value="<%=strPrefCustomerCdList%>">
<input name="GlobalAreaList" type="hidden" value="<%=strGlobalAreaList%>">

</div>
</form>

<script type="text/javaScript">
<!--
moveTo(10,10);
resizeTo(screen.availWidth*0.8,screen.availHeight*0.8);//20160102

var prefcd="";
var prefnam="";
var customercd=""


function pref_rec(){
	prefcd="";
	prefnam="";
	customercd="";//20170616
	var maxcnt = <%=intMaxCnt%>*1;
	var d = document.all;//20160102重要
	
	for(var i=0; i< maxcnt; i++){
		for(var j=0; j<10; j++){
			var prefnamij =d["PrefNam"+i+"-"+j].value;		
			
			if(prefnamij!="" && d["PrefCd"+i+"-"+j].checked==true){			
				if('<%=strGlobalAreaList%>'!=""){
					customercdij=d["CustomerCd"+i+"-"+j].value;
				}
				
				if(prefcd==""){
					prefcd= d["PrefCd"+i+"-"+j].value;
					prefnam=prefnamij;
					if('<%=strGlobalAreaList%>'!=""){
						customercd=d["CustomerCd"+i+"-"+j].value;
					}
				}else{
					prefcd+="," + d["PrefCd"+i+"-"+j].value;
					prefnam+="," + prefnamij;
					if('<%=strGlobalAreaList%>'!=""){
						customercd+="," + d["CustomerCd"+i+"-"+j].value;
					}
				}
			}	
		}		
	}
}// end of function pref_rec()

function chg_bgcolor(a,i,j){

	if(a.checked==true){
		document.getElementById("PrefCdTd"+i+"-"+j).style="background-color:Khaki";
		a.checked=true;
	}else{
		document.getElementById("PrefCdTd"+i+"-"+j).style="background-color:lavender";
		a.checked=false;
	}
}

function pref_set(){
	pref_rec();

	if(window.opener.name!="fr_main"){
		var pgnam = window.opener.parent.pgnam;

		if(pgnam=="entryopt_inp") {
			window.opener.parent.document.entryopt_inp.PrefCdList.value=prefcd;
			window.opener.parent.document.entryopt_inp.PrefNam.value=prefnam;
		}else if(pgnam=="entrybase_inp") {
			window.opener.parent.document.entrybase_inp.PrefCdList.value=prefcd;
			window.opener.parent.document.entrybase_inp.PrefNam.value=prefnam;
		}else if(pgnam=="checkitem_inp") {
			window.opener.parent.document.checkitem_inp.PrefCdList.value=prefcd;
			window.opener.parent.document.checkitem_inp.PrefNam.value=prefnam;
		}else if(pgnam=="totalassygrp_inp") {//20170615
			pref_rec();
			//customercd の並べ替えがいるかも　。　表示欄のsize指定が必要だ。　
			window.opener.parent.document.totalassygrp_inp.PrefList.value=customercd;
			window.opener.parent.document.totalassygrp_inp.PrefNamList.value=prefnam;
			if(prefnam.length>0){
				window.opener.parent.document.totalassygrp_inp.PrefNamList.size=prefnam.length*2;
			}
		}
	}
	window.opener.focus();
	window.close();

}// end of function pref_set()

//-->
</script>

</body>
</html>

<%
objSql.close();
db.close();
%>

<!-- ***************************** end of pref_link.jsp ***************************** -->