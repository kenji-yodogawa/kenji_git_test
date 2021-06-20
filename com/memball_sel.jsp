<!-- *****************************************************
	＜メンバー選択（SEIグループ）＞
	File Name :memball_sel.jsp
	     (realorgapl.jsp実態所属登録で利用。)
	Date	:2006-09-14  Author  :k-mizuno
	
	Update
	2014-03-28 kaneshi 全般整理
	   検索キー（組織名２つのand検索にした。）
	2014-04-07 kaneshi 存在しない組織名を指定した場合、全部署を表示するエラーに対処。
	2014-05-29 kaneshi CSS外部化
	2014-07-26 kaneshi 名前だけ指定すると検索できないバグへ対処
	2014-11-03 kaneshi sql select * のカラム特定
	　　　　　　　　　ResultSetを読んだらすぐ閉じる
	2015-03-27 kaneshi StringBuilder とString#concatで高速化
	2016-01-29 kaneshi var d = document.all; 利用する必要がなかった
	2016-02-08 kaneshi 孫画面でよばれるときonblur=focus()をやると文字入力ができなくなるので、外した
	　　　　　　　　　　　　　　　　　不要なjqueryのインポートをなくした
	2016-04-09 kaneshi StringBuilder化徹底
	2016-07-26 kaneshi PreparedStatementの行数節約
	2016-09-04 kaneshi テキスト入力欄で、autocomplete="off"
	2016-09-22 kaneshi StringBuilder化再徹底
	2016-10-14 kaneshi concat -> append
	2018-03-29 kaneshi SQL検索条件のtodateの優先度アップ
		 　
************************************************************ -->

<%@ page contentType="text/html;charset=UTF-8"
	         import="java.sql.*,java.io.*,java.net.*, java.util.*,java.text.*" %>

<% String strRight=""; %>
<%@ include file="../header_utf8.jsp" %>

<%//初期画面の場合 （初期画面は不要だ）
StringBuilder sbTmp = new StringBuilder();
StringBuilder sbQry = new StringBuilder();

String strSosikiSc0  =request.getParameter("SosikiSc0");
String strSosikiSc1  =request.getParameter("SosikiSc1");
String strUserNamSc0 =request.getParameter("UserNamSc0");
String strUserNamSc1 =request.getParameter("UserNamSc1");

if(strSosikiSc0==null){
    strSosikiSc0="";
}
if(strSosikiSc1==null){
  strSosikiSc1="";
}
if(strUserNamSc0==null){
     strUserNamSc0="";
}
if(strUserNamSc1==null){
  strUserNamSc1="";
}

String strMultSetDate=strNowDate;

if(request.getParameter("SetDate")!=null){
	strMultSetDate=request.getParameter("SetDate");
}
%>

<html>
<head>
<title>メンバー選択(SEIグループ)</title>
<meta http-equiv="Content-Style-Type" content="text/css">
<link href="../com/mierucchics.css" rel="stylesheet" type="text/css">
</head>

<body>
<table class="header">
<tr><th>メンバー選択(SEIグループ)</th></tr>
</table>
<br style="line-height:0.6em;">
<form name="memball_sel" action="memball_sel.jsp" method="POST">
<div align="center">
<table class="basetable">
<tr><th>組織名</th>
<td>
<input name="SosikiSc0" style="ime-mode:active" value="<%=strSosikiSc0%>" size="20"
		autocomplete="off"
		onkeypress="javascript:enter_in(this,event.keyCode);"
		onchange="javascript:sc_char_del(this);" onblur="javascript:sc_char_del(this);">
＆
<input name="SosikiSc1" style="ime-mode:active" value="<%=strSosikiSc1%>" size="20"
		autocomplete="off"
        onkeypress="javascript:enter_in(this,event.keyCode);"
        onchange="javascript:sc_char_del(this);" onblur="javascript:sc_char_del(this);">
</td>
<td rowspan="2">
<input name="Search" type="submit" value="検 索">
</td></tr>
<tr><th>氏名</th>
<td>
<input name="UserNamSc0" style="ime-mode:active" value="<%=strUserNamSc0%>" size="20"
		autocomplete="off"
		onkeypress="javascript:enter_in(this,event.keyCode);"
		onchange="sc_char_del(this);" onblur="sc_char_del(this);">
＆
<input name="UserNamSc1" style="ime-mode:active" value="<%=strUserNamSc1%>" size="20"
		autocomplete="off"
		onkeypress="javascript:enter_in(this,event.keyCode);"
		onchange="sc_char_del(this);" onblur="sc_char_del(this);">
</td></tr>
</table>
<br style="line-height:0.4em;">

<%
StringBuilder sbSosikiQry = new StringBuilder();
StringBuilder sbSosikiQry1 = new StringBuilder();

if(!strSosikiSc0.equals("") || !strUserNamSc0.equals("")
		|| !strSosikiSc1.equals("")  || !strUserNamSc1.equals("")) {//検索キーがあれば検索処理開始

int SosikiCnt =0;
if(!strSosikiSc0.equals("") || !strSosikiSc1.equals("")) {
		//組織絞込の開始
	if(!strSosikiSc0.equals("")){
	 	sbSosikiQry
	 	.append("and (OrgFulNam like '%") .append(strSosikiSc0) .append("%'")
		.append(" or OrgNam like '%") .append(strSosikiSc0) .append("%')");
	}
	if(!strSosikiSc1.equals("")){
		sbSosikiQry
		.append("and (OrgFulNam like '%") .append(strSosikiSc1) .append("%'")
		.append(" or OrgNam like '%") .append(strSosikiSc1) .append("%')");
	}

	//System.out.println("sbSosikiQry = "+sbSosikiQry.toString());

	ResultSet rsOrgList=objSql.executeQuery(sbTmp
		.append(" select orgId from meorg")
		.append(" where (ToDate='' or ToDate>='") .append(strMultSetDate) .append("')")
		.append(sbSosikiQry)
		.append(" and  FromDate<= '") .append(strMultSetDate) .append("'")
		.toString());sbTmp.delete(0,sbTmp.length());
	sbSosikiQry.delete(0,sbSosikiQry.length());

	while(rsOrgList.next()){
		if(sbSosikiQry1.length()!=0){
			sbSosikiQry1.append(" or ");
		}
		sbSosikiQry1.append("RealOrgId=") .append(rsOrgList.getString("OrgId"));
	}
	rsOrgList.close();

	if(sbSosikiQry1.length()!=0){
		sbSosikiQry1.insert(0, " and (") .append(")");
	}
	rsOrgList.close();
}//if(!strSosikiSc0.equals("") && !strSosikiSc1.equals(""))

StringBuilder sbNamQry = new StringBuilder();

if(!strUserNamSc0.equals("")){
  sbNamQry
  .append(" and UserNam like '%") .append(strUserNamSc0) .append("%'");
}
if(!strUserNamSc1.equals("")){
	sbNamQry
	.append(" and UserNam like '%") .append(strUserNamSc1) .append("%'");
}

if(sbSosikiQry1.length()!=0 || sbNamQry.length()!=0){
	sbQry
	.append(" select userNo from meuser")
	.append(" where (ToDate='' or ToDate>='") .append(strMultSetDate) .append("')")
	.append(sbNamQry) //名前の絞込
	.append(sbSosikiQry1) // 部署の絞り込み
	.append(" and FromDate<= '") .append(strMultSetDate) .append("'")
	.append(" order by UserKanaNam");
	;

sbNamQry.delete(0,sbNamQry.length());
sbSosikiQry1.delete(0,sbSosikiQry1.length());

StringBuilder sbUserNoList=new StringBuilder();
ResultSet rsUserList=objSql.executeQuery(sbQry.toString());
sbQry.delete(0,sbQry.length());

while(rsUserList.next()){
	  sbUserNoList .append(",") .append(rsUserList.getString("UserNo"));
}
rsUserList.close();
%>
<table class="baselist">
<tr><td>
<%
PreparedStatement ps0=null;
PreparedStatement ps1=null;

StringTokenizer noTkn=new StringTokenizer(sbUserNoList.toString(),",")	;
sbUserNoList.delete(0,sbUserNoList.length());

while(noTkn.hasMoreTokens()){
	if(ps0 == null){ps0 =db.prepareStatement(sbTmp
		.append(" select userNo,userId,userNam,mailAddr,realOrgId ")
		.append(" from meuser ")
		.append(" where UserNo=?")
		.toString());sbTmp.delete(0,sbTmp.length());
	}
	ps0.setInt(1, Integer.valueOf( noTkn.nextToken()));
	ResultSet rsUser = ps0.executeQuery();

	rsUser.next()	;
	String strUserNo  =rsUser.getString("UserNo")	;
	String strUserId  =rsUser.getString("UserId")	;
	String strUserNam =rsUser.getString("UserNam")	;
	String strMailAddr=rsUser.getString("MailAddr")	;
	String strOrgId   =rsUser.getString("RealOrgId")	;
	rsUser.close();

	if(ps1 == null){ps1 =db.prepareStatement(sbTmp
		.append(" select orgNam,orgFulNam ")
		.append(" from meorg ")
		.append(" where OrgId=? ")
		.toString());sbTmp.delete(0,sbTmp.length());
	}
	ps1.setInt(1, Integer.valueOf( strOrgId));
	ResultSet rsOrg = ps1.executeQuery();

	rsOrg.next();
	String strOrgNam = rsOrg.getString("OrgNam");
	String strOrgFulNam = rsOrg.getString("OrgFulNam");
	rsOrg.close();
	
	%>
	<a href="javaScript:memb_set('<%=strUserNo%>','<%=strUserNam%>','<%=strOrgId%>','<%=strOrgNam%>','<%=strOrgFulNam%>','<%=strMailAddr%>');">
	<%=sbTmp .append(strOrgFulNam) .append(" <b>") .append(strUserNam) .append("</b>") .toString()%></a><br>
	<%sbTmp.delete(0,sbTmp.length()); %>
<%}%>
</td></tr>
</table>

<%}// end of if(sbSosikiQry.length()!=0 && sbNamQry.length()!=0)
}// end of if(!strSosikiSc0.equals("") && !strUserNamSc0.equals("") && !strSosikiSc1.equals("") && !strUserNamSc1.equals(""))
%>

<%if(request.getParameter("ScOrgArea")!=null){%>
	<input name="ScOrgArea" type="hidden" value="<%=request.getParameter("ScOrgArea")%>">
<%}%>
<%if(request.getParameter("ScUserArea")!=null){%>
	<input name="ScUserArea" type="hidden" value="<%=request.getParameter("ScUserArea")%>">
<%}%>
</div>
</form>
<script type="text/javaScript" src="com_utf8.js"></script>
<script type="text/javaScript"><!--

function enter_in(a,key){
	if(key == 13) {
		document.forms[0].Search.disabled=true;
		document.forms[0].setAttribute('readonly','readonly');//disabledはだめ
		sc_char_del(a);
		document.forms[0].submit();
	}
}

function memb_set(userno,usernm,orgkey,orgnm,orgfnm,mail){
	if(window.opener.name=="fr_main"){
		if( window.opener.parent.fr_main.g_pageno == 0 ) {
			window.opener.memb_dsp(userno,usernm);
		}
	}
	window.opener.focus();
	window.close();
}

function init(){
	moveTo(20,20);//20160922
	resizeTo(600,600);
	document.forms[0].Search.disabled=false;
	document.forms[0].removeAttribute('readonly');
}

window.onload=init;
//-->
</script>

</body>
</html>
<%
//}//end of else of 初期画面（初期画面以外の画面表示処理）%>

<%
objSql.close();
db.close();
%>

<!-- *************************- end of memball_sel.jsp *********************** -->