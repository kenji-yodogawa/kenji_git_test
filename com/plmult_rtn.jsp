<%@ page contentType="text/html;charset=Windows-31J"%>
<!-- *****************************************************************
		File Name :plmult_rtn.jsp
		
		�ďo���Fdrinfoapv_inp.jsp
		        drinfompapv_upl.jsp (���d�v)
		        ploptset_upl.jsp�@�i���d�v�j
		Auther	:k-mizuno
		Date	:2006-09-05
		       2014-12-25 kaneshi ������
		       2015-12-07 kaneshi �s�v�ȃR�����g���폜
		       �@�@�@�@�@�@�@�@�@�@�@�@�@�@StringBuilder��String#concat�ō�����
		       2016-03-19 kaneshi ���v���O�����g��r�`�F�b�N
		       2016-09-22 kaneshi StringBuilder���ēO��
		       2016-10-11 kaneshi select L.* �C���@�J��������
		       �@�@�@�@�@�@�@�@�@�@�@�@�@StringBuilder#setLength(0)�Ή�
		       2016-10-19 kaneshi �o�͂���p�����[�^���`����ꏊ�����������C�����܂����B
******************************************************************** -->
<meta http-equiv="Content-Type" content="text/html;charset=Windows-31J">
<%
//******���j�ȉ��̕ϐ��͌ďoProgram�Œ�`���K�v*******
//strMultTopPartNo(�W�JPartNo)
//strMultSetDate(�W�J����)
//strMultSpread(�W�JM:�}���` S:�V���O�� E:���i)
//strMultDir(�W�JF:���W�J B:�t�W�J)
//strMultTopQty(���v��)
//dblMultQty(���v��:���[�N)
// (strMultQuery ??) ��L�������Ȃ��A���낢�날��
//strMultIniTopPartno ?? �����ɂ����Ȃ���
//intMultPlCnt  ??�@�@plmult_var.jsp�ɂ���
//intEcoPlMaxCnt ?? header �ɂ���B�@plmult_var.jsp�ɂ������B�����ɂȂ��Ă���
// 	strMultPartNoList�@plmult_var.jsp�ɂ�����
// 	strMultElmPartNoList�@plmult_var.jsp�ɂ�����
// 	strMultSeqNoList�@�@plmult_var�ɂ�����
// 	strMultQtySumList�@plmult_var�ɂ�����
// 	strMultLevelList�@plmult_var�ɂ�����
// 	intMultLevel�@�@�@�@plmult_var�ɂ�����
// 	intMultMaxLevel�@�@plmult_var�ɂ�����
//�@strMultAllSeqNo�@�@plmult_var�ɂ�����
//  strMultEfc�@�@�@plmult_var�ɂ�����//


StringBuilder sbMultQry = new StringBuilder();
StringBuilder sbMultQry1 = new StringBuilder();
StringBuilder sbTmpPM = new StringBuilder();

strMultIniTopPartNo=strMultTopPartNo;
intMultPlCnt=0;

StringBuilder sbMultPartNoList = new StringBuilder();//20160922
StringBuilder sbMultElmPartNoList = new StringBuilder();//20160922
StringBuilder sbMultSeqNoList = new StringBuilder();//20160922
StringBuilder sbMultQtySumList = new StringBuilder();//20160922
StringBuilder sbMultLevelList = new StringBuilder();//20160922


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
	sbMultPartNoList .setLength(0);//20160922 -> 20161019

	//strMultElmPartNoList="";
	sbMultElmPartNoList .setLength(0);//20160922 -> 20161019

	//strMultSeqNoList="";
	sbMultSeqNoList  .setLength(0);//20160922 -> 20161019

	//strMultQtySumList="";
	sbMultQtySumList .setLength(0);//20160922 -> 20161019

	//strMultLevelList="";
	sbMultLevelList .setLength(0);//20160922 -> 20161019
	//strMultQuery="";
	sbMultQry.setLength(0);

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
			sbMultQry.setLength(0);
		}else{
			sbMultQry.setLength(0);
			//�����ԍ��w��̏ꍇ
			if(!strMultAllSeqNo.equals("")){
				if(!strMultAllSeqNo.equals("99999999")){
					sbMultQry.append(" and AllSeqNoFrom<=") .append(strMultAllSeqNo);
					
					if(strMultEfc.equals("")){
					//�w��Ver.�Ŕp�~�̕��i���܂�
						sbMultQry.append(" and AllSeqNoTo>=") .append(strMultAllSeqNo);
					}else{
					//�w��Ver.�Ŕp�~�̕��i���܂܂Ȃ�
						sbMultQry.append(" and AllSeqNoTo>") .append(strMultAllSeqNo);
					}
				}else{
					sbMultQry.append(" and AllSeqNoFrom<=") .append(strMultAllSeqNo);
					if(strMultEfc.equals("")){
					//�w��Ver.�Ŕp�~�̕��i���܂�
						sbMultQry.append(" and (ToDate='' or ToDate='9999-99-99')");
					}else{
					//�p�~�̕��i���܂܂Ȃ�
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
			//-----�\�����`�F�b�N-----//
			ResultSet rsMultPlCnt=objSql.executeQuery(
				sbTmpPM
				.append(" select count(*) as count from pldat")//plps0
				.append(" where PartNo='") .append(strMultTopPartNo) .append("'")
				.append(" and ObjType='PART'")
				.append(sbMultQry)
				.toString());sbTmpPM.setLength(0);

			rsMultPlCnt.next();
			intMultPlCnt=rsMultPlCnt.getInt("count");
			rsMultPlCnt.close();
			
			sbMultQry1.setLength(0);

			if(strMultDir.equals("F")){
				sbMultQry1
				.append(" select L.PartNo,L.ElmPartNo,L.seqNo,L.amount,L.allSeqNoTo,L.toDate,partdat.Category ")//plps1
				.append(" from pldat as L,partdat")
				.append(" where L.PartNo=partdat.PartNo")
				.append(" and L.PartNo='") .append(strMultTopPartNo) .append("'")
				.append(" and L.ObjType='PART'")
				.append(sbMultQry)
				.append(" order by ElmPartNo,SeqNo")
				;
			}else{
				sbMultQry1
				.append(" select L.PartNo,L.ElmPartNo,L.seqNo,L.amount,L.allSeqNoTo,L.toDate,partdat.Category ")//plps2
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
		//�\�������ݒ�𒴂���ꍇ�͐ݒ�ύX���ēW�J
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
					//-----�q���iread-----//
					//ResultSet rsMultPart=objSql.executeQuery(strMultQuery);

					ResultSet rsMultPart=objSql.executeQuery(
						sbMultQry1
						.toString());sbMultQry1.setLength(0);

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
					//�ŏI�{�P�s�ɓW�J�I���i�X�y�[�X�j�Z�b�g
					aryMultPartNo[intMultLevel][aryMultDatCnt[intMultLevel]]="";

					//�q���i��������Ώ�ʊK�w�ɖ߂��ēW�J�Ώۃt�H���_���Z�b�g
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
								//���ʓW�J�I����ǂݏo��No. SET
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
}

//20160922
strMultPartNoList = sbMultPartNoList .toString();
strMultElmPartNoList = sbMultElmPartNoList .toString();
strMultSeqNoList = sbMultSeqNoList .toString();
strMultQtySumList = sbMultQtySumList .toString();
strMultLevelList = sbMultLevelList .toString();

if(intEcoPlMaxCnt>intEcoIniPlMaxCnt){
	objSql.executeUpdate("update meeco set PlMaxCnt=" + intEcoPlMaxCnt);
}



%>

<!------------------------------ End of plmult_rtn.jsp ------------------------------>