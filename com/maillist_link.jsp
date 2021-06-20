<!-- ********************************************************
	＜回覧先リスト＞　複数選択
	File Name :maillist_link.jsp 　 
	呼出元：drinfo_inp.jsp
	     これは主にサブウィンドウからよばれるやつだ
	Author	:k-mizuno
	Date	:2006-08-07
	
	Update
	2015-01-06 kaneshi 不在になった人の赤色表示を復活させる
	2015-01-07 kaneshi メンバの欄は折り返し表示にした
	2015-02-23 kaneshi StringBuilderで高速化, 画面resizeTo追加
	2015-03-16 kaneshi resizeToの修正
	2015-07-15 kaneshi PreparedStatementで高速化,文字コードをＵＴＦ－８へ
	2016-01-04 kaneshi var d = document.allで簡素化
	2016-04-09 kaneshi StringBuilder化　徹底
	2016-05-29 kaneshi SQLへセットするパラメータ減
	2016-07-26 kaneshi PreparedStatementの行数節約
	2016-09-22 kaneshi StringBuilder化再徹底
	2016-10-14 kaneshi concat -> append
	2018-04-04 kaneshi コード整理、内容変更はなし
********************************************************* -->

<%@ page contentType="text/html;charset=UTF-8"
	import="java.io.*,java.sql.*,java.net.*,java.util.*,java.text.*"%>

<% String strRight="USER"; %>
<%@ include file="../header_utf8.jsp"%>
<%if(request.getParameter("despatch")==null){%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
<link href="../com/mierucchics.css" rel="stylesheet" type="text/css">
<title>回覧先リスト</title>
</head>

<body onBlur="focus();">
<form name="maillist_link" action="maillist_link.jsp" method="post">
  <div align="center">
			<br> <br>
			<input name='despatch' type='hidden' value=''>
			<div id='request'></div>
	</div>
</form>

<script type="text/javaScript">
	<!--
	doc = "";
	var mlcnt = window.opener.document [window.opener.bodyNam].MlCnt.value * 1;

	for(var i=0; i < mlcnt; i++) {
		doc += "<input name='CcMlNo"+i+"' type='hidden' "
			+" value='"+ window.opener.document [window.opener.bodyNam] ['CcMlNo'+ i].value+"'>";
	}
	doc += "<input name='MlCnt' type='hidden' "
			+" value='"+ window.opener.document [window.opener.bodyNam].MlCnt.value + "'>";
	document.getElementById("request").innerHTML = doc;
	document.forms[0].submit();
	//-->
	</script>
</body>
</html>

<%
}else{
	HashMap<Integer, Integer> mlNoHashMap = new HashMap<Integer, Integer>();
	int mlcnt = Integer.parseInt(request.getParameter("MlCnt"));

	for(int i=0; i < mlcnt; i++) {
		mlNoHashMap.put(
				Integer.parseInt(request.getParameter("CcMlNo" + i))
				,Integer.parseInt(request.getParameter("CcMlNo" + i)));
	}
	%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
<link href="../com/mierucchics.css" rel="stylesheet" type="text/css">
<title>回覧先リスト</title>
</head>

<body onBlur="focus()">
<table class="header">
<tr><th>回覧先リスト</th></tr>
</table>

<form name="maillist_link" action="maillist_link.jsp" method="post">
<div align="center">

<br style="line-height:0.3em;">
<input type='button' value=' S E T ' onClick='mail_set()'>
<br style="line-height:0.3em;">
<table class="baselist">
<tr>
	<th>選択</th>
	<th>名称</th>
	<th>メンバ</th>
	<th>メーリングリスト</th>
	<th>管理者</th>
</tr>

	<%
	StringBuilder sbTmp = new StringBuilder();

	PreparedStatement ps0=null;
	PreparedStatement ps1=null;
	PreparedStatement ps2=null;

	ArrayList<Integer> listNoList=new ArrayList<Integer>();

	ResultSet rsList=objSql.executeQuery(sbTmp
		.append(" select listNo from maillist ")
		.append(" order by AdmUserId,ListNo")
		.toString());sbTmp.delete(0,sbTmp.length());
	while(rsList.next()){
		listNoList.add(rsList.getInt("ListNo"));
	}
	rsList.close();

	int listnosize = listNoList.size();
	for(int i=0; i<listnosize; i++){

		if(ps0 == null){ps0 =db.prepareStatement(sbTmp
			.append(" select listnam,admuserid,admorgid,orglist,userlist,maillist,mailtype ")
			.append(" from maillist ")
			.append(" where ListNo=?")
			.toString());sbTmp.delete(0,sbTmp.length());
		}
		ps0.setInt(1, Integer.valueOf(listNoList.get(i)));
		ResultSet rsDat = ps0.executeQuery();

		rsDat.next();
		String strListNam     =rsDat.getString("ListNam");
		String strAdmUserId   =rsDat.getString("AdmUserId");
		String strAdmOrgId    =rsDat.getString("AdmOrgId");
		String strOrgIdList   =rsDat.getString("OrgList");
		String strUserIdList  =rsDat.getString("UserList");
		String strMailList    =rsDat.getString("MailList");
		String strMailType    =rsDat.getString("MailType");
		String strCcMlAddrList=rsDat.getString("MailList");
		rsDat.close();

		StringBuilder sbCcMlUserNoList=new StringBuilder();
		StringBuilder sbCcMlUserNamList=new StringBuilder();
		
		if(ps1 == null){ps1 =db.prepareStatement(sbTmp
			.append(" select userNam,toDate ")
			.append(" from meuser")
			.append(" where UserId=?")
			.append(" and RealOrgId=?")
			.append(" and FromDate=(select max(FromDate) from meuser as m")
			.append("                where UserId=meuser.UserId")
			.append("                  and RealOrgId=meuser.RealOrgId )")
			.toString());sbTmp.delete(0,sbTmp.length());
		}
		ps1.setString(1,strAdmUserId);
		ps1.setInt(2, Integer.valueOf(strAdmOrgId));
		ResultSet rsAdmUser = ps1.executeQuery();

		rsAdmUser.next();
		StringBuilder sbAdmNam = new StringBuilder();
		sbAdmNam   .append(rsAdmUser.getString("UserNam"));
		String strAdmToDate=rsAdmUser.getString("ToDate");

		if(!rsAdmUser.getString("ToDate").equals("")){
			sbAdmNam .insert(0,"<span style='color:red;'>")  .append("</span>");
		}
		rsAdmUser.close();

		StringBuilder sbUserList=new StringBuilder();
		StringTokenizer usTkn=new StringTokenizer(strUserIdList,",");
		StringTokenizer ogTkn=new StringTokenizer(strOrgIdList,",");

		while(usTkn.hasMoreTokens()){
			String strUserId=usTkn.nextToken();
			String strOrgId=ogTkn.nextToken();
			
			if(ps2 == null){ps2 =db.prepareStatement(sbTmp
				.append(" select todate,usernam,userno ")
				.append(" from meuser")
				.append(" where UserId=?")
				.append(" and RealOrgId=?")
				.append(" and FromDate=(select max(FromDate) from meuser as m")
				.append("                where UserId=meuser.UserId")
				.append("                 and RealOrgId=meuser.RealOrgId )")
				.toString());sbTmp.delete(0,sbTmp.length());
			}
			ps2.setString(1,strUserId);
			ps2.setInt(2, Integer.valueOf(strOrgId));
			ResultSet rsUser = ps2.executeQuery();

			while(rsUser.next()){
				String strFontColor="black";
				if(rsUser.getString("ToDate") != null){

					if(!rsUser.getString("ToDate").equals("")){
						strFontColor="red";
					}
					if(sbUserList.length()==0){
						sbUserList 
						.append("<span style='color:") .append(strFontColor) .append("'>") 
						.append(rsUser.getString("UserNam")) .append("</span>");

						if(rsUser.getString("todate").equals("")){
							sbCcMlUserNoList .append(rsUser.getString("UserNo"));
							sbCcMlUserNamList .append(rsUser.getString("UserNam"));
						}
					}else{
						sbUserList 
						.append(" ,<span style='color:") .append(strFontColor) .append("'>") 
						.append(rsUser.getString("UserNam")) .append("</span>")
						;
						if(rsUser.getString("ToDate").equals("")){
							sbCcMlUserNoList  .append(",") .append(rsUser.getString("UserNo"));
							sbCcMlUserNamList .append(",") .append(rsUser.getString("UserNam"));
						}
					}
				}
			}
			rsUser.close();
		}

		String checked = "";
		if(mlNoHashMap.get(listNoList.get(i)) != null) {
			checked = "checked";
		}
		%>
<tr>
	<td><input name='listno<%=i%>' type='checkbox' value='<%=listNoList.get(i)%>' <%=checked%>>
	</td>
	<td><%=strListNam%></td>
	<td style="white-space:normal;"><%=sbUserList.toString()%></td>
	<%sbUserList.delete(0,sbUserList.length());%>
	<td><%=strMailList%><br></td>
	<%strMailList=null;%>
	<td><%=sbAdmNam.toString()%><br>
	<%sbAdmNam.delete(0,sbAdmNam.length());%>
	<input name='listnam<%=i%>' type='hidden' value='<%=strListNam%>'>
	<%strListNam=null;%>
	<input name='listtype<%=i%>' type='hidden' value='<%=strMailType%>'>
	<%strMailType=null;%>
	<input name='listuserno<%=i%>' type='hidden' value='<%=sbCcMlUserNoList.toString()%>'>
	<%sbCcMlUserNoList.delete(0,sbCcMlUserNoList.length());%>
	<input name='listusernam<%=i%>' type='hidden' value='<%=sbCcMlUserNamList.toString()%>'>
	<%sbCcMlUserNamList.delete(0,sbCcMlUserNamList.length());%>
	<input name='listuseraddr<%=i%>' type='hidden' value='<%=strCcMlAddrList%>'>
	<%strCcMlAddrList=null;;%>
  </td>
</tr>
<%}%>
</table>

<input name='listcnt' type='hidden' value='<%=listNoList.size()%>'>
</div>
</form>

<script type="text/javaScript" src="../com/com_utf8.js"></script>
<script type="text/javaScript">
<!--
moveTo(10,10);
resizeTo(900,screen.availHeight);

function mail_set(){

	arrayWinMlNo = new Array();
	arrayWinMlNam = new Array();
	arrayWinMlType = new Array();
	arrayWinMlUserNo = new Array();
	arrayWinMlUserNam = new Array();
	arrayWinMlAddr = new Array();
	count = 0;
	var d = document.all;
	var listcnt = d.listcnt.value;

	for(var i=0; i < listcnt; i++) {
		if(d ['listno' + i].checked == true) {
			arrayWinMlNo[count] = d ['listno' + i].value;
			arrayWinMlNam[count] = d ['listnam' + i].value;
			arrayWinMlType[count] = d ['listtype' + i].value;
			arrayWinMlUserNo[count] = d ['listuserno' + i].value;
			arrayWinMlUserNam[count] = d ['listusernam' + i].value;
			arrayWinMlAddr[count] = d ['listuseraddr' + i].value;
			count ++;
		}
	}
	window.opener.mltb_dsp(arrayWinMlNo, arrayWinMlNam, arrayWinMlType, arrayWinMlUserNo, arrayWinMlUserNam, arrayWinMlAddr);
	if(window.opener){
		window.opener.focus();
	};
	window.close();
}


//-->
</script>
</body>
</html>

<%}%>

<%
objSql.close();
db.close();
%>

<!-- ******************************** End of maillist_link.jsp **********************************-->