<%@ page contentType="text/html;charset=UTF-8"%>
<!-- *****************************************************
		＜製品オプション展開＞　in　みえるっち
		File Name :opt_rtn.jsp
		呼出元：
		design/
		drinfo_inp.jsp
		entryopt_inp.jsp
		opt_folder.jsp
		ploptset_inp.jsp
		ploptset_sc.jsp

		Auther	:k-mizuno
		Date	:2007-02-26

		Update	2007-11-13 mizuno テーブル２重結合データ除外
			2008-02-08 mizuno GREEN対応
			2014-10-31 kaneshi select *　のカラム特定
			　　　　　　　　　 ResultSetをすぐ閉じる
		  2015-11-30 kaneshi SQLインデント整理
		  　　　　　　　　　　変数の複数回展開をやめさせる措置 
		            　　　　　　文字コードをＵＴＦ－８へ 　opt_folderでOK
		  2016-02-16 kaneshi リリース
		            
		            
		   【課題】宣言文のサブルーチンにする。
		   　　　　input ,outputはなにか？
		             
********************************************************** -->

<%@page import="java.sql.PreparedStatement"%>
<%
//******注）以下の変数は呼出Programで定義が必要*******
//intMultTopOptNo;　(input項目)
//Connection dbも必要

// output 項目と思われる。
int[][] aryMultOptLevel=new int[10][100];
int[][] aryMultUpOptNo=new int[15][1000];
int[][] aryMultTreeOptNo=new int[15][1000];
int[] aryMultTailOptNo=new int[15];
int[] aryMultDatCnt=new int[15];
int[] aryMultNextLine=new int[150];

StringBuilder sbTmpOpt = new StringBuilder();

StringBuilder sbMultOptQry = new StringBuilder();
StringBuilder sbMultOptQry1 = new StringBuilder();

PreparedStatement psopt0=null;
PreparedStatement psopt1=null;
PreparedStatement psopt2=null;
PreparedStatement psopt3=null;
PreparedStatement psopt4=null;
PreparedStatement psopt5=null;

while(intMultTopOptNo>=0){

	if(psopt0 == null){
		psopt0 =db.prepareStatement(
			sbTmpOpt
			.append(" select topSign from entryopt")//psopt0
			.append(" where OptNo=?")
			.append(" and VerNo=(select max(VerNo) from entryopt")
			.append(" where OptNo=?)")
			.toString()
		);
		sbTmpOpt.delete(0,sbTmpOpt.length());
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
				if(psopt1 == null){
					psopt1 =db.prepareStatement(
						sbTmpOpt
						.append(" select opttree.optNo,opttree.treeOptNo,entryopt.Green ")//psopt1
						.append(" from opttree,entryopt")
						.append(" where opttree.TreeOptNo=entryopt.OptNo")
						.append(" and opttree.OptNo=?")
						.append(" and (opttree.ToDate='' or opttree.ToDate='9999-99-99')")
						.append(" and entryopt.Latest='YES'")
						.append(" order by SortNo")
						.toString()
					);
					sbTmpOpt.delete(0,sbTmpOpt.length());
				}
				psopt1.setInt(1, intMultTopOptNo);
				rsMultOpt = psopt1.executeQuery();

			}else{
				if(psopt2 == null){
					psopt2 =db.prepareStatement(
						sbTmpOpt
						.append(" select opttree.optNo,opttree.treeOptNo,entryopt.Green ")//psopt2
						.append(" from opttree,entryopt")
						.append(" where opttree.OptNo=entryopt.OptNo")
						.append(" and opttree.TreeOptNo=?")
						.append(" and (opttree.ToDate='' or opttree.ToDate='9999-99-99')")
						.append(" and entryopt.Latest='YES'")
						.append(" order by SortNo")
						.toString()
					);
					sbTmpOpt.delete(0,sbTmpOpt.length());
				}
				psopt2.setInt(1, intMultTopOptNo);
				rsMultOpt = psopt2.executeQuery();

			}
		}else{
			if(strMultOptDir.equals("F")){
				sbMultOptQry1 //psopt3
				.append(strMultSelQuery)
				.append(" and opttree.OptNo=") .append(intMultTopOptNo)
				.append(" order by opttree.SortNo")
				;
				//-----下位Option read-----//
				//ResultSet rsMultOpt=objSql.executeQuery(strMultOptQuery);
				rsMultOpt=objSql.executeQuery(sbMultOptQry1.toString());
				sbMultOptQry1.delete(0, sbMultOptQry1.length());
			}else{
				sbMultOptQry1  //psopt4
				.append(strMultSelQuery)
				.append(" and opttree.TreeOptNo=") .append(intMultTopOptNo)
				.append(" order by opttree.SortNo")
				;
				//-----下位Option read-----//
				//ResultSet rsMultOpt=objSql.executeQuery(strMultOptQuery);
				rsMultOpt=objSql.executeQuery(sbMultOptQry1.toString());
				sbMultOptQry1.delete(0, sbMultOptQry1.length());
			}
		}

		aryMultDatCnt[intMultLevel]=0;
		intMultTopOptNo=-1;


		//2007-11-13 mizuno テーブル２重結合データ除外
		String strMultOptChkList="";

		while(rsMultOpt.next()){
			int intTreeOptno = rsMultOpt.getInt("TreeOptNo");

			if(("," .concat(strMultOptChkList) .concat(","))
					.indexOf("," .concat(String.valueOf(intTreeOptno)) .concat(","))<0){
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
					strMultUpOptNoList = strMultUpOptNoList .concat(",") .concat(String.valueOf(intOptno));
					strMultTreeOptNoList = strMultTreeOptNoList .concat(",") .concat(String.valueOf(intTreeOptno));
					strMultOptLevelList= strMultOptLevelList .concat(",") .concat(String.valueOf(intMultLevel));
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

			strMultOptChkList=strMultOptChkList .concat(",") .concat(String.valueOf(intTreeOptno));
		}
		rsMultOpt.close();

		if(aryMultDatCnt[intMultLevel]>0){
			strMultTailOptNoList = strMultTailOptNoList
					.concat(",") .concat(String.valueOf(aryMultTailOptNo[intMultLevel]));
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
				strMultUpOptNoList=strMultUpOptNoList 
						.concat(",") .concat(String.valueOf(aryMultUpOptNo[intMultLevel][int_multnextline_multlevel]));
				strMultTreeOptNoList = strMultTreeOptNoList
						.concat(",") .concat(String.valueOf(aryMultTreeOptNo[intMultLevel][int_multnextline_multlevel]));
				strMultOptLevelList = strMultOptLevelList
						.concat(",") .concat(String.valueOf(aryMultOptLevel[intMultLevel][int_multnextline_multlevel]));
				intMultTopOptNo=aryMultTreeOptNo[intMultLevel][aryMultNextLine[intMultLevel]];
				strMultTailOptNoList = strMultTailOptNoList
						.concat(",") .concat(String.valueOf(aryMultTailOptNo[intMultLevel]));
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
}
%>

<!------------------------------ End of opt_rtn.jsp ------------------------------>