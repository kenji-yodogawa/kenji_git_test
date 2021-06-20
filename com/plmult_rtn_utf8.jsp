<%@ page contentType="text/html;charset=UTF-8"%>
<!-- *****************************************************************
		File Name :plmult_rtn.jsp
		
		呼出元：drinfoapv_inp.jsp
		        drinfompapv_upl.jsp
		        ploptset_upl.jsp
		Auther	:k-mizuno
		Date	:2006-09-05
		       2014-12-25 kaneshi 高速化
		       2015-12-07 kaneshi 不要なコメントを削除
		       　　　　　　　　　　　　　　StringBuilderとString#concatで高速化
		       2016-03-19 kaneshi 旧プログラムト比較チェック
		       2016-09-22 kaneshi StringBuilder化再徹底
******************************************************************** -->
<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
<%
//******注）以下の変数は呼出Programで定義が必要*******
//strMultTopPartNo(展開PartNo)
//strMultSetDate(展開期日)
//strMultSpread(展開M:マルチ S:シングル E:製品)
//strMultDir(展開F:順展開 B:逆展開)
//strMultTopQty(所要数)
//dblMultQty(所要数:ワーク)
// (strMultQuery ??) 上記だけだなく、いろいろある
//strMultIniTopPartno ?? ここにしかないぞ
//intMultPlCnt  ??　　plmult_var.jspにある
//intEcoPlMaxCnt ?? header にある。　plmult_var.jspにあった。無効になっている
// 	strMultPartNoList　plmult_var.jspにもある
// 	strMultElmPartNoList　plmult_var.jspにもある
// 	strMultSeqNoList　　plmult_varにもある
// 	strMultQtySumList　plmult_varにもある
// 	strMultLevelList　plmult_varにもある
// 	intMultLevel　　　　plmult_varにもある
// 	intMultMaxLevel　　plmult_varにもある
//　strMultAllSeqNo　　plmult_varにもある
//  strMultEfc　　　plmult_varにもある

StringBuilder sbMultQry = new StringBuilder();
StringBuilder sbMultQry1 = new StringBuilder();
StringBuilder sbTmpPM = new StringBuilder();

strMultIniTopPartNo=strMultTopPartNo;
intMultPlCnt=0;



for(int multn=0; multn<100; multn++){
	String[][] aryMultPartNo=new String[15][intEcoPlMaxCnt+1];
	String[][] aryMultElmPartNo=new String[15][intEcoPlMaxCnt+1];
	String[][] aryMultSeqNo=new String[15][intEcoPlMaxCnt+1];
	String[][] aryMultQuantity=new String[15][intEcoPlMaxCnt+1];
	String[][] aryMultToDate=new String[15][intEcoPlMaxCnt+1];
	int[][] aryMultLevel=new int[15][intEcoPlMaxCnt+1];
	int[][] aryMultAllSeqNoTo=new int[15][intEcoPlMaxCnt+1];
	double[][] aryMultQtySum=new double[15][intEcoPlMaxCnt+1];
	int[] aryMultDatCnt=new int[15];
	int[] aryMultNextLine=new int[15];

	//strMultPartNoList="";
	StringBuilder sbMultPartNoList = new StringBuilder();//20160922

	//strMultElmPartNoList="";
	StringBuilder sbMultElmPartNoList = new StringBuilder();//20160922

	//strMultSeqNoList="";
	StringBuilder sbMultSeqNoList = new StringBuilder();//20160922

	//strMultQtySumList="";
	StringBuilder sbMultQtySumList = new StringBuilder();//20160922

	//strMultLevelList="";
	StringBuilder sbMultLevelList = new StringBuilder();//20160922
	//strMultQuery="";
	sbMultQry.delete(0,sbMultQry.length());

	intMultLevel=0;
	intMultMaxLevel=0;
	intMultSpread=15;
	if(strMultSpread.equals("S")){
		intMultSpread=1;
	}else if(!strMultSpread.equals("M") && !strMultSpread.equals("E")){
		intMultSpread=Integer.parseInt(strMultSpread);
	}

	while(!strMultTopPartNo.equals("")){

		if(strMultTopPartNo.equals("ABOLISH")){
			//strMultQuery="";
			sbMultQry.delete(0,sbMultQry.length());
		}else{
			sbMultQry.delete(0,sbMultQry.length());
			//改訂番号指定の場合
			if(!strMultAllSeqNo.equals("")){
				if(!strMultAllSeqNo.equals("99999999")){
					sbMultQry.append(" and AllSeqNoFrom<=") .append(strMultAllSeqNo);
					if(strMultEfc.equals("")){
					//指定Ver.で廃止の部品を含む
						sbMultQry.append(" and AllSeqNoTo>=") .append(strMultAllSeqNo);
					}else{
					//指定Ver.で廃止の部品を含まない
						sbMultQry.append(" and AllSeqNoTo>") .append(strMultAllSeqNo);
					}
				}else{
					sbMultQry.append(" and AllSeqNoFrom<=") .append(strMultAllSeqNo);
					if(strMultEfc.equals("")){
					//指定Ver.で廃止の部品を含む
						sbMultQry.append(" and (ToDate='' or ToDate='9999-99-99')");
					}else{
					//廃止の部品を含まない
						sbMultQry.append(" and ToDate=''");
					}
				}
			}
			if(!strMultSetDate.equals("")){
				if(strMultSetDate.equals("9999-99-99")){
					sbMultQry.append(" and ToDate=''");
				}else{
					sbMultQry
					.append(" and FromDate<='") .append(strMultSetDate) .append("'")
					.append(" and (ToDate>='") .append(strMultSetDate) .append("' or ToDate='')");
				}
			}
			//-----構成数チェック-----//
			ResultSet rsMultPlCnt=objSql.executeQuery(
				sbTmpPM
				.append(" select count(*) as count from pldat")//plps0
				.append(" where PartNo='") .append(strMultTopPartNo) .append("'")
				.append(" and ObjType='PART'")
				.append(sbMultQry)
				.toString()
				);
			sbTmpPM.delete(0,sbTmpPM.length());

			rsMultPlCnt.next();
			intMultPlCnt=rsMultPlCnt.getInt("count");
			rsMultPlCnt.close();
			
			sbMultQry1.delete(0,sbMultQry1.length());

			if(strMultDir.equals("F")){
				sbMultQry1
				.append(" select L.*,partdat.Category ")//plps1
				.append(" from pldat as L,partdat")
				.append(" where L.PartNo=partdat.PartNo")
				.append(" and L.PartNo='") .append(strMultTopPartNo) .append("'")
				.append(" and L.ObjType='PART'")
				.append(sbMultQry)
				.append(" order by ElmPartNo,SeqNo")
				;
			}else{
				sbMultQry1
				.append(" select L.*,partdat.Category ")//plps2
				.append(" from pldat as L ,partdat")
				.append(" where L.PartNo=partdat.PartNo")
				.append(" and L.ElmPartNo='") .append(strMultTopPartNo) .append("'")
				.append(" and L.ObjType='PART'")
				.append(sbMultQry)
				.append(" order by PartNo")
				;
			}
		}

		if(intMultPlCnt>intEcoPlMaxCnt){
		//構成数が設定を超える場合は設定変更し再展開
			intEcoPlMaxCnt=intMultPlCnt;
			strMultTopPartNo=strMultIniTopPartNo;
			break;
		}else{
			intMultLevel++;
			if(intMultMaxLevel<intMultLevel){
				intMultMaxLevel=intMultLevel;
			}

			if(intMultLevel>intMultSpread){
				strMultTopPartNo="";
				break;
			}else{
				aryMultDatCnt[intMultLevel]=0;
				strMultTopPartNo="";
				intMultCnt=0;
				
				if(sbMultQry1.length()!=0){
					//-----子部品read-----//
					//ResultSet rsMultPart=objSql.executeQuery(strMultQuery);
					System.out.println(sbMultQry1.toString());
					ResultSet rsMultPart=objSql.executeQuery(
							sbMultQry1.toString());
					sbMultQry1.delete(0,sbMultQry1.length());

					while(rsMultPart.next()){
						if(intMultLevel==intMultSpread){
							if(sbMultPartNoList.length()==0){
								sbMultPartNoList .append(rsMultPart.getString("PartNo"));
								sbMultElmPartNoList .append(rsMultPart.getString("ElmPartNo"));
								sbMultSeqNoList .append(rsMultPart.getString("SeqNo"));
								sbMultQtySumList .append("") .append(rsMultPart.getDouble("Amount")*dblMultTopQty);
								sbMultLevelList .append(intMultLevel);
							}else{
								sbMultPartNoList .append(",") .append(rsMultPart.getString("PartNo"));
								sbMultElmPartNoList .append(",") .append(rsMultPart.getString("ElmPartNo"));
								sbMultSeqNoList .append(",") .append(rsMultPart.getString("SeqNo"));
								sbMultQtySumList .append(",") .append(rsMultPart.getDouble("Amount")*dblMultTopQty);
								sbMultLevelList .append(",") .append(intMultLevel);
							}
						}else{
						//-----read next data set-----//
							aryMultPartNo[intMultLevel][aryMultDatCnt[intMultLevel]]=rsMultPart.getString("PartNo");
							aryMultElmPartNo[intMultLevel][aryMultDatCnt[intMultLevel]]=rsMultPart.getString("ElmPartNo");
							aryMultSeqNo[intMultLevel][aryMultDatCnt[intMultLevel]]=rsMultPart.getString("SeqNo");
							aryMultQuantity[intMultLevel][aryMultDatCnt[intMultLevel]]=rsMultPart.getString("Amount");
							aryMultQtySum[intMultLevel][aryMultDatCnt[intMultLevel]]=rsMultPart.getDouble("Amount");
							aryMultLevel[intMultLevel][aryMultDatCnt[intMultLevel]]=intMultLevel;
							aryMultAllSeqNoTo[intMultLevel][aryMultDatCnt[intMultLevel]]=rsMultPart.getInt("AllSeqNoTo");
							aryMultToDate[intMultLevel][aryMultDatCnt[intMultLevel]]=rsMultPart.getString("ToDate");

						//-----read next data list set(read next first data)-----//
							if(intMultCnt==0){
								if(!strMultSpread.equals("E")
										|| (strMultSpread.equals("E")
												&& rsMultPart.getString("Category").equals("EQP"))){
									if(sbMultPartNoList.length()==0){
										sbMultPartNoList .append(rsMultPart.getString("PartNo"));
										sbMultElmPartNoList .append(rsMultPart.getString("ElmPartNo"));
										sbMultSeqNoList .append(rsMultPart.getString("SeqNo"));
										sbMultLevelList .append(intMultLevel);
									}else{
										sbMultPartNoList .append(",") .append(rsMultPart.getString("PartNo"));
										sbMultElmPartNoList .append(",") .append(rsMultPart.getString("ElmPartNo"));
										sbMultSeqNoList .append(",") .append(rsMultPart.getString("SeqNo"));
										sbMultLevelList .append(",") .append(intMultLevel);
									}
									if(strMultDir.equals("F")){
										dblMultQty=dblMultTopQty*rsMultPart.getDouble("Amount");
										for(int multcnt=1; multcnt<intMultLevel; multcnt++){
											dblMultQty=dblMultQty*aryMultQtySum[multcnt][aryMultNextLine[multcnt]-1];
										}
										sbMultQtySumList .append(",") .append(dblMultQty);//20151003
									}else{
										sbMultQtySumList .append(",") .append(rsMultPart.getString("Amount"));
									}
								}
								if(strMultDir.equals("F")){
									strMultTopPartNo=rsMultPart.getString("ElmPartNo");
								}else{
									strMultTopPartNo=rsMultPart.getString("PartNo");
								}
								if(!rsMultPart.getString("ToDate").equals("") && !strMultAllSeqNo.equals("")){
									if(rsMultPart.getInt("AllSeqNoTo")<=Integer.parseInt(strMultAllSeqNo)){
										strMultTopPartNo="ABOLISH";
									}
								}
								aryMultNextLine[intMultLevel]=1;
							}
							aryMultDatCnt[intMultLevel]++;
						}
						intMultCnt++;
					}
					rsMultPart.close();
				}

				if(intMultLevel<=intMultSpread){
					//最終＋１行に展開終了（スペース）セット
					aryMultPartNo[intMultLevel][aryMultDatCnt[intMultLevel]]="";

					//子部品が無ければ上位階層に戻って展開対象フォルダをセット
					if(aryMultDatCnt[intMultLevel]==0){
						while(intMultLevel>1){
							intMultLevel--;
							String MultPartNoNextLine = aryMultPartNo[intMultLevel][aryMultNextLine[intMultLevel]];
							String MultElmPartNoNetLine = aryMultElmPartNo[intMultLevel][aryMultNextLine[intMultLevel]];

							if(!MultPartNoNextLine.equals("")){
								if(sbMultPartNoList.length()==0){
									sbMultPartNoList .append(MultPartNoNextLine);
									sbMultElmPartNoList .append(MultElmPartNoNetLine);
									sbMultSeqNoList .append(aryMultSeqNo[intMultLevel][aryMultNextLine[intMultLevel]]);
									sbMultLevelList .append(aryMultLevel[intMultLevel][aryMultNextLine[intMultLevel]]);
								}else{
									sbMultPartNoList .append(",") .append(MultPartNoNextLine);
									sbMultElmPartNoList .append(",") .append(MultElmPartNoNetLine);
									sbMultSeqNoList .append(",") .append(aryMultSeqNo[intMultLevel][aryMultNextLine[intMultLevel]]);
									sbMultLevelList .append(",") .append(aryMultLevel[intMultLevel][aryMultNextLine[intMultLevel]]);//20151003
								}
								if(strMultDir.equals("F")){
									strMultTopPartNo=MultElmPartNoNetLine;
									dblMultQty=dblMultTopQty*aryMultQtySum[intMultLevel][aryMultNextLine[intMultLevel]];
									for(int multcnt=1; multcnt<aryMultLevel[intMultLevel][aryMultNextLine[intMultLevel]]; multcnt++){
										dblMultQty=dblMultQty*aryMultQtySum[multcnt][aryMultNextLine[multcnt]-1];
									}
									sbMultQtySumList .append(",") .append(dblMultQty);//20151003 double
								}else{
									strMultTopPartNo=MultPartNoNextLine;
									sbMultQtySumList .append(",") .append(aryMultQuantity[intMultLevel][aryMultNextLine[intMultLevel]]);
								}
								if(!strMultAllSeqNo.equals("") && !aryMultToDate[intMultLevel][aryMultNextLine[intMultLevel]].equals("")){
									if(aryMultAllSeqNoTo[intMultLevel][aryMultNextLine[intMultLevel]]<=Integer.parseInt(strMultAllSeqNo)){
										strMultTopPartNo="ABOLISH";
									}
								}
								//下位展開終了後読み出しNo. SET
								aryMultNextLine[intMultLevel]++;
								break;
							}
						}
					}
				}
			}
		}
	}
	if(strMultTopPartNo.equals("")){
		break;
	}
	//20160922
	strMultPartNoList = sbMultPartNoList .toString();
	strMultElmPartNoList = sbMultElmPartNoList .toString();
	strMultSeqNoList = sbMultSeqNoList .toString();
	strMultQtySumList = sbMultQtySumList .toString();
	strMultLevelList = sbMultLevelList .toString();
}
if(intEcoPlMaxCnt>intEcoIniPlMaxCnt){
	objSql.executeUpdate("update meeco set PlMaxCnt=" + intEcoPlMaxCnt);
}


%>

<!------------------------------ End of plmult_rtn.jsp ------------------------------>