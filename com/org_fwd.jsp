<%@ page contentType="text/html;charset=Windows-31J"%>
<!-- ******************************************************
	org_spread
	File Name :org_fwd.jsp
	 call origin: com/memb_link,memb_sel
	        design/ drinfoapv_inp
	                drinfomp_inp
	        designinfra / defmail_set
	                      druser_list ＯＫ
	        sys/ mailaddr_dwn
	             mailapl_inp
	             memb_list 
	Author	:k-mizuno
	Date	:2006-06-09
	
	Update:2014-12-22 kaneshi
	2015-08-08 kaneshi StringBuilder,PreparedStatement_speed up
	2016-02-16 kaneshi delete SQL commend
	2016-03-19 kaneshi String#concatの徹底
	　　　　　　　　　文字コードs-jisとutf-8をわけた。
	2018-03-29 kaneshi SQL検索条件の優先度変更
		                

******************************************************** -->

<%
//******注）以下の変数は呼出Programで定義が必要*******
//strMultpOrgId
//strMultTopOrgNam
//strMultSetDate
//intMultTopLevel
//intMultMaxLevel

String[][] aryMultOrgId=new String[10][100];
String[][] aryMultOrgNam=new String[10][100];
String[][] aryMultOrgLevel=new String[10][100];
int[] aryMultDatCnt=new int[10];
int[] aryMultNextLine=new int[10];


String strMultOrgIdList="";
StringBuilder sbMultOrgIdList = new StringBuilder();

String strMultOrgNamList="";
StringBuilder sbMultOrgNamList = new StringBuilder();


StringBuilder sbMultOrgLevelList = new StringBuilder(); 
sbMultOrgLevelList .append(Integer.toString(intMultTopLevel));


String strMultQuery="";
StringBuilder sbMultQry = new StringBuilder();

int intMultLevel=intMultTopLevel;

StringTokenizer multtopnoTkn=new StringTokenizer(strMultTopOrgId,",");
StringTokenizer multtopnamTkn=new StringTokenizer(strMultTopOrgNam,",");

PreparedStatement psOrg=null;

while(multtopnoTkn.hasMoreTokens()){
	strMultTopOrgId=multtopnoTkn.nextToken();
	sbMultOrgIdList .append(",") .append(strMultTopOrgId);
	sbMultOrgNamList .append(",") .append(multtopnamTkn.nextToken());
	
	while(!strMultTopOrgId.equals("")){
		if(sbMultQry.length()==0){
			sbMultQry
			.append(" select orgid,orgnam,levelno ")
			.append(" from ") .append(strMultTbNam)
			.append(" where UpOrgId=?")// S1
			.append(" and (ToDate>='") .append(strMultSetDate) .append("' or ToDate='')")
			.append(" and UpOrgId!=0")
			.append(" and LevelNo<=?") //I2
			.append(" and FromDate<='") .append(strMultSetDate) .append("'")
			.append(" order by LevelNo desc,SortNo");
		}

		if(psOrg == null){
			psOrg =db.prepareStatement(
				sbMultQry.toString()
				);
		}
		psOrg.setInt(1, Integer.valueOf( strMultTopOrgId));
		psOrg.setInt(2, intMultMaxLevel);
		ResultSet rsMultOrg=psOrg.executeQuery();

// 		//-----下位フォルダread-----//
// 		ResultSet rsMultOrg=objSql.executeQuery(strMultQuery);

		intMultLevel++;
		aryMultDatCnt[intMultLevel]=0;
		strMultTopOrgId="";

		while(rsMultOrg.next()){
		//-----read next data set-----//
			aryMultOrgId[intMultLevel][aryMultDatCnt[intMultLevel]]=rsMultOrg.getString("OrgId");
			aryMultOrgNam[intMultLevel][aryMultDatCnt[intMultLevel]]=rsMultOrg.getString("OrgNam");
			aryMultOrgLevel[intMultLevel][aryMultDatCnt[intMultLevel]]=rsMultOrg.getString("LevelNo");

		//-----read next data list set(read next first data)-----//
			if(strMultTopOrgId.equals("")){
				sbMultOrgIdList .append(",") .append(rsMultOrg.getString("OrgId"));
				sbMultOrgNamList .append(",") .append(rsMultOrg.getString("OrgNam"));
				sbMultOrgLevelList .append(",") .append(rsMultOrg.getString("LevelNo"));
				strMultTopOrgId=rsMultOrg.getString("OrgId");
				aryMultNextLine[intMultLevel]=1;
			}
			aryMultDatCnt[intMultLevel]++;
		}
		rsMultOrg.close();

		//最終＋１行に展開終了（スペース）セット
		aryMultOrgId[intMultLevel][aryMultDatCnt[intMultLevel]]="0";

		//下位フォルダが無ければ上位階層に戻って展開対象フォルダをセット
		if(aryMultDatCnt[intMultLevel]==0){
			while(intMultLevel>intMultTopLevel+1){
				intMultLevel--;
				String multorgid = aryMultOrgId[intMultLevel][aryMultNextLine[intMultLevel]];
				if(!multorgid.equals("0")){
					sbMultOrgIdList .append(",") .append(multorgid);
					sbMultOrgNamList .append(",") .append(aryMultOrgNam[intMultLevel][aryMultNextLine[intMultLevel]]);
					sbMultOrgLevelList .append(",") .append(aryMultOrgLevel[intMultLevel][aryMultNextLine[intMultLevel]]);
					strMultTopOrgId=multorgid;
					//下位展開終了後読み出しNo. SET
					aryMultNextLine[intMultLevel]++;
					break;
				}
			}
		}
	}
	strMultOrgIdList = sbMultOrgIdList.toString();
	strMultOrgNamList=sbMultOrgNamList.toString();
	
	String strMultOrgLevelList =sbMultOrgLevelList.toString();
	
}
%>

<!------------------------------ End of org_fwd.jsp ------------------------------>