
<%
String strZyuClassCd="";
String strZyuListType="";

int intZyuTbCnt=0;

objSql.executeUpdate("create temp table zyukeytemp("
			+ "KIKIMEI_ID	int,"
			+ "SysNam	text,"
			+ "TableCd	text,"
			+ "ItemCd	text,"
			+ "ItemVal	text"
			+ ")"
			);

objSql.executeUpdate("create temp table zyuvaltemp("
			+ "KIKIMEI_ID	int,"
			+ "SysNam	text,"
			+ "TableCd	text,"
			+ "TbItemCd	text,"
			+ "KeyVal	text,"
			+ "ItemNam	text,"
			+ "ItemVal	text,"
			+ "SortNo	int"
			+ ")"
			);

//--------------------------------------//
//----------KEY TABLE€–ÚƒZƒbƒg---------//
//--------------------------------------//
ResultSet rsZyuKeyTbCnt=objSql.executeQuery("select count(*) as count from zyumeitb");
rsZyuKeyTbCnt.next();

String[] aryZyuSysNam=new String[rsZyuKeyTbCnt.getInt("count")];
String[] aryZyuTableCd=new String[rsZyuKeyTbCnt.getInt("count")];
String[] aryZyuKeyItem=new String[rsZyuKeyTbCnt.getInt("count")];
String[] aryZyuKeyType=new String[rsZyuKeyTbCnt.getInt("count")];
String[] aryZyuSelUnique=new String[rsZyuKeyTbCnt.getInt("count")];

ResultSet rsZyuTbList=objSql.executeQuery("select * from zyumeitb");
while(rsZyuTbList.next()){
	aryZyuSysNam[intZyuTbCnt]=rsZyuTbList.getString("SysNam");
	aryZyuTableCd[intZyuTbCnt]=rsZyuTbList.getString("TableCd");
	aryZyuKeyItem[intZyuTbCnt]=rsZyuTbList.getString("KeyItem");
	aryZyuKeyType[intZyuTbCnt]=rsZyuTbList.getString("KeyType");
	aryZyuSelUnique[intZyuTbCnt]=rsZyuTbList.getString("SelUnique");
	intZyuTbCnt++;
}

int intZyuClmCnt=100;
String[] aryZyuKeyCd=new String[intZyuClmCnt];
String[] aryZyuItemVal=new String[intZyuClmCnt];
%>	
