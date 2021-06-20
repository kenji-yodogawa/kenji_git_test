<!--**************************************************************************************
    ＜組織表＞ in みえるっち
    File Name :orgtree_checkbox.jsp
    
    呼出元：design/ drinfo_inp.jsp.　（drpart_sc.jsp）, 
            (partexchanege_inp(これから呼ばれると動作しない。一人の選択))
            sys/pjmemb_inp（複数人選択）
            
            シス事開発プロジェクトと管理部門は選べない）
            
    Author  :k-mizuno
    Date  :2009-09-17

    Update 
    2014-03-24 kaneshi 全般整理
	2014-04-13 kaneshi コード整理 作業中（アラームがきえない）
	2014-11-24 kaneshi sql select *のカラム指定
	　　　　　　　　　ResultSetを読んだらすぐ閉じる。
	2014-12-09 kaneshi from栫
	　　　　東日本エンジニアリング部，ITS事業推進部が＋マーククリックで展開されない！！
	　　　　<a href ='javaScript:clickPlus("＜%=tableNo%＞+1")'>＋</a>　が動かない
	　　　　　無線システム部の場合javascript:clickPlus("68+1")　になっていた
	
	　　　　　htmlタグ出力を、out.printlnを廃止。
	          部署や人を選ぶと、同じ部署や人がクリヤされなくなる問題あり。（もともと）
	2015-01-07 kaneshi 上記問題を直した。
	
	2015-02-27 kaneshi StringBuilder とString#concatで高速化
	
	2015-04-14 kaneshi javascript の若干の高速化
	2015-07-15 kaneshi PreparedStatementで高速化
	2016-01-06 kaneshi resizeToの調整
	2016-04-09 kaneshi PreparedStatement内のstrNowDateを　固定化
	2016-10-14 kaneshi concat -> append
	2017-02-25 kaneshi var D = document.all で簡素化
	2017-11-18 kaneshi テーブル結合のleft join 化
	2018-01-08 kaneshi テーブル結合前の絞り込み
	2018-02-16 kaneshi 上記の強化
	2018-03-29 kaneshi SQL検索条件のtodateの優先度アップ
           

　　問題、廃品対応の画面からよんでも、内容を表示しない
　　　　　（設計変更通知からならＯＫ） →対応した.これを使わず、memb_selにかえた。

**************************************************************************************-->

<%@ page contentType="text/html;charset=UTF-8"
    import="java.io.*,java.sql.*,java.net.*,java.util.*,java.text.*" %>

<% String strRight="USER"; %>
<%@ include file="../header_utf8.jsp" %>

<%if(request.getParameter("despatch")==null) {%>
	<html>
	<head>
	<title>組織表</title>
	<meta http-equiv="Content-Style-Type" content="text/css">
	<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
	<link href="../com/mierucchics.css" rel="stylesheet" type="text/css">
	</head>
	
	<body onBlur="focus()">
	 <form name="orgtree_checkbox" action="orgtree_checkbox.jsp" method="post">
	<div align="center">
	<br style="line-height:0.3em;">
	<input name='despatch' type='hidden' value=''>
	<input name='from' type='hidden' value='<%=request.getParameter("from")%>'>
	<%if(request.getParameter("checkboxflag") != null) {%>
	 <input name='checkboxflag' type='hidden'
	    value='<%=request.getParameter("checkboxflag")%>'>
	<%}%>
	<div id='request'></div>
	</div>
	</form>

  <script style="text/javaScript">
  <!--
  //'use strict';//ieで動いてもffで動かなくことがあった。変数の宣言をしないとき
  var from = document.forms[0].from.value;
  var doc = "";
  var x = window.opener.document [window.opener.bodyNam] [from+"Count"].value * 1;

  if(from == 'AplUserNo') {
    doc += "<input name='checkCount' type='hidden' value='0'>";
  } else if(from.indexOf('User') == 0 || from.indexOf('CcUserNo') == 0) {

    for(var i=0; i < x; i++) {
      doc += "<input name='checkedUserNo" + i + "' type='hidden' "
            +" value='" + window.opener.document [window.opener.bodyNam] [from+i].value + "'>"
        + "<input name='checkedOrgId" + i + "' type='hidden' "
           +" value='" + window.opener.document [window.opener.bodyNam] ['orgId' + from + i].value + "'>"
        ;
    };
    doc += "<input name='checkCount' type='hidden' value='"+x+ "'>";
  } else if(from.indexOf('CcOrgId') == 0) {

    // 組織選択部
    var checkCount=0;
    for(var i=0; i < x; i++) {
      yi = window.opener.document [window.opener.bodyNam] [from+i].value;
      doc += "<input name='checkedOrgId" + checkCount + "' type='hidden' "
        +" value='"+yi.replace("C", "")+"'>";
      // 直轄ONLY
      if(yi.indexOf("C") < 0) {
        doc += "<input name='directOrgId" + checkCount + "' type='hidden' "
          +" value='" + yi.replace("C", "")+"'>";
      };
      if(window.opener.bodyNam != 'drinfo_inp') {
        // 役職
        doc += "<input name='postNam" + checkCount + "' type='hidden' value=''>";
          ;
        // 協力会社除外
        if(window.opener.document [window.opener.bodyNam] ["flwException" + from + i].value != "") {
          doc += "<input name='empOnly" + checkCount + "' type='hidden' "
            +" value='"+yi.replace("C", "") + "'>";
        };
      };
      checkCount ++;
    };
    doc += "<input name='checkCount' type='hidden' "
      +" value='"+x+ "'>";
  } else if(from.indexOf('UserNo') < 0) {
    checkCount=0;
    // 管理部門SELECT部
    if(from.indexOf("OrgId") > 0) {
      rightFlg = "";
      if(from.indexOf("rightOrgId") == 0) {
        rightFlg = from.replace("rightOrgId", "");
      }else if(from.indexOf("toOrgId") == 0) {
        rightFlg = "C";
      };
      var grouporg_rightflg
       = window.opener.document [window.opener.bodyNam] ["groupOrg"+rightFlg][window.opener.document [window.opener.bodyNam] ["groupOrg"+rightFlg].selectedIndex].value;
      doc += "<input name='checkedOrgId" + checkCount + "' type='hidden' "
         +" value='"+grouporg_rightflg.replace("C", "") + "'>"
      // 役職
        + "<input name='postNam" + checkCount + "' type='hidden' "
          +" value='"+window.opener.document [window.opener.bodyNam] ["groupPostNam"+rightFlg].value + "'>"
        ;
      // 直轄ONLY
      directFlag = 0;
      if(grouporg_rightflg.indexOf("C") != 0) {
        doc += "<input name='directOrgId" + checkCount + "' type='hidden' "
            +" value='" + grouporg_rightflg.replace("C", "") + "'>";
      };

      // 協力会社除外
      if(window.opener.document [window.opener.bodyNam] ["groupFlw"+rightFlg].checked == true) {
        doc += "<input name='empOnly" + checkCount + "' type='hidden' "
           +" value='" + grouporg_rightflg.replace("C", "") + "'>";
      };
      doc += "<input name='addOpenOrg" + checkCount + "' type='hidden' "
        +" value='" + window.opener.document [window.opener.bodyNam].admOrgCsv.value + "'>";
      checkCount ++;
    };

    // 組織選択部
    for(var i=0; i < x; i++) {
      var fromi =window.opener.document [window.opener.bodyNam] [from+i].value;
      doc += "<input name='checkedOrgId"+checkCount + "' type='hidden' value='"+fromi+"'>";
      // 直轄ONLY
      if(fromi== "") {
        doc += "<input name='directOrgId" + checkCount + "' type='hidden' value='" + fromi+ "'>";
      };
      if(window.opener.bodyNam != 'drinfo_inp') {
        // 役職
        doc += "<input name='postNam" + checkCount + "' type='hidden' "
          +" value='" + window.opener.document [window.opener.bodyNam] ["postNam" + from + i].value + "'>"
          ;
        if(window.opener.document [window.opener.bodyNam] ["flwException" + from + i].value == "1") {
          doc += "<input name='empOnly" + checkCount + "' type='hidden' "
            +" value='" + fromi+ "'>";
        };
      };
      doc += "<input name='addOpenOrg" + checkCount + "' type='hidden' "
        +" value='" + fromi+ "'>";
      checkCount ++;
    };
    doc += "<input name='checkCount' type='hidden' value='" + checkCount + "'>";
  } else {
    doc += "<input name='checkCount' type='hidden' value='0'>";
  };

  doc += "<input name='bodyNam' type='hidden' value='" + window.opener.bodyNam + "'>";
  document.getElementById("request").innerHTML = doc;
  document.forms[0].submit();

  //-->
  </script>
  </body>
  </html>

<%}else { // end of %if(request.getParameter("despatch")==null)

	StringBuilder sbTmp = new StringBuilder();
	StringBuilder sbQry = new StringBuilder();

	ArrayList<Integer> orgIdList = new ArrayList<Integer>();
	ArrayList<String> orgNamList = new ArrayList<String>();
	ArrayList<String> upOrgCsvList = new ArrayList<String>();
	ArrayList<Integer> chkOrgIdList = new ArrayList<Integer>();
	ArrayList<Integer> dspLevelNoList = new ArrayList<Integer>();
	ArrayList<Integer> downwardFlagList = new ArrayList<Integer>();
	
	HashMap<Integer, Integer> opnOrgHashMap = new HashMap<Integer, Integer>();
	HashMap<Integer, Integer> checkedOrgHashMap = new HashMap<Integer, Integer>();
	HashMap<Integer, Integer> directOrgHashMap = new HashMap<Integer, Integer>();
	HashMap<Integer, Integer> checkedUserNoHashMap = new HashMap<Integer, Integer>();

	int checkcount = Integer.parseInt(request.getParameter("checkCount"));
	
	PreparedStatement ps0=null;
	PreparedStatement ps1=null;
	PreparedStatement ps2=null;

  for(int i=0; i < checkcount; i++) {
    if(request.getParameter("from").indexOf("User") >= 0) {
      checkedUserNoHashMap.put(
          Integer.parseInt(request.getParameter("checkedUserNo"+i))
          , Integer.parseInt(request.getParameter("checkedUserNo"+i)));
		if(ps0 == null){ps0 =db.prepareStatement(sbTmp
			.append(" select levelNo,orgid1,orgid2,orgid3,orgid4,orgid5,orgid6,orgid7,orgid8,orgid9,orgid10 ")
			.append(" from meorg")
			.append(" where orgid = ?")
			.append(" and (todate = '' or todate >= '") .append(strNowDate) .append("')")
			.append(" and fromdate <= '") .append(strNowDate) .append("'")
			.toString());sbTmp.delete(0,sbTmp.length());
		}
		ps0.setInt(1, Integer.valueOf( request.getParameter("checkedOrgId" + i)));
		ResultSet rsOpnOrg = ps0.executeQuery();

      if(rsOpnOrg.next()) {
        int levelno = rsOpnOrg.getInt("levelno")-1;

        for(int j=0; j < levelno; j++) {
          int opnorgidj1 = rsOpnOrg.getInt("orgid" + (j + 1));

          if(opnOrgHashMap.get(opnorgidj1) == null
              && opnorgidj1 != 0) {
            opnOrgHashMap.put(opnorgidj1, opnorgidj1);
          }
        }
      }
      rsOpnOrg.close();

    } else {
      checkedOrgHashMap.put(
          Integer.parseInt(request.getParameter("checkedOrgId" + i))
          , Integer.parseInt(request.getParameter("checkedOrgId" + i)));
      String directorgidi = request.getParameter("directOrgId" + i);

      if(directorgidi != null) {
        directOrgHashMap.put(
            Integer.parseInt(directorgidi)
            , Integer.parseInt(directorgidi));
      }

		if(ps1 == null){ps1 =db.prepareStatement(sbTmp
			.append(" select levelNo,orgid1,orgid2,orgid3,orgid4,orgid5,orgid6,orgid7,orgid8,orgid9,orgid10 ")
			.append(" from meorg")
			.append(" where orgid = ?")
			.append(" and (todate = '' or todate >= '") .append(strNowDate) .append("')")
			.append(" and fromdate <= '") .append(strNowDate) .append("'")
			.toString());sbTmp.delete(0,sbTmp.length());
		}
		ps1.setInt(1, Integer.valueOf( request.getParameter("checkedOrgId" + i)));
		ResultSet rsOpnOrg = ps1.executeQuery();

      if(rsOpnOrg.next()) {
        int opnlevelno_1 = rsOpnOrg.getInt("levelno") - 1;

        for(int j=0; j < opnlevelno_1; j++) {
          int opnorgidj1 = rsOpnOrg.getInt("orgid" + (j + 1));

          if(opnOrgHashMap.get(opnorgidj1) == null
              && opnorgidj1 != 0) {
            opnOrgHashMap.put(opnorgidj1, opnorgidj1);
          }
        }
      }
      rsOpnOrg.close();
    }
  }

  //String orgQuery = "";
  StringBuilder sbOrgQry = new StringBuilder();

  sbQry
  .append(" SELECT O.orgid, O.orgnam, O.levelno,O.sortno ")
  .append(" FROM (select orgid from orgright ")
  .append("       WHERE righttype='USER'")
  .append("     ) as R ")
  .append(" LEFT JOIN (select orgid,orgnam,levelno,sortno,todate,fromdate from meorg ")
  .append("          ) as O ")
  .append("   on R.orgid=O.orgid ")
  .append("   and (O.todate='' or O.todate>='") .append(strNowDate) .append("') ")
  .append("   and O.fromdate<= '") .append(strNowDate) .append("'")
  .append(" where O.orgid is not null")
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

    if(sbOrgQry.length()==0) {
    	sbOrgQry.append(" realorgid = ") .append(rsOrgList.getInt("orgid"));
    } else {
    	sbOrgQry.append(" or realorgid = ") .append(rsOrgList.getInt("orgid"));
    }
  }
  rsOrgList.close();

  for(int i=0; i < orgIdList.size(); i++) {
    /// SQL
	if(ps2 == null){ps2 =db.prepareStatement(sbTmp
		.append("SELECT orgid,orgnam,levelno,sortno ")
		.append("FROM meorg ")
		.append("WHERE uporgid = ?")
		.append("AND (todate='' or todate>='") .append(strNowDate) .append("') ")
		.append("AND fromdate<= '") .append(strNowDate) .append("'")
		.append("ORDER BY levelno DESC,sortno DESC ")
		.toString());sbTmp.delete(0,sbTmp.length());
	}
	ps2.setInt(1, Integer.valueOf( orgIdList.get(i)));
	ResultSet rs = ps2.executeQuery();

    /// 取得データの設定(検索された行数分ループ)
    while(rs.next()){
      if(downwardFlagList.get(i) == 0) {
        downwardFlagList.remove(i);
        downwardFlagList.add(i, 1);
      }
      downwardFlagList.add((i+1), 0);
      dspLevelNoList.add((i+1), dspLevelNoList.get(i) + 1);
      orgIdList.add((i+1), rs.getInt("orgid"));
      orgNamList.add((i+1), rs.getString("orgnam"));
      upOrgCsvList.add((i+1), upOrgCsvList.get(i) + "," + rs.getInt("orgid"));
            sbOrgQry.append(" or realorgid = ") .append(rs.getInt("orgid"));
    }
    rs.close();
  }

  if(request.getParameter("from").indexOf("User") >= 0) {
    objSql.executeUpdate(sbTmp
      .append(" select * into temp tempuser ")
      .append(" from meuser")
      .append(" where (") .append(sbOrgQry) .append(")")
      .append(" and (todate = '' or todate >= '") .append(strNowDate) .append("')")
      .append(" and fromdate <= '") .append(strNowDate) .append("'")
      .toString());sbTmp.delete(0,sbTmp.length());
      
    sbOrgQry.delete(0,sbOrgQry.length());
  }
  %>
  <html>
  <head>
  <meta http-equiv="Content-Style-Type" content="text/css">
  <meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
  <link href="../com/mierucchics.css" rel="stylesheet" type="text/css">
  <title>組織表</title>
  </head>

  <body onBlur="focus()">
  <table class="header"><tr><th>
  <%if(request.getParameter("from").indexOf("User") < 0) {%>
    組織選択(複数)
  <%} else {%>
    メンバ選択(複数)
  <%}%>
  </th></tr></table>

  <form name="orgtree_checkbox" action="orgtree_checkbox.jsp" method="post">
  <div align="center">
  <br style="line-height:0.2em;">

  <input name='despatch' type='hidden' value=''>
  <input name='from' type='hidden' value='<%=request.getParameter("from")%>'>

  <table class="noborder">
  <tr><td style="text-align:left;">

  <table id='0' class="noborder" >
  <%
  int tableNo=1;
  int userCounter=0;
  int[] tableNoByLevel = new int[50];
  Arrays.fill(tableNoByLevel, 0);
  StringBuilder sbTableList = new StringBuilder();
  StringBuilder sbCheckedList = new StringBuilder();

  int orgidlistsize = orgIdList.size();

  for (int i=0; i < orgidlistsize; i++) {
    if(i == 0 || dspLevelNoList.get(i) == dspLevelNoList.get(i - 1)) {%>
    <tr>
    <%
      if(i < orgIdList.size() - 1
          && dspLevelNoList.get(i + 1) > dspLevelNoList.get(i)) {%>
      <td id='downwardMark<%=tableNo+1%>'>
        <%
        if(opnOrgHashMap.get(orgIdList.get(i)) != null) {
             %><a href ='javaScript:clickMinus("<%=tableNo+1%>");'>－</a><%
        } else {
          %><a href ='javaScript:clickPlus(<%=tableNo+1%>);'>＋</a>
          <br>
          <%
          sbTableList .append(",") .append(tableNo + 1);
        }
      } else {
        %><td><img border='0' src='../img/trans.gif' width='5' height='0'><%
      }%>
      </td>
      <td><%

   } else if(dspLevelNoList.get(i) > dspLevelNoList.get(i - 1)) {
      %><tr>
      <td><img border='0' src='../img/trans.gif' width='4' height='0'></td>
      <td style="vertical-align:top;" colspan='4'>
      <%
          int desplevelnodeff = dspLevelNoList.get(i) - dspLevelNoList.get(i - 1);
          for(int j=0; j < desplevelnodeff; j++) {
            tableNo ++;
            tableNoByLevel[dspLevelNoList.get(i)] = tableNo;
            %>
            <table class="noborder" id="<%=tableNo%>">
            <tr>
            <%if(j == dspLevelNoList.get(i) - dspLevelNoList.get(i - 1) - 1) {
              if(i < orgIdList.size() - 1 && dspLevelNoList.get(i + 1) > dspLevelNoList.get(i)) {
                %><td id='downwardMark<%=tableNo+1%>'><%
                    if(opnOrgHashMap.get(orgIdList.get(i)) != null) {%>
                    <a href ='javaScript:clickMinus("<%=tableNo+1%>")'>－</a>
                    <%
                    } else {
                      %><a href ='javaScript:clickPlus("<%=tableNo+1%>")'>＋</a><%
                      sbTableList .append(",") .append(tableNo + 1);
                    }
              } else {
                %><td><img border='0' src='../img/trans.gif' width='4' height='0'><%
              }
              %></td><%
            } else {
              %><td><img border='0' src='../img/trans.gif' width='4'></td><%
            }
            %><td><%
          }
        } else { // end of else if(dspLevelNoList.get(i) > dspLevelNoList.get(i - 1))

          int deplevelnodeff = dspLevelNoList.get(i - 1) - dspLevelNoList.get(i);
          for(int j=0; j < deplevelnodeff; j++) {
           %></table>
           </td>
           </tr><%
          }
          %><tr><%

          if(i < orgIdList.size() - 1 && dspLevelNoList.get(i + 1) > dspLevelNoList.get(i)) {
            %><td id='downwardMark<%=tableNo+1%>'><%
                if(opnOrgHashMap.get(orgIdList.get(i)) != null) {
                 %><a href ='javaScript:clickMinus("<%=tableNo+1%>");'>－</a><%
                } else {
                 %><a href ='javaScript:clickPlus("<%=tableNo+1%>");'>＋</a><%
                  sbTableList .append(",") .append(tableNo + 1);
                }
          } else {
            %><td><img border='0' src='../img/trans.gif' width='4' height='0'><%
          }
          %></td>
          <td>
      <%}// end of else of else if(dspLevelNoList.get(i) > dspLevelNoList.get(i - 1))
    String checked = "";
    if(request.getParameter("from").indexOf("User") < 0) {//ここからユーザ選択用
      if(request.getParameter("checkboxflag") == null) {
        %>
        <a href ='javaScript:setOrg("<%=i%>");'>
          <%=orgNamList.get(i)%>
        </a>
        <input name='orgId<%=i%>' type='hidden' value='<%= orgIdList.get(i) %>'>
        <input name='tableNo<%=i%>' type='hidden' value='<%= tableNo%>'>
        <input name='dspLevelNo<%=i%>' type='hidden' value='<%= dspLevelNoList.get(i) %>'>
        </td>
        <%
      } else { // end of if(request.getParameter("checkboxflag") == null)
        checked = "";
        if(checkedOrgHashMap.get(orgIdList.get(i)) != null) {
          checked = "checked";
          sbCheckedList .append("|") .append(Integer.toString(i));
        }
        %>
        <input name='orgId<%=i%>' type='checkbox' value='<%=orgIdList.get(i)%>'  <%=checked%>
              onClick="orgClick('<%=i %>');"><%=orgNamList.get(i)%>
        <input name='tableNo<%=i %>' type='hidden' value='<%=tableNo %>'>
        <input name='dspLevelNo<%=i %>' type='hidden' value='<%=dspLevelNoList.get(i)%>'>
        </td>

        <%
        if(!request.getParameter("bodyNam").equals("drinfo_inp")) {
          /// 役職選択ボタン
          %>
          <td style="text-align:right;">
          <table class="noborder">
          <tr><td nowrap id='areaPostNam"<%=i%>"' width='100%'>
          <input name='postNam"<%=i%>"' type='hidden' value=''>
          </td><td>
          <input type='button' value='役職選択' onclick='postWin("<%=i%>");'>
          </td></tr>
          </table>
          </td>
          <%
        }

        /// 直轄選択チェックボックス
        %><td nowrap><%
        if(downwardFlagList.get(i) == 1) {
          checked = "";
          if(directOrgHashMap.get(orgIdList.get(i)) != null) {
            checked = "checked";
          }
          %>
          <input name='directFlg<%=i%>' type='checkbox' value='DIRECT'  <%=checked%> >直轄ONLY<%
        }
        %>
        <td>
        <%if(!request.getParameter("bodyNam").equals("drinfo_inp")) {
          /// 協力会社社員チェックボックス
          %>
          <td nowrap width='100%'>
             <input name='flwException<%=i%>' type='checkbox' value='<%=orgIdList.get(i)%>'>協力会社の方を除く
          </td>
          <%
        }
      }// else end of if(request.getParameter("checkboxflag") == null)
      %></tr><%
    } else { //end of if(request.getParameter("from").indexOf("User") < 0)　ここまでは人選択

      %><%=orgNamList.get(i)%>
      <%
      //これからが組織選択用
      ResultSet rsUser = objSql.executeQuery(sbTmp
        .append(" select T.bossFlg,T.styleCd,T.statusCd")
        .append(",T.userNo,T.usernam,T.postNam,T.userid,T.compcd")
        .append(",S.compcd ")
        .append(" from (select * from tempuser")
        .append("       where realorgid = ") .append(orgIdList.get(i))
        .append("         and (todate = '' or todate >= '") .append(strNowDate) .append("')")
        .append("         and fromdate <= '") .append(strNowDate) .append("'")
        .append("      ) as T ")
        .append(" left join (select stylecd,compcd from psstyle ")
        .append("           ) as S ")
        .append("   on T.stylecd = S.stylecd")
        .append(" where S.stylecd is not null ")
        .append(" order by bossflg desc, stylecd, statuscd")
        .toString());sbTmp.delete(0,sbTmp.length());

      HashMap<String, String> userNamHashMap = new HashMap<String, String>();
      while(rsUser.next()) {
        checked = "";
        if(checkedUserNoHashMap.get(rsUser.getInt("userno")) != null) {
              checked = "checked";
              sbCheckedList .append("|") .append(userCounter);
        }
        String userNo =rsUser.getString("userno");
        String stylecd =rsUser.getString("stylecd");
        String userNam =rsUser.getString("usernam");
        String postNam =rsUser.getString("postnam");
        userNam = sbTmp .append(rsUser.getString("usernam").substring(0,rsUser.getString("usernam").indexOf(" ")))  .append(rsUser.getString("postnam")) 
            		.toString();sbTmp.delete(0,sbTmp.length());
        
        if(userNamHashMap.get(userNam) != null) {
          userNam = sbTmp .append(rsUser.getString("usernam")) .append(rsUser.getString("postnam")) 
        		  .toString();sbTmp.delete(0,sbTmp.length());
        }
        String flwFlg = "0";
        if(rsUser.getString("userid").indexOf("sh") == 0
        || rsUser.getString("compcd").equals("TEMP")) {
          flwFlg = "1";
        }
        if(request.getParameter("checkboxflag") == null) {
          %>
          <a href ='javaScript:setMemb(<%=userCounter%>);'><%=userNam%></a>
          <input name='userNo<%=userCounter%>' type='hidden' value='<%=userNo%>'>
          <input name='userNam<%=userCounter%>' type='hidden' value='<%=userNam%>'>
          <input name='postNam<%=userCounter%>' type='hidden' value='<%=postNam%>'>
          <input name='flwFlg<%=userCounter%>' type='hidden' value='<%=flwFlg%>'>
          <input name='userOrgId<%=userCounter%>' type='hidden' value='<%=orgIdList.get(i)%>'>
          <input name='userOrgNam<%=userCounter%>' type='hidden' value="<%=orgNamList.get(i)%>">
          <input name='userUpOrgCsv<%=userCounter%>' type='hidden' value='<%=upOrgCsvList.get(i)%>'>
          <input name='tableNo<%=userCounter%>' type='hidden' value='<%=tableNo%>'>
          <input name='dspLevelNo<%=userCounter%>' type='hidden' value='<%=dspLevelNoList.get(i)%>'>
          <%
        } else {// end of if(request.getParameter("checkboxflag") == null)
              %>
          <input name='userNo<%=userCounter%>' type='checkbox' value='<%=userNo%>' <%=checked%>  onClick='userClick(<%=userCounter%>);'>
          <%=userNam%>
          <input name='userNam<%=userCounter%>' type='hidden' value='<%=userNam%>'>
          <input name='postNam<%=userCounter%>' type='hidden' value='<%=postNam%>'>
          <input name='flwFlg<%=userCounter%>' type='hidden' value='<%=flwFlg%>'>
          <input name='userOrgId<%=userCounter%>' type='hidden' value='<%=orgIdList.get(i)%>'>
          <input name='userOrgNam<%=userCounter%>' type='hidden' value="<%=orgNamList.get(i)%>">
          <input name='userUpOrgCsv<%=userCounter%>' type='hidden' value='<%=upOrgCsvList.get(i)%>'>
          <input name='tableNo<%=userCounter%>' type='hidden' value='<%=tableNo%>'>
          <input name='dspLevelNo<%=userCounter%>' type='hidden' value='<%=dspLevelNoList.get(i)%>'>
          <%
        }// end of else of if(request.getParameter("checkboxflag") == null)

        userCounter ++;
      }// end of while(rsUser.next())
      rsUser.close();
      %></td></tr><%
    }// end of else of if(request.getParameter("from").indexOf("User") < 0)
  if(i == orgIdList.size() - 1) {
    int dsplevelnoi = dspLevelNoList.get(i);
     for(int j=0; j < dsplevelnoi; j++) {
     %>
      </table>
      </td>
      </tr>
     <%}
   }
  %>
  <tr><td>
  <input name='thisOrgId<%=i %>' value='<%=orgIdList.get(i)%>' type='hidden'>
  <input name='orgNam<%=i %>' value='<%=orgNamList.get(i)%>' type='hidden'>
  <input name='upOrgCsv<%=i%>' value='<%=upOrgCsvList.get(i)%>' type='hidden'>
  <input name='downwordFlg<%=i %>' value='<%=downwardFlagList.get(i)%>' type='hidden'>
  </td></tr>
  <%}// end of for (int i=0; i < orgIdList.size(); i++)%>
  </table>
  <input name='tableList' type='hidden' value='<%=sbTableList.toString()%>'>
  <input name='checkedList' type='hidden' value='<%=sbCheckedList.toString()%>'>
  <input name='bodyNam' type='hidden' value='<%=request.getParameter("bodyNam")%>'>

  <br style="line-height:0.3em;">

  <%if(request.getParameter("checkboxflag") != null) {%>
   <div style="text-align:left;">
    <input type='button' value='　SET　' onClick='setRight();'>
   </div>
  <%}%>

  </div>
  </form>

  <script type="text/javaScript" src="../com/com_utf8.js"></script>
  <script type="text/javaScript">
  <!--
  var D = document.all;
  checkedLineList = "";
  from = D.from.value;
  tableClear();
  moveTo(20,20);
  resizeTo(screen.availWidth-20,screen.availHeight-20);

  function tableClear() {
    tableSplit = D.tableList.value.split(",");
    var tablelen = tableSplit.length;

    for(var i=0; i < tablelen; i++) {
    	var tablei = tableSplit[i];
      if(tablei != '') {
        document.getElementById(tablei).style.display = 'none';
      };
    }
    checkedLineList = D.checkedList.value;
  }

  function clickPlus(nextNo) {
    document.getElementById('downwardMark' + nextNo).innerHTML
         = "<a href ='javaScript:clickMinus(" + nextNo + ");'>－</a>";
    document.getElementById(nextNo).style.display = 'block';
  }

  function clickMinus(nextNo) {
    document.getElementById('downwardMark' + nextNo).innerHTML
        = "<a href ='javaScript:clickPlus(" + nextNo + ");'>＋</a>";
    document.getElementById(nextNo).style.display = 'none';
    // 非表示部チェッククリア
    checkedSplit = checkedLineList.split("|");
    checkedLineList = "";
    var checkedlen = checkedSplit.length;
    
    var D = document.all;

    for(var i=0; i < checkedlen; i++) {
      var dsplevelnochecked = D ["dspLevelNo"+checkedSplit[i]].value;
      var checkedi = checkedSplit[i] ;

      if(checkedi != "") {
        if(from.indexOf('User') > 0) {
          checked = 'checked';

          if(dsplevelnochecked* 1 > 0) {
            for(j = 0; ; j++){
              var tablenochecked = D ["tableNo"+(checkedi * 1 - j)].value;

              if(document.getElementById(tablenochecked).style.display == 'none') {
                checked = "";
                break;
              } else if(dsplevelnochecked* 1
                             <= D ["dspLevelNo"+(checkedi * 1 - j)].value * 1) {
                break;
              } else if(tablenochecked*1 == 0) {
                break;
              };
            };
          }
          if(checked != '') {
            checkedLineList = checkedLineList.concat("|") .concat(checkedi);
          } else {
            document.forms[0] ["userNo"+checkedi].checked = false;
          };
        } else {
          checked = 'checked';
          if(dsplevelnochecked* 1 > 0) {
            for(j = 0; ; j++){
              var tablenochecked =D ["tableNo"+(checkedi * 1 - j)].value ;

              if(document.getElementById(tablenochecked).style.display == 'none') {
                checked = "";
                break;
              } else if(dsplevelnochecked*1 <= D ["dspLevelNo"+(checkedi * 1 - j)].value * 1) {
                break;
              } else if(tablenochecked*1 == 0) {
                break;
              };
            };
          }
          if(checked != '') {
            checkedLineList = checkedLineList.concat("|") .concat(checkedi);
          } else {
            document.forms[0] ["thisOrgId"+checkedi].checked = false;
          };
        };
      };
    };
  }

  // 直轄、協力会社チェックボックス表示
  function orgClick(line) {
    if(document.forms[0] ["orgId"+line].checked==true){
      // 選択リスト作成
      checkedSplit = checkedLineList.split("|");
      setFlg=0;

      if(checkedLineList == "") {
        checkedLineList = "|" + line;
      } else if(checkedSplit.length > 0
          && line > parseInt(checkedSplit[checkedSplit.length-1])) {
        checkedLineList = checkedLineList.concat("|") .concat(line);
      } else if(checkedSplit[0] != "" && line < parseInt(checkedSplit[0])) {
        checkedLineList = "|" .concat(line) .concat(checkedLineList);
      } else {
        checkedLineList = "";
        for(var i=0; i < checkedSplit.length; i++) {
        	var checkedi = checkedSplit[i];

          if(checkedi != "") {
            if(line < parseInt(checkedi) && setFlg == 0) {
              checkedLineList = checkedLineList.concat("|") .concat(line);
              setFlg = 1;
            }
            checkedLineList = checkedLineList.concat("|") .concat(checkedi);
          };
        };
      };
    } else {
      checkedLineList = (checkedLineList+"|").replace("|"+line+"|","|");
      checkedLineList = checkedLineList.replace("||","|");
      if(checkedLineList == "||" || checkedLineList == "|") {
        checkedLineList = "";
      };
    };
  }

  function userClick(no) {
    var D = document.all;
	if(D ["userNo"+no].checked==true){
      // 選択リスト作成
      checkedSplit = checkedLineList.split("|");
      setFlg=0;
      
      if(checkedLineList == "") {
        checkedLineList = "|" .concat(no);
      } else if(checkedSplit.length > 0
          && no > parseInt(checkedSplit[checkedSplit.length-1])) {
        checkedLineList =  checkedLineList.concat("|") .concat(no);
      } else if(checkedSplit[0] != "" && no < parseInt(checkedSplit[0])) {
        checkedLineList = "|" .concat(no) .concat(checkedLineList);
      } else {
        checkedLineList = "";
        var checkedlen = checkedSplit.length;

        for(var i=0; i < checkedlen; i++) {
        	var checkedi = checkedSplit[i];
          if(checkedi != "") {
            if(no < parseInt(checkedi) && setFlg == 0) {
              checkedLineList = checkedLineList.concat("|") .concat(no);
              setFlg = 1;
            }
            checkedLineList = checkedLineList.concat("|") .concat(checkedi);
          };
        };
      };
    } else {
      checkedLineList = (checkedLineList+"|").replace("|"+no+"|","|");
      checkedLineList = checkedLineList.replace("||","|");
      if(checkedLineList == "||" || checkedLineList == "|") {
        checkedLineList = "";
      };
    };
  }

  function setRight() {
		var D = document.all;
	  	var list = "";
		var cnt=0;

		var checkedSplit = checkedLineList.split("|");
		var bodynam = D.bodyNam.value;
		var checkedlen = checkedSplit.length;

    for(var i=0; i < checkedlen; i++) {
    	var checkedi = checkedSplit[i];

      if(checkedi != "") {
        if(from.indexOf('User') >= 0) {
          var org= D ["userOrgId"+checkedi].value;
          var orgnam= D ["userOrgNam"+checkedi].value;
          var csv= D ["userUpOrgCsv"+checkedi].value;
          var id= D ["userNo"+checkedi].value;
          var nam= D ["userNam"+checkedi].value;
          var postnam= '';
          var flw = 0;

          if(bodynam!= 'drinfo_inp') {
            postnam= D ["postNam"+checkedi].value;
            flw= D ["flwFlg"+checkedi].value;
          }
          window.opener.setRight(cnt, id, nam, '', flw, csv, org, orgnam, postnam);
          cnt++;
        } else {

          flw = "0";
          var postNam = '';
          var orgid = D ["thisOrgId"+checkedi].value;
          var orgnam = D ["orgNam"+checkedi].value;
          var csv = D ["upOrgCsv"+checkedi].value;

          if(D.bodyNam.value != 'drinfo_inp') {
            postNam = D ["postNam"+checkedi].value;
            if(D ["flwException"+checkedi].checked==true) {
              flw = "1";
            };
          }
          if(D ["downwordFlg"+checkedi].value == "1") {
            if(D ["directFlg"+checkedi].checked==true) {
              window.opener.setRight(cnt, orgid, orgnam+"直轄", '', flw, csv, orgid, orgnam+"直轄", postNam);
            } else {
              window.opener.setRight(cnt, orgid, orgnam+"ALL", 'C', flw, csv, orgid, orgnam+"ALL", postNam);
            };
          } else {
            window.opener.setRight(cnt, orgid, orgnam, '', flw, csv, orgid, orgnam, postNam);
          };
          cnt++;
        };
      };
    }
    window.opener.focus();
    window.opener.displayRight(from,cnt);
    window.close();
  }

	function setOrg(line) {
		var D = document.all;
		var orgnam = D ["orgNam"+line].value;
		var orgid = D ["orgId"+line].value;
		
		window.opener.setOrg(orgid, orgnam);
		window.opener.focus();
		window.close();
	}

	function setMemb(line) {
		var D = document.all;
		var orgnam= D ["userOrgNam"+line].value;
		var userno= D ["userNo"+line].value;
		var usernam= D ["userNam"+line].value;
		
		window.opener.setMemb(userno, usernam, orgnam);
		
		window.opener.focus();
		window.close();
	}

  // 役職呼び出し
  function postWin(line){
    var field = "postNam" + line;
    var orgId = document.forms[0] ["orgId" + line].value;
    subwin = window.open(
        "PostSelection"
        +"?field=" + field
        + "&orgId=" + orgId
        , "postChoiceWin"
        , "scrollbars=1,resizable=1,top=10,left=30,width=500,height=400");
  }

  // 役職SET
  function setPostNam(postNamList,field) {
    var doc = "<input name='"+field+"' type='hidden' value='"+postNamList+"'>";
    if(postNamList != "") {
      doc += "(" + postNamList + ")";
    }
    document.getElementById("area" + field).innerHTML = doc;
  };

  //-->
  </script>
  </body>
  </html>
<%}// end of else of %if(request.getParameter("despatch")==null)%>

<%
objSql.close();
db.close();
%>

<!--******************************** End of orgtree_checkbox.jsp ******************************-->