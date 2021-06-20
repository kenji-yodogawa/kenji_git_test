<!-- **********************************************************************
	＜組織・メンバ選択＞ in みえるっち
	File Name :memb_link.jsp
	 呼出元：designinfra/drchkuser_inp.jsp(承認代行・査閲者登録)
            sys/mailapl_inp.jsp (組織一覧からセット)

	Author	:k-mizuno
	Date	:2006-06-09
	
	Update 
	2014-03-15 kaneshi 全般整理
	2014-08-19 kaneshi CSS外部化,SQLのインデント整理と無駄なスペース排除
	2014-09-22 kaneshi IEのバージョンをEDGEへ ,SQLほかコード整理
	2014-12-22 kaneshi 高速化
	2015-03-17 kaneshi StringBuilder とString#concatで高速化
	2016-01-03 kaneshi var d = document.all; 対応
	2016-01-06 kaneshi resizeTo調整
	2016-03-18 kaneshi 
	　　　　　javascript が動いていない状態だった。　　栫氏より指摘あり。
	  var d = window.opener.parent.fr_main.documentををもどした。　memb_set内
	  　　　　　上記ではだめで、<script type ='text/html' <head> 内にもっていったらなおった。
	2016-04-07 kaneshi StringBuilder化徹底
	2016-07-11 kaneshi 上位部署の部内部長が選択できるようにする。
	2016-09-22 kaneshi StringBuilder化徹底　indexOf内
	                   一覧表表示後は、パラメータをnullへ
	2016-10-14 kaneshi  concat -> append
	2017-06-07 代理承認者は、本人と協力会社社員以外　（図面権限に関係なく選べるように）
		 　　　　　　　　　　また、査閲者は、図面の権限のある人から選べるように　。
	2017-07-28 kaneshi sys\postingsettluser_inp.jsp　からの呼び出しに対応
	2017-12-18 kaneshi テーブル結合を　left join 化
	2018-01-30 kaneshi テーブル結合前の絞り込み
	2018-03-29 kaneshi SQLの検索条件のtodateの優先度アップ
		         
		     【課題】部署を選ばせるモードでは、画面の横幅は半分でいいね。

************************************************************************* -->

<%@ page contentType="text/html;charset=UTF-8"
	import="java.sql.*,java.io.*,java.net.*, java.util.*,java.text.*"%>

<% String strRight=""; %>
<%@ include file="../header_utf8.jsp"%>

<%
StringBuilder sbQry = new StringBuilder();
StringBuilder sbTmp = new StringBuilder();
StringBuilder sbTmp1 = new StringBuilder();

String strExcList=request.getParameter("ExcList")	;

if(request.getParameter("ExcList")==null){
	strExcList=""	;
}


String strDrChkUser=request.getParameter("DrChkUser");
if(strDrChkUser==null){
	strDrChkUser=""	;
}

String strFaNam="";
StringBuilder sbMembNamList=new StringBuilder();
int intDatCnt=0;
String[] aryOrgId=new String[200];
String[] aryOrgNam=new String[200];
String[] aryOrgFulNam=new String[200];
int[] aryLevelNo=new int[200];

String strMultTopOrgId="";
String strMultTopOrgNam="";

StringBuilder sbMultTopOrgId=new StringBuilder();
StringBuilder sbMultTopOrgNam=new StringBuilder();

String strTopOrgId="";
StringBuilder sbTopOrgId=new StringBuilder();

if(strLoginUserRight.indexOf("SETUP")>=0){
	sbQry
	.append(" select M.orgid,M.orgnam,R.OrgAll ")
	.append(" from (select orgid,orgAll from orgright ")
	.append("        where RightType='USER'")
	.append("      ) as R ")
	.append(" left join (select orgId,orgNam,levelNo,sortNo,todate,fromdate from meorg ")
	.append("           ) as M ")
	.append("   on R.OrgId=M.OrgId")
	.append("   and (M.ToDate='' or M.ToDate>='") .append(strNowDate) .append("')")
	.append("   and M.FromDate<= '") .append(strNowDate) .append("'")
	.append(" where M.orgid is not null ")
	.append(" order by LevelNo,SortNo")	
	;
//シス事グループ所属
}else if(strLoginGroupType.equals("DEPT")){
	sbQry
	.append(" select M.orgid,M.orgnam,R.OrgAll ")
	.append(" from (select orgid,orgAll from orgright ")
	.append("        where RightType='USER'")
	.append("         and GroupType='DEPT'")// ここだけちがうのだ。
	.append("      ) as R ")
	.append(" left join (select orgId,orgNam,levelNo,sortNo,todate,fromdate from meorg ")
	.append("           ) as M ")
	.append("   on R.OrgId=M.OrgId")
	.append("   and (M.ToDate='' or M.ToDate>='") .append(strNowDate) .append("')")
	.append("   and M.FromDate<= '") .append(strNowDate) .append("'")
	.append(" where M.orgid is not null ")
	.append(" order by LevelNo,SortNo")	
	;

//事業本部所属
}else{
	StringTokenizer hqTkn=new StringTokenizer(strLoginHqList,",");
	StringBuilder sbQry1 = new StringBuilder();
	
	while(hqTkn.hasMoreTokens()){
		if(sbQry.length()!=0){
			sbQry1.append(" or ");
		}
		sbQry1.append("OrgId=") .append(hqTkn.nextToken());
	}
	sbQry
	.append(" select orgid,orgnam,'YES' as OrgAll ")
	.append(" from meorg")
	.append(" where (") .append(sbQry1.toString()) .append(")")
	.append(" and (ToDate='' or ToDate>='") .append(strNowDate) .append("')")
	.append(" and FromDate<= '") .append(strNowDate) .append("'")
	.append(" order by LevelNo,SortNo")
	;
}

ResultSet rsTopOrg = objSql.executeQuery(sbQry.toString());
sbQry.delete(0,sbQry.length());

while(rsTopOrg.next()){
	if(rsTopOrg.getString("OrgAll").equals("YES")){

		sbMultTopOrgId .append(",") .append(rsTopOrg.getString("OrgId"));
		sbMultTopOrgNam .append(",") .append(rsTopOrg.getString("OrgNam"));
	}else{
		sbTopOrgId .append(",") .append(rsTopOrg.getString("OrgId"));
	}
}
rsTopOrg.close();

String strOrgAllList=strMultTopOrgId;

String strMultTbNam="meorg";
String strMultSetDate=strNowDate;
String strMultApvSign="TRUE";
int intMultTopLevel=0;
int intMultMaxLevel=15;

strMultTopOrgId = sbMultTopOrgId.toString(); 
strMultTopOrgNam = sbMultTopOrgNam.toString();
strTopOrgId = sbTopOrgId.toString();

%>

<%@ include file="../com/org_fwd_utf8.jsp"%>

<html>
<head>
<title>組織・メンバ選択</title>
<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
<link href="../com/mierucchics.css" rel="stylesheet" type="text/css">
<script type="text/javaScript">
<!--

moveTo(10,10);
resizeTo(screen.availWidth*0.9-20,screen.availHeight*0.9-20);

function memb_set(userno,usernm,yakunm,orgkey,orgnm,orgfnm,mail,chkno,chknm,apvno,apvnm){
	var D = document.all;

	if(window.opener.name=="fr_main"){
		var g_pageno = window.opener.parent.fr_main.g_pageno;
		var pgnam = window.opener.parent.fr_main.pgnam;
		
	//承認代行・査閲者
		if( g_pageno == 210 ) {
			window.opener.parent.fr_main.document.drchkuser_inp ["UserNo<%=request.getParameter("Line")%>"].value = userno;
			window.opener.parent.fr_main.document.drchkuser_inp ["UserNam<%=request.getParameter("Line")%>"].value = usernm;
			window.opener.parent.fr_main.document.drchkuser_inp ["UserOrgNam<%=request.getParameter("Line")%>"].value = orgfnm;

	//設計資格者
		}else if( g_pageno == 290 ) {
			window.opener.parent.fr_main.document.druser_inp ["OrgNam<%=request.getParameter("Line")%>"].value = orgfnm;
			window.opener.parent.fr_main.document.druser_inp ["UserNo<%=request.getParameter("Line")%>"].value = userno;
			window.opener.parent.fr_main.document.druser_inp ["UserNam<%=request.getParameter("Line")%>"].value = usernm;
	//入札案件決裁者登録　
		}else if( pgnam == "postingsettluser_inp" ) {//20170728 追加　kaneshi
			window.opener.parent.fr_main.document.postingsettluser_inp ["UserOrgFulNam<%=request.getParameter("Line")%>"].value = orgfnm;
			window.opener.parent.fr_main.document.postingsettluser_inp ["UserNo<%=request.getParameter("Line")%>"].value = userno;
			window.opener.parent.fr_main.document.postingsettluser_inp ["UserNam<%=request.getParameter("Line")%>"].value = usernm;		
		}
	}else{
		var g_pageno = window.opener.parent.g_pageno;
		//var d = window.opener.parent.document.all;
		
		if( g_pageno ==250 ) {
			window.opener.parent.document.mailmemb_inp ["<%=request.getParameter("KeyItem")%>"].value = userno;
			window.opener.parent.document.mailmemb_inp ["<%=request.getParameter("NamItem")%>"].value = orgfnm + " " + usernm;
			if(<%=request.getParameter("LineNo")%>>=0){
				document.forms[0].mailmemb_inp ["Err<%=request.getParameter("LineNo")%>"].value ="";
				window.opener.user_dsp(<%=request.getParameter("LineNo")%>);
			}
		}else if( g_pageno ==270 ) {
			window.opener.parent.document.part_inp.UserNo.value = userno;
			window.opener.parent.document.part_inp.UserNam.value = orgfnm + " " + usernm;
		}
	}
	window.opener.focus();
	window.close();
}

function org_set(orgkey,orgnm,orgfnm,tree){
	if(window.opener.name=="fr_main"){
		var g_pageno = window.opener.parent.fr_main.g_pageno;
		var d = window.opener.parent.fr_main.document.all;

		if( g_pageno ==440 ) {
			window.opener.parent.fr_main.document.mailapl_inp ["OrgId<%=request.getParameter("Line")%>"].value=orgkey;
			window.opener.parent.fr_main.document.mailapl_inp ["OrgNam<%=request.getParameter("Line")%>"].value=orgfnm;

			if(d.mailapl_inp ["ListNam<%=request.getParameter("Line")%>"].value==""){
				window.opener.parent.fr_main.document.mailapl_inp ["ListNam<%=request.getParameter("Line")%>"].value=orgnm;
			}else if(d.mailapl_inp ["ListNam<%=request.getParameter("Line")%>"].value!=orgnm){
				if(confirm("アドレス帳名を組織名に変更しますか？")){
					window.opener.parent.fr_main.document.mailapl_inp ["ListNam<%=request.getParameter("Line")%>"].value=orgnm;
				}
			}
		}
	}
	window.opener.focus();
	window.close();
}
//-->
</script>
</head>

<body>
<%
PreparedStatement ps0=null;
PreparedStatement ps1=null;
PreparedStatement ps2=null;
PreparedStatement ps3=null;

for(int i=0; i<2; i++) {
	String strTknOrg="";
	String strOrgTree="";
	if(i==0){
		strTknOrg=strMultOrgIdList;
		strOrgTree="MULT";
	}else{
		strTknOrg=strTopOrgId;
		strOrgTree="SINGLE";
	}
	StringTokenizer idTkn=new StringTokenizer(strTknOrg,",");
	strTknOrg=null;
	int intTopLevelNo=99	;

	while(idTkn.hasMoreTokens()) {
		strTkn=idTkn.nextToken();
		if(ps0 == null){ps0 =db.prepareStatement(sbTmp
			.append(" select orgnam,orgfulnam,levelno ")
			.append(" from meorg")
			.append(" where OrgId= ?")
			.append(" and (ToDate='' or ToDate>='") .append(strMultSetDate) .append("')")
			.append(" and FromDate<= '") .append(strMultSetDate) .append("'")
			.toString());sbTmp.delete(0,sbTmp.length());
		}
		ps0.setInt(1, Integer.valueOf( strTkn));
		ResultSet rsOrg = ps0.executeQuery();

		rsOrg.next();
		String strOrgNam   =rsOrg.getString("OrgNam");
		String strOrgFulNam=rsOrg.getString("OrgFulNam");
		int intLevelNo     =rsOrg.getInt("LevelNo");
		rsOrg.close();

		
		sbTmp .append(",") .append(strOrgAllList) .append(",");
		sbTmp1 .append(",") .append(strTkn) .append(",");
		if(sbTmp .indexOf(sbTmp1.toString())>=0
				|| strOrgTree.equals("SINGLE")){
			intTopLevelNo=intLevelNo;
		}
		sbTmp.delete(0,sbTmp.length());
		sbTmp1.delete(0,sbTmp1.length());

		sbMembNamList.delete(0,sbMembNamList.length());
		
		if(request.getParameter("OrgOnly")==null){
			//メンバ
			ResultSet rsMemb;
			if(request.getParameter("BossOnly")!=null){

				if(ps1 == null){ps1 =db.prepareStatement(sbTmp
					.append(" select usernam,userno,postnam,bossflg,mailaddr,userId ")
					.append(" from meuser")
					.append(" where RealOrgId=?")
					.append(" and (ToDate='' or ToDate>='") .append(strMultSetDate) .append("')")
					.append(" and BossFlg!='0'")
					.append(" and BossFlg!=''")
					.append(" and FromDate<='") .append(strMultSetDate) .append("'")
					.toString());sbTmp.delete(0,sbTmp.length());
				}
				ps1.setInt(1, Integer.valueOf( strTkn));
				rsMemb = ps1.executeQuery();

			}else{
				if(ps2 == null){ps2 =db.prepareStatement(sbTmp
					.append(" select usernam,userno,postnam,bossflg,mailaddr,userId ")
					.append(" from meuser")
					.append(" where  RealOrgId=?")
					.append(" and (ToDate='' or ToDate>='") .append(strMultSetDate) .append("')")
					.append(" and FromDate<= '") .append(strMultSetDate) .append("'")
					.append(" order by BossFlg desc")
					.toString());sbTmp.delete(0,sbTmp.length());
				}
				ps2.setInt(1, Integer.valueOf( strTkn));
				rsMemb = ps2.executeQuery();
 			}

			while(rsMemb.next()){
				if(rsMemb.getString("UserNam").indexOf(" ")>0){
					strFaNam=rsMemb.getString("UserNam").substring(0,rsMemb.getString("UserNam").indexOf(" "));
				}else{
					strFaNam=rsMemb.getString("UserNam");
				}
				//氏名間SPACE
				if(sbMembNamList.length()!=0){
					sbMembNamList .append("　");
				}

				// strDrChkUser の場合のみリンクをつける
				if(strDrChkUser.equals("YES")){
					if(ps3 == null){ps3 =db.prepareStatement(sbTmp
						.append(" select userid from druser")
						.append(" where userid=?")
						.append("  and invalid=''")
						.toString());sbTmp.delete(0,sbTmp.length());
					}
					ps3.setString(1, rsMemb.getString("UserId"));
					ResultSet rsDrUser = ps3.executeQuery();
					
					if(rsDrUser.next()){
						sbMembNamList
						.append("<a href='javaScript:memb_set(\"")
						.append(rsMemb.getString("UserNo")) .append("\",\"")
						.append(rsMemb.getString("UserNam")) .append("\",\"")
						.append(rsMemb.getString("PostNam")) .append("\",\"")
						.append(strTkn) .append("\",\"")
						.append(strOrgFulNam) .append("\",\"")//20160318 変更
						.append(strOrgFulNam) .append("\",\"")
						.append(rsMemb.getString("MailAddr")) .append("\");'>")
						.append(strFaNam) .append(rsMemb.getString("PostNam")) .append("</a>");
					}else{
						sbMembNamList
						.append(strFaNam) .append(rsMemb.getString("PostNam"))
						;
						
					}
				}else{
					sbMembNamList
					.append("<a href='javaScript:memb_set(\"")
					.append(rsMemb.getString("UserNo")) .append("\",\"")
					.append(rsMemb.getString("UserNam")) .append("\",\"")
					.append(rsMemb.getString("PostNam")) .append("\",\"")
					.append(strTkn) .append("\",\"")
					.append(strOrgFulNam) .append("\",\"")//20160318 変更
					.append(strOrgFulNam) .append("\",\"")
					.append(rsMemb.getString("MailAddr")) .append("\");'>")
					.append(strFaNam) .append(rsMemb.getString("PostNam")) .append("</a>");
				
				}
			}
			rsMemb.close();
		}
		%>

	<form method="POST" action="memb_link.jsp">
	<div style="text-align:left;">
	<table class="noborder">
	<tr><td style="vertical-align:top;" >
		<% 
			for(int j=0; j<intLevelNo; j++){ //修正２０１６０８１２%>
		  <img border="0" src="../img/trans.gif">
		<%}%>
		<%if(request.getParameter("OrgOnly")==null){%>
			<%if(strOrgTree.equals("MULT")){%>
			   <%=strOrgNam%>
			<%}else{%>
			   <%=strOrgFulNam%>
			<%}%>
		<%}else{%>
		   <%if(strOrgTree.equals("MULT")){%>
		     <a href="javaScript:org_set('<%=strTkn%>','<%=strOrgNam%>','<%=strOrgFulNam%>','<%=strOrgTree%>');">
		     <%=strOrgNam%>
		     </a>
			 <%}else{%>
			   <a href="javaScript:org_set('<%=strTkn%>','<%=strOrgNam%>','<%=strOrgFulNam%>','<%=strOrgTree%>');">
			   <%=strOrgFulNam%>
			   </a>
			 <%}%>
		<%}
		strOrgFulNam=null;
		strOrgNam=null;
		
		%>
	</td>
	<td style="vertical-align:top;" >&nbsp;<%=sbMembNamList.toString()%></td>
	<%sbMembNamList.delete(0,sbMembNamList.length());%>
</tr>
	<%}//end of while(idTkn.hasMoreTokens())
	strOrgTree=null;
	%>
<%}//end of for(int i=0; i<2; i++)%>

</table>
<br>

</div>
</form>

</body>
</html>

<%
objSql.close();
db.close();
%>

<!-- ***************************** End of memb_link.jsp **************************** -->