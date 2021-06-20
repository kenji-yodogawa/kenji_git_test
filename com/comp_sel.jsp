<!--******************************************************
		＜会社選択＞
		File Name :comp_sel.jsp　（com） sys/meuser_inp.jspで利用
		　　　　（ほかには、personal/psoffice_inp、pspost_inp）
		Auther	:k-mizuno
		Date	:2006-06-13
		       2014-01-04 kaneshi 整理,改行インデント整理,CSS整理　
		       2014-05-29 kaneshi CSS外部化
		       2015-01-06 kaneshi 高速化,文字コードをutf-8へ
		       2016-01-04 kaneshi var d = document.all　利用で簡素化
********************************************************* -->

<%@ page contentType="text/html;charset=UTF-8"
	import="java.sql.*,java.io.*,java.net.*, java.util.*,java.text.*"%>

<% String strRight=""; %>
<%@ include file="../header_utf8.jsp"%>

<%
StringBuilder sbTmp = new StringBuilder();

String strCompSc=request.getParameter("CompSc");

if(strCompSc==null){
	strCompSc="";
}
%>

<html>
<head>
<title>会社選択</title>
<meta http-equiv="Content-Style-Type" content="text/css">
<link href="../com/mierucchics.css" rel="stylesheet" type="text/css">
</head>

<body onBlur="focus()">
<table class="header">
<tr><th>会社選択</th></tr>
</table>
<br>

<form name="comp_sel" action="comp_sel.jsp" method="POST">
<div align="center">
<table class="basetable">
	<tr><th>会社名</th>
		<td><input name="CompSc" style="ime-mode:active" value="<%=strCompSc%>" size="50"
		    onblur="trimall(this);"
		    onchange="trimall(this)">
		</td>
		<td>
		 <input name="Search" type="submit" value="検索">
		</td>
	</tr>
</table>
<br>

<%if(!strCompSc.equals("")){%>
	<table class="baselist">
		<tr>
			<td>
	<%
	ResultSet rsCompList=objSql.executeQuery(
		sbTmp
		.append(" select compcd,compnam from pscomp")
		.append(" where CompNam like '%") .append(strCompSc) .append("%'")
		.append(" and Invalid=''")
		.append(" order by CompNam")
		.toString()
		);
	sbTmp.delete(0,sbTmp.length());

	String strCompIdList=""	;
	while(rsCompList.next()){
		String x0 =rsCompList.getString("CompCd");
		String x1 =rsCompList.getString("CompNam");
	%>
	     <a href="javaScript:comp_set('<%=x0%>','<%=x1%>','<%=x1%>');">
	       <%=x1%>
	     </a>
	     <br>
	<%}
	rsCompList.close();
	%>
			</td>
		</tr>
	</table>
<%}// end of if(!strCompSc.equals(""))%>

<% if(request.getParameter("OpnProg")!=null){ %>
	<input name="OpnProg" type="hidden" value="<%=request.getParameter("OpnProg")%>">
<% } %>
</div>
</form>

<script type="text/javaScript">
<!--
document.forms[0].CompSc.focus();

function comp_set(id,nm){
  if(window.opener.name=="fr_main"){
  }else{
	  var g_pageno = window.opener.parent.g_pageno;
	  var d = window.opener.parent.document.all;//2016-01-04

    if(g_pageno == 110 ) {
      d.meuser_inp.CompCd.value=id;
      d.meuser_inp.CompNam.value=nm;
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

<!-- ********************************  end of comp_sel.jsp ******************************* -->