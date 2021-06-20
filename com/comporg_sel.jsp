<!----------------------------------------------------------
	システム事業部
	みえるっち
		＜組織選択＞
		File Name :comporg_sel.jsp　（com内、apluser_inp.jsp から呼ばれるSubW）
		Auther	:k-mizuno
		Date	:2006-06-16
		       2014-01-04  kaneshi,CSS整理、改行インデント整理、アラーム除去
		                   html5へ修正
		       　　　　　　エンターキーで検索開始、入力キーをトリム
----------------------------------------------------------->

<%@ page contentType="text/html;charset=Windows-31J"
	import="java.sql.*,java.io.*,java.net.*, java.util.*,java.text.*"%>

<% String strRight=""; %>
<%@ include file="../header.jsp"%>

<%
String strSosikiSc=request.getParameter("SosikiSc");

if(strSosikiSc==null){
	strSosikiSc="";
}
%>
<!DOCTYPE html> <!-- 　2014-01-04追加　kaneshi -->
<html>
<head>
<title>組織選</title>
<style><!--
  html {
     overflowX:auto;
  }

  table.header {
    background-color:#4600BB; 
    width:100%
  }  
  table.header th{
    cellspacing:0;
    cellpadding:3;
    color  :#FFFFFF;
    font-size:large;
  }

  table.content0 {
    margin-left:auto;
    margin-right:auto;
    border-collapse :collapse;
    background-color:#F9FBE0;
    border      :0px;
  }
  table.content0 th,td {
    cellpadding   :0;
    cellspacing   :0;
    white-space   :nowrap;
    border      :ridge 1px ;
  }
  table.content0 th{
    text-align    :center;
    background-color:lightslategray;
    font-weight   :bold;
    border-color  :white;
    color     :mintcream;
  }
  table.content0 td{
    border      :ridge 1px white;
    background-color:lavender;
    text-align    :left;
  }
//-->
</style>
</head>

<body bgcolor="#F9FBE0" onload="document.forms[0].SosikiSc.focus();">
<table class="header">
<tr><th>組織選択</th></tr>
</table>
<br>

<form name="comporg_sel" action="comporg_sel.jsp" method="POST">
<div align="center">

<table class="content0">
	<tr>
		<th>組織名</th>
		<td>
		  <input name="SosikiSc" style="ime-mode:active" value="<%=strSosikiSc%>" size="50"
		       onblur="trimall(this);"
           onchange="trimall(this)">
		</td>
		<td>
		   <input name="Search" type="submit" value="検索">
		</td>
	</tr>
</table>
<br>

<% 
String sQry = 
    "select * from meorg "
  + " where ToDate=''"
	+ " and (OrgFulNam like '%" + strSosikiSc + "%'"
	+ " or OrgNam like '%" + strSosikiSc + "%')"
	+ " and (OrgType='3' or OrgType='2')" //2014-01-04修正 kaneshi　以前は(OrgType=3 or OrgType=2)
	+ " order by SortNo";

if(!strSosikiSc.equals("")){
	ResultSet rsOrgList=objSql.executeQuery(sQry);
	String strOrgIdList=""	;
	while(rsOrgList.next()){
		strOrgIdList+="," + rsOrgList.getString("OrgId")	;
	}
	
	%>
	<table class="content0">
	<tr>
		<td>
		<%
	StringTokenizer orTkn=new StringTokenizer(strOrgIdList,",")	;
	while(orTkn.hasMoreTokens()){
		ResultSet rsOrg=objSql.executeQuery(
				"select * from meorg() "
		   +" where OrgId=" + Integer.parseInt(orTkn.nextToken()))	;
		rsOrg.next()	;
		
		String strOrgId    =rsOrg.getString("OrgId")	;
		String strOrgFulNam=rsOrg.getString("OrgFulNam")	;
		int intLevelNo     =rsOrg.getInt("LevelNo")	;
		int intDwdOrg=0	;
		if(request.getParameter("OrgOnly")==null){
			strQuery=""	;
			for(int j=intLevelNo; j<10; j++){
				if(!strQuery.equals("")){
					strQuery+=" or "	;
				}
				strQuery+="OrgId" + (j+1) + "!=0"	;
			}
			if(!strQuery.equals("")){
				strQuery="and (" + strQuery + ")"	;
			}
			
			ResultSet rsDwdOrg=objSql.executeQuery(
					"select count(*) as count from meorg"
				+ " where OrgId" + intLevelNo + "=" + Integer.parseInt(strOrgId)
				+ strQuery
				)	;
			rsDwdOrg.next()	;
			intDwdOrg=rsDwdOrg.getInt("count")	;
      String x = strOrgFulNam+"全体";
      String y = strOrgFulNam+"直轄";
      String z = strOrgFulNam;

			if(intDwdOrg>0 && request.getParameter("ComOrg")!=null){
			%> <a href="javaScript:org_set('<%="C"+strOrgId%>','<%=x%>');">
			     <%=x%>
			   </a><br>
				 <a href="javaScript:org_set('<%=strOrgId%>','<%=y%>');">
				   <%=y%>
				 </a><br>
						<% }else{ %> 
				 <a href="javaScript:org_set('<%=strOrgId%>','<%=z%>');">
				    <%=z%>
				 </a><br>
						<%
			}
		}
	}
	%>
		</td>
	</tr>
	</table>
<%}%>

<% if(request.getParameter("OpnProg")!=null){ %>
  <input name="OpnProg" type="hidden"
	 value="<%=request.getParameter("OpnProg")%>">
<% } %>
<% if(request.getParameter("Line")!=null){ %>
  <input name="Line" type="hidden"
  	value="<%=request.getParameter("Line")%>">
<% } %>
<% if(request.getParameter("OrgOnly")!=null){ %>
  <input name="OrgOnly" type="hidden"
	 value="<%=request.getParameter("OrgOnly")%>">
<% } %>

</div>
</form>

<script type="text/javaScript">
<!--
//document.forms[0].SosikiSc.focus();//<body onload="へ移した。

function org_set(id,fnm){
  if(window.opener.name=="fr_main"){
    if(window.opener.parent.fr_main.g_pageno == 130 ) {
      window.opener.parent.fr_main.document.apluser_inp.RealOrgId.value =id;
      window.opener.parent.fr_main.document.apluser_inp.OrgFulNam.value = fnm;
    }
  }else{
    if(window.opener.parent.g_pageno == 130 ) {
      window.opener.parent.document.apluser_inp.RealOrgId.value=id;
      window.opener.parent.document.apluser_inp.OrgFulNam.value=fnm;
    }
  }
  window.opener.focus();
  window.close();
}

function trimall(a){
    a.value = a.value.toUpperCase();
    //半角、全角スペースをトリム
    a.value = a.value.replace(/^[ 　]+/,"").replace(/[ 　]+$/,"");
}
//-->
</script>

</body>
</html>

<%
objSql.close();
db.close();
%>

<!------------------------------ End of comporg_sel.jsp ------------------------------>