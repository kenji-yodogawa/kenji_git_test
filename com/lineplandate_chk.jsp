<!--***********************************************************
	＜生産計画日付チェック＞
	File Name :lineplandate_chk.jsp
	Author	:f-moriwaki
	Date	:2014-10-23
	
	Update 
	2014-10-27 kaneshi スタイルシートを適用
	           select * のカラム指定
	           ResultSetを読んだら、すぐ閉じる
	2015-01-01 kaneshi 高速化の追加 動作チェックずみ
	2015-02-27 kaneshi StringBuilder ,String#concatで高速化
	2015-06-09 kaneshi assylinecd1 was not found in this resultset
	2015-08-08 kaneshi PreparedStatement で高速化
	2015-09-05 kaneshi 文字コードをＵＴＦ－８へ
	2015-10-20 kaneshi 登録した日＋ＬＴのカレンダを点検するようコメント追加
	                     ps9でエラーがでてしまっている。
	                     400行目で、何もでないといっている 　解消した
	2018-02-26 kaneshi テーブル結合前の絞り込み 1箇所
	　　　　　　　　　　　　　　　　　動作ＯＫ
	2018-06-21 kaneshi SQLバグあり

               
*********************************************************** -->

<%@ page contentType="text/html;charset=UTF-8"
		import="java.io.*,java.sql.*,java.net.*,java.util.*,java.text.*" %>

<% String strRight="USER"; %>
<%@ include file="../header_utf8.jsp" %>

<%if(request.getParameter("partNo")==null) {%>
	<html>
	<head>
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
<!-- 	<link href="../com/mierucchics.css" rel="stylesheet" type="text/css"> -->
	<title>生産計画日付チェック</title>
	</head>
	<body bgcolor="#F9FBE0">

	<form name="lineplandate_chk" action="lineplandate_chk.jsp" method="POST">

	<div align="center">
	<table class="header">
	<tr><th>生産計画日付チェック</th></tr>
	</table>
	<br>

	<div id = 'request'></div>
	</div>
	</form>

	<script type="text/javaScript"><!--
	plancount = <%=request.getParameter("planCount")%>;

	doc = "";
	if(window.opener.name=="fr_main"){
		doc = "<input name = 'partNo' type = 'hidden' value='" + window.opener.parent.fr_main.document.lineplan_inp ["PlanPartNo"+plancount].value + "'>"
			+ "<input name = 'calArea' type = 'hidden' value='<%=request.getParameter("calArea")%>'>"
			+ "<input name = 'planCount' type = 'hidden' value='<%=request.getParameter("planCount")%>'>"
			+ "<input name = 'seq' type = 'hidden' value='<%=request.getParameter("seq")%>'>"
			+ "<input name = 'KIKIMEI_ID' type = 'hidden' value='" + window.opener.parent.fr_main.document.lineplan_inp ["KIKIMEI_ID"+plancount].value + "'>"
			+ "<input name = 'planDate' type = 'hidden' value='" + window.opener.parent.fr_main.document.lineplan_inp ["PlanDate"+plancount+"-0"].value + "'>"
			+ "<input name = 'despatchDate' type = 'hidden' value='" + window.opener.parent.fr_main.document.lineplan_inp ["despatchDate"+plancount+"-0"].value + "'>";

		if(window.opener.parent.fr_main.document.lineplan_inp ["assyLineCd"+plancount].type =="select-one") {
			doc += "<input name = 'assyLineCd' type = 'hidden' value='" + window.opener.parent.fr_main.document.lineplan_inp ["assyLineCd"+plancount][window.opener.parent.fr_main.document.lineplan_inp ["assyLineCd"+plancount].selectedIndex].value + "'>";
		} else {
			doc += "<input name = 'assyLineCd' type = 'hidden' value='" + window.opener.parent.fr_main.document.lineplan_inp ["assyLineCd"+plancount].value + "'>";
		}
		if(window.opener.parent.fr_main.document.lineplan_inp ["despatchLineCd"+plancount].type =="select-one") {
			doc += "<input name = 'despatchLineCd' type = 'hidden' value='" + window.opener.parent.fr_main.document.lineplan_inp ["despatchLineCd"+plancount][window.opener.parent.fr_main.document.lineplan_inp ["despatchLineCd"+plancount].selectedIndex].value + "'>";
		} else {
			doc += "<input name = 'despatchLineCd' type = 'hidden' value='" + window.opener.parent.fr_main.document.lineplan_inp ["despatchLineCd"+plancount].value + "'>";
		}
	}else{
		doc = "<input name = 'partNo' type = 'hidden' value='" + window.opener.parent.document.linedayplan_sc ["PlanPartNo"+plancount].value + "'>"
			+ "<input name = 'calArea' type = 'hidden' value='<%=request.getParameter("calArea")%>'>"
			+ "<input name = 'planCount' type = 'hidden' value='<%=request.getParameter("planCount")%>'>"
			+ "<input name = 'seq' type = 'hidden' value='<%=request.getParameter("seq")%>'>"
			+ "<input name = 'KIKIMEI_ID' type = 'hidden' value='" + window.opener.parent.document.linedayplan_sc ["KIKIMEI_ID"+plancount].value + "'>"
			+ "<input name = 'planDate' type = 'hidden' value='" + window.opener.parent.document.linedayplan_sc ["PlanDate"+plancount+"-0"].value + "'>"
			+ "<input name = 'despatchDate' type = 'hidden' value='" + window.opener.parent.document.linedayplan_sc ["despatchDate"+plancount+"-0"].value + "'>";

		if(window.opener.parent.document.linedayplan_sc ["assyLineCd"+plancount].type =="select-one") {
			doc += "<input name = 'assyLineCd' type = 'hidden' value='" + window.opener.parent.document.linedayplan_sc ["assyLineCd"+plancount][window.opener.parent.document.linedayplan_sc ["assyLineCd"+plancount].selectedIndex].value + "'>";
		} else {
			doc += "<input name = 'assyLineCd' type = 'hidden' value='" + window.opener.parent.document.linedayplan_sc ["assyLineCd"+plancount].value + "'>";
		}
		if(window.opener.parent.document.linedayplan_sc ["despatchLineCd"+plancount].type =="select-one") {
			doc += "<input name = 'despatchLineCd' type = 'hidden' value='" + window.opener.parent.document.linedayplan_sc ["despatchLineCd"+plancount][window.opener.parent.document.linedayplan_sc ["despatchLineCd"+plancount].selectedIndex].value + "'>";
		} else {
			doc += "<input name = 'despatchLineCd' type = 'hidden' value='" + window.opener.parent.document.linedayplan_sc ["despatchLineCd"+plancount].value + "'>";
		}
	}

	document.getElementById("request").innerHTML = doc;

	document.forms[0].submit();
	//-->
	</script>
	</body>
  </html>
<%
}else{
	StringBuilder sbTmp = new StringBuilder();
	StringBuilder sbQry = new StringBuilder();
	PreparedStatement ps0=null;
	PreparedStatement ps1=null;
	PreparedStatement ps2=null;
	PreparedStatement ps3=null;
	PreparedStatement ps4=null;
	PreparedStatement ps5=null;
	PreparedStatement ps6=null;
	PreparedStatement ps7=null;
	PreparedStatement ps8=null;
	PreparedStatement ps9=null;

	Calendar wrkCal = Calendar.getInstance();

	String errMsg = "";
	String assyLineCd = "";
	String despatchLineCd = "";
	ArrayList<Integer> lineLTList = new ArrayList<Integer>();
	ArrayList<String> lineCdList = new ArrayList<String>();

	ResultSet rsZyu=objSql.executeQuery(sbTmp
		.append(" select partNo from mezyumei")
		.append(" where KIKIMEI_ID=") .append(request.getParameter("KIKIMEI_ID"))
		.toString());sbTmp.delete(0,sbTmp.length());

	String upEqpClass = "";

	if(rsZyu.next()) {
		if(ps0 == null){ps0 =db.prepareStatement(sbTmp
			.append(" select eqpclass from partdat")
			.append(" where PartNo=?")
			.toString());sbTmp.delete(0,sbTmp.length());
		}
		ps0.setString(1, rsZyu.getString("partno"));
		ResultSet rsUpPart=ps0.executeQuery();

		if(rsUpPart.next()) {
			upEqpClass = rsUpPart.getString("eqpclass");
		}
		rsUpPart.close();
	}
	rsZyu.close();

	//投入日を求める


	ResultSet rsPart=objSql.executeQuery(sbTmp
		.append(" select eqpClass,category,partType ")//  ps1 対応せず
		.append(" from partdat")
		.append(" where PartNo='") .append(request.getParameter("partNo")) .append("'")
		.toString());sbTmp.delete(0,sbTmp.length());

	rsPart.next();
	String eqpClass = rsPart.getString("eqpclass");
	String category = rsPart.getString("category");
	//購買部品
	if(rsPart.getString("parttype").equals("2")) {
		assyLineCd = request.getParameter("assyLineCd");
		despatchLineCd = request.getParameter("despatchLineCd");
		lineCdList.add(request.getParameter("assyLineCd"));
	} else {
		//かんばん
		ResultSet rsKbBase=objSql.executeQuery(sbTmp
			.append(" select * from kanbanbase ")
			.append(" where PartNo='") .append(request.getParameter("partNo")) .append("'")
			.toString());sbTmp.delete(0,sbTmp.length());

		if(rsKbBase.next()){
			despatchLineCd = rsKbBase.getString("acclinecd");

			for(int i=0; i<5; i++){
				if(!rsKbBase.getString("AssyLineCd"+i).equals("")) {
					lineCdList.add(rsKbBase.getString("AssyLineCd"+i));
					if(assyLineCd.equals("")) {
						assyLineCd = rsKbBase.getString("AssyLineCd"+i);
					}
				} else {
					break;
				}
			}
		//製品
		} else if(category.equals("EQP")) {
			if(!eqpClass.equals("")) {
				ResultSet rsLineEqp=objSql.executeQuery(sbTmp
					.append(" select lineCd from lineeqp")// ps　対応せず
					.append(" where classcd='") .append(eqpClass) .append("'")
					.toString());sbTmp.delete(0,sbTmp.length());

				if(rsLineEqp.next()){
					lineCdList.add(rsLineEqp.getString("linecd"));

					assyLineCd = rsLineEqp.getString("linecd");
					if(ps4 == null){ps4 =db.prepareStatement(sbTmp
						.append(" select lineCd from lineeqp")
						.append(" where classcd=?")
						.toString());sbTmp.delete(0,sbTmp.length());
					}
					ps4.setString(1, upEqpClass);
					ResultSet rsUpLineEqp=ps4.executeQuery();

					if(rsUpLineEqp.next()){
						despatchLineCd = rsUpLineEqp.getString("linecd");
					} else {
						despatchLineCd = assyLineCd;
					}
					rsUpLineEqp.close();
				} else {
					errMsg = "製品製造ライン登録を行ってください。";
				}
			} else {
				errMsg = "品番登録で製品分類を登録してください。";
			}
		} else {
		//下位かんばん有無チェック
			ArrayList<String> linePartList = new ArrayList<String>();
			ArrayList<String> kbPartList = new ArrayList<String>();
			kbPartList.add(request.getParameter("partNo"));

			for(int i = 0; i < kbPartList.size(); i++) {
				if(ps5 == null){ps5 =db.prepareStatement(sbTmp
					.append(" select K.partno,K.acclinecd,")
					.append("P.category,P.parttype,LE.linecd")
					.append(" from (select elmPartNo from pldat")
					.append("        where PartNo=?")
					.append("         and objtype='PART'")//20130313
					.append("         and todate =''")
					.append("      ) as L ")
					.append(" left join (select partNo,category,partType,eqpclass from partdat")//20160621修正
					.append("           ) as P ")
					.append("   on L.elmpartno = P.partno")
					.append("   and (P.parttype='5' or P.parttype = '4')")
					.append(" left join (select partNo,acclinecd from kanbanbase")
					.append("           ) as K ")// nullを利用
					.append("   on K.partno = L.elmpartno")
					.append(" left join (select classcd,linecd from lineeqp")
					.append("           ) as LE ")
					.append("   on LE.classcd = P.eqpclass")
					.append(" where P.partno is not null")
					//.append("   and K.partNo is not null ")//つけちゃだめ
					//.append("   and LE.linecd is not null")// nullを利用
					.toString());sbTmp.delete(0,sbTmp.length());
				}
				ps5.setString(1, kbPartList.get(i));
				ResultSet rsKbPl=ps5.executeQuery();

				//すべてのかんばん納入先が同一なら採用
				while(rsKbPl.next()){
					String lineCd = "";

					if(rsKbPl.getString("parttype").equals("4")) {
					//ダミー品番は下位展開へ
						kbPartList.add(rsKbPl.getString("partno"));
					} else if(rsKbPl.getString("parttype").equals("5")) {
						if(rsKbPl.getString("acclinecd")!=null) {
							lineCd = rsKbPl.getString("acclinecd");
						} else
						if(rsKbPl.getString("category").equals("EQP") 
								&& rsKbPl.getString("linecd")!=null) {
							lineCd = rsKbPl.getString("linecd");
						}

						if(!lineCd.equals("")) {
							linePartList.add(rsKbPl.getString("partno"));

							if(despatchLineCd.equals("")) {
								despatchLineCd = lineCd;
							}
						} else {
						//ライン未設定は下位展開へ
							kbPartList.add(rsKbPl.getString("partno"));
						}
					}
				}

				if(!errMsg.equals("")) {
					break;
				}
			}
		}
		rsKbBase.close();
	}

	for(int i=0; i < lineCdList.size(); i++){
		if(ps6 == null){ps6 =db.prepareStatement(sbTmp
			.append(" select assyLt from assyline ")
			.append(" where LineCd=?")
			.toString());sbTmp.delete(0,sbTmp.length());
		}
		ps6.setString(1, lineCdList.get(i));
		ResultSet rsLine=ps6.executeQuery();

		if(rsLine.next()){
			lineLTList.add(rsLine.getInt("AssyLT"));
		}else{
			lineLTList.add(0);
		}
		rsLine.close();
	}

	String planDate = request.getParameter("planDate");
	String despatchDate = request.getParameter("despatchDate");

	String strDate = "";
	if(request.getParameter("calArea").equals("PLAN")) {
		strDate = request.getParameter("planDate");
	} else {
		strDate = request.getParameter("despatchDate");
	}
	wrkCal.set(Integer.parseInt(strDate.substring(0,4))
			,Integer.parseInt(strDate.substring(5,7))-1
			,Integer.parseInt(strDate.substring(8,10)));

	String strCalDate="";
	for(int i=0; i < lineLTList.size(); i++){
		if(ps7 == null){ps7 =db.prepareStatement(sbTmp
			.append(" select lineCd,lineSeq from workscal")
			.append(" where CalDate=?")
			.append(" and (LineCd='' or LineCd=?)")
			.append(" and HolFlg=''")
			.append(" order by LineCd desc")
			.toString());sbTmp.delete(0,sbTmp.length());
		}
		ps7.setString(1, dateFmt.format(wrkCal.getTime()));
		ps7.setString(2, lineCdList.get(i));
		ResultSet rsLTCal=ps7.executeQuery();

		if(rsLTCal.next()){
			String strCalLineCd=rsLTCal.getString("LineCd");
			int intLineSeq=rsLTCal.getInt("LineSeq");

			ResultSet rsLineCal;
			if(request.getParameter("calArea").equals("PLAN")) {
				if(ps8 == null){ps8 =db.prepareStatement(sbTmp
					.append(" select calDate from workscal")
					.append(" where LineSeq=?")
					.append(" and LineCd=?")
					.append(" and HolFlg=''")
					.toString());sbTmp.delete(0,sbTmp.length());
				}
				ps8.setInt(1, (intLineSeq+lineLTList.get(i)));
				ps8.setString(2, strCalLineCd);
				rsLineCal=ps8.executeQuery();

			} else {
				if(ps9 == null){ps9 =db.prepareStatement(sbTmp
					.append(" select calDate from workscal")
					.append(" where LineSeq=?")
					.append(" and LineCd=?")
					.append(" and HolFlg=''")
					.toString());sbTmp.delete(0,sbTmp.length());
				}
				ps9.setInt(1, (intLineSeq-lineLTList.get(i)));
				ps9.setString(2, strCalLineCd);
				rsLineCal=ps9.executeQuery();
			}

			if(rsLineCal.next()){
				strCalDate=rsLineCal.getString("CalDate");
				wrkCal.set(Integer.parseInt(strCalDate.substring(0,4))
						,Integer.parseInt(strCalDate.substring(5,7))-1
						,Integer.parseInt(strCalDate.substring(8,10)));
			}else{
				errMsg = "カレンダ未登録（登録日＋ＬＴも点検ください）";
				break;
			}
			rsLineCal.close();
		}else{
			errMsg = "カレンダ未登録（登録日＋ＬＴも点検ください）";
			break;
		}
	}
	if(request.getParameter("calArea").equals("PLAN")) {
		despatchDate = strCalDate;
	} else {
		planDate = strCalDate;
	}

	if(!assyLineCd.equals("")) {
		ResultSet rsLine=objSql.executeQuery(sbTmp
			.append(" select lineCd from assyline")
			.append(" where (linecd='") .append(assyLineCd) .append("'")
			.append("        or linecd='") .append(despatchLineCd) .append("')")
			.append(" and invalid!=''")//廃止日がはいっとる。
			.toString());sbTmp.delete(0,sbTmp.length());

		if(rsLine.next()){
			planDate = "";
			despatchDate = "";
			assyLineCd = "";
			despatchLineCd = "";
			errMsg = sbTmp .append(rsLine.getString("linecd")) .append("ライン廃止されています。") 
					.toString();sbTmp.delete(0,sbTmp.length());
		}
		rsLine.close();
	}
	%>
	<html>
	<head>
	<meta http-equiv="Pragma" content="no-cache" />
	<meta http-equiv="cache-control" content="no-cache" />
	<meta http-equiv="expires" content="0" />
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
	<link href="../com/mierucchics.css" rel="stylesheet" type="text/css">
	<title>生産計画日付チェック</title>
	</head>

	<body>
	<form name="lineplandate_chk" action="lineplandate_chk.jsp" method="POST">
	<div align="center">

	<table class="header">
	<tr><th>生産計画日付チェック</th></tr>
	</table>
	<br>

	<input name='calArea' type='hidden' value='<%=request.getParameter("calArea")%>'>
	<input name='planCount' type = 'hidden' value='<%=request.getParameter("planCount")%>'>
	<input name='seq' type = 'hidden' value='<%=request.getParameter("seq")%>'>
	<input name='planDate' type='hidden' value='<%=planDate%>'>
	<input name='despatchDate' type='hidden' value='<%=despatchDate%>'>
	<input name='assyLineCd' type='hidden' value='<%=assyLineCd%>'>
	<input name='despatchLineCd' type='hidden' value='<%=despatchLineCd%>'>
	<input name='errMsg' type='hidden' value='<%=errMsg%>'>
	</div>
	</form>

	<script type="text/javaScript"><!--
		var D = document.all;
		planCount = D.planCount.value;
		seq = D.seq.value;
		planDate = D.planDate.value;
		despatchDate = D.despatchDate.value;
		assyLineCd = D.assyLineCd.value;
		despatchLineCd = D.despatchLineCd.value;
		errMsg = D.errMsg.value;

		window.opener.date_set(planCount,seq,planDate,despatchDate,assyLineCd,despatchLineCd,errMsg);

		window.opener.parent.focus();
		window.close();
	//--></script>
	</body>
  </html>

<%}%>

<%
objSql.close();
db.close();
%>

<!-- **************************** end of lineplandate_chk.jsp ******************************** -->

