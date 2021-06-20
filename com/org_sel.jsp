<!-- **********************************************************
	＜組織選択 org_sel.jsp＞ in みえるっち
	呼出元：
	design/	    drinfochk_inp.jsp ない。、
	   drinfomp_inp.jsp
	   drinfoapv_inp.jsp
	   drrequest_inp.jsp
	   drrequestans_inp.jsp
	   entrybase_inp.jsp ●
	   drchkuser_inp.jsp
		
	designinfra/drchkuser_inp.jsp　 ●

	sales/posting_inp.jsp (2 matches)　
	      postingapv_inp.jsp
	sys/meuser_inp.jsp
	    orgright_inp.jsp ●
	    realorgapl_inp.jsp　●

	Date  :2006-06-16　　Author  :k-mizuno
	
    UpDate
	2013-12-20 kaneshi アラーム除去、改行・インデント調整
         インデントのタブをスペース２つに修正
　　　　CSS整理、JavaScriptをbodyタグ内部へ移動
	2014-03-15 kaneshi 全般整理
              ２つ文字列で組織を検索させる。
    入力文字にトリムをかける。
	2014-04-02 kaneshi SQLのto_numberをto_charへ修正（Fill Mode で書式指定）
	2014-05-29 CSS外部化
	2014-07-28 kaneshi JavaScript一部外部化　comA.js
	2014-11-03 kaneshi sql select * のカラム特定
	　　　　　　　　　 ResultSet を読んだらすぐ閉じる
	2014-11-17 kaneshi drchkuser.OrgId のinteger化対応
	2014-12-22 kaneshi 画面から同じパラメータを繰り返し読まない（集約化）
	2015-02-17 kaneshi StringBuilderで高速化
	2015-03-17 kaneshi 上記の徹底
	           drinfomp_inp.jspで管理部署をセットする部分にバグがあり修正
	2015-07-15 kaneshi PreparedStatementで高速化
	2016-01-04 kaneshi 下記で簡素化
			  var D = document.all;
			  var DP = window.opener.parent.fr_main.document.all;
	2016-02-08 kaneshi <body onblur=focus の廃止　ＩＥで動作しなくなるので外した
	　　　　　　　　　　　　　　　　　　　　不要なjqueryのインポートを外した
	2016-04-09 kaneshi StringBuilder化徹底
	                   PreparedStatementからstrNowDateを排除
	2016-05-29　kaneshi ＳＱＬミス修正
	                   strMultSetDateをパラメータから固定値へ
	2016-09-04 kaneshi テキスト入力欄で、autocomplete="off"
	                   だいぶ変更したので、細かいテストが必要ですね。！！！！
	     realorgapl　で動作している。
	2016-09-22 kaneshi StringBuilder化徹底　indexOf内
	2016-10-20 kaneshi StringBuilder#setLength(0)
	            concat -> append
	2016-10-20 kaneshi 製造移管の管理部署の変更を可にした。ｃ通知部署がまだ
	2016-11-14 kaneshi drrequest_inp から呼ばれたときエラーになっていた問題に対応
      　　　　　　　　ＳｕｂＷから呼ばれるとき全部エラーになってたみたい。
	2016-12-28 kaneshi 製造移管（design/drinfomp_inp.jsp）で、管理部署を変更したとき、
						査閲者と承認者をセットしてない問題へ対処
					(配布先をセットしたあと、画面を閉じない問題あり)
	2017-12-14 kaneshi テーブル結合を　left join へ
	2018-01-26 kaneshi テーブル結合前の絞り込み
	2018-04-08 kaneshi SQL検索条件のtodateの優先度アップ
	2018-05-23 kaneshi テーブル結合の高度化


      
       【課題】このプログラムはシス事、シス営、ＳＳＳ全体の組織から検索するもの
       ユーザ部署から検索するプログラムや
       　ユーザの自部署（兼務＋上位）から選択するプログラムもほしい。
************************************************************** -->

<%@ page contentType="text/html;charset=UTF-8"
  import="java.sql.*,java.io.*,java.net.*, java.util.*,java.text.*"%>

<% String strRight=""; %>
<%@ include file="../header_utf8.jsp"%>

<%if(request.getParameter("ScArea")!=null && request.getParameter("SosikiSc")==null){%>
	<html>
	<head>
	<title>組織選択</title>
	<meta http-equiv="Content-Style-Type" content="text/css">
	<link href="../com/mierucchics.css" rel="stylesheet" type="text/css">
	<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
	</head>
	
	<body>
	<table class="header">
	<tr><th>組織選択</th></tr>
	</table>
	
	<form name="org_sel" action="org_sel.jsp" method="POST">
	<div align="center">
	
	<br style="line-height:1.3em;">
	<input name="SosikiSc" value="" size="30">
	<input name="ScArea" type="hidden"  value="<%=request.getParameter("ScArea")%>">
	
	<% if(request.getParameter("ComOrg")!=null){ %>
		<input name="ComOrg" type="hidden" value="<%=request.getParameter("ComOrg")%>">
	<% } %>
	
	<% if(request.getParameter("OrgList")!=null){ %>
		<input name="OrgList" type="hidden" value="<%=request.getParameter("OrgList")%>">
	<% } %>
	<% if(request.getParameter("FlwExcp")!=null){ %>
		<input name="FlwExcp" type="hidden" value="<%=request.getParameter("FlwExcp")%>">
	<% } %>
	<% if(request.getParameter("OpnProg")!=null){ %>
		<input name="OpnProg" type="hidden" value="<%=request.getParameter("OpnProg")%>">
	<% } %>
	<% if(request.getParameter("tgt")!=null){ %>
		<input name="tgt" type="hidden" value="<%=request.getParameter("tgt")%>">
	<% } %>
	<% if(request.getParameter("Line")!=null){ %>
		<input name="Line" type="hidden" value="<%=request.getParameter("Line")%>">
	<% } %>
	<% if(request.getParameter("OrgOnly")!=null){ %>
		<input name="OrgOnly" type="hidden" value="<%=request.getParameter("OrgOnly")%>">
	<% } %>
	<% if(request.getParameter("SetDate")!=null){ %>
		<input name="SetDate" type="hidden" value="<%=request.getParameter("SetDate")%>">
	<% } %>
	<%if(request.getParameter("AllOrg")!=null){%>
		<input name="AllOrg" type="hidden" value="<%=request.getParameter("AllOrg")%>">
	<% } %>
	<%if(request.getParameter("ExceptOrg")!=null){%>
		<input name="ExceptOrg" type="hidden" value="<%=request.getParameter("ExceptOrg")%>">
	<% } %>
	<%if(request.getParameter("OrgNamList")!=null){%>
		<input name="ExceptOrg" type="hidden" value="<%=request.getParameter("OrgNamList")%>">
	<% } %>
	</div>
	</form>
	
	<script type="text/javaScript">
	<!--
	var D = document.all;
	
	document.forms[0].SosikiSc.style.display="none";
	
	if(window.opener.name=="fr_main"){
		var DP = window.opener.parent.fr_main.document.all;//20160413 if文の内側へうつした。
		if(DP [DP.pgnam] ["<%=request.getParameter("ScArea")%>"]){
		document.forms[0].SosikiSc.value
				=DP [DP.pgnam] ["<%=request.getParameter("ScArea")%>"].value;
		}
	}else{
		var DP = window.opener.parent.document.all;
		//drrequest_inp.jsp で動作しない DP [DP.pgnam] が認識されない
		//alert("DP="+DP);//OK
		//alert("DP.pgnam="+DP.pgnam);// undefined になる。

		if(DP [window.opener.parent.pgnam] ["<%=request.getParameter("ScArea")%>"]){
			document.forms[0].SosikiSc.value
				=DP [window.opener.parent.pgnam] ["<%=request.getParameter("ScArea")%>"].value;
		}
	}
	 document.forms[0].submit();
	 //-->
	 </script>
	
	</body>
	</html>

<%
}else{// of if(request.getParameter("ScArea")!=null && request.getParameter("SosikiSc")==null)
	String strSosikiSc=request.getParameter("SosikiSc");
	String strSosikiSc1=request.getParameter("SosikiSc1");
	String strMultSetDate=strNowDate;
	
	if(request.getParameter("SetDate")!=null){
	  strMultSetDate=request.getParameter("SetDate");
	}
	
	StringBuilder sbQry = new StringBuilder();
	StringBuilder sbTmp = new StringBuilder();
	StringBuilder sbTmp1 = new StringBuilder();
	
	int intSssLvlNo=0;
	ResultSet rsSssOrg=objSql.executeQuery(sbTmp
		.append(" select levelNo from meorg")
		.append(" where OrgId=") .append(strEcoSfsCompCd)
		.append(" and (ToDate='' or ToDate>='") .append(strNowDate) .append("')")
		.append(" and FromDate<='") .append(strNowDate) .append("'")
		.toString());sbTmp.delete(0,sbTmp.length());
	
	if(rsSssOrg.next()){
	  intSssLvlNo=rsSssOrg.getInt("LevelNo");
	}
	rsSssOrg.close();

	sbQry
	.append(" select M.orgid,M.levelNo,R.OrgAll ")
	.append(" from (select orgId,orgAll from orgright")
	.append("        where RightType='USER'")
	.append("      ) as R ")
	.append(" left join (select orgid,levelNo,sortNo,todate,fromdate from meorg ")
	.append("           ) as M ")
	.append("   on R.OrgId=M.OrgId")
	.append("   and (M.ToDate='' or M.ToDate>='") .append(strMultSetDate) .append("')")
	.append("   and M.FromDate<= '") .append(strMultSetDate) .append("'")
	.append(" where M.orgid is not null ")
	.append(" order by SortNo")
	;
	ResultSet rsTopOrg = objSql.executeQuery(sbQry.toString());
	sbQry.delete(0,sbQry.length());

	StringBuilder sbTopOrgIdList=new StringBuilder();
	StringBuilder sbTopLevelList=new StringBuilder();
	StringBuilder sbTopOrgAll=new StringBuilder();
	
	while(rsTopOrg.next()){
		sbTopOrgIdList .append(rsTopOrg.getString("OrgId")) .append(",");
		sbTopLevelList .append(rsTopOrg.getString("LevelNo")) .append(",");
		sbTopOrgAll .append(rsTopOrg.getString("OrgAll")) .append(",");
	}
	rsTopOrg.close();
	
	if(strSosikiSc==null){
		strSosikiSc="";
	}
	if(strSosikiSc1==null){
	 	strSosikiSc1="";
	}
  %>

  <html>
  <head>
  <title>組織選択</title>
	<meta http-equiv="Content-Style-Type" content="text/css">
	<link href="../com/mierucchics.css" rel="stylesheet" type="text/css">
  </head>

  <body>
  <table class="header">
  <tr><th>組織選択</th></tr>
  </table>
  <br style="line-height:0.4em;">

  <form name="org_sel" action="org_sel.jsp" method="POST">
  <div align="center">

  <table class="basetable">
  <tr>
    <th>組織名</th>
    <td><input name="SosikiSc" style="ime-mode:active" 
    		value="<%=strSosikiSc%>" size="22"
    		autocomplete="off"
			onkeypress="javascript:enter_in(this,event.keyCode);"
			onchange="javascript:sc_char_del(this);" 
			onblur="javascript:sc_char_del(this);">
      ＆
      <input name="SosikiSc1" style="ime-mode:active" 
      		value="<%=strSosikiSc1%>" size="22"
      		autocomplete="off"
			onkeypress="enter_in(this,event.keyCode);"
			onchange="javascript:sc_char_del(this);" 
			onblur="javascript:sc_char_del(this);">
    </td>
    <td><input name="Search" type="submit" value=" 検 索 ">
    </td>
  </tr>
  </table>
  <br style="line-height:0.6em;">
      <%
    

  if(!strSosikiSc.equals("")|| !strSosikiSc1.equals("")){
    strQuery="";
    StringBuilder sbScQry = new StringBuilder();

    if(request.getParameter("AllOrg")==null){
      StringTokenizer tiTkn=new StringTokenizer(sbTopOrgIdList.toString(),",");
      StringTokenizer tlTkn=new StringTokenizer(sbTopLevelList.toString(),",");
      StringTokenizer oaTkn=new StringTokenizer(sbTopOrgAll.toString(),",");

      while(tiTkn.hasMoreTokens()){
        String strOgTkn=tiTkn.nextToken();
        String strLvlTkn=tlTkn.nextToken();
        String strOaTkn=oaTkn.nextToken();

        if(sbScQry.length()==0){
          sbScQry.append(" and (");
        }else{
        	sbScQry.append(" or ");
        }
        if(strOaTkn.equals("YES")){
        	sbScQry.append("OrgId") .append(strLvlTkn) .append("=") .append(strOgTkn);
        }else{
        	sbScQry.append("OrgId=") .append(strOgTkn);
        }
      }
      if(sbScQry.length()!=0){
        sbScQry.append(")");
      }
    }
    //String strQury1 ="";
    if(!strSosikiSc1.equals("")){
    	sbScQry.append("and (OrgFulNam like '%") .append(strSosikiSc1) .append("%' ") 
    				.append(" or OrgNam like '%") .append(strSosikiSc1) .append("%')");
    }
    sbQry
      .append("select orgId from meorg")
      .append(" where (OrgFulNam like '%") .append(strSosikiSc) .append("%' ") 
    		  .append(" or OrgNam like '%") .append(strSosikiSc) .append("%')")
      //+ strQury1
      .append(" and OrgId") .append(intSssLvlNo) .append("!=") .append(strEcoSfsCompCd)
      .append(" and (ToDate='' or ToDate>='") .append(strMultSetDate) .append("')")
      .append(" and FromDate<= '") .append(strMultSetDate) .append("'")
      .append(sbScQry)
      .append(" order by OrgFulNam,LevelNo")
      ;

    ResultSet rsOrgList=objSql.executeQuery(sbQry.toString());
    sbQry.delete(0,sbQry.length());

    StringBuilder sbOrgIdList=new StringBuilder()  ;
    while(rsOrgList.next()){
      sbOrgIdList .append(",") .append(rsOrgList.getString("OrgId"));
    }
    rsOrgList.close();
    %>
      <table class="basetable">
        <tr>
          <td>
            <%
	String strExceptOrg="";
	if(request.getParameter("ExceptOrg")!=null){
	  strExceptOrg=request.getParameter("ExceptOrg");
	}
	StringTokenizer orTkn=new StringTokenizer(sbOrgIdList.toString(),",")  ;
	sbOrgIdList.delete(0,sbOrgIdList.length());
	

	PreparedStatement ps0=null;
	PreparedStatement ps1=null;
	PreparedStatement ps2=null;
	PreparedStatement ps3=null;
	PreparedStatement ps4=null;
	PreparedStatement ps5=null;  

	while(orTkn.hasMoreTokens()){
		if(ps0 == null){ps0 =db.prepareStatement(sbTmp
			.append(" select * from meorg ") // カラム指定しない。
			.append(" where OrgId=?")
			.append(" and (ToDate='' or ToDate>='") .append(strMultSetDate) .append("')")
			.append(" and FromDate<= '") .append(strMultSetDate) .append("'")
			.toString());sbTmp.delete(0,sbTmp.length());
		}
		ps0.setInt(1,Integer.valueOf(orTkn.nextToken()));
		ResultSet rsOrg = ps0.executeQuery();

		rsOrg.next()  ;
		
		String strOrgId    =rsOrg.getString("OrgId")  ;
		String strOrgFulNam=rsOrg.getString("OrgFulNam")  ;
		String strOrgNam   =rsOrg.getString("OrgNam")  ;
		String strUpOrgId  =rsOrg.getString("UpOrgId")  ;
		int intLevelNo     =rsOrg.getInt("LevelNo")  ;
		int intDwdOrg=0  ;
		
		if(request.getParameter("OrgOnly")==null){
			int[] aryOrgId=new int[10]  ;
			Arrays.fill(aryOrgId,0)  ;
			int intTopCnt=0;
			
			for(int i=0; i<intLevelNo; i++){
				//社長、事業部長除外
				if(intTopCnt>0 || rsOrg.getInt("OrgId"+(i+1)) == rsOrg.getInt("OrgId")){
					aryOrgId[i]=rsOrg.getInt("OrgId"+(i+1))  ;
				}
				sbTmp .append(",") .append(rsOrg.getInt("OrgId"+(i+1))) .append(",");
				if(sbTopOrgIdList .indexOf(sbTmp.toString())>=0){
					intTopCnt++  ;
				}
				sbTmp.delete(0,sbTmp.length());
			}
			rsOrg.close();
			
			strQuery=""  ;
			StringBuilder sbQry1 = new StringBuilder();
			
			for(int j=intLevelNo; j<10; j++){
			  if(sbQry1.length()!=0){
				  sbQry1 .append(" or ")  ;
			  }
			  sbQry1 .append("OrgId") .append(j+1) .append("!=0")  ;
			}
			if(sbQry1.length()!=0){
				sbQry1 .insert(0,"and (") .append(")")  ;
			}
			
			ResultSet rsDwdOrg=objSql.executeQuery(sbTmp
				.append(" select count(*) as count ")
				.append(" from meorg")
				.append(" where OrgId") .append(intLevelNo) .append("=") .append(strOrgId)
				.append(sbQry1)
				.toString());sbTmp.delete(0,sbTmp.length());
			  
			sbQry1.delete(0,sbQry1.length());
			
			rsDwdOrg.next()  ;
			intDwdOrg=rsDwdOrg.getInt("count")  ;
			rsDwdOrg.close();

		StringBuilder sbChkNoList=new StringBuilder();
		StringBuilder sbChkIDList=new StringBuilder();
		StringBuilder sbChkNamList=new StringBuilder();
		
		StringBuilder sbApvNoList=new StringBuilder();
		StringBuilder sbApvIDList=new StringBuilder();
		StringBuilder sbApvNamList=new StringBuilder();
		StringBuilder sbApvLvlList=new StringBuilder();
		StringBuilder sbApvMainList=new StringBuilder();

		for(int i=0; i<intLevelNo; i++){
			if(ps2 == null){ps2 =db.prepareStatement(sbTmp
				.append(" select userId,userNo,userNam ")
				.append(" from meuser")
				.append(" where RealOrgId=?")
				.append(" and (ToDate='' or ToDate>='") .append(strMultSetDate) .append("')")
				.append(" and BossFlg!='0'")
				.append(" and BossFlg!=''")
				.append(" and FromDate<= '") .append(strMultSetDate) .append("'")
				.toString());sbTmp.delete(0,sbTmp.length());
			}
			ps2.setInt(1,Integer.valueOf(aryOrgId[i]));
			ResultSet rsMemb = ps2.executeQuery();

			while(rsMemb.next()){
				if(sbApvIDList.indexOf(rsMemb.getString("UserID"))<0){
					sbApvNoList .append(",") .append(rsMemb.getString("UserNo"));
					sbApvIDList .append(",") .append(rsMemb.getString("UserID"));
					sbApvNamList .append(",") .append(rsMemb.getString("UserNam"));
					sbApvLvlList .append(sbChkNoList) .append(",") .append(i+1);
					
					if(aryOrgId[i]==Integer.parseInt(strOrgId)){
					  sbApvMainList .append(",MAIN");
					}else{
					  sbApvMainList .append(",SUB");
					}
				}
			}
			rsMemb.close();
		}
			//設計検証員、承認代行
		if(ps3 == null){ps3 =db.prepareStatement(sbTmp
			.append(" select U.UserID,DU.UserOrgId,DU.UserType")
			.append(" from (select userType,userId,userOrgId from drchkuser")
			.append("        where OrgId=?") //2014-11-15
			.append("          and (ToDate='' or ToDate>='") .append(strMultSetDate) .append("')")
			.append("          and FromDate<='") .append(strMultSetDate) .append("'")
			.append("      ) as DU ")
			.append(" left join (select userId,realOrgId,todate,fromdate from meuser ")
			.append("           ) as U ")
			.append("   on DU.UserID=U.UserID")
			.append("   and to_number(DU.UserOrgId,'99999999999')=U.realorgId ") //2014-11-15
			.append("   and (U.ToDate='' or U.ToDate>='") .append(strMultSetDate) .append("')")
			.append("   and U.FromDate<='") .append(strMultSetDate) .append("'")
			.append(" where U.userId is not null")
			.append(" order by UserID")
			.toString());sbTmp.delete(0,sbTmp.length());
		}
		ps3.setString(1,strOrgId);
		ResultSet rsChkList = ps3.executeQuery();

		String[] aryApvUserId=new String[100];
		String[] aryApvOrgId=new String[100];
		String[] aryUserType=new String[100];
		int intChkUserCnt=0;
		
		while(rsChkList.next()){
			aryApvUserId[intChkUserCnt]=rsChkList.getString("UserId")  ;
			aryApvOrgId[intChkUserCnt] =rsChkList.getString("UserOrgId")  ;
			aryUserType[intChkUserCnt] =rsChkList.getString("UserType")  ;
			intChkUserCnt++;
		}
		rsChkList.close();

		for(int i=0; i<intChkUserCnt; i++){
			
			if(ps4 == null){ps4 =db.prepareStatement(sbTmp
				.append(" select userId,userNo,userNam ")
				.append(" from meuser")
				.append(" where UserId=?")
				.append(" and RealOrgId=?")
				.append(" and (ToDate='' or ToDate>='") .append(strNowDate) .append("')")
				.append(" and FromDate<='") .append(strNowDate) .append("'")
				.toString());sbTmp.delete(0,sbTmp.length());
			}
			ps4.setString(1, aryApvUserId[i]);
			ps4.setInt(2, Integer.valueOf(aryApvOrgId[i]));
			ResultSet rsChk = ps4.executeQuery();
		
		  rsChk.next();
		  if(sbChkIDList.indexOf(rsChk.getString("UserID"))<0
		      && aryUserType[i].equals("CHECK")){
		    sbChkNoList .append(",")  .append(rsChk.getString("UserNo"));
		    sbChkNamList .append(",") .append(rsChk.getString("UserNam"));
		    sbChkIDList .append(sbApvNoList) .append(",")  .append(rsChk.getString("UserID"));
		  }
		  //
		  if(sbApvIDList.indexOf(rsChk.getString("UserID"))<0
		      && aryUserType[i].equals("APPROVE")){
		    sbApvNoList .append(",")  .append(rsChk.getString("UserNo"));
		    sbApvNamList .append(",") .append(rsChk.getString("UserNam"));
		    sbApvIDList .append(",")  .append(rsChk.getString("UserID"));
		    
			if(ps5 == null){ps5 =db.prepareStatement(sbTmp
				.append(" select levelNo from meorg")
				.append(" where OrgId=?")
				.append(" and (ToDate='' or ToDate>='") .append(strNowDate) .append("')")
				.append(" and FromDate<='") .append(strNowDate) .append("'")
				.toString());sbTmp.delete(0,sbTmp.length());
        	}
        	ps5.setInt(1, Integer.valueOf(aryApvOrgId[i]));
        	ResultSet rsApvOrg = ps5.executeQuery();

           	rsApvOrg.next();
            	sbApvLvlList .append(",") .append(rsApvOrg.getString("LevelNo"));
            rsApvOrg.close();
            sbApvMainList .append(",SUB");
          }
          rsChk.close();
        }

        if(intDwdOrg>0 && request.getParameter("ComOrg")!=null){
        	sbTmp .append(",") .append(strExceptOrg) .append(",");
        	sbTmp1 .append(",C") .append(strOrgId) .append(",");
        	
        	if(sbTmp .indexOf(sbTmp1 .toString())<0){
                sbTmp.delete(0,sbTmp.length());
                sbTmp1.delete(0,sbTmp1.length());
                
            	String x0 = sbTmp .append("C") .append(strOrgId) 
            			.toString();sbTmp.delete(0,sbTmp.length());
            			
				String x1 = sbTmp .append(strOrgFulNam) .append("全体").toString();sbTmp.delete(0,sbTmp.length());
				String x2 = sbTmp .append(strOrgNam) .append("全体").toString();sbTmp.delete(0,sbTmp.length());
				String x3 = sbChkNoList.toString();
				String x4 = sbChkNamList.toString();
				String x5 = sbApvNoList.toString();
				String x6 = sbApvNamList.toString();
				String x7 = sbApvMainList.toString();
				String x8 = sbApvLvlList.toString();
				%>
				  <a href="javaScript:org_set('<%=x0%>','<%=x1%>','<%=x2%>','<%=x3%>','<%=x4%>','<%=x5%>','<%=x6%>','<%=x7%>','<%=x8%>');">
				    <%sbTmp.delete(0,sbTmp.length()); %>
				    <%=sbTmp .append(strOrgFulNam) .append("全体") .toString()%>
				    
				  </a><br>
				<%
				x0=null;x1=null;x2=null;x3=null;x4=null;x5=null;x6=null;x7=null;x8=null;
				}%>
				  <%
				  sbTmp .append(",") .append(strExceptOrg) .append(",");
				  sbTmp1 .append(",") .append(strOrgId) .append(",");
				  
				  if(!request.getParameter("ComOrg").equals("COMONLY")
				      && sbTmp.indexOf(sbTmp1.toString())<0){
				    String y0 = strOrgId;
				    String y1 = strOrgFulNam+"直轄";
				    String y2 = strOrgNam+"直轄";
				    String y3 = sbChkNoList.toString();
				    String y4 = sbChkNamList.toString();
				    String y5 = sbApvNoList.toString();
				    String y6 = sbApvNamList.toString();
				    String y7 = sbApvMainList.toString();
				    String y8 = sbApvLvlList.toString();
				  %>
				  <a href="javaScript:org_set('<%=y0%>','<%=y1%>','<%=y2%>','<%=y3%>','<%=y4%>','<%=y5%>','<%=y6%>','<%=y7%>','<%=y8%>');">
				    <%sbTmp.delete(0,sbTmp.length()); %>
				    <%=sbTmp .append(strOrgFulNam) .append("直轄") .toString()%>
				  </a><br>
				<%
					y0=null;y1=null;y2=null;y3=null;y4=null;y5=null;y6=null;y7=null;y8=null;
				  }
				  
				sbTmp.delete(0,sbTmp.length());
				sbTmp1.delete(0,sbTmp1.length());
				%>
				<% }else if((sbTmp .append(",") .append(strExceptOrg) .append(","))
						.indexOf(sbTmp1 .append(",") .append(strOrgId) .append(",") .toString())<0){
				  String z0 = strOrgId;
				  String z1 = strOrgFulNam;
				  String z2 = strOrgNam;
				  String z3 = sbChkNoList.toString();
				  String z4 = sbChkNamList.toString();
				  String z5 = sbApvNoList.toString();
				  String z6 = sbApvNamList.toString();
				  String z7 = sbApvMainList.toString();
				  String z8 = sbApvLvlList.toString();
				%>
				  <a href="javaScript:org_set('<%=z0%>','<%=z1%>','<%=z2%>','<%=z3%>','<%=z4%>','<%=z5%>','<%=z6%>','<%=z7%>','<%=z8%>');">
				    <%=strOrgFulNam%>
				    <%strOrgFulNam=null;%>
				  </a><br>
				<%
				sbTmp.delete(0,sbTmp.length());
				sbTmp1.delete(0,sbTmp1.length());
				z0=null;z1=null;z2=null;z3=null;z4=null;z5=null;z6=null;z7=null;z8=null;
				}
			}
		}
		%>
		</td>
	</tr>
	</table>
	<%}%>

	<% if(request.getParameter("ComOrg")!=null){ %>
	  <input name="ComOrg" type="hidden" value="<%=request.getParameter("ComOrg")%>">
	<% } %>
	<% if(request.getParameter("OrgList")!=null){ %>
	  <input name="OrgList" type="hidden" value="<%=request.getParameter("OrgList")%>">
	<% } %>
	<% if(request.getParameter("FlwExcp")!=null){ %>
	  <input name="FlwExcp" type="hidden" value="<%=request.getParameter("FlwExcp")%>">
	<% } %>
	<% if(request.getParameter("OpnProg")!=null){ %>
	  <input name="OpnProg" type="hidden" value="<%=request.getParameter("OpnProg")%>">
	<% } %>
	<% if(request.getParameter("tgt")!=null){ %>
	  <input name="tgt" type="hidden" value="<%=request.getParameter("tgt")%>">
	<% } %>
	<% if(request.getParameter("Line")!=null){ %>
	  <input name="Line" type="hidden" value="<%=request.getParameter("Line")%>">
	<% } %>
	<% if(request.getParameter("OrgOnly")!=null){ %>
	  <input name="OrgOnly" type="hidden" value="<%=request.getParameter("OrgOnly")%>">
	<% } %>
	<% if(request.getParameter("SetDate")!=null){ %>
	  <input name="SetDate" type="hidden" value="<%=request.getParameter("SetDate")%>">
	<% } %>
	<%if(request.getParameter("AllOrg")!=null){%>
	  <input name="AllOrg" type="hidden" value="<%=request.getParameter("AllOrg")%>">
	<% } %>
	<%if(request.getParameter("ExceptOrg")!=null){%>
	  <input name="ExceptOrg" type="hidden" value="<%=request.getParameter("ExceptOrg")%>">
	<% } %>
	<%if(request.getParameter("ScArea")!=null){%>
	  <input name="ScArea" type="hidden" value="<%=request.getParameter("ScArea")%>">
	<% } %>

	</div>
	</form>
	
	<script type="text/javaScript" src="../com/com_utf8.js"></script>
	<script type="text/javaScript">
	<!--
	moveTo(10,10);
	resizeTo(600,500);
	
	
	function init(){
		document.forms[0].Search.disabled=false;
		document.forms[0].removeAttribute('readonly');
		document.forms[0].SosikiSc.focus();
	}
	window.onload=init;
	
	function enter_in(a,key){
		if(key == 13) {
			document.forms[0].Search.disabled=true;
			document.forms[0].setAttribute('readonly','readonly');//disabledはだめ
			sc_char_del(a);
			document.forms[0].submit();
		}
	}

	function org_set(id,fnm,nm,chkno,chknm,apvno,apvnm,apvmain,apvlvl){
		  //drinfo_inp.jsp へ返す場合の考慮ぬけかも　
		var D = document.all;
		if(window.opener.name=="fr_main"){
			var g_pageno = window.opener.parent.fr_main.g_pageno;
			var DP = window.opener.parent.fr_main.document.all;
				
			if( g_pageno == 0 ) {
				if( window.opener.parent.fr_main.pgnam == 'realorgapl_inp' ) {//DPにできないな
					window.opener.orgSet(nm, id,apvno,apvnm,apvmain);
				};
			} else if( g_pageno == 210 ) {
			//承認代行・査閲者
				window.opener.parent.fr_main.document.drchkuser_inp.OrgId.value = id;
				window.opener.parent.fr_main.document.drchkuser_inp.OrgFulNam.value = fnm;
				window.opener.parent.fr_main.document.drchkuser_inp.UpdType.checked=false;
				window.opener.parent.fr_main.document.drchkuser_inp.submit();
			
			};
		}else{//以下はサブウィンドウからの呼び出しの場合
			
			var g_pageno = window.opener.parent.g_pageno;
		 	var DP = window.opener.parent.document.all;

			if( g_pageno == 100 ) {
				window.opener.parent.document.orgright_inp.OrgId.value =id;
				window.opener.parent.document.orgright_inp.OrgNam.value = fnm;
			}else if( g_pageno == 110 ) {
				window.opener.parent.document.meuser_inp.RealOrgId.value=id;
				window.opener.parent.document.meuser_inp.OrgFulNam.value=fnm;
			}else if( g_pageno ==260 ) {
				if((","+DP.drrequest_inp.CcOrgId.value+",")
						.indexOf(","+id+",")<0){
				  if(DP.drrequest_inp.CcOrgId.value==""){
					window.opener.parent.document.drrequest_inp.CcOrgId.value=id;
					window.opener.parent.document.drrequest_inp.CcOrgNam.value=fnm;
				  }else{
					  window.opener.parent.document.drrequest_inp.CcOrgId.value+="," + id;
					  window.opener.parent.document.drrequest_inp.CcOrgNam.value+="\n" + fnm;
				  };
				};
			}else if( g_pageno ==300 ) {
				if((","+DP.entrybase_inp.CcOrgId.value+",").indexOf(","+id+",")<0){
					if(DP.entrybase_inp.CcOrgId.value==""){
						window.opener.parent.document.entrybase_inp.CcOrgId.value=id;
						window.opener.parent.document.entrybase_inp.CcOrgNam.value=fnm;
					}else{
						window.opener.parent.document.entrybase_inp.CcOrgId.value+="," + id;
						window.opener.parent.document.entrybase_inp.CcOrgNam.value+="\n" + fnm;
					};
				};
			}else if( g_pageno ==410 ) {
				if( window.opener.parent.tgtorg=="ADMI") {
					window.opener.org_set(id,fnm);
					window.opener.apv_opt('ORG',apvno,apvnm,apvmain);
				}else{
					var ccorgid = DP.posting_inp.CcOrgId.value;
					if((","+ccorgid+",").indexOf(","+id+",")<0){
						if(ccorgid==""){
							window.opener.parent.document.posting_inp.CcOrgId.value=id;
							window.opener.parent.document.posting_inp.CcOrgNam.value=fnm;
						}else{
							window.opener.parent.document.posting_inp.CcOrgId.value+="," + id;
							window.opener.parent.document.posting_inp.CcOrgNam.value+="\n" + fnm;
						};
					};
				};
			}else if( g_pageno ==430 ) {
				var ccorgid = DP.postingapv_inp.CcOrgId.value;
				if((","+ccorgid+",").indexOf(","+id+",")<0){
					if(ccorgid==""){
						window.opener.parent.document.postingapv_inp.CcOrgId.value=id;
						window.opener.parent.document.postingapv_inp.CcOrgNam.value=fnm;
					}else{
						window.opener.parent.document.postingapv_inp.CcOrgId.value+="," + id;
						window.opener.parent.document.postingapv_inp.CcOrgNam.value+="\n" + fnm;
					};
				};
	
			}else if( g_pageno==240//drinfo_inp
			   || g_pageno==250
			   || g_pageno==310 //drinfomp_inp
			   || g_pageno==320) {
				//alert("org_sel 設計変更通知配布先 セット開始");
				<%if(request.getParameter("OrgList")!=null){%>
					//設計変更通知配布先
					window.opener.ccorg_dsp(id,fnm,'SET');
					if(g_pageno!=310){
						window.opener.parent.document [DP.pgnam] ["<%=request.getParameter("ScArea")%>"].value 
							=DP.SosikiSc.value;
					}
				<%}else{%>
				//設計変更通知管理部署  //g_pageno==310 //drinfomp_inp の対応ができてないみたいだ。
					window.opener.org_set(id,fnm);
					if( g_pageno==240) {//drinfo_inp 
						window.opener.apv_opt(chkno,chknm,apvno,apvnm,apvmain,apvlvl);
						// 査閲者、承認者を自動でセットするべし
					}else if(g_pageno==270) {
					  window.opener.apv_opt('ORG',chkno,chknm,apvno,apvnm,apvmain,apvlvl);
					}else if(g_pageno==250) {
					  window.opener.apv_opt('ORG',apvno,apvnm,apvmain,apvlvl);
					}else if(g_pageno==310){//drinfomp_inp 20161228
						window.opener.apv_opt('ORG',chkno,chknm,apvno,apvnm,apvmain);
					}
				<%}%>
			};
		};
		window.opener.focus();
		window.close();
	}// end of function org_set(id,fnm,nm,chkno,chknm,apvno,apvnm,apvmain,apvlvl)
	
	//-->
	</script>
	
	</body>
	</html>

<%}// else end of if(request.getParameter("ScArea")!=null && request.getParameter("SosikiSc")==null)%>

<%
objSql.close();
db.close();
%>

<!-- **************************** end of org_sel.jsp ******************************** -->