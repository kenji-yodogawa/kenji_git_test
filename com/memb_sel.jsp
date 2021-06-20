<!-- *************************************************************************
	＜メンバー選択＞ in みえるっち
	File Name :memb_sel.jsp
	Date  :2006-09-14  Author  :k-mizuno
	呼出元：
	design/
		    comdrpl_inp.jsp　●
		    drawing_inp.jsp
		    drinfoapv_inp.jsp　●複数行へ追加
		    drinfochk_inp.jsp　●●複数行へ追加
		    drinfomp_inp.jsp　●●複数行へ追加　 、g_pageno==310、
		    drmodel_inp.jsp
		    drpl_inp.jsp
		    drrequest_inp.jsp (3 match)
		    drrequestans_inp.jsp
		    entrybase_inp.jsp
		    mailmemb_inp.jsp
		    mustdrans_inp.jsp
		    mustdrinfo_chk.jsp
		    part_inp.js
		    pl_inp.jsp ●●
		    ploptset_inp.jsp
		    ploptset_sc.jsp
		    plupl_set.jsp
		    softverpart_list.jsp
	designinfra/constuser_inp.jsp
					    prefconstuser_inp.jsp
					    sales/
					    posting_inp.jsp
					    postingapv_inp.jsp
	seikan/     lockmk_inp.jsp
					    workstd_inp.jsp
	sys/
					    meeco_inp.jsp
					    meuser_inp.jsp ●

	Update
	2014-03-15 kaneshi CSS他全般整理
	2014-04-04 kaneshi
	    課題：　　入力値へトリム
　　              エンター入力で検索開始
　　　　　　　　部署名と名前の各２つづつの文字列で検索可能へ。
	2014-04-06 kaneshi 指定組織名に該当がない場合、検索しないよう対処した。（バグだった）
	2014-05-29 kaneshi CSS外部化
	2014-07-28 kaneshi JavaScript一部外部化　comA.js
	2014-08-29 kaneshi 画面オープン時に名前にフォーカスするとした。
	　　　　　　　　　（以前は組織名だった。）
	　　　　　        resizeTo(600,600)→resizeTo(350,400);
	2014-11-02 kaneshi sql  select * のカラム特定
	　　　　　　　　　ResultSetを読んだらすぐ閉じる
	2014-12-09 kaneshi drinfomp_inp から開いたとき動作しない　一覧表をださない
	　　　　　　　　　 drinfoapv_inp も同様
	2014-12-17 kaneshi StringBuilder で高速化
	
	2015-03-06 kaneshi 設計変更通知から開いたとき、検索できない問題へ対処開始
	2015-04-02 kaneshi 若干のコード整理、String#concatで高速化
	2015-01-04 kaneshi var d = document.all; 利用で簡素化
	                   partexchange_inp.jsp から開いて組織＋人をセットするようにした。
	2016-01-06 kaneshi resizeTo調整
	2016-02-07 kaneshi 孫画面でよばれるときonblur=focus()をやると文字入力ができなくなるので、外した
	　　　　　　　　　　　　　　　　　　　（comdrpl_inpから）
	2016-04-07 kaneshi StringBuilder化強化
	2016-07-26 kaneshi PreparedStatementの行数節約
	2016-09-04 kaneshi テキスト入力欄で、autocomplete="off"
	2016-09-22 kaneshi StringBuilder化再徹底
	2017-12-15 kaneshi テーブル結合のleft join 化
	2018-01-30 kaneshi テーブル結合前の絞り込み
	2018-03-29 kaneshi ＳＱＬ検索条件のtodateの優先度アップ
	2018-07-18 kaneshi　定数担当者は設計権限があるものとする。　
	　　　　　　　　　　　　　　（テーブルでconstpref ）

********************************************************************************* -->

<%@ page contentType="text/html;charset=UTF-8"
	import="java.sql.*,java.io.*,java.net.*, java.util.*,java.text.*"%>

<% String strRight=""; %>
<%@ include file="../header_utf8.jsp"%>

<%
StringBuilder sbQry = new StringBuilder();
StringBuilder sbTmp = new StringBuilder();

String strSosikiSc0 =request.getParameter("SosikiSc0");
String strSosikiSc1 =request.getParameter("SosikiSc1");
String strUserNamSc0 = request.getParameter("UserNamSc0");
String strUserNamSc1 = request.getParameter("UserNamSc1");

String strMultSetDate=strNowDate;

if(request.getParameter("SetDate")!=null){
	strMultSetDate=request.getParameter("SetDate");
}

sbQry
.append(" select O.orgId,O.orgNam,O.sortNo ")
.append(" from (select orgId from orgright")
.append("        where RightType='USER'")
.append("      ) as R ")
.append(" left join (select orgId,orgNam,sortNo,todate,fromdate from meorg ")
.append("           ) as O ")
.append("   on R.OrgId=O.OrgId")
.append("   and (O.ToDate='' or O.ToDate>='") .append(strMultSetDate) .append("')")
.append("   and O.FromDate<= '") .append(strMultSetDate) .append("'")
.append(" where O.orgid is not null ")
.append(" order by SortNo")
;
ResultSet rsTopOrg = objSql.executeQuery(sbQry.toString());
sbQry.delete(0,sbQry.length());

StringBuilder sbMultTopOrgId=new StringBuilder();
StringBuilder sbMultTopOrgNam=new StringBuilder();

while(rsTopOrg.next()){
	sbMultTopOrgId .append(",") .append(rsTopOrg.getString("OrgId"));
	sbMultTopOrgNam .append(",") .append(rsTopOrg.getString("OrgNam"));
}
rsTopOrg.close();

String strMultTopOrgId=sbMultTopOrgId.toString();
String strMultTopOrgNam=sbMultTopOrgNam.toString();

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
	%>

<html>
<head>
<meta http-equiv="Content-Style-Type" content="text/css">
<link href="../com/mierucchics.css" rel="stylesheet" type="text/css">
<title>メンバー選択</title>
</head>

<body><!-- onbluｒ=focusをはずした -->
<table class="header">
<tr><th>メンバー選択(シス事グループ)</th></tr>
</table>
<br style="line-height:0.4em;">

<form name="memb_sel" action="memb_sel.jsp" method="POST">
<div align="center">

<table class="basetable">
<tr><th>組織名</th>
	<td><input name="SosikiSc0" style="ime-mode:active" 
			value="<%=strSosikiSc0%>" size="20"
			autocomplete="off"
			onkeypress="enter_in(this,event.keyCode);"
			onchange="sc_char_del(this);" 
			onblur="sc_char_del(this);">
		＆
	<input name="SosikiSc1" style="ime-mode:active" 
			value="<%=strSosikiSc1%>" size="20"
			autocomplete="off"
			onkeypress="enter_in(this,event.keyCode);"
			onchange="sc_char_del(this);" 
			onblur="sc_char_del(this);">
	</td>
	<td rowspan="2" >
	<input name="Search" type="submit" value="検索">
	</td>
</tr>
<tr>
	<th>氏名</th>
	<td><input name="UserNamSc0" style="ime-mode:active" 
			value="<%=strUserNamSc0%>" size="20"
			autocomplete="off"
			onkeypress="enter_in(this,event.keyCode);"
			onchange="sc_char_del(this);" 
			onblur="sc_char_del(this);">
		＆
	<input name="UserNamSc1" style="ime-mode:active" 
			value="<%=strUserNamSc1%>" size="20"
			autocomplete="off"
			onkeypress="enter_in(this,event.keyCode);"
			onchange="sc_char_del(this);" 
			onblur="sc_char_del(this);">
	</td>
</tr>
</table>
<br style="line-height:0.5em;">
<%
PreparedStatement ps0=null;
PreparedStatement ps1=null;
PreparedStatement ps2=null;

if(!strSosikiSc0.equals("") || !strSosikiSc1.equals("")
	|| !strUserNamSc0.equals("") || !strUserNamSc1.equals("")) {

	String strMultTbNam="meorg";
	String strMultApvSign="TRUE";
	int intMultTopLevel=0;
	int intMultMaxLevel=15;
	%>
	<%@ include file="../com/org_fwd_utf8.jsp"%>
	<%
	strMultOrgIdList=sbTmp .append(",") .append(strMultOrgIdList) .append(",") 
		.toString();sbTmp.delete(0,sbTmp.length());

	StringBuilder sbScQry = new StringBuilder();
	int SosikiCnt =0;
	StringBuilder sbScOrgId  = new StringBuilder();

	if(!strSosikiSc0.equals("") || !strSosikiSc1.equals("")) {

		StringBuilder sbScOrgNam = new StringBuilder();
		
		if(!strSosikiSc0.equals("")){
			sbScOrgNam
			.append(" and (OrgFulNam like '%") .append(strSosikiSc0) .append("%'") 
			.append("      or OrgNam like '%") .append(strSosikiSc0) .append("%')");
		}
		//String strQuery1="";
		if(!strSosikiSc1.equals("")){
			sbScOrgNam
			.append(" and (OrgFulNam like '%") .append(strSosikiSc1) .append("%'") 
			.append("     or OrgNam like '%") .append(strSosikiSc1) .append("%')");
		}
		
		ResultSet rsOrgList=objSql.executeQuery(sbTmp
		.append(" select orgId from meorg")
		.append(" where (ToDate='' or ToDate>='") .append(strMultSetDate) .append("')")
		.append(" and  FromDate<= '") .append(strMultSetDate) .append("'")
		.append(sbScOrgNam)
		.toString());sbTmp.delete(0,sbTmp.length());

		while(rsOrgList.next()){
			sbTmp .append(",") .append(rsOrgList.getString("OrgId")) .append(",");
			if(strMultOrgIdList	.indexOf(sbTmp.toString())>=0){
				if(sbScOrgId.length()!=0){
					sbScOrgId.append(" or ");
				}
				sbScOrgId
				.append(" RealOrgId=") .append(rsOrgList.getString("OrgId"));
				SosikiCnt ++;
			}
			sbTmp.delete(0,sbTmp.length());
		}
		rsOrgList.close();

	}else { // end of if(!(strSosikiSc0+strSosikiSc1).equals(""))
		StringTokenizer idTkn=new StringTokenizer(strMultOrgIdList,",");
		while(idTkn.hasMoreTokens()){
			if(sbScOrgId.length()!=0){
				sbScOrgId.append(" or ");
			}
			sbScOrgId.append(" RealOrgId=") .append(idTkn.nextToken());
			SosikiCnt ++;
		}
	}// end of else of if(!(strSosikiSc0+strSosikiSc1).equals(""))

	if(SosikiCnt!=0) {
		if(sbScOrgId.length()!=0){
			sbScOrgId.insert(0," and (") .append(")");
		}

		if(!strUserNamSc0.equals("")){
			sbScQry
			.append(" and UserNam like '%") .append(strUserNamSc0) .append("%'");
		}
		if(!strUserNamSc1.equals("")){
			sbScQry
			.append(" and UserNam like '%") .append(strUserNamSc1) .append("%'");
		}

		sbQry
		.append(" select userNo from meuser")
		.append(" where UserNam like '%") .append(strUserNamSc0) .append("%'")
		.append(" and (ToDate='' or ToDate>='") .append(strMultSetDate) .append("')")
		.append(" and FromDate<= '") .append(strMultSetDate) .append("'")
		.append(sbScQry.append(sbScOrgId))
		;
	
		StringBuilder sbExcList=new StringBuilder();
		
		if(request.getParameter("ExcList")!=null){
			sbExcList .append(",") .append(request.getParameter("ExcList")) .append(",");
		}
	
		StringBuilder sbDrUserIdList=new StringBuilder();
		
		if(request.getParameter("DRINP")!=null){
			// 20180717 druser テーブルだけでなく　constpref　もみるようにする
			
			ResultSet rsDrInp=objSql.executeQuery(
				" select distinct userId from druser where Invalid=''"
			);
			while(rsDrInp.next()){
				sbDrUserIdList .append(",") .append(rsDrInp.getString("UserId"));
			}
			rsDrInp.close();
			
			ResultSet rsDrInp1=objSql.executeQuery(// 定数担当は、設計者とみす
				" select distinct userId from constpref "
			);
			StringBuilder sbTmp1 = new StringBuilder();
			while(rsDrInp1.next()){
				sbTmp  .append(",") .append(sbDrUserIdList) .append(",");
				String x = rsDrInp1.getString("UserId");
				sbTmp1 .append(",") .append(x) .append(",");
				
				if(sbTmp .indexOf(sbTmp1.toString())<0){
					sbDrUserIdList .append(",") .append(x);
				}
				sbTmp.delete(0,sbTmp.length());
				sbTmp1.delete(0,sbTmp1.length());
			}
			rsDrInp1.close();
		}
		if(request.getParameter("BossOnly")!=null){
			sbQry.append(" and BossFlg='YES'");
		}
		if(request.getParameter("MngFlg")!=null){
			sbQry.append(" and MngFlg='YES'");
		}

		if(request.getParameter("ExceptMemb")!=null){
			StringTokenizer exTkn=new StringTokenizer(request.getParameter("ExceptMemb"),",");
			
			while(exTkn.hasMoreTokens()){
				if(ps0 == null){ps0 =db.prepareStatement(sbTmp
					.append(" select userId from meuser ")
					.append(" where UserNo=?")
					.toString());sbTmp.delete(0,sbTmp.length());
				}
				ps0.setInt(1, Integer.valueOf( exTkn.nextToken()));
				ResultSet rsExUser = ps0.executeQuery();
	
				rsExUser.next();
					sbQry
					.append(" and UserId!='") .append(rsExUser.getString("UserId")) .append("'");
				rsExUser.close();
				}
			}
			sbQry.append(" order by UserKanaNam");
	
			ResultSet rsUserList=objSql.executeQuery(sbQry.toString());
			sbQry.delete(0,sbQry.length());
			sbScQry.delete(0,sbScQry.length());
			
			StringBuilder sbUserNoList=new StringBuilder();
			
			while(rsUserList.next()){
				sbUserNoList .append(",") .append(rsUserList.getString("UserNo"));
			}
			rsUserList.close();
		%>
			<table class="thinborder">
				<tr>
					<td>
						<%
		StringTokenizer noTkn=new StringTokenizer(sbUserNoList.toString(),",")	;
	
		while(noTkn.hasMoreTokens()){
			if(ps1 == null){ps1 =db.prepareStatement(sbTmp
				.append(" select userNo,userId,userNam,mailAddr,realOrgId,userKanaNam ")
				.append(" from meuser ")
				.append(" where UserNo=?")
				.append(" order by jnjOrgId ")
				.toString());sbTmp.delete(0,sbTmp.length());
			}
			ps1.setInt(1, Integer.valueOf( noTkn.nextToken()));
			ResultSet rsUser = ps1.executeQuery();
	
			rsUser.next()	;
			String strUserNo  =rsUser.getString("UserNo")	;
			String strUserId  =rsUser.getString("UserId")	;
			String strUserNam =rsUser.getString("UserNam")	;
			String strMailAddr=rsUser.getString("MailAddr")	;
			String strOrgId   =rsUser.getString("RealOrgId")	;
			rsUser.close();
			
			if(ps2 == null){ps2 =db.prepareStatement(sbTmp
				.append(" select orgNam,orgFulNam ")
				.append(" from meorg ")
				.append(" where OrgId=?")
				.append(" and (ToDate='' or ToDate>='") .append(strMultSetDate) .append("')")
				.append(" and FromDate<= '") .append(strMultSetDate) .append("'")
				.toString());sbTmp.delete(0,sbTmp.length());
			}
			ps2.setInt(1, Integer.valueOf( strOrgId));
			ResultSet rsOrg = ps2.executeQuery();
	
			rsOrg.next();
			String strOrgNam   =rsOrg.getString("OrgNam")	;
			String strOrgFulNam=rsOrg.getString("OrgFulNam")	;
			rsOrg.close();
			%>
			<%
			sbTmp .append(",") .append(strUserNo) .append(",");
			if(sbExcList.length()!=0 
				   && sbExcList.indexOf(sbTmp.toString())>=0){
				   sbTmp.delete(0,sbTmp.length());
				   %>
					<div style="color:red; font-weight:bold;">
					  <%=sbTmp .append(strOrgFulNam) .append(" ") .append(strUserNam) .toString()%>(条件外です)
					</div>
					<br>
			<%}else if(sbDrUserIdList.length()!=0
						&& sbDrUserIdList.indexOf(strUserId)<0){%>
					<%sbTmp.delete(0,sbTmp.length()); %>
					<div style="color:red; font-weight:bold;">
					  <%=sbTmp .append(strOrgFulNam) .append(" ") .append(strUserNam) .toString() %>(設計資格がありません)
					</div>
					<br>
			<%}else{%>
				<a href="javaScript:memb_set('<%=strUserNo%>','<%=strUserNam%>','<%=strOrgId%>','<%=strOrgNam%>','<%=strOrgFulNam%>','<%=strMailAddr%>');">
				<%sbTmp.delete(0,sbTmp.length()); %>
				<%=sbTmp .append(strOrgFulNam) .append(" <span style='font-weight:bold;'>") .append(strUserNam) .append("</span>") .toString()%>
				</a><br>
			<%}
			sbTmp.delete(0,sbTmp.length());
			
			strOrgFulNam=null;
			strUserNam=null;
			strOrgId=null;
			strMailAddr=null;
			%>
		<%}%>
</td>
</tr>
</table>

<%	}// end of if(SosikiCnt!=0)
}%>

<%if(request.getParameter("DRINP")!=null){%>
	<input name="DRINP" type="hidden"
  	value="<%=request.getParameter("DRINP")%>">
<%}%>
<%if(request.getParameter("KeyItem")!=null){%>
	<input name="KeyItem" type="hidden"
		value="<%=request.getParameter("KeyItem")%>">
<%}%>
<%if(request.getParameter("NamItem")!=null){%>
	<input name="NamItem" type="hidden"
		value="<%=request.getParameter("NamItem")%>">
<%}%>
<%if(request.getParameter("ExcList")!=null){%>
	<input name="ExcList" type="hidden"
		value="<%=request.getParameter("ExcList")%>">
<%}%>
<%if(request.getParameter("BossOnly")!=null){%>
	<input name="BossOnly" type="hidden"
		value="<%=request.getParameter("BossOnly")%>">
<%}%>
<%if(request.getParameter("MngFlg")!=null){%>
	<input name="Manager" type="hidden"
		value="<%=request.getParameter("Manager")%>">
<%}%>
<% if(request.getParameter("OpnProg")!=null){ %>
	<input name="OpnProg" type="hidden"
		value="<%=request.getParameter("OpnProg")%>">
<% } %>
<% if(request.getParameter("Line")!=null){ %>
	<input name="Line" type="hidden"
		value="<%=request.getParameter("Line")%>">
<% } %>
<% if(request.getParameter("SetDate")!=null){ %>
	<input name="SetDate" type="hidden"
		value="<%=request.getParameter("SetDate")%>">
<% } %>
<% if(request.getParameter("ExceptMemb")!=null){ %>
	<input name="ExceptMemb" type="hidden"
		value="<%=request.getParameter("ExceptMemb")%>">
<% } %>
<%if(request.getParameter("ScOrgArea")!=null){%>
	<input name="ScOrgArea" type="hidden"
		value="<%=request.getParameter("ScOrgArea")%>">
<%}%>
<%if(request.getParameter("ScUserArea")!=null){%>
	<input name="ScUserArea" type="hidden"
		value="<%=request.getParameter("ScUserArea")%>">
<%}%>

</div>
</form>

<script type="text/javaScript" src="../com/com_utf8.js"></script>
<script type="text/javaScript">
<!--
function enter_in(a,key){
	if(key == 13) {
		document.forms[0].Search.disabled=true;
		document.forms[0].setAttribute('readonly','readonly');//disabledはだめ
		trimall(a);
		document.forms[0].submit();
	}
}

function memb_set(userno,usernm,orgkey,orgnm,orgfnm,mail) {
	if(window.opener.name=="fr_main"){
		var g_pageno = window.opener.parent.fr_main.g_pageno;
		var d = window.opener.parent.fr_main.document.all;
		var pgnam = window.opener.parent.fr_main.pgnam;

		//if( g_pageno== 0 && window.opener.parent.fr_main.pgnam != "partexchange_inp") {
		if( g_pageno== 0 && pgnam!="partexchange_inp") {
			window.opener.memb_dsp(userno,orgnm+" "+usernm);
		//環境設定
		}else if( g_pageno== 110 ) {
			d.meeco_inp.AcAdmNo.value = userno;
			d.meeco_inp.AcAdmNam.value = usernm;

		}else if( g_pageno==910 ) {
			d.pl_inp.AplUserNo.value = userno;
			d.pl_inp.AplUserNam.value = orgfnm + " " + usernm;
		}else if( g_pageno==920 ) {
			d.plupl_set.AplUserNo.value = userno;
			d.plupl_set.AplUserNam.value = orgfnm + " " + usernm;
		}else if( g_pageno==930 ) {
			d.comdrpl_inp.AplUserNo.value = userno;
			d.comdrpl_inp.AplUserNam.value = orgfnm + " " + usernm;
		}else if( window.opener.parent.fr_main.pgnam == "partexchange_inp") {//20160104
			d.partexchange_inp ["AplUserNo"].value = userno;
			d.partexchange_inp ["AplUserNam"].value = orgfnm + " " + usernm;
		}
	}else{// no fr_main
		var g_pageno = window.opener.parent.g_pageno;
		var pgnam = window.opener.parent.pgnam;
		var d = window.opener.parent.document.all;

		if( g_pageno==0) {//ploptset_inpはここ。
			//alert("memb_sel::memb_set start");
			window.opener.memb_dsp(userno,orgnm+" "+usernm);
			<%if(request.getParameter("ScOrgArea")!=null){%>
				d [window.opener.parent.pgnam] ["<%=request.getParameter("ScOrgArea")%>"].value 
					=document.forms[0].SosikiSc.value;
			<%}%>
			<%if(request.getParameter("ScUserArea")!=null){%>
				d [window.opener.parent.pgnam] ["<%=request.getParameter("ScUserArea")%>"].value 
					=document.forms[0].UserNamSc.value;
			<%}%>
		}else if( g_pageno==150 ) {
			d.drawing_inp.AplUserNo.value = userno;
			d.drawing_inp.AplUserNam.value = orgfnm + " " + usernm;
			d.drawing_inp.AplToDate.value = "";
		}else if( g_pageno==240 ) {
			<% if(request.getParameter("KeyItem")==null){ %>
			//設計変更通知配布先
				window.opener.ccmemb_dsp(userno,orgfnm+" "+usernm,'SET');
				d [window.opener.parent.pgnam] ["<%=request.getParameter("ScOrgArea")%>"].value 
					=document.forms[0].SosikiSc.value;
				d [window.opener.parent.pgnam] ["<%=request.getParameter("ScUserArea")%>"].value 
					=document.forms[0].UserNamSc.value;
			<%}else{%>
				d.drinfo_inp.AplOrgId.value = orgkey;
				d.drinfo_inp.AplOrgNam.value = orgfnm;
				d.drinfo_inp.AplUserNo.value = userno;
				d.drinfo_inp.AplUserNam.value = usernm;
			<%}%>

		}else if(g_pageno==250|| g_pageno==320){ //drinfoapv_inp.jsp //drinfo_chk.inp
		//(userno,usernm,orgkey,orgnm,orgfnm,mail)
			window.opener.ccmemb_dsp(userno,orgfnm+" "+usernm,'SET');
			//window.opener.parent.document [pgnam] ["<%=request.getParameter("ScOrgArea")%>"].value =orgfnm;
			//window.opener.parent.document [pgnam] ["<%=request.getParameter("ScUserArea")%>"].value = usrnm;

		}else if(g_pageno==310){ //drinfomp_inp
			window.opener.ccmemb_dsp(userno,orgfnm+" "+usernm,'SET');
		}else if( g_pageno==260 ) {
			if(d.drrequest_inp ["<%=request.getParameter("NamItem")%>"].type=="textarea"){
				if(mail==""){
					orgfnm + " " + usernm + "にはメールアドレスがありません。";
				}else{
					if(d.drrequest_inp ["<%=request.getParameter("KeyItem")%>"].value==""){
						d.drrequest_inp ["<%=request.getParameter("KeyItem")%>"].value=userno;
						d.drrequest_inp ["<%=request.getParameter("NamItem")%>"].value=orgfnm + " " + usernm;
					}else{
						d.drrequest_inp ["<%=request.getParameter("KeyItem")%>"].value+="," + userno + ",";
						d.drrequest_inp ["<%=request.getParameter("NamItem")%>"].value+="\n" + orgfnm + " " + usernm;
					}
				}
			}else{
				d.drrequest_inp ["<%=request.getParameter("KeyItem")%>"].value = userno;
				d.drrequest_inp ["<%=request.getParameter("NamItem")%>"].value = orgfnm + " " + usernm;
				num="0123456789";
				if(num.indexOf("<%=request.getParameter("NamItem")%>".charAt("<%=request.getParameter("NamItem")%>".length-1))>=0){
					window.opener.line_dsp();

				}
			}

		}else if( g_pageno==300 ) {
			if(mail==""){
				orgfnm + " " + usernm + "にはメールアドレスがありません。";
			}else if("<%=request.getParameter("KeyItem")%>"=="DrUserNo"){
				d.entrybase_inp.DrUserNo.value=userno;
				d.entrybase_inp.DrUserNam.value=orgfnm + " " + usernm;
				d.entrybase_inp.DrToDate.value="";
			}else{
				if(d.entrybase_inp ["<%=request.getParameter("KeyItem")%>"].value==""){
					d.entrybase_inp ["<%=request.getParameter("KeyItem")%>"].value=userno;
					d.entrybase_inp ["<%=request.getParameter("NamItem")%>"].value=orgfnm + " " + usernm;
				}else{
					d.entrybase_inp ["<%=request.getParameter("KeyItem")%>"].value+="," + userno + ",";
					d.entrybase_inp ["<%=request.getParameter("NamItem")%>"].value+="\n" + orgfnm + " " + usernm;
				}
			}
		}else if( g_pageno==270 ) {//2016-08-30 修正
			//alert("set start to part_inp ");
			d.part_inp.UserNo.value = userno;
			d.part_inp.UserId.value = userid;//???
			d.part_inp.UserNam.value = orgfnm + " " + usernm;
		}else if( g_pageno==340 ) {
			if("<%=request.getParameter("KeyItem")%>"!=""){
				d.mailmemb_inp ["<%=request.getParameter("KeyItem")%>"].value = userno;
				d.mailmemb_inp ["<%=request.getParameter("NamItem")%>"].value = orgfnm + " " + usernm;
			}else{
				window.opener.memb_dsp(userno,orgfnm+" "+usernm,'SET');
			}
		}else if( g_pageno==410 ) {
			//var d =window.opener.parent.document.all;
			if(mail==""){
				orgfnm + " " + usernm + "にはメールアドレスがありません。";
			}else{
				if(d.posting_inp.CcUserNo.value==""){
					d.posting_inp.CcUserNo.value=userno;
					d.posting_inp.CcUserNam.value=orgfnm + " " + usernm;
				}else{
					d.posting_inp.CcUserNo.value+="," + userno + ",";
					d.posting_inp.CcUserNam.value+="\n" + orgfnm + " " + usernm;
				}
			}
		}else if( g_pageno==420 ) {
			//var d =window.opener.parent.document.all;	
			if(mail==""){
				orgfnm + " " + usernm + "にはメールアドレスがありません。";
			}else{
				if(d.postingapv_inp.CcUserNo.value==""){
					d.postingapv_inp.CcUserNo.value=userno;
					d.postingapv_inp.CcUserNam.value=orgfnm + " " + usernm;
				}else{
					d.postingapv_inp.CcUserNo.value+="," + userno + ",";
					d.postingapv_inp.CcUserNam.value+="\n" + orgfnm + " " + usernm;
				}
			}
		}else if( g_pageno==800 ) {
			d.workstd_inp.StdUserNo.value = userno;
			d.workstd_inp.StdUserNam.value = orgnm + " " + usernm;
		}else if( g_pageno==930 ) {
			d.comdrpl_inp.AplUserNo.value = userno;
			d.comdrpl_inp.AplUserNam.value = orgfnm + " " + usernm;
		}else if( g_pageno==940 ) {
			d.drmodel_inp.UserNo.value = userno;
			d.drmodel_inp.UserNam.value = orgfnm + " " + usernm;
			d.drmodel_inp.OrgId.value = orgkey;
		}else if( g_pageno==950 ) {
			d.drpl_inp.AplUserNo.value = userno;
			d.drpl_inp.AplUserNam.value = orgnm + " " + usernm;
	//定数担当者
		}else if( g_pageno < 0  && pgnam == "prefconstuser_inp" ) {
			window.opener.namSet(orgnm + " " + usernm, userno);
	//必須図面担当者
		}else if( g_pageno < 0  && pgnam == "mustdr_chk" ) {
			window.opener.namSet(orgnm + " " + usernm, userno);
	//感知器ソフト指示リスト
		}else if( pgnam == "softverpart_list") {
			window.opener.namSet(usernm, userno);
	//担当者
		}else if( g_pageno < 0  && pgnam == "ploptset_sc" ) {
			window.opener.namSet(orgnm + " " + usernm, userno);
		}
	}
	window.opener.focus();
	window.close();
}// end of function memb_set(userno,usernm,orgkey,orgnm,orgfnm,mail)

function init(){
	moveTo(20,20);
	resizeTo(700,400);//2014-11-03 画面の横幅を広げた
	document.forms[0].Search.disabled=false;
	if(document.forms[0].UserNamSc0){
		document.forms[0].UserNamSc0.focus();
	}
}

window.onload = init;
//-->
</script>

</body>
</html>


<%
objSql.close();
db.close();
%>

<!-- ******************************* end of memb_sel.jsp ********************************* -->