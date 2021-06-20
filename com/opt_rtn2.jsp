<%-- <%@ page contentType="text/html;charset=Windows-31J"%> --%>
<!-- *****************************************************
	＜製品オプション展開＞　in　みえるっち
	File Name :opt_rtn.jsp
	呼出元：
	design/
	drinfo_inp.jsp
	entryopt_inp.jsp (utf8)
	opt_folder.jsp (utf8)
	ploptset_inp.jsp
	ploptset_sc.jsp (utf8)
	
	Author	:k-mizuno
	Date	:2007-02-26

	Update	
	2007-11-13 mizuno テーブル２重結合データ除外
	2008-02-08 mizuno GREEN対応
	2014-10-31 kaneshi select *　のカラム特定
	　　　　　　　　　 ResultSetをすぐ閉じる
	2015-11-30 kaneshi SQLインデント整理
	　　　　　　　　　　変数の複数回展開をやめさせる措置 
	          　　　　　　文字コードをＵＴＦ－８へ 　opt_folderでOK
	2016-02-16 kaneshi リリース
	2016-09-19 kaneshi StringBuilder化強化
	2018-01-25 kaneshi テーブル結合前の絞り込み
	2018-03-12 kaneshi ploptset_inp.jspから呼ばれる際に
	　strMultSelQuery　の書き方がかわったことに対応
	　　　sbEO(entryopt)、ｓｂOT（optTreeに対応）,
	   sbOM(optModel)に対応
		            
		            
		   【課題】宣言文のサブルーチンにする。
		   　　　　input ,outputはなにか？
		             
********************************************************** -->

<%@page import="java.sql.PreparedStatement"%>
<%
//******注）以下の変数は呼出Programで定義が必要*******
//intMultTopOptNo;　(input項目)
//strMultSelQuery
//intMultLevel
//sbMultOptQry1 strMultOptQuery
// strMultUpOptNoList
// strMultTreeOptNoList
// strMultOptLevelList
// strMultTailOptNoList　//trail しっぽ
//strMultOptDir
//Connection dbも必要

// output 項目と思われる。
int[][] aryMultOptLevel=new int[10][100];
int[][] aryMultUpOptNo=new int[15][1000];
int[][] aryMultTreeOptNo=new int[15][1000];
int[] aryMultTailOptNo=new int[15];
int[] aryMultDatCnt=new int[15];
int[] aryMultNextLine=new int[150];

StringBuilder sbTmpOpt = new StringBuilder();
StringBuilder sbTmpOpt1 = new StringBuilder();
StringBuilder sbTmpOpt2 = new StringBuilder();
StringBuilder sbTmpOpt3 = new StringBuilder();

StringBuilder sbMultOptQry = new StringBuilder();
StringBuilder sbMultOptQry1 = new StringBuilder();

PreparedStatement psopt0=null;
PreparedStatement psopt1=null;
PreparedStatement psopt2=null;
PreparedStatement psopt3=null;
PreparedStatement psopt4=null;
PreparedStatement psopt5=null;

//20160918
StringBuilder sbMultUpOptNoList = new StringBuilder();
sbMultUpOptNoList .append(strMultUpOptNoList);

StringBuilder sbMultTreeOptNoList = new StringBuilder();
sbMultTreeOptNoList .append(strMultTreeOptNoList);
System.out.println("shoki　strMultTreeOptNoList="+strMultTreeOptNoList);
//optset_inp では初期はからっぽ

StringBuilder sbMultOptLevelList = new StringBuilder();
sbMultOptLevelList .append(strMultOptLevelList);

StringBuilder sbMultTailOptNoList = new StringBuilder();
sbMultTailOptNoList .append(strMultTailOptNoList);

while(intMultTopOptNo>=0){

	if(psopt0 == null){psopt0 =db.prepareStatement(sbTmpOpt
		.append(" select topSign from entryopt")
		.append(" where OptNo=?")
		.append(" and VerNo=(select max(VerNo) from entryopt")
		.append("            where OptNo=?)")
		.toString());sbTmpOpt.delete(0,sbTmpOpt.length());
	}
	psopt0.setInt(1, intMultTopOptNo);
	psopt0.setInt(2, intMultTopOptNo);
	ResultSet rsMultTopOpt = psopt0.executeQuery();

	rsMultTopOpt.next();
	String strMultTopSign=rsMultTopOpt.getString("TopSign");
	rsMultTopOpt.close();

	if(intMultLevel==0||strMultTopSign.equals("NO")){
		ResultSet rsMultOpt=null;

		if(strMultSelQuery.equals("")){
			//2008-02-08 mizuno GREEN対応
			if(strMultOptDir.equals("F")){
				//optNo,treeOptNo,green
				//-----下位Option read-----//
				if(psopt1 == null){psopt1 =db.prepareStatement(sbTmpOpt
					.append(" select O.optNo,O.treeOptNo,E.Green ")
					.append(" from (select optNo,treeOptNo,sortNo from opttree")
					.append("        where OptNo=?")
					.append("         and (ToDate='' or ToDate='9999-99-99')")
					.append("      ) as O ")
					.append(" left join (select green,optNo,latest from entryopt ")
					.append("           ) as E ")
					.append("   on O.TreeOptNo=E.OptNo")
					.append(" where E.Latest='YES'")
					.append(" order by SortNo")
					.toString());sbTmpOpt.delete(0,sbTmpOpt.length());
				}
				psopt1.setInt(1, intMultTopOptNo);
				rsMultOpt = psopt1.executeQuery();

			}else{
				if(psopt2 == null){psopt2 =db.prepareStatement(sbTmpOpt
					.append(" select O.optNo,O.treeOptNo,E.Green ")
					.append(" from (select optNo,treeOptNo,sortNo from opttree")
					.append("        where TreeOptNo=?")
					.append("         and (ToDate='' or ToDate='9999-99-99')")
					.append("      ) as O ")
					.append(" left join (select green,optNo,latest from entryopt ")
					.append("           ) as E ")
					.append("   on O.OptNo=E.OptNo")
					.append(" where E.Latest='YES'")
					.append(" order by SortNo")
					.toString());sbTmpOpt3.delete(0,sbTmpOpt3.length());
				}
				psopt2.setInt(1, intMultTopOptNo);
				rsMultOpt = psopt2.executeQuery();
			}
		}else{
			if(strMultOptDir.equals("F")){
				sbMultOptQry1
				.append(strMultSelQuery)
				.append(" and OT.OptNo=") .append(intMultTopOptNo)
				.append(" order by OT.SortNo")
				;
				//-----下位Option read-----//
				//ResultSet rsMultOpt=objSql.executeQuery(strMultOptQuery);
				rsMultOpt=objSql.executeQuery(sbMultOptQry1.toString());
				sbMultOptQry1.delete(0,sbMultOptQry1.length());
			}else{
				sbMultOptQry1
				.append(strMultSelQuery)
				.append(" and OT.TreeOptNo=") .append(intMultTopOptNo)
				.append(" order by OT.SortNo")
				;
				//-----下位Option read-----//
				//ResultSet rsMultOpt=objSql.executeQuery(strMultOptQuery);
				rsMultOpt=objSql.executeQuery(sbMultOptQry1.toString());
				sbMultOptQry1.delete(0,sbMultOptQry1.length());
			}
		}

		aryMultDatCnt[intMultLevel]=0;
		intMultTopOptNo=-1;


		//2007-11-13 mizuno テーブル２重結合データ除外
		StringBuilder sbMultOptChkList = new StringBuilder();

		while(rsMultOpt.next()){
			int intTreeOptno = rsMultOpt.getInt("TreeOptNo");

			if((sbTmpOpt1 .append(",") .append(sbMultOptChkList) .append(","))
					.indexOf(sbTmpOpt2 .append(",") .append(intTreeOptno) .append(",") .toString())<0){
				
				sbTmpOpt1.delete(0,sbTmpOpt1.length());
				sbTmpOpt2.delete(0,sbTmpOpt2.length());
				
				int intOptno = rsMultOpt.getInt("OptNo");
			//-----read next data set-----//
			 	int multdatcnt_multlevel = aryMultDatCnt[intMultLevel];
				aryMultUpOptNo[intMultLevel][multdatcnt_multlevel]=intOptno;
				aryMultTreeOptNo[intMultLevel][multdatcnt_multlevel]=intTreeOptno;
				aryMultOptLevel[intMultLevel][multdatcnt_multlevel]=intMultLevel;
				aryMultTailOptNo[intMultLevel]=intTreeOptno;
		  //
			//-----read next data list set(read next first data)-----//
				if(multdatcnt_multlevel==0){
					sbMultUpOptNoList .append(",") .append(intOptno);
					//重要値↓
					sbMultTreeOptNoList .append(",") .append(intTreeOptno);
					sbMultOptLevelList .append(",") .append(intMultLevel);
					intMultTopOptNo=intTreeOptno;
					aryMultNextLine[intMultLevel]=1;
				}

				//2008-02-08 mizuno GREEN対応
				String green = rsMultOpt.getString("Green");
				if(green.compareTo(strMultOptGreen)<0){
					strMultOptGreen=green;
				}
				aryMultDatCnt[intMultLevel]++;
			}
			sbTmpOpt1.delete(0,sbTmpOpt1.length());
			sbTmpOpt2.delete(0,sbTmpOpt2.length());

			sbMultOptChkList .append(",") .append(intTreeOptno);
		}
		rsMultOpt.close();

		if(aryMultDatCnt[intMultLevel]>0){
			sbMultTailOptNoList .append(",") .append(aryMultTailOptNo[intMultLevel]);
		}
	}else{
		aryMultDatCnt[intMultLevel]=0;
		intMultTopOptNo=-1;
	}

	//最終＋１行に展開終了（スペース）セット
	aryMultTreeOptNo[intMultLevel][aryMultDatCnt[intMultLevel]]=0;

	//下位フォルダが無ければ上位階層に戻って展開対象フォルダをセット
	if(aryMultDatCnt[intMultLevel]==0){
		while(intMultLevel>0){
			intMultLevel--;
			int int_multnextline_multlevel = aryMultNextLine[intMultLevel];

			if(aryMultTreeOptNo[intMultLevel][int_multnextline_multlevel]>0){
				sbMultUpOptNoList .append(",") .append(aryMultUpOptNo[intMultLevel][int_multnextline_multlevel]);
				//重要値↓
				sbMultTreeOptNoList .append(",") .append(aryMultTreeOptNo[intMultLevel][int_multnextline_multlevel]);
				sbMultOptLevelList .append(",") .append(aryMultOptLevel[intMultLevel][int_multnextline_multlevel]);
				intMultTopOptNo=aryMultTreeOptNo[intMultLevel][aryMultNextLine[intMultLevel]];
				sbMultTailOptNoList .append(",") .append(aryMultTailOptNo[intMultLevel]);
				//下位展開終了後読み出しNo. SET
				aryMultNextLine[intMultLevel]++;
				break;
			}
		}
	}

	intMultLevel++;
	if(intMultLevel>intMultMaxLevel){
		intMultMaxLevel=intMultLevel;
	}
	if(intMultLevel>15){
		break;
	}
	

	//20160918
	strMultUpOptNoList = sbMultUpOptNoList.toString();
	strMultTreeOptNoList = sbMultTreeOptNoList.toString();
	strMultOptLevelList = sbMultOptLevelList.toString();
	strMultTailOptNoList = sbMultTailOptNoList.toString();
	
// 	System.out.println("MultUpOptNoList="+strMultUpOptNoList);
// 	System.out.println("MultTreeOptNoList="+strMultTreeOptNoList);
	
}
%>

<!------------------------------ End of opt_rtn.jsp ------------------------------>