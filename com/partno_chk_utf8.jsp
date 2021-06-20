<!-- *******************************************************************
	＜部品表登録チェック＞
	File Name :partno_chk_utf8.jsp
	Author	:k-mizuno
	Date	:2006-09-05
	
	Update	
	2007-12-05 mizuno 構成展開無限ルーチンロジック追加
	2009-11-09 mizuno グリーンチェック追加
	2012-04-10 moriwaki 廃止部品登録（使用禁止→警告）
	
	2013-03-15 kaneshi 全般整理　
	2014-05-09 kaneshi 本来なら、designの中?  参照元が多岐にわたるためらしい。。
	　　　　　利用元は
		design) drrequest_inp.jsp
				drsimple_inp.jsp　チェックずみ
				entryopt_inp.jsp
				part_inp.jsp　チェックずみ
				partexchange_inp.jsp
				pl_inp.jsp  2
				plupl_set.jsp 2
		sales)  qcinspection_inp.jsp
		        qcpartno_chk.jsp 4
		seikan) kanban_inp.jsp　チェックずみ
				nonkbpart_inp.jsp　チェックずみ

	2014-09-20 kaneshi <font => <div
	2014-11-12 kaneshi select * のカラム特定、
	　　　　　　　　　ResultSetを読んだらすぐ閉じる
	　　　　　　　　　保守品　partdat.recommend='M'もＯＫにした
	2014-11-15        部品未登録ですのエラーがでる
	
	2015-02-22 kaneshi StringBuilder ,String#concatで高速化
	
	           SBBS060001に、登録ずみのSSCO100033 を追加しようとすると??
	2015-04-02 kaneshi var line = "＜%=request.getParameter("Line")%＞"; の動作点検が必要
	2015-08-08 kaneshi PreparedStatement 、StringBuilderで高速化
	2015-12-07 kaneshi 文字コードをutf-8へ、不要なコメントの削除
	2015-12-11 kaneshi ファイル名に_utf8をつけた
	2016-03-18 kaneshi 動作ﾁｪｯｸすると、画面をひらいたまま閉じないみたいだ。
	2016-09-29 kaneshi kitflagのセットをはずした
	2016-10-14 kaneshi StringBuilder#setLength(0)
	               concat -> append
	2016-12-28 kaneshi sql 内でselect * で　kitflagをはずした
	2018-03-18 kaneshi 本番の昼に２０秒かかりトラブル有。　SQLへ対処
   　　　　　　　　　　　　　　　　　　pldatの絞り込み条件のobjtype優先度アップ
	　　　　　　　　　　　　　　　　


********************************************************************* -->

<%@ page contentType="text/html;charset=UTF-8"
	import="java.io.*,java.sql.*,java.net.*,java.util.*,java.text.*"%>

<% String strRight="USER"; %>
<%@ include file="../header_utf8.jsp"%>

<%
StringBuilder sbErrMsg=new StringBuilder();
String strPartNam="";
String strPartType="";
String strModelNo="";
String strMakerNam="";
String strComplete="";
String strMasPro="";
String strGreen="";
String plGreen = "";
String category = "";
String strRecommend = "";	//20120409
int plcheckpassflag = 0;
//int PartKitFlag = 0;
int DeleteFlag = 0;

StringBuilder sbTmp = new StringBuilder();

// 2010-03-26 mizuno 廃止品番対応
ResultSet rsPartDel = objSql.executeQuery(sbTmp
	.append(" select partNo from partdel")
	.append(" where PartNo='") .append(request.getParameter("PartNo")) .append("'")
	.toString());sbTmp.delete(0,sbTmp.length());

if(rsPartDel.next()) {
	DeleteFlag = 1;
}
rsPartDel.close();

if(request.getParameter("PlPartNo")!=null){
	ResultSet rsPlPart=objSql.executeQuery(sbTmp
		.append(" select green,category from partdat")
		.append(" where PartNo='") .append(request.getParameter("PlPartNo")) .append("'")
		.toString());sbTmp.delete(0,sbTmp.length());

	rsPlPart.next();
	plGreen  = rsPlPart.getString("green");
	category = rsPlPart.getString("category");
	rsPlPart.close();

	// 最上位製品の部品表は廃品可
	if(category.equals("EQP")) {
		ResultSet rsUpPl=objSql.executeQuery(sbTmp
			.append(" select elmPartNo from pldat")
			.append(" where elmPartNo='") .append(request.getParameter("PlPartNo")) .append("'")
			.toString());sbTmp.delete(0,sbTmp.length());

		if(!rsUpPl.next()) {
			plcheckpassflag = 1;
		}
		rsUpPl.close();
	}
}

ResultSet rsPart=objSql.executeQuery(sbTmp
		.append(" select P.partNam,P.modelNo,P.partType,P.maspro,P.green,P.kitflag,P.complete")
		.append(",P.category,P.eqpclass,P.recommend")
		.append(",M.MakerNam,C.DocOnly ")
		.append(" from (select * from partdat ")// しぼらんでいい
		.append("        where PartNo='") .append(request.getParameter("PartNo")) .append("'")
		.append("      ) as P ")
		.append(" left join (select classCd,docOnly from partclass")
		.append("           ) as C ")
		.append("   on P.ClassCd=C.ClassCd")
		.append(" left join (select makerId,makerNam from maker")//ないことがある
		.append("           ) as M")
		.append("   on P.MakerID=M.MakerID")
		.toString());sbTmp.delete(0,sbTmp.length());

// 2010-03-26 mizuno 廃止品番対応
if(DeleteFlag == 1){
	sbErrMsg .append("廃止品番です。");
} else if(rsPart.next()){
	strPartNam =rsPart.getString("PartNam");
	strModelNo =rsPart.getString("ModelNo");
	strPartType=rsPart.getString("PartType");
	strMakerNam=rsPart.getString("MakerNam");
	strGreen   =rsPart.getString("Green");
	//PartKitFlag=rsPart.getInt("kitflag");
	if(strMakerNam==null){
		strMakerNam="";
	}
	strComplete      =rsPart.getString("Complete");
	String strDocOnly=rsPart.getString("DocOnly");
	if(strDocOnly==null){
		strDocOnly="NO";
	}

	// 2008-08-28 mizuno 図面簡易登録専用チェック
	if(request.getParameter("classCd") != null) {
		if(request.getParameter("DesignType").equals("M")
				&& !rsPart.getString("maspro").equals("MP")) {
			sbErrMsg .append("量産品変更ではありません。");
		} else
		if(!request.getParameter("DesignType").equals("M")
				&& rsPart.getString("maspro").equals("MP")) {
			sbErrMsg .append("量産品変更になります。");
		} else
		if(rsPart.getString("category").equals("EQP")
				&& !request.getParameter("classCd").equals(rsPart.getString("eqpclass"))) {
			sbErrMsg .append("製品分類不一致です。");
		}
	}else if(request.getParameter("OldPart")!=null){
		if(strDocOnly.equals("YES")){
			sbErrMsg.delete(0,sbErrMsg.length());
			sbErrMsg .append("旧品図面専用品番です。");
		}
	}else{
		if(rsPart.getString("MasPro").equals("MP")){
			strMasPro="量産";
		}else{
			strMasPro="試作";
		}
		if(plcheckpassflag == 0
				&& request.getParameter("subpartflag") == null
				&& (rsPart.getString("Recommend").equals("D")
						||rsPart.getString("Recommend").equals("M"))){//保守品へ対応
			sbErrMsg.delete(0,sbErrMsg.length());
			sbErrMsg .append("廃品(or保守品)です。");
			strRecommend = rsPart.getString("Recommend");	//20120409
		}else if(plcheckpassflag == 0
				      && request.getParameter("subpartflag") == null
				      && rsPart.getString("Recommend").equals("M")){
			sbErrMsg.delete(0,sbErrMsg.length());
			sbErrMsg .append("保守品（生産中止）です。");
		}else if(request.getParameter("subpartflag") != null
				      && !rsPart.getString("parttype").equals("2")){
			sbErrMsg.delete(0,sbErrMsg.length());
			sbErrMsg .append("購買部品ではありません。");
		}else if(strDocOnly.equals("YES")){
			sbErrMsg.delete(0,sbErrMsg.length());
			sbErrMsg .append("図面専用品番です。");
		}else if(request.getParameter("InfoNo")!=null
				      && !request.getParameter("InfoNo").equals("")
				      && rsPart.getString("Category").equals("PCH")
				      && !rsPart.getString("Complete").equals("FINISH")){
			sbErrMsg.delete(0,sbErrMsg.length());
			sbErrMsg .append("未完了購買部品です。");
		}else if(rsPart.getString("Category").indexOf("COST") >= 0){
			sbErrMsg.delete(0,sbErrMsg.length());
			sbErrMsg .append("費用処理品番です。");
		}
	}
	rsPart.close();
} else {
	if(request.getParameter("OldPart")!=null){
		sbErrMsg.delete(0,sbErrMsg.length());
		sbErrMsg .append("旧品品番未登録");
	}else{
		sbErrMsg.delete(0,sbErrMsg.length());
		sbErrMsg .append("部品未登録");
	}
}

PreparedStatement ps0=null;
PreparedStatement ps1=null;

//2007-12-05 mizuno 構成展開無限ルーチンロジック追加
if(request.getParameter("PlPartNo")!=null&&sbErrMsg.length()==0){

	if(strGreen.compareTo(plGreen) < 0) {
		sbErrMsg.delete(0,sbErrMsg.length());
		sbErrMsg .append("グリーン未対応です。");
	} else if(request.getParameter("PlPartNo").equals(request.getParameter("PartNo"))){
		sbErrMsg.delete(0,sbErrMsg.length());
		sbErrMsg .append("子品番＝親品番です。");
	} else {
		// 上位品番HASHMAP作成
		ArrayList<Integer> upLevelList = new ArrayList<Integer>();
		ArrayList<String> upPartNoList = new ArrayList<String>();
		HashMap<String, String> upPartNoHashMap = new HashMap<String, String>();
		int intUpMaxLevel=0;

		upLevelList.add(0);
		upPartNoList.add(request.getParameter("PlPartNo"));
		upPartNoHashMap.put(request.getParameter("PlPartNo"), request.getParameter("PlPartNo"));

		for(int i=0; i < upPartNoList.size(); i++) {//途中で追加されている
			if(ps0 == null){ps0 =db.prepareStatement(sbTmp
				.append(" select partNo from pldat")
				.append(" where ElmPartNo=?")
				.append(" and ObjType='PART'")//20180315 優先度アップ
				.append(" and (todate='' or todate = '9999-99-99')")
				
				.toString());sbTmp.delete(0,sbTmp.length());
			}
			ps0.setString(1, upPartNoList.get(i));
			ResultSet rsUpPlList=ps0.executeQuery();

			while(rsUpPlList.next()) {
				if(upPartNoHashMap.get(rsUpPlList.getString("PartNo")) == null) {
					upPartNoList   .add(rsUpPlList.getString("PartNo"));
					upPartNoHashMap.put(rsUpPlList.getString("PartNo"), rsUpPlList.getString("PartNo"));
					upLevelList    .add(upLevelList.get(i) + 1);
					if(upLevelList.get(i) + 1 > intUpMaxLevel) {
						intUpMaxLevel = upLevelList.get(i) + 1;
					}
				}
			}
			rsUpPlList.close();
		}

		// 下位構成チェック
		ArrayList<Integer> dwLevelList = new ArrayList<Integer>();
		ArrayList<String> dwPartNoList = new ArrayList<String>();
		HashMap<String, String> dwPartNoHashMap = new HashMap<String, String>();

		dwLevelList.add(intUpMaxLevel);
		dwPartNoList.add(request.getParameter("PartNo"));
		dwPartNoHashMap.put(request.getParameter("PartNo"), request.getParameter("PartNo"));

		int intElmMaxLevel = intUpMaxLevel;

		for(int i=0; i < dwPartNoList.size(); i++) {//上限値にループ途中でadd、putされている
			if(ps1 == null){ps1 =db.prepareStatement(sbTmp
				.append(" select partNo,elmpartNo from pldat")
				.append(" where PartNo=?")
				.append(" and ObjType='PART'")//20180315 優先度アップ
				.append(" and (todate='' or todate = '9999-99-99')")
				.toString());sbTmp.delete(0,sbTmp.length());
			}
			ps1.setString(1, dwPartNoList.get(i));
			ResultSet rsDwPlList=ps1.executeQuery();

			while(rsDwPlList.next()) {
				if(upPartNoHashMap.get(rsDwPlList.getString("PartNo")) == null) {
					if(dwPartNoHashMap.get(rsDwPlList.getString("ElmPartNo")) == null) {
						dwPartNoList   .add(rsDwPlList.getString("ElmPartNo"));
						dwPartNoHashMap.put(rsDwPlList.getString("ElmPartNo"), rsDwPlList.getString("ElmPartNo"));
						dwLevelList    .add(dwLevelList.get(i) + 1);

						if(dwLevelList.get(i) + 1 > intElmMaxLevel) {
							intElmMaxLevel = dwLevelList.get(i) + 1;
						}
					}
				} else {
					sbErrMsg.delete(0,sbErrMsg.length());
					sbErrMsg .append("下位構成に親品番があります。");
					break;
				}
			}
			rsDwPlList.close();

			if(sbErrMsg.length()!=0){
				break;
			} else if(intElmMaxLevel>14){
				sbErrMsg.delete(0,sbErrMsg.length());
				sbErrMsg .append("構成レベルが１５レベルを超えています。");
				break;
			} else if(dwPartNoList.size()>10000){
				sbErrMsg.delete(0,sbErrMsg.length());
				sbErrMsg .append("部品点数が許容範囲を超えています。");
				break;
			}
		}
	}
}
int subpartflag = 0;
if(request.getParameter("subpartflag") != null){
	subpartflag = Integer.parseInt(request.getParameter("subpartflag"));
}
%>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
<title>部品表登録チェック</title>
</head>

<body bgcolor="lightyellow" onLoad="blur();">
<form name='partno_chk_utf8' action='partno_chk_utf8.jsp' method='post'>
		<br><br>
		<div style="text-align:center;color:red;font-weight:bold;"><%=sbErrMsg.toString()%></div>
		<input name='subpartflag' type='hidden' value='<%=subpartflag%>'>
</form>

<script type="text/javaScript">
<!--
var D = document.all;

if(window.opener.name=="fr_main"){
	var g_pageno =window.opener.parent.fr_main.g_pageno;
	var pgnam =window.opener.parent.fr_main.pgnam;
	var DP =window.opener.parent.fr_main.document.all;
	
	if( g_pageno == 0 ) {
		if(pgnam == "drsimple_inp") {
			if("<%=sbErrMsg.toString()%>" != "") {
				alert("<%=sbErrMsg.toString()%>");
				window.opener.parent.fr_main.document.drsimple_inp ["partNo<%=request.getParameter("Line")%>"].value="";
			} else if("<%=strPartType%>" != "2" && "<%=strPartType%>" != "5") {
				alert("ドキュメント登録対象品番ではありません。");
				window.opener.parent.fr_main.document.drsimple_inp ["partNo<%=request.getParameter("Line")%>"].value="";
			} else {
				window.opener.drnoset_win(<%=request.getParameter("Line")%>,"PARTNO");
			}
		} else if(pgnam == "partexchange_inp") {
			partno="<%=request.getParameter("PartNo")%>";
			partnam="<%=strPartNam%>";
			modelno="<%=strModelNo%>";
			parttype="<%=strPartType%>";
			window.opener.part_set("<%=sbErrMsg.toString()%>", partno, partnam, modelno, parttype);
		}
	} else if( g_pageno == 910 ) {
		//20120410if("<%=sbErrMsg.toString()%>" == "") {
		if("<%=sbErrMsg.toString()%>" == "" || (("<%=strRecommend%>"=="D" 
				||"<%=strRecommend%>"=="M") && "<%=sbErrMsg.toString()%>" == "廃品(or保守品)です。")) {
			partnam="<%=strPartNam%>";
			modelno="<%=strModelNo%>";
			makernam="<%=strMakerNam%>";
			green="<%=strGreen%>";
<%-- 			//partkitflag=<%=PartKitFlag%>; --%>
			maspro="<%=strMasPro%>";
			parttype="<%=strPartType%>";
			recommend="<%=strRecommend%>";	//20120409
			i = <%=request.getParameter("Line")%>;

			if(document.forms[0].subpartflag.value == 0) {
				//window.opener.linedata_set(partnam, modelno, makernam, partkitflag, green, maspro, parttype, recommend, i);	//20120409
				window.opener.linedata_set(partnam, modelno, makernam, green, maspro, parttype, recommend, i);	//20160830 partkitflagをはずした
				
				if(DP.pl_inp ["SubPartNo<%=request.getParameter("Line")%>"].value != ''
				&& DP.pl_inp ["ElmPartNo<%=request.getParameter("Line")%>"].value==DP.pl_inp ["SubPartNo<%=request.getParameter("Line")%>"].value) {
					alert("子品番＝代替旧品です。代替旧品クリアします。");
					window.opener.parent.fr_main.document.pl_inp ["SubPartNo<%=request.getParameter("Line")%>"].value="";
				}
			} else {
				if(DP.pl_inp ["SubPartNo<%=request.getParameter("Line")%>"].value != ''
				&& DP.pl_inp ["ElmPartNo<%=request.getParameter("Line")%>"].value==DP.pl_inp ["SubPartNo<%=request.getParameter("Line")%>"].value) {
					alert("子品番＝代替旧品です。代替旧品クリアします。");
					window.opener.parent.fr_main.document.pl_inp ["SubPartNo<%=request.getParameter("Line")%>"].value="";
				}
			}
			//20120409
			if("<%=strRecommend%>" == "D") {
				alert("廃品部品です");
			}
		  if("<%=strRecommend%>" == "M") {
		    alert("保守品です");
		  }
		} else {
			alert("<%=sbErrMsg.toString()%>");
			if(D.subpartflag.value == 0) {
				window.opener.parent.fr_main.document.pl_inp ["ElmPartNo<%=request.getParameter("Line")%>"].value = '';
			} else {
				window.opener.parent.fr_main.document.pl_inp ["SubPartNo<%=request.getParameter("Line")%>"].value="";
			}
		}
		window.opener.partcheckflag = 0;

	}else if( g_pageno == 920 ) {//plupl_set
		if("<%=sbErrMsg.toString()%>" == "") {

			partnam="<%=strPartNam%>";
			modelno="<%=strModelNo%>";
			makernam="<%=strMakerNam%>";
			green="<%=strGreen%>";
<%-- 			//partkitflag=<%=PartKitFlag%>; --%>
			maspro="<%=strMasPro%>";
			parttype="<%=strPartType%>";
			i = <%=request.getParameter("Line")%>;

			if(document.forms[0].subpartflag.value == 0) {
				if(DP.plupl_set ["SubPartNo<%=request.getParameter("Line")%>"].value != ''
				&& DP.plupl_set ["ElmPartNo<%=request.getParameter("Line")%>"].value==DP.plupl_set ["SubPartNo<%=request.getParameter("Line")%>"].value) {
					alert("子品番＝代替旧品です。代替旧品クリアします。");
					window.opener.parent.fr_main.document.plupl_set ["SubPartNo<%=request.getParameter("Line")%>"].value="";
				} else {
					//window.opener.linedata_set(partnam, modelno, makernam, partkitflag, green, maspro, parttype, i);
					window.opener.linedata_set(partnam, modelno, makernam, green, maspro, parttype, i);//partkitflagを削除
				}
			} else {
				if(DP.plupl_set ["SubPartNo<%=request.getParameter("Line")%>"].value != ''
				&& DP.plupl_set ["ElmPartNo<%=request.getParameter("Line")%>"].value==DP.plupl_set ["SubPartNo<%=request.getParameter("Line")%>"].value) {
					alert("子品番＝代替旧品です。代替旧品クリアします。");
					window.opener.parent.fr_main.document.plupl_set ["SubPartNo<%=request.getParameter("Line")%>"].value="";
				}
			}
		} else {
			alert("<%=sbErrMsg.toString()%>");
			if(D.subpartflag.value == 0) {
				window.opener.parent.fr_main.document.plupl_set ["ElmPartNo<%=request.getParameter("Line")%>"].value = '';
			} else {
				window.opener.parent.fr_main.document.plupl_set ["SubPartNo<%=request.getParameter("Line")%>"].value="";
			}
		}
		window.opener.partcheckflag = 0;
	}
}else{
	var g_pageno = window.opener.parent.g_pageno;

	if(g_pageno==260) {
		window.opener.parent.document.drrequest_inp.PartNam<%=request.getParameter("Line")%>.value="<%=strPartNam%>";
		window.opener.parent.document.drrequest_inp.ErrMsg<%=request.getParameter("Line")%>.value="<%=sbErrMsg.toString()%>";
	}else if( g_pageno==270) {
		window.opener.parent.document.part_inp.OldPartErrMsg.value="<%=sbErrMsg.toString()%>";
		window.opener.parent.document.part_inp.OldPartNam.value="<%=strPartNam%>";
		window.opener.parent.document.part_inp.OldModelNo.value="<%=strModelNo%>";
	}else if( g_pageno==110) {
		if("<%=sbErrMsg.toString()%>"!=""){
			alert("<%=sbErrMsg.toString()%>");
			window.opener.parent.document.entryopt_inp ["<%=request.getParameter("KeyItem")%>"].value="";
			window.opener.part_area();
		}
	}else if( g_pageno==610) {
		if("<%=sbErrMsg.toString()%>"!=""){
			alert("<%=sbErrMsg.toString()%>");
			window.opener.parent.document.nonkbpart_inp.PartNo.value="";
			window.opener.parent.document.nonkbpart_inp.PartNam.value="";
		}else{
			window.opener.parent.document.nonkbpart_inp.PartNam.value="<%=strPartNam%>";
		}
	}else if( window.opener.parent.g_pageno==620) {
		if("<%=sbErrMsg.toString()%>"!=""){
			alert("<%=sbErrMsg.toString()%>");
			window.opener.parent.document.kanban_inp.PartNo.value="";
			window.opener.parent.document.kanban_inp.PartNam.value="";
		}else{
			window.opener.parent.document.kanban_inp.PartNam.value="<%=strPartNam%>";
		}
	}
}

window.close();
//-->
</script>

</body>
</html>

<%
objSql.close();
db.close();
%>

<!-- *************************** end of partno_chk_utf8.jsp *************************** -->