<!-- ********************************************************
		＜ファイル閲覧＞ in みえるっち
		File Name :file_get_utf8.jsp
		Auther	:k-mizuno
		Date	:2006-09-05

		Update	2007-12-28 mizuno ファイル名「/」回避
		        2014-07-03 kaneshi 全般整理
		        　　　　製造標準のＰＤＦファイルのリンクに/pdf/pdfの重複をなくした。
		        2014-10-27 kaneshi
		            ResultSet (close rapidly)
		        2015-01-14 kaneshi SQL整理
		        2015-01-27 kaneshi SQLの＋をconcatに修正
		        2015-02-26 kaneshi StringBuilderとString#concatで高速化
		        2015-12-01 kaneshi 文字コードをＵＴＦ－８へ
		        　　　　　　　　　ＳＱＬのインデント整理
		        2015-12-12 kaneshi html ヘッ、ダに以下を追加
		        	<meta http-equiv="pragma" content="no-cache">
					<meta http-equiv="cache-control" content="non-cache">
					ファイル名に_utf8をつけ、以前のものと区別する。
					
			    2015-12-26 kaneshi URLのファイル名が読めなくならない処置　
			    デフォルトのファイル名を日本語のままで表示したい場合
	
				//ContentTypeの設定
				response.setContentType("application/octet-stream");？
				//Headerの設定
				response.setHeader("Content-Dispotision","attachment;filename="
				+ URLEncoder.encode(fileName,"UTF-8"));//？				
		        
************************************************************** -->

<%@ page contentType="text/html;charset=UTF-8"
         import="java.sql.*,java.io.*,java.net.*,java.util.*,java.text.*,
	 	java.nio.channels.*,
		javax.mail.*,javax.mail.internet.*,javax.servlet.*,javax.servlet.http.*,
		java.lang.*,java.lang.Character.UnicodeBlock" %>

<%String strRight="USER";%>
<%@ include file="../header_utf8.jsp" %>

<%
StringBuilder sbTmp = new StringBuilder();
StringBuilder sbQry = new StringBuilder();

String strSysNamList="";
String strFlNamList="";
String strSysFileNam="";
String strFileDir="";
String strTmpFileNam="";
String strDbNam="";
String strAction=request.getParameter("Action");
String strLinkNo=request.getParameter("LinkNo");
String strNote="";
if(request.getParameter("Action")==null){
	strAction="";
}

if(request.getParameter("LinkNo")!=null){
	ResultSet rsLink=objSql.executeQuery(
		sbTmp
		.append(" select linkno from filelink")
		.append(" where LinkNo='") .append(request.getParameter("LinkNo")) .append("'")
		.append(" and TableNam='files'")
		.append(" and ExpireDate>='") .append(strNowDate) .append("'")
		.toString()
		);
	sbTmp.delete(0,sbTmp.length());

	rsLink.next();
}else{
	strLinkNo="";
}

String strDir="";
//ユーザディレクトリ作成
if(request.getParameter("LinkNo")==null){
	strDir=strLoginUserNo;
}else{
	strDir=request.getParameter("LinkNo");
}

File df = new File(strEcoTmpDir .concat(strDir));
if(!df.exists()){
	df.mkdir();
}

if(request.getParameter("OptNo")!=null && request.getParameter("FileGet")==null){
//FILE名 2BITE CHARACTER 使用
%>
	<html>
	<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>ファイル閲覧</title>
	</head>
	<body style="background-color:#F9FBE0" OnLoad="focus();">

	<form name="file_get" action="file_get_utf8.jsp" method="post">
	<div align="center">
	<br><br>
	<input name="OptNo" type="hidden" value="<%=request.getParameter("OptNo")%>">
	<input name="FileNam" type="hidden" value="">
	<input name="FileGet" type="hidden" value="TRUE">
	</div>
	</form>

	<script type="text/javaScript">
	<!--
	var pgnam = window.opener.parent.pgnam;
	if(pgnam == 'ploptset_inp') {
		document.forms[0].FileNam.value=window.opener.parent.document.ploptset_inp1.FileNam.value;
	} else if(pgnam == 'ploptset_inp') {
		document.forms[0].FileNam.value=window.opener.parent.document.plopthed_inp.FileNam.value;
	}
	document.forms[0].submit();
	//-->
	</script>
  </body>
  </html>
<%
}else if(request.getParameter("ModelFile")!=null){
%>
	<html>
	<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>ファイル閲覧</title>
	</head>
	<body style="background-color:#F9FBE0" OnLoad="focus();">

	<form name="file_get" action="file_get_utf8.jsp" method="post">
	<div align="center">
	<br><br>
	<input name="ModelId" type="hidden" value="">
	<input name="MakerId" type="hidden" value="">
	<input name="FileNam" type="hidden" value="">
	<input name="FileGet" type="hidden" value="TRUE">
	</div>
	</form>

	<script type="text/javaScript">
	<!--

	if(window.opener.name=="fr_main"){
		document.forms[0].ModelId.value=window.opener.parent.fr_main.document.drmodel_sc.ModelId.value;
		document.forms[0].MakerId.value=window.opener.parent.fr_main.document.drmodel_sc.MakerId.value;
		document.forms[0].FileNam.value=window.opener.parent.fr_main.document.drmodel_sc.FileNam.value;
	} else {
		document.forms[0].ModelId.value=window.opener.parent.document [window.opener.parent.formname].ModelId.value;
		document.forms[0].MakerId.value=window.opener.parent.document [window.opener.parent.formname].MakerId.value;
		document.forms[0].FileNam.value=window.opener.parent.document [window.opener.parent.formname].FileNam.value;
	}

	document.forms[0].submit();
	//-->
	</script>
  </body>
  </html>
<%
}else{
	String strPartNam = "";

	if(request.getParameter("DrNo")!=null){
	//図面
		strFileDir=strEcoDrawDir;
		strDbNam="drawings";
		sbQry
		.append(" select DrFileCom as FileNam,DrFileNam as SysFileNam ")
		.append(" from drawings")
		.append(" where DrNo='") .append(request.getParameter("DrNo")) .append("'")
		;
		if(request.getParameter("InfoNo")!=null){
			strNote=request.getParameter("InfoNo");
		}
		// 2009-08-17 mizuno 画像感知器交差点名取得
		if(request.getParameter("partno")!=null){
			ResultSet rsPart=objSql.executeQuery(
				sbTmp
				.append(" select partNam from partdat ")
				.append(" where partno='") .append(request.getParameter("partno")) .append("'")
				.toString()
				);
			sbTmp.delete(0,sbTmp.length());
			
			rsPart.next();
			strPartNam = rsPart.getString("partnam");
			rsPart.close();
		}

	}else if(request.getParameter("CombDrNo")!=null){
		strFileDir=strEcoDrawDir .concat("pdf/");
		strDbNam="drcomb";
		
		sbQry
		.append(" select CombFileCom as FileNam,CombFileNam as SysFileNam ")
		.append(" from drcomb")
		.append(" where DrNo='") .append(request.getParameter("CombDrNo")) .append("'")
		;
		if(request.getParameter("InfoNo")!=null){
			strNote=request.getParameter("InfoNo");
		}
	}else if(request.getParameter("InfoNo")!=null){
	//設計変更通知
		strFileDir=strEcoDrawDir;
		strDbNam="drinfo";
		
		if(request.getParameter("Tgt").equals("REPORT")){
		//検査結果レポート
			sbQry
			.append(" select RepNam as FileNam,RepFileNam as SysFileNam ")
			.append(" from drinfo")
			.append(" where InfoNo='") .append(request.getParameter("InfoNo")) .append("'")
			;
		}else{
		//指示書
			sbQry
			.append(" select DirFileNam as FileNam,DirFileNam as SysFileNam ")
			.append(" from drinfo")
			.append(" where InfoNo='") .append(request.getParameter("InfoNo")) .append("'")
			;
		}
	}else if(request.getParameter("ModelId")!=null){
	//仕様書
		strFileDir=strEcoSpcDir;
		strDbNam="drmodel";
		sbQry
		.append(" select FileNam,SysFileNam ")
		.append(" from drmodel")
		.append(" where ModelId='") .append(request.getParameter("ModelId")) .append("'")
		.append(" and MakerId='") .append(request.getParameter("MakerId")) .append("'")
		;
		if(request.getParameter("VerNo")==null){
			sbQry
			.append(" and VerNo=(select max(VerNo) from drmodel")
			.append( " where ModelId='") .append(request.getParameter("ModelId")) .append("'")
			.append( " and MakerId='") .append(request.getParameter("MakerId")) .append("')")
			;
		}else{
			sbQry.append(" and VerNo=") .append(request.getParameter("VerNo"))
				;
		}
	}else if(request.getParameter("RequestNo")!=null){
	//設計変更要望
		strFileDir=strEcoDocDir;
		strDbNam="drrequest";
		sbQry
		.append(" select FileNam,FileNam as SysFileNam ")
		.append(" from drrequest")
		.append(" where RequestNo='") .append(request.getParameter("RequestNo")) .append("'")
		;
	}else if(request.getParameter("OptNo")!=null){
	//オーダエントリテンプレートファイル
		strFileDir = strEcoDocDir;
		strDbNam="entryopt";
		sbQry
		.append(" select FileCom as FileNam,Template as SysFileNam ")
		.append(" from entryopt ")
		.append(" where OptNo='") .append(request.getParameter("OptNo")) .append("'")
		//2010-05-02 mizuno プロトタイプ対応
		//	+ " and TopSign='YES'"
		;
	}else if(request.getParameter("OptSetNo")!=null){
	//オーダエントリ添付ファイル
		strFileDir = strEcoDocDir;
		strDbNam="optset";
		sbQry
		.append(" select FileComList as FileNam,FileNamList as SysFileNam ")
		.append(" from optset")
		.append(" where OptSetNo=") .append(request.getParameter("OptSetNo"))
		.append(" and VerNo=(select max(VerNo) from optset")
		.append(" where OptSetNo=") .append(request.getParameter("OptSetNo")) .append(")")
		;
	}else if(request.getParameter("StdNo")!=null){
	//製造標準
		strFileDir=strEcoStdDir;
		strDbNam="stddoc";
		sbQry
		.append(" select FileNam,FileNam as SysFileNam from stddoc")
		.append(" where StdNo=") .append(request.getParameter("StdNo"))
		.append(" and SeqNo=") .append(request.getParameter("SeqNo"))
		.append(" and DatNo=") .append(request.getParameter("DatNo"))
		;
	}else if(request.getParameter("JOMAE")!=null){
	//錠前
		strFileDir=strEcoStdDir;
		strDbNam="lockcer";
		sbQry
		.append(" select FileNam,FileNam as SysFileNam from lockcer")
		.append(" where SEIBAN='") .append(request.getParameter("SEIBAN")) .append("'")
		.append(" and SEIBAN_KO='") .append(request.getParameter("SEIBAN_KO")) .append("'")
		;
	}else if(request.getParameter("DrTypeCd")!=null){
		strFileDir=strEcoFmtDir + "drsheet/";
		strDbNam="drtype";
		sbQry
		.append(" select sheetname as FileNam,sheetfile as SysFileNam")
		.append(" from drtype")
		.append(" where drtypecd= '") .append(request.getParameter("DrTypeCd")) .append("'")
		;
	}else if(request.getParameter("estimateno")!=null){
		strFileDir=strEcoDocDir;
		strDbNam="pjestimate";
		sbQry
		.append(" select FileNam, SysFileNam ")
		.append(" from pjestimate ")
		.append(" where estimateno= '") .append(request.getParameter("estimateno")) .append("'")
		;
	}else if(request.getParameter("qcdatafile")!=null){
	// 試験成績書
		strFileDir=strEcoQcDir;
		strDbNam="qcdatafile";
		sbQry
		.append(" select partno as FileNam,filenam as SysFileNam ")
		.append(" from qcdatafile")
		.append(" where seiban = '") .append(request.getParameter("seiban")) .append("'")
		.append(" and partno = '") .append(request.getParameter("qcpartno")) .append("'")
		;
	}

	if(!sbQry.toString().equals("")){
		
		ResultSet rsFile=objSql.executeQuery(sbQry.toString());
		sbQry.delete(0,sbQry.length());
		
		rsFile.next();
		strSysNamList=rsFile.getString("SysFileNam");
		strFlNamList=rsFile.getString("FileNam");
		rsFile.close();
	}

	StringTokenizer fsTkn=new StringTokenizer(strSysNamList,",");
	StringTokenizer fmTkn=new StringTokenizer(strFlNamList,",");
	
	while(fsTkn.hasMoreTokens()){
		strSysFileNam=fsTkn.nextToken();
		strTmpFileNam=fmTkn.nextToken();

		// 2009-08-17 mizuno 画像感知器交差点名付加
		if(!strPartNam.equals("")){
			strTmpFileNam = strPartNam .concat("-") .concat(strTmpFileNam);
		}

		//拡張子付加
		if(request.getParameter("PDF")!=null){
			//直下ディレクトリのPDF Fileにファイル名変更
			if(strSysFileNam.indexOf(".")>0){
				strSysFileNam = "pdf/" .concat(strSysFileNam.substring(0,strSysFileNam.lastIndexOf("."))) .concat(".pdf");
			}else{
				strSysFileNam = "pdf/" .concat(strSysFileNam) .concat(".pdf");
			}
			strTmpFileNam=strTmpFileNam + ".pdf";
		}else if(strSysFileNam.indexOf(".")>0){
			if(strTmpFileNam.indexOf(".")<=0
					|| !strSysFileNam.substring(strSysFileNam.lastIndexOf("."),strSysFileNam.length()).equals(strTmpFileNam.substring(strTmpFileNam.lastIndexOf("."),strTmpFileNam.length()))){
				strTmpFileNam = strTmpFileNam .concat(strSysFileNam.substring(strSysFileNam.lastIndexOf("."),strSysFileNam.length()));
			}
		}

		//指定がなければ先頭ファイル
		if(request.getParameter("PartNo")==null && request.getParameter("FileNam")==null){
			break;
		}else{
			String strDspFileNam=request.getParameter("FileNam");
			if(request.getParameter("PartNo")!=null){
				if(request.getParameter("CADNo")!=null){
					if(strSysFileNam.equals(strDspFileNam)){
						break;
					}
			//部品表
				}else if(strSysFileNam.indexOf(request.getParameter("PartNo"))>=0){
					break;
				}
			}else{
				//指定ファイルが自動変換PDFの場合照合ファイル名編集
				if(request.getParameter("PDF")!=null){
					strDspFileNam = "pdf/" .concat(strDspFileNam.substring(0,strDspFileNam.lastIndexOf("."))) .concat(".pdf");
				}
				if(strSysFileNam.equals(strDspFileNam)){
					break;
				}
			}
		}
	}

	sbQry
	.append("insert into docread(")
	.append( "UserId,")		//ユーザＩＤ
	.append( "LinkNo,")		//One Time Pass
	.append( "DbNam,")		//DB
	.append( "ReadFile,")		//ファイル
	.append( "Action,")		//閲覧目的
	.append( "IpAddr,")		//IP
	.append( "ReadDate,")		//閲覧日
	.append( "Note")
	.append( ")values(")
	.append( "'") .append(strLoginUserId) .append("',")
	.append( "'") .append(strLinkNo) .append("',")
	.append( "'") .append(strDbNam) .append("',")
	.append( "'") .append(strSysFileNam) .append("',")
	.append( "'") .append(strAction) .append("',")
	.append( "'',")
	.append( "now(),")
	.append( "'") .append(strNote) .append("'")
	.append( ")")
	;
	objSql.executeUpdate(sbQry.toString());
	sbQry.delete(0,sbQry.length());

	//------------------------------
	//----------FILE COPY-----------
	//------------------------------
	if(strFileDir.substring(strFileDir.length() - 4).equals("pdf/")
		   && strSysFileNam.substring(0,4).equals("pdf/")){
	  strSysFileNam = strSysFileNam.substring(4);
	}
	
	File objInFl=new File(strFileDir .concat(strSysFileNam));

//2007-12-28 mizuno ファイル名「/」回避
	String strOutFileNam=strTmpFileNam.replaceAll("/","／");
	strOutFileNam=strOutFileNam.replaceAll(":","：");
	
	if(strOutFileNam.indexOf("pdf/")==0){
		strOutFileNam = strOutFileNam.substring(strOutFileNam.indexOf("/"),strOutFileNam.length());
	}
	strOutFileNam = strOutFileNam.replaceAll("#", "＃");
	//ファイル名を強制的にSJISにしてみる。　２０１５１２２６
	//String strOutFileNam1=new String(strOutFileNam.getBytes("UTF-16"),"UTF-8");
	
	File objOutFl=new File(strEcoTmpDir .concat(strDir) .concat("\\") .concat(strOutFileNam));

	if(objOutFl.exists()){
		objOutFl.delete();
	}
	
	RandomAccessFile inFile=new RandomAccessFile(objInFl,"r");
	RandomAccessFile outFile=new RandomAccessFile(objOutFl,"rw");

	FileChannel inChannel=inFile.getChannel();
	FileChannel outChannel=outFile.getChannel();

	inChannel.transferTo(0,inChannel.size(),outChannel);
	outChannel.force(true);

	outFile.close();
	inFile.close();
	String strOutFileNamEnc = URLEncoder.encode(strOutFileNam,"UTF-8");//20151226(テスト環境はUTF-8で動く)
	%>

	<html>
	<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="non-cache">
	<meta http-equiv="Expires" content="0">
	</head>	
	<body>
		<script type="text/JavaScript">
			window.location="<%=strEcoTmpUrl%><%=strDir%>/<%=strOutFileNamEnc%>";
		</script>
  </body>
  </html>
<%}%>

<%
objSql.close();
db.close();
%>

<!--*********************** End of file_get_utf8.jsp *****************************-->