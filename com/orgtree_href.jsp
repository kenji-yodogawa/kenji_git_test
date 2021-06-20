<!-- ******************************************************
	＜組織表＞ in みえるっち
	File Name :orgtree_href.jsp (com)
	           呼出元：drinfo_inp.jsp 管理部署
	Author	:k-mizuno
	Date	:2009-09-17

	Update
	2014-03-15 kaneshi 全般整理　
	　　　　　　　　　out.printlnでだすタグと混在させると、エラー認識が変
	2014-11-04 kaneshi　sql select * をカラム指定
	　　　　　　　　　　ResultSetを読んだらすぐ閉じる。
	2014-01-05 kaneshi for文の上限値を再計算しない処理
	　　　　　　　　　　タグエラーを除去
	2015-02-17 kaneshi StringBuilder とString#concatで高速化
	2015-11-30 kaneshi com_uft8.js→com.utf8.jsへミスの修正
	2016-04-09 kaneshi StringBuilder化徹底
	2016-09-21 kaneshi StringBuilder化再徹底
	2016-10-14 kaneshi concat -> append
	2017-12-18 kaneshi テーブル結合を　left join へ
	2018-01-09 kaneshi テーブル結合前に絞り込み 
	2018-02-16 kaneshi 上記の強化
	2018-03-29 kaneshi SQL検索条件のtodateの優先度アップ
         
********************************************************* -->

<%@ page contentType="text/html;charset=UTF-8"
	import="java.io.*,java.sql.*,java.net.*,java.util.*,java.text.*"%>

<% String strRight="USER"; %>
<%@ include file="../header_utf8.jsp"%>

<%
StringBuilder sbQry = new StringBuilder();
StringBuilder sbTmp = new StringBuilder();
StringBuilder sbOrg = new StringBuilder();

ArrayList<Integer> orgIdList = new ArrayList<Integer>();
ArrayList<String> orgNamList = new ArrayList<String>();
ArrayList<String> upOrgCsvList = new ArrayList<String>();
ArrayList<Integer> chkOrgIdList = new ArrayList<Integer>();
ArrayList<Integer> dspLevelNoList = new ArrayList<Integer>();
ArrayList<Integer> downwardFlagList = new ArrayList<Integer>();

 sbQry
 .append(" SELECT M.orgid,M.orgnam,M.levelno,M.sortno ")
 .append(" FROM (select orgid from orgright")
 .append("        where righttype='USER' ")
 .append("      ) as R ")
 .append(" left join (select orgid,orgnam,levelno,sortno,todate,fromdate from meorg ")
 .append("           ) as M ")
 .append("   on R.orgid = M.orgid ")
 .append("   and (M.todate='' or M.todate>='") .append(strNowDate) .append("') ")
 .append("   and M.fromdate<= '") .append(strNowDate) .append("' ")
 .append(" where M.orgid is not null ")
 .append(" ORDER BY levelno,sortno ")
 ;

/// クエリーを実行して結果セットを取得
ResultSet rsOrgList = objSql.executeQuery(sbQry.toString());
sbQry.delete(0,sbQry.length());

/// 取得データの設定(検索された行数分ループ)
while(rsOrgList.next()){
	downwardFlagList.add(0);
	dspLevelNoList.add(0);
	orgIdList.add(rsOrgList.getInt("orgid"));
	orgNamList.add(rsOrgList.getString("orgnam"));
	upOrgCsvList.add(rsOrgList.getString("orgid"));

  if(sbOrg.length()==0) {
    sbOrg.append(" realorgid = ") .append(rsOrgList.getInt("orgid"));
  } else {
	  sbOrg.append(" or realorgid = ") .append(rsOrgList.getInt("orgid"));
  }
}
rsOrgList.close();

PreparedStatement ps0=null;
PreparedStatement ps1=null;

for(int i=0; i < orgIdList.size(); i++) {//処理途中でaddがあり
	/// SQL
	if(ps0 == null){ps0 =db.prepareStatement(sbTmp
		.append(" SELECT orgid,orgnam,levelno,sortno ")
		.append(" FROM meorg ")
		.append(" WHERE uporgid = ? ")
		.append(" AND  (todate='' or todate>='") .append(strNowDate) .append("') ")
		.append(" AND  fromdate<= '") .append(strNowDate) .append("'")
		.append(" ORDER BY levelno DESC,sortno DESC ")
		.toString());sbTmp.delete(0,sbTmp.length());
	}
	ps0.setInt(1, Integer.valueOf( orgIdList.get(i)));
	ResultSet rs = ps0.executeQuery();

	/// 取得データの設定(検索された行数分ループ)
	while(rs.next()){
		if(downwardFlagList.get(i) == 0) {
			downwardFlagList.remove(i);
			downwardFlagList.add(i, 1);
		}
		downwardFlagList.add((i + 1), 0);
		dspLevelNoList.add((i + 1), dspLevelNoList.get(i) + 1);
		orgIdList.add((i + 1), rs.getInt("orgid"));
		orgNamList.add((i + 1), rs.getString("orgnam"));
		upOrgCsvList.add(
				(i + 1)
				, sbTmp .append(upOrgCsvList.get(i)) .append(",") .append(rs.getInt("orgid")) .toString());
		sbTmp.delete(0,sbTmp.length());
       sbOrg.append(" or realorgid = ") .append(rs.getInt("orgid"));
	}
	rs.close();
}

if(request.getParameter("from").indexOf("User") >= 0) {
	objSql.executeUpdate(sbTmp
		.append(" select * into temp tempuser ")
		.append(" from meuser")
		.append(" where (todate = '' or todate >= '") .append(strNowDate) .append("')")
		.append(" and (") .append(sbOrg) .append(")")
		.append(" and fromdate <= '") .append(strNowDate) .append("'")
		.toString());sbTmp.delete(0,sbTmp.length());
		
	sbOrg.delete(0,sbOrg.length());
}
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
<link href="../com/mierucchics.css" rel="stylesheet" type="text/css">
<title>組織表</title>
</head>

<body onBlur="focus()">
<table class="header">
<%if(request.getParameter("from").indexOf("User") < 0) {%>
<tr><th>組織選択</th></tr>
<%} else {%>
<tr><th>メンバ選択</th></tr>
<%}%>
</table>

<br style="line-height:0.4em;">

<form name="orgtree_href" action="orgtree_href.jsp" method="post">
<div style="text-align:center;">

<input name='despatch' type='hidden' value=''>
<input name='from' type='hidden' value='<%=request.getParameter("from")%>'>

<table class="noborder" >
<tr><td style="text-align:left">
<table class="noborder" id='0'>

<%
int tableNo = 1;
int userCounter = 0;
int[] tableNoByLevel = new int[50];
Arrays.fill(tableNoByLevel, 0);
StringBuilder sbTableList = new StringBuilder();

int orgidlistsize = orgIdList.size();
for(int i = 0; i < orgidlistsize; i++) {
    	if(i == 0 || dspLevelNoList.get(i) == dspLevelNoList.get(i - 1)) {
    		%><tr><%
    		if(i < orgIdList.size() - 1
    				&& dspLevelNoList.get(i + 1) > dspLevelNoList.get(i)) {
	    		%>
	    		<td id='downwardMark" + (tableNo + 1) + "'>
	    		<a href = 'javaScript:clickPlus(" + (tableNo + 1) + ")'>＋</a>
	    		<%
	    		sbTableList .append(",") .append(tableNo + 1);
    		} else {%>
    			<td>
    			<img style='border:0px;width:5px;height:0px;' src='../img/trans.gif'>
    		<%
    		}%>
    		</td>
    		<td style='vertical-align:top;'>
    		<%
    	} else if(dspLevelNoList.get(i) > dspLevelNoList.get(i - 1)) {
    	%>
    		<tr>
    		<td><img style='border:0px;width:5px;height:0px;' src='../img/trans.gif'></td>
    		<td style='vertical-align:top;' colspan='4'>
    		<%
    		int desplevelnodeff0 = dspLevelNoList.get(i) - dspLevelNoList.get(i - 1);
    		for(int j=0; j < desplevelnodeff0; j++) {
    			tableNo ++;
    			tableNoByLevel[dspLevelNoList.get(i)] = tableNo;
        	%>
        	<table class='noborder' id='" + tableNo + "'>
        	<tr>
        	<%
    			if(j == desplevelnodeff0 - 1) {
    				if(i < orgIdList.size() - 1 && dspLevelNoList.get(i + 1) > dspLevelNoList.get(i)) {%>
	    		    <td id='downwardMark" + (tableNo + 1) + "'>
	    		    <a href = 'javaScript:clickPlus(" + (tableNo + 1) + ")'>＋</a>
	    		    <%
		    	    sbTableList .append(",") .append(tableNo + 1);
	    			} else {%>
    					<td>
    					<img style='border:0px; width:5px; height:0px;' src='../img/trans.gif'>
    				<%}%>
             </td>
          <%
    			} else {%>
    				<td><img style='border:0px; width:5px; height:0px;' src='../img/trans.gif'></td>
    				<%
    			}
    			%><td style='vertical-align:top;'>
    			<%
    		}
    	} else {
    		int dsplevelnodeff = dspLevelNoList.get(i - 1) - dspLevelNoList.get(i);
    		for(int j=0; j < dsplevelnodeff; j++) {
        	%>
        	</table>
        	</td>
        	</tr>
        	<%
    		}
    		%><tr>
    		<%
    		if(i < orgIdList.size() - 1
    				&& dspLevelNoList.get(i + 1) > dspLevelNoList.get(i)) {
          %>
          <td id='downwardMark" + (tableNo + 1) + "'>
          <a href = 'javaScript:clickPlus(" + (tableNo + 1) + ")'>＋</a>
          <%
          		sbTableList .append(",") .append(tableNo + 1);
    		} else {
    			%>
    			<td><img style='border:0px; width:5px; height:0px;' src='../img/trans.gif'>
    			<%
    		}
    		%>
    		</td>
    		<td style='vertical-align:top;'>
    		<%
    	}
	if(request.getParameter("from").indexOf("User") < 0) {
		out.println(sbTmp
		   .append("<a href = 'javaScript:orgClick(") .append(i) .append(")'>")
		   .append(orgNamList.get(i)) .append("</a>"));
		sbTmp.delete(0,sbTmp.length());
	} else {

		out.println(orgNamList.get(i));
		out.println("　　　");
		if(ps1 == null){ps1 =db.prepareStatement(sbTmp
			.append(" select T.bossFlg,T.stylecd,T.statuscd,T.userno,T.usernam,T.postnam")
			.append(",S.compcd ")
			.append(" from (select * ") 
			.append("       from tempuser ")
			.append("       where realorgid = ? ")
			.append("         and (todate = '' or todate >= '") .append(strNowDate) .append("')")
			.append("         and fromdate <= '") .append(strNowDate) .append("'")
			.append("      ) as T ")
			.append(" left join (select styleCd,compcd from psstyle ")
			.append("           ) as S ")
			.append("   on T.stylecd = S.stylecd")
			.append(" where S.stylecd is not null ")
			.append(" order by bossflg desc, stylecd, statuscd")
			.toString());sbTmp.delete(0,sbTmp.length());
		}
		ps1.setInt(1, Integer.valueOf( orgIdList.get(i)));
		ResultSet rsUser = ps1.executeQuery();

		HashMap<String, String> userNamHashMap = new HashMap<String, String>();
		while(rsUser.next()) {
   			String userNo  =rsUser.getString("userno");
   			String stylecd =rsUser.getString("stylecd");
   			String userNam =rsUser.getString("usernam");
   			String postNam =rsUser.getString("postnam");

   			userNam = sbTmp .append(userNam.substring(0,userNam.indexOf(" "))) .append(postNam)
   					.toString();sbTmp.delete(0,sbTmp.length());
   			if(userNamHashMap.get(userNam) != null) {
    			userNam = sbTmp .append(userNam) .append(postNam) 
    					.toString();sbTmp.delete(0,sbTmp.length());
   			}
   			%>
			<a href="userClick('<%=userCounter%>');"><%=userNam%></a>
			<input name='userNo<%=userCounter%>' type='hidden' value='<%=userNo%>'>
			<input name='userNam<%=userCounter%>' type='hidden' value='<%=userNam%>'>
			<input name='userOrgId<%=userCounter%>' type='hidden' value='<%=orgIdList.get(i)%>'>
			<input name='userOrgNam<%=userCounter%>' type='hidden' value="<%=orgNamList.get(i)%>">
			<input name='userUpOrgCsv<%=userCounter%>' type='hidden' value='<%=upOrgCsvList.get(i)%>'>
			<%
			userCounter ++;
	    }
		rsUser.close();
	}
	%>
	  </td>
	  </tr>
	<%
  	if(i == orgIdList.size() - 1) {
  		int dsplevelnolisti =  dspLevelNoList.get(i);
  		for(int j=0; j < dsplevelnolisti; j++) {
       %>
         </table>
        </td>
        </tr>
       <%
  		}
  	}
	%>
	<input name='orgId<%=i %>' value='<%= orgIdList.get(i)%>' type='hidden'>
	<input name='orgNam<%=i %>' value='<%= orgNamList.get(i)%>' type='hidden'>
	<input name='upOrgCsv<%=i %>' value='<%= upOrgCsvList.get(i)%>' type='hidden'>
	<input name='downwordFlg<%=i %>' value='<%= downwardFlagList.get(i)%>' type='hidden'>
	<%
}
%>
</table>

<input name='tableList' type='hidden' value='<%=sbTableList.toString()%>'>
<input name='bodyNam' type='hidden' value='<%=request.getParameter("bodyNam")%>'>
<br style="line-height:0.4em;">

<input type='button' value='　SET　' onClick='setRight();'>

</div>
</form>

<script type="text/javaScript" src="../com/com_utf8.js"></script>
<script type="text/javaScript">
<!--
tableClear();
var d = document.all;

function tableClear() {
	var tablelen = document.forms[0].tableList.value.split(",").length;

	for(var i=0; i < tablelen; i++) {
		var tsi = tableSplit[i];
		if(tsi != '') {
			document.getElementById(tsi).style.display = 'none';
		}
	}
}

function clickPlus(nextNo) {
	document.getElementById('downwardMark' + nextNo).innerHTML
	      = "<a href = 'javaScript:clickMinus(" + nextNo + ")'>－</a>";
	document.getElementById(nextNo).style.display = 'block';
}

function clickMinus(nextNo) {
	document.getElementById('downwardMark' + nextNo).innerHTML
	     = "<a href = 'javaScript:clickPlus(" + nextNo + ")'>＋</a>";
	document.getElementById(nextNo).style.display = 'none';

}

function orgClick(no) {
	var D = document.all;
	var orgid = D ["orgId"+no].value;
	var orgnam = D ["orgNam"+no].value;

	window.opener.setOrg(orgid, orgnam);
	window.opener.focus();
	window.close();
}

function userClick(no) {
	var D = document.all;
	var org= D ["userOrgId"+no].value;
	var orgnam= D ["userOrgNam"+no].value;
	var csv= D ["userUpOrgCsv"+no].value;
	var userno= D ["userNo"+no].value;
	var usernam= D ["userNam"+no].value;

	window.opener.setUser(userno, usernam, csv, org, orgnam);
	window.opener.focus();
	window.close();
}

//-->
</script>

</body>
</html>
<%
objSql.close();
db.close();
%>

<!-- ****************************** end of orgtree_href.jsp ***************************** -->