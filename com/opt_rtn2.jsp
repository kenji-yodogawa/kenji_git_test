<%-- <%@ page contentType="text/html;charset=Windows-31J"%> --%>
<!-- *****************************************************
	�����i�I�v�V�����W�J���@in�@�݂������
	File Name :opt_rtn.jsp
	�ďo���F
	design/
	drinfo_inp.jsp
	entryopt_inp.jsp (utf8)
	opt_folder.jsp (utf8)
	ploptset_inp.jsp
	ploptset_sc.jsp (utf8)
	
	Author	:k-mizuno
	Date	:2007-02-26

	Update	
	2007-11-13 mizuno �e�[�u���Q�d�����f�[�^���O
	2008-02-08 mizuno GREEN�Ή�
	2014-10-31 kaneshi select *�@�̃J��������
	�@�@�@�@�@�@�@�@�@ ResultSet����������
	2015-11-30 kaneshi SQL�C���f���g����
	�@�@�@�@�@�@�@�@�@�@�ϐ��̕�����W�J����߂�����[�u 
	          �@�@�@�@�@�@�����R�[�h���t�s�e�|�W�� �@opt_folder��OK
	2016-02-16 kaneshi �����[�X
	2016-09-19 kaneshi StringBuilder������
	2018-01-25 kaneshi �e�[�u�������O�̍i�荞��
	2018-03-12 kaneshi ploptset_inp.jsp����Ă΂��ۂ�
	�@strMultSelQuery�@�̏�����������������ƂɑΉ�
	�@�@�@sbEO(entryopt)�A����OT�ioptTree�ɑΉ��j,
	   sbOM(optModel)�ɑΉ�
		            
		            
		   �y�ۑ�z�錾���̃T�u���[�`���ɂ���B
		   �@�@�@�@input ,output�͂Ȃɂ��H
		             
********************************************************** -->

<%@page import="java.sql.PreparedStatement"%>
<%
//******���j�ȉ��̕ϐ��͌ďoProgram�Œ�`���K�v*******
//intMultTopOptNo;�@(input����)
//strMultSelQuery
//intMultLevel
//sbMultOptQry1 strMultOptQuery
// strMultUpOptNoList
// strMultTreeOptNoList
// strMultOptLevelList
// strMultTailOptNoList�@//trail ������
//strMultOptDir
//Connection db���K�v

// output ���ڂƎv����B
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
System.out.println("shoki�@strMultTreeOptNoList="+strMultTreeOptNoList);
//optset_inp �ł͏����͂������

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
			//2008-02-08 mizuno GREEN�Ή�
			if(strMultOptDir.equals("F")){
				//optNo,treeOptNo,green
				//-----����Option read-----//
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
				//-----����Option read-----//
				//ResultSet rsMultOpt=objSql.executeQuery(strMultOptQuery);
				rsMultOpt=objSql.executeQuery(sbMultOptQry1.toString());
				sbMultOptQry1.delete(0,sbMultOptQry1.length());
			}else{
				sbMultOptQry1
				.append(strMultSelQuery)
				.append(" and OT.TreeOptNo=") .append(intMultTopOptNo)
				.append(" order by OT.SortNo")
				;
				//-----����Option read-----//
				//ResultSet rsMultOpt=objSql.executeQuery(strMultOptQuery);
				rsMultOpt=objSql.executeQuery(sbMultOptQry1.toString());
				sbMultOptQry1.delete(0,sbMultOptQry1.length());
			}
		}

		aryMultDatCnt[intMultLevel]=0;
		intMultTopOptNo=-1;


		//2007-11-13 mizuno �e�[�u���Q�d�����f�[�^���O
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
					//�d�v�l��
					sbMultTreeOptNoList .append(",") .append(intTreeOptno);
					sbMultOptLevelList .append(",") .append(intMultLevel);
					intMultTopOptNo=intTreeOptno;
					aryMultNextLine[intMultLevel]=1;
				}

				//2008-02-08 mizuno GREEN�Ή�
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

	//�ŏI�{�P�s�ɓW�J�I���i�X�y�[�X�j�Z�b�g
	aryMultTreeOptNo[intMultLevel][aryMultDatCnt[intMultLevel]]=0;

	//���ʃt�H���_��������Ώ�ʊK�w�ɖ߂��ēW�J�Ώۃt�H���_���Z�b�g
	if(aryMultDatCnt[intMultLevel]==0){
		while(intMultLevel>0){
			intMultLevel--;
			int int_multnextline_multlevel = aryMultNextLine[intMultLevel];

			if(aryMultTreeOptNo[intMultLevel][int_multnextline_multlevel]>0){
				sbMultUpOptNoList .append(",") .append(aryMultUpOptNo[intMultLevel][int_multnextline_multlevel]);
				//�d�v�l��
				sbMultTreeOptNoList .append(",") .append(aryMultTreeOptNo[intMultLevel][int_multnextline_multlevel]);
				sbMultOptLevelList .append(",") .append(aryMultOptLevel[intMultLevel][int_multnextline_multlevel]);
				intMultTopOptNo=aryMultTreeOptNo[intMultLevel][aryMultNextLine[intMultLevel]];
				sbMultTailOptNoList .append(",") .append(aryMultTailOptNo[intMultLevel]);
				//���ʓW�J�I����ǂݏo��No. SET
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