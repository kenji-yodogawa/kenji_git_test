<!-- *************************************************************
	＜回覧先リスト＞ リストを１つだけ選ぶコマンド
	File Name :mail_link.jsp  

	呼出元：defmail_set.jsp
	        drinfoapv_inp.jsp 
	        drinfochk_inp.jsp
	        drinfomp_inp.jsp 
	Author	:k-mizuno
	Date	:2006-08-07
	
	Update
	2014-04-07 kaneshi
		 (1)SQL integer=text問題解消
		    meuser int(userno,jnjorgid,realorgid,sssuserno) orgid多数
		      maillist  int(listno,mailcnt) text(admorgid) 対応なし
		 (2)改行インデント整理
		 (3)CSS整理
		 (4)SQL  integer=text エラーチェック
		 　 maillist int(listno,mailcnt)
	2014-05-29 kaneshi CSS外部化,
	2014-09-22 kaneshi ＜ｆｏｎｔを廃止、IEのバージョンをEDGEへ
	2014-12-22 kaneshi sql select * のカラム特定
	　　　　　　　　　ResultSetを読んだらすぐ閉じる。
	                  <font をスタイルシート（<spanタグ内）へ書き換えた。
     　　　　　　　　　SQLのインデント整理
	2015-03-17 kaneshi StringBuilder で高速化
	2015-07-15 kaneshi PreparedStatementで高速化
	2016-01-04 kaneshi var d =document.all利用で簡素化
	　　　　　　　maillist_linktとorgtree_chekbox に機能が移されてしまい,使っていないのでは。
	    →defmail_set.jspで利用している。
	2016-01-06 kaneshi resizeToの調整
	2016-05-29 kaneshi SQLへセットするパラメータ減
	2016-10-14 kaneshi concat -> append
	2018-04-02 kaneshi defmail_set.jspからよばれる場合の処理にバグあり修正

***************************************************************** -->

<%@ page contentType="text/html;charset=UTF-8"
	import="java.io.*,java.sql.*,java.net.*,java.util.*,java.text.*"%>

<% String strRight="USER"; %>
<%@ include file="../header_utf8.jsp"%>

<html>
<head>
<title>回覧先リスト</title>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta http-equiv="Content-Style-Type" content="text/css">
<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
<link href="../com/mierucchics.css" rel="stylesheet" type="text/css">
</head>

<body onBlur="focus()">
<table class="header">
<tr><th>回覧先リスト</th></tr>
</table>
<br style="line-height:0.4em;">
<form name="mail_link" action="mail_link.jsp" method="post">
<div align="center">

<table class="baselist">
<tr>
	<th>名称</th>
	<th>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;メンバ&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
	<th>メールリスト</th>
	<th>管理者</th>
</tr>

<%
StringBuilder sbTmp = new StringBuilder();

ResultSet rsListCnt=objSql.executeQuery(sbTmp
	.append(" select count(*) as count ")
	.append(" from maillist")
	.toString());sbTmp.delete(0,sbTmp.length());
rsListCnt.next();
int[] aryListNo=new int[rsListCnt.getInt("count")];
rsListCnt.close();

ResultSet rsList=objSql.executeQuery(sbTmp
	.append(" select listNo from maillist ")
	.append(" order by AdmUserId,ListNo")
	.toString());sbTmp.delete(0,sbTmp.length());
intCnt=0;

while(rsList.next()){
	aryListNo[intCnt]=rsList.getInt("ListNo");
	intCnt++;
}
rsList.close();

PreparedStatement ps0=null;
PreparedStatement ps1=null;
PreparedStatement ps2=null;
PreparedStatement ps3=null;

for(int i=0; i<intCnt; i++){
	if(ps0 == null){ps0 =db.prepareStatement(sbTmp
		.append(" select listNam,admUserId,admOrgId,orgList,userList,mailList,mailType,mailList ")
		.append(" from maillist ")
		.append(" where ListNo=?")
		.toString());sbTmp.delete(0,sbTmp.length());
	}
	ps0.setInt(1,Integer.valueOf( aryListNo[i]));
	ResultSet rsDat = ps0.executeQuery();

	rsDat.next();
	String strListNam     =rsDat.getString("ListNam");
	String strAdmUserId   =rsDat.getString("AdmUserId");
	String strAdmOrgId    =rsDat.getString("AdmOrgId");
	String strOrgIdList   =rsDat.getString("OrgList");
	String strUserIdList  =rsDat.getString("UserList");
	String strMailList    =rsDat.getString("MailList");
	String strMailType    =rsDat.getString("MailType");
	String strCcMlIdList  =rsDat.getString("UserList");
	String strCcMlAddrList=rsDat.getString("MailList");
	rsDat.close();

	StringBuilder sbCcMlNamList=new StringBuilder();

	StringTokenizer midTkn=new StringTokenizer(strCcMlIdList,",");
	int intMlIdCnt=0;

	while(midTkn.hasMoreTokens()){
		strTkn=midTkn.nextToken();
		sbTmp.delete(0,sbTmp.length());

		if(ps1 == null){ps1 =db.prepareStatement(sbTmp
			.append(" select userNam from meuser")
			.append(" where UserId=?")
			.append(" and FromDate = (select max(FromDate) from meuser as m")
			.append(               " where UserId=meuser.UserId )")
			.toString());sbTmp.delete(0,sbTmp.length());
		}
		ps1.setString(1, strTkn);
		ResultSet rsMlUser = ps1.executeQuery();

		rsMlUser.next();
		if(sbCcMlNamList.length()==0){
			sbCcMlNamList .append(rsMlUser.getString("UserNam"));
		}else{
			sbCcMlNamList .append(",") .append(rsMlUser.getString("UserNam"));
		}
		rsMlUser.close();

		intMlIdCnt++;
	}
	StringTokenizer madTkn=new StringTokenizer(strCcMlAddrList,",");
	int intMlAddrCnt=0;
	while(madTkn.hasMoreTokens()){
		strTkn=madTkn.nextToken();
		intMlAddrCnt++;
	}

	if(ps2 == null){ps2 =db.prepareStatement(sbTmp
		.append(" select userNam,toDate ")
		.append(" from meuser")
		.append(" where UserId=?")
		.append(" and RealOrgId=?")
		.append(" and FromDate=(select max(FromDate) from meuser as m")
		.append(                " where UserId=meuser.UserId ")
		.append(                  " and RealOrgId=meuser.RealOrgId )")
		.toString());sbTmp.delete(0,sbTmp.length());
	}
	ps2.setString(1, strAdmUserId);
	ps2.setInt(2, Integer.valueOf( strAdmOrgId));
	ResultSet rsAdmUser = ps2.executeQuery();

	rsAdmUser.next();
	StringBuilder sbAdmNam=new StringBuilder();
	sbAdmNam .append(rsAdmUser.getString("UserNam"));
	String strAdmToDate=rsAdmUser.getString("ToDate");

	if(!rsAdmUser.getString("ToDate").equals("")){
		sbAdmNam .insert(0,"<div style='color:red;'>") .append("</div>");
	}
	rsAdmUser.close();

	StringBuilder sbUserList=new StringBuilder();
	StringTokenizer usTkn=new StringTokenizer(strUserIdList,",");
	StringTokenizer ogTkn=new StringTokenizer(strOrgIdList,",");
	
	while(usTkn.hasMoreTokens()){
		String strUserId=usTkn.nextToken();
		String strOrgId=ogTkn.nextToken();

		if(ps3 == null){ps3 =db.prepareStatement(sbTmp
			.append(" select toDate,userNam ")
			.append(" from meuser")
			.append(" where UserId=?")
			.append(" and RealOrgId=?")
			.append(" and FromDate=(select max(FromDate) from meuser as m")
			.append(                " where UserId=meuser.UserId")
			.append(                "  and RealOrgId=meuser.RealOrgId )")
			.toString());sbTmp.delete(0,sbTmp.length());
		}
		ps3.setString(1, strUserId);
		ps3.setInt(2, Integer.valueOf(strOrgId));
		ResultSet rsUser = ps3.executeQuery();

		rsUser.next();
		String strFontColor="black";
		if(!rsUser.getString("ToDate").equals("")){
			strFontColor="red";
		}

		if(sbUserList.length()==0){
			sbUserList 
			.append("<span style='color:") .append(strFontColor) .append(";'>") 
			.append(rsUser.getString("UserNam")) .append("</span>");
		}else{
			sbUserList 
			.append(" ,<span style='color:") .append(strFontColor) .append(";'>") 
			.append(rsUser.getString("UserNam")) .append("</span>");
		}
		rsUser.close();
	}
	String x0 = String.valueOf(aryListNo[i]);
	String x1 = strListNam;
	String x2 = strMailType;
	String x3 = strCcMlIdList;
	String x4 = sbCcMlNamList.toString();
	String x5 = strCcMlAddrList;
	String x6 = String.valueOf(intMlIdCnt);
	String x7 = String.valueOf(intMlAddrCnt);
	%>
<tr>
	<td>
<!-- 	↓javascript:をとると動作しない。要注意 -->
	  <a href="javascript:mail_set('<%=x0%>','<%=x1%>','<%=x2%>','<%=x3%>','<%=x4%>','<%=x5%>','<%=x6%>','<%=x7%>');">
	    <%=strListNam%>
	  </a>
	  <%strListNam=null;%>
	  <%x0=null;x1=null;x2=null;x3=null;x4=null;x5=null;x6=null;x7=null; %>
	</td>
	<td style="width:80%; white-space:normal;"><%=sbUserList.toString()%><br></td>
	<%sbUserList.delete(0,sbUserList.length());%>
	<td><%=strMailList%><br></td>
	<%strMailList=null;%>
	<td style="width:10%; white-space:normal;"><%=sbAdmNam.toString()%></td>
	<%sbAdmNam.delete(0,sbAdmNam.length());%>
</tr>
<%}%>
</table>
</div>
</form>

<script type="text/javaScript" src="../com/com_utf8.js"></script>
<script type="text/javaScript">
<!--
moveTo(20,20);
resizeTo(screen.availWidth*0.8,screen.availHeight-20);

function mail_set(listno,listnam,mltype,idlist,namlist,addrlist,idcnt,addrcnt) {
	if(window.opener &&  window.opener.name=="fr_main"){
		var g_pageno=window.opener.parent.fr_main.g_pageno;
		if( g_pageno == 260 ) {
			//alert("CC ")//OK
			window.opener.parent.fr_main.defmail_set ["<%=request.getParameter("KeyItem")%>"].value=listno;//動いてない２０１６０１０４
			window.opener.parent.fr_main.defmail_set ["<%=request.getParameter("NamItem")%>"].value=listnam;//動いてない２０１６０１０４
			window.opener.mail_dsp(<%=request.getParameter("LineNo")%>);
		}
	}else{//以下はＳｕｂＷからひらくもの
		var g_pageno = window.opener.parent.g_pageno;
		var d = window.opener.parent.document.all;
	
		if( g_pageno ==240 ) {//20160105正常にうごいている
			window.opener.parent.document.forms[0].drinfo_inp ["CcMlNo<%=request.getParameter("LineNo")%>"].value=listno;
			window.opener.parent.document.forms[0].drinfo_inp ["CcMlNam<%=request.getParameter("LineNo")%>"].value=listnam;
			window.opener.parent.document.forms[0].drinfo_inp ["CcMlType<%=request.getParameter("LineNo")%>"].value=mltype;
			window.opener.parent.document.forms[0].drinfo_inp ["CcMlIdList<%=request.getParameter("LineNo")%>"].value=idlist;
			window.opener.parent.document.forms[0].drinfo_inp ["CcMlAddrList<%=request.getParameter("LineNo")%>"].value=addrlist;
			
			window.opener.mail_set(listno,listnam,mltype,idlist,namlist,addrlist);
			window.opener.mltb_dsp();
		
		}else if( g_pageno ==250 ) {
			window.opener.parent.document.forms[0].drinfochk_inp ["CcMlNo<%=request.getParameter("LineNo")%>"].value=listno;
			window.opener.parent.document.forms[0].drinfochk_inp ["CcMlNam<%=request.getParameter("LineNo")%>"].value=listnam;
			window.opener.parent.document.forms[0].drinfochk_inp ["CcMlType<%=request.getParameter("LineNo")%>"].value=mltype;
			window.opener.parent.document.forms[0].drinfochk_inp ["CcMlIdList<%=request.getParameter("LineNo")%>"].value=idlist;
			window.opener.parent.document.forms[0].drinfochk_inp ["CcMlNamList<%=request.getParameter("LineNo")%>"].value=namlist;
			window.opener.parent.document.forms[0].drinfochk_inp ["CcMlAddrList<%=request.getParameter("LineNo")%>"].value=addrlist;
			window.opener.parent.document.forms[0].drinfochk_inp ["CcMlIdCnt<%=request.getParameter("LineNo")%>"].value=idcnt;
			window.opener.parent.document.forms[0].drinfochk_inp ["CcMlAddrCnt<%=request.getParameter("LineNo")%>"].value=addrcnt;
			
			window.opener.mltb_dsp(<%=request.getParameter("LineNo")%>);
			window.opener.mail_dsp(<%=request.getParameter("LineNo")%>);
		}else if( g_pageno ==270 ) {
			window.opener.parent.document.forms[0].drinfoapv_inp ["CcMlNo<%=request.getParameter("LineNo")%>"].value=listno;
			window.opener.parent.document.forms[0].drinfoapv_inp ["CcMlNam<%=request.getParameter("LineNo")%>"].value=listnam;
			window.opener.parent.document.forms[0].drinfoapv_inp ["CcMlType<%=request.getParameter("LineNo")%>"].value=mltype;
			window.opener.parent.document.forms[0].drinfoapv_inp ["CcMlIdList<%=request.getParameter("LineNo")%>"].value=idlist;
			window.opener.parent.document.forms[0].drinfoapv_inp ["CcMlNamList<%=request.getParameter("LineNo")%>"].value=namlist;
			window.opener.parent.document.forms[0].drinfoapv_inp ["CcMlAddrList<%=request.getParameter("LineNo")%>"].value=addrlist;
			window.opener.parent.document.forms[0].drinfoapv_inp ["CcMlIdCnt<%=request.getParameter("LineNo")%>"].value=idcnt;
			window.opener.parent.document.forms[0].drinfoapv_inp ["CcMlAddrCnt<%=request.getParameter("LineNo")%>"].value=addrcnt;
			
			window.opener.mltb_dsp(<%=request.getParameter("LineNo")%>);
			window.opener.mail_dsp(<%=request.getParameter("LineNo")%>);
	
		}else if( g_pageno==310 ) {// drinfomp_inp(正常にうごく)
			window.opener.parent.document.forms[0].drinfomp_inp ["CcMlNo<%=request.getParameter("LineNo")%>"].value=listno;
			window.opener.parent.document.forms[0].drinfomp_inp ["CcMlNam<%=request.getParameter("LineNo")%>"].value=listnam;
			window.opener.parent.document.forms[0].drinfomp_inp ["CcMlType<%=request.getParameter("LineNo")%>"].value=mltype;
			window.opener.parent.document.forms[0].drinfomp_inp ["CcMlIdList<%=request.getParameter("LineNo")%>"].value=idlist;
			window.opener.parent.document.forms[0].drinfomp_inp ["CcMlNamList<%=request.getParameter("LineNo")%>"].value=namlist;
			window.opener.parent.document.forms[0].drinfomp_inp ["CcMlAddrList<%=request.getParameter("LineNo")%>"].value=addrlist;
			window.opener.parent.document.forms[0].drinfomp_inp ["CcMlIdCnt<%=request.getParameter("LineNo")%>"].value=idcnt;
			window.opener.parent.document.forms[0].drinfomp_inp ["CcMlAddrCnt<%=request.getParameter("LineNo")%>"].value=addrcnt;
			// 
			window.opener.mltb_dsp(<%=request.getParameter("LineNo")%>);
			window.opener.mail_dsp(<%=request.getParameter("LineNo")%>);
		}
	}
	if(window.opener){
		window.opener.focus();
	};
	window.close();
}// end of function mail_set

//-->
</script>

</body>
</html>


<%
objSql.close();
db.close();
%>

<!-- *************************** end of mail_link.jsp ************************************* -->