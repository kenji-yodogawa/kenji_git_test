<%@ page contentType="text/html;charset=UTF-8"
         import="java.sql.*,java.io.*,java.net.*,java.util.*,java.text.*,
	 	java.nio.channels.*,
		javax.mail.*,javax.mail.internet.*,javax.servlet.*,javax.servlet.http.*,
		java.lang.*,java.lang.Character.UnicodeBlock,
		org.apache.commons.codec.net.URLCodec" 
%><%String strRight="USER";%><%@ include file="../header_utf8.jsp" %><%
// ********************************************************
// ＜ファイル閲覧＞ みえるっち
// File Name :file_getspc.jsp
// Author	:k-mizuno
// Date	:2006-09-05
// 呼出し元：
//    (design)
//        drawing_sc.jsp   （table drawings） OK
//        drawing_list.jsp  （table drawings） OK 
//		  drawingchg_list.jsp (table drawings) OK

//        drver_list.jsp  （table drawings）  <- part_dtl.jsp,drcopy_list.jsp,drawing_list.jsp OK
//        pl_dsp.jsp <- （table drawings）
//        part_dtl <- （table drawings）　SPECシート　ＯＫだが　未本番
//        part_sc <= (table drawings) SPECシート　ＯＫだが　未本番
//        drcopy_list.jsp  （table drawings）      <- drpl_inp.jsp <-part_dtl.jsp
//		  comdr_listsub.jsp   
//
//        drawingsc_win.jsp  （table drawings）  <- drinfo_inp.jsp <- drinfo_folder

//		  drinfo_dtl  （table drawings）                  <- drinfo_folder
//        drapv_inp.jsp  （table drawings）           <- drinfo_chk.jsp のメール＋　drinfo_folder
//        drinfochk_inp.jsp  （table drawings）  <-drinfo_inp.jsp メールとdrinfo_folder から
//        drinfosc_win.jsp   （table drawings）　<- drinfo_inp.jsp

//
//        drmodel_arc.jsp  
//        drmodel_sc.jsp
//        drrequest.dtl.jsp

//        estimate_dtl.jsp
//        opt_folder.jsp
//        optpart_sc.jsp

//        plopthed_inp.jsp
//        ploptset_inp.jsp
//        softdraw_sc.jsp
//        softver_tree.jsp
//        softverrec_inp.jsp
//    (designinfra)
//        drtyppe_list.jsp
//    (sales)
//        lockcer_inp.jsp
//        lockcer_list.jsp
//        lockpch_inp.jsp
//        qcinspection_list.jsp
//        softverrec_inp.jsp
//    (seikan)
//        lopch_inp.jsp
//        lopch_list.jsp
//        stddoc_dtl.jsp
//        stddoc_list
//        stddocapv_inp.jsp
//        stddocver_list.jsp
// Update	
// 2007-12-28 mizuno ファイル名「/」回避
// 2014-07-03 kaneshi 全般整理
// 　　　　製造標準のＰＤＦファイルのリンクに/pdf/pdfの重複をなくした。
// 2014-10-27 kaneshi
//     ResultSet (close rapidly)
// 2015-01-14 kaneshi SQL整理
// 2015-01-27 kaneshi SQLの＋をconcatに修正
// 2015-02-26 kaneshi StringBuilderとString#concatで高速化,concat -> append
// 2016-02-03 kaneshi ファイル名に全角スペースがあったらアンダーバー（半角）に変換
// 2017-02-04 kaneshi URL相対化
// 2017-02-18 kaneshi バグ修正　	,呼出元のコメント追加        
// 2017-03-08 kaneshi ファイルが大きくて、少しずつダウンロードするように修正
// 2017-03-21 kaneshi IE１１　でＰＤＦファイルをダウンロードするとfile_getspc.jsp に化けることへの対応
// 2017-03-29 kaneshi drinfo_dtl.jsp からのダウンロードの問題解決
// 2017-04-21 kaneshi opthed_inp.jsp のダウンロード問題へ対処
//                     まだファイル拡張子がはずれる問題あり
//
// ************************************************************** 
StringBuilder sbTmp = new StringBuilder();
StringBuilder sbQry = new StringBuilder();

String strSysNamList="";
String strFlNamList="";
StringBuilder sbSysFileNam=new StringBuilder();
String strFileDir="";
StringBuilder sbUsrFileNam=new StringBuilder();
String strDbNam="";
String strAction=request.getParameter("Action");
String strLinkNo=request.getParameter("LinkNo");
if(request.getParameter("LinkNo")==null){
	strLinkNo="";
}

String strNote="";
if(request.getParameter("Action")==null){
	strAction="";
}

//System.out.println("request.getParameter('FileRow')="+request.getParameter("FileRow"));

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


if(request.getParameter("ModelFile")!=null){
%>
	<html>
	<head>
	<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
	<title>ファイル閲覧</title>
	</head>
	<body style="background-color:#F9FBE0" OnLoad="focus();">

	<form name="file_getspc" action="file_getspc.jsp" method="post">
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
		var DP=window.opener.parent.fr_main.document.all;
		document.forms[0].ModelId.value=DP.drmodel_sc.ModelId.value;
		document.forms[0].MakerId.value=DP.drmodel_sc.MakerId.value;
		document.forms[0].FileNam.value=DP.drmodel_sc.FileNam.value;
	} else {
		var DP=window.opener.parent.document.all;
		document.forms[0].ModelId.value=DP [window.opener.parent.formname].ModelId.value;
		document.forms[0].MakerId.value=DP [window.opener.parent.formname].MakerId.value;
		document.forms[0].FileNam.value=DP [window.opener.parent.formname].FileNam.value;
	}

	document.forms[0].submit();
	//-->
	</script>
  </body>
  </html>
<%
}else if(request.getParameter("ModelFile")!=null){// end of else if(request.getParameter("ModelFile")!=null){
%>
	<html>
	<head>
	<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
	<title>ファイル閲覧</title>
	</head>
	<body style="background-color:#F9FBE0" OnLoad="focus();">

	<form name="file_getspc" action="file_getspc.jsp" method="post">
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
		var DP = window.opener.parent.fr_main.document.all;
		document.forms[0].ModelId.value=DP.drmodel_sc.ModelId.value;
		document.forms[0].MakerId.value=DP.drmodel_sc.MakerId.value;
		document.forms[0].FileNam.value=DP.drmodel_sc.FileNam.value;
	} else {
		var DP = window.opener.parent.document.all;
		document.forms[0].ModelId.value=DP [window.opener.parent.formname].ModelId.value;
		document.forms[0].MakerId.value=DP [window.opener.parent.formname].MakerId.value;
		document.forms[0].FileNam.value=DP [window.opener.parent.formname].FileNam.value;
	}
	document.forms[0].submit();
	//-->
	</script>
  </body>
  </html>
<%
}else if (request.getParameter("ModelFileArc")!=null){
	%>
	<html>
	<head>
	<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
	<title>ファイル閲覧</title>
	</head>
	<body style="background-color:#F9FBE0" OnLoad="focus();">

	<form name="file_getspc" action="file_getspc.jsp" method="post">
	<div align="center">
	<br><br>
	<input name="ModelId" type="hidden" value="<%=request.getParameter("ModelId")%>">
	<input name="MakerId" type="hidden" value="<%=request.getParameter("MakerId")%>">
	<input name="Ver" type="hidden" value="<%=request.getParameter("Ver") %>">
	<input name="FileNam" type="hidden" value="<%=request.getParameter("FileNam") %>">
	<input name="FileGet" type="hidden" value="TRUE">
	</div>
	</form>

	<script type="text/javaScript">
	<!--
	document.forms[0].submit();
	//-->
	</script>
  </body>
  </html>
<%

}else{
	String strPartNam = "";

	if(request.getParameter("DrNo")!=null){
	//図面(ほとんどの図面がこれ)
		strFileDir=strEcoDrawDir;
		strDbNam="drawings";
		sbQry
		.append(" select DrFileCom as FileNam,DrFileNam as SysFileNam \n")
		.append(" from drawings \n")
		.append(" where DrNo='") .append(request.getParameter("DrNo")) .append("' \n")
		;
		if(request.getParameter("InfoNo")!=null){
			strNote=request.getParameter("InfoNo");
		}
		// 2009-08-17 mizuno 画像感知器交差点名取得
		if(request.getParameter("partno")!=null){
			ResultSet rsPart=objSql.executeQuery(sbTmp
				.append(" select partNam from partdat \n")
				.append(" where partno='") .append(request.getParameter("partno")) .append("'\n")
				.toString());sbTmp.delete(0,sbTmp.length());
			
			rsPart.next();
			strPartNam = rsPart.getString("partnam");
			rsPart.close();
		}

	}else if(request.getParameter("CombDrNo")!=null){
		strFileDir=strEcoDrawDir .concat("pdf\\");
		strDbNam="drcomb";
		
		//System.out.println(" if(request.getParameter('CombDrNo')!=null start ");
		
		sbQry
		.append(" select CombFileCom as FileNam,CombFileNam as SysFileNam \n")
		.append(" from drcomb \n")
		.append(" where DrNo='") .append(request.getParameter("CombDrNo")) .append("'\n")
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
			.append(" select RepNam as FileNam,RepFileNam as SysFileNam \n")
			.append(" from drinfo \n")
			.append(" where InfoNo='") .append(request.getParameter("InfoNo")) .append("'\n")
			;
		}else{
		//指示書
			sbQry
			.append(" select DirFileNam as FileNam,DirFileNam as SysFileNam \n")
			.append(" from drinfo \n")
			.append(" where InfoNo='") .append(request.getParameter("InfoNo")) .append("'\n")
			;
		}
	}else if(request.getParameter("ModelId")!=null){
	//仕様書
		strFileDir=strEcoSpcDir;
		strDbNam="drmodel";
		sbQry
		.append(" select FileNam,SysFileNam \n")
		.append(" from drmodel \n")
		.append(" where ModelId='") .append(request.getParameter("ModelId")) .append("'\n")
		.append(" and MakerId='") .append(request.getParameter("MakerId")) .append("'\n")
		;
		if(request.getParameter("VerNo")==null){
			sbQry
			.append(" and VerNo=(select max(VerNo) from drmodel\n")
			.append( " where ModelId='") .append(request.getParameter("ModelId")) .append("'\n")
			.append( " and MakerId='") .append(request.getParameter("MakerId")) .append("')\n")
			;
		}else{
			sbQry.append(" and VerNo=") .append(request.getParameter("VerNo"))
				;
		}
	}else if(request.getParameter("RequestNo")!=null){
	//設計変更要望
		strFileDir=strEcoDocDir;//meeco.docdir らしい sysjifile\doc
		strDbNam="drrequest";
		sbQry
		.append(" select FileNam,FileNam as SysFileNam \n")
		.append(" from drrequest \n")
		.append(" where RequestNo='") .append(request.getParameter("RequestNo")) .append("' \n")
		;
	}else if(request.getParameter("OptNo")!=null){
	//オーダエントリテンプレートファイル from opthed_inp,optset_inp,opt_folder
	// 	intTopOptNo=6955
// 	strDocNamList=設置条件確認シート                                                                    ,個別定数確認シート                                       ,現場工事図面,,
// 	strTemplate  =SBDC150146-設置条件確認シート.XLSX              ,SBDC150146-個別定数確認シート.XLSX,SPACE
// 	strFileCom   =STD-09-0041-0037_rev004_SCIDET設置条件確認シート,個別情報シート_Rev003             ,SPACE

		strFileDir = strEcoDocDir;//   sysjifile\doc
		strDbNam="entryopt";
		sbQry
		.append(" select FileCom as FileNam,Template as SysFileNam \n")
		.append(" from entryopt \n")
		.append(" where OptNo=") .append(request.getParameter("OptNo")) .append("\n")//int 対応20170304
		//2010-05-02 mizuno プロトタイプ対応
		//	+ " and TopSign='YES'"
		;
	}else if(request.getParameter("OptSetNo")!=null){
	//オーダエントリ添付ファイル from opthed_inp,optset_inp,opt_folder
		strFileDir = strEcoDocDir;// sysjifile\doc
		strDbNam="optset";
		sbQry
		.append(" select FileComList as FileNam,FileNamList as SysFileNam \n")
		.append(" from optset \n")
		.append(" where OptSetNo=") .append(request.getParameter("OptSetNo")) .append("\n")
		.append(" and VerNo=(select max(VerNo) from optset \n")
		.append("            where OptSetNo=") .append(request.getParameter("OptSetNo")) .append(")\n")
		;
	}else if(request.getParameter("StdNo")!=null){
	//製造標準
		strFileDir=strEcoStdDir;// sysjifile\doc
		strDbNam="stddoc";
		sbQry
		.append(" select FileNam,FileNam as SysFileNam from stddoc \n")
		.append(" where StdNo=") .append(request.getParameter("StdNo")) .append("\n")
		.append(" and SeqNo=") .append(request.getParameter("SeqNo")) .append("\n")
		.append(" and DatNo=") .append(request.getParameter("DatNo")) .append("\n")
		;
	}else if(request.getParameter("JOMAE")!=null){
	//錠前
		strFileDir=strEcoStdDir;
		strDbNam="lockcer";
		sbQry
		.append(" select FileNam,FileNam as SysFileNam from lockcer \n")
		.append(" where SEIBAN='") .append(request.getParameter("SEIBAN")) .append("' \n")
		.append(" and SEIBAN_KO='") .append(request.getParameter("SEIBAN_KO")) .append("' \n")
		;
	}else if(request.getParameter("DrTypeCd")!=null){
		strFileDir=strEcoFmtDir + "drsheet/";
		strDbNam="drtype";
		sbQry
		.append(" select sheetname as FileNam,sheetfile as SysFileNam \n")
		.append(" from drtype \n")
		.append(" where drtypecd= '") .append(request.getParameter("DrTypeCd")) .append("' \n")
		;
	}else if(request.getParameter("estimateno")!=null){
		strFileDir=strEcoDocDir; //sysjifile\doc
		strDbNam="pjestimate";
		sbQry
		.append(" select FileNam, SysFileNam \n")
		.append(" from pjestimate \n")
		.append(" where estimateno= '") .append(request.getParameter("estimateno")) .append("' \n")
		;
	}else if(request.getParameter("qcdatafile")!=null){
	// 試験成績書
		strFileDir=strEcoQcDir;
		strDbNam="qcdatafile";
		sbQry
		.append(" select partno as FileNam,filenam as SysFileNam \n")
		.append(" from qcdatafile \n")
		.append(" where seiban = '") .append(request.getParameter("seiban")) .append("'\n")
		.append(" and partno = '") .append(request.getParameter("qcpartno")) .append("'\n")
		;
	}
	// これで各種の親画面データ読み込み終了----------------------------------------------------
	//System.out.println(sbQry.toString());
	if(sbQry.length()!=0){
		ResultSet rsFile=objSql.executeQuery(sbQry.toString());
		sbQry.delete(0,sbQry.length());
		
		rsFile.next();
		strSysNamList=rsFile.getString("SysFileNam");
		strFlNamList=rsFile.getString("FileNam");
		rsFile.close();
	}

	StringTokenizer fsTkn=new StringTokenizer(strSysNamList,",");
	StringTokenizer fmTkn=new StringTokenizer(strFlNamList,",");
	
	int intFileRow=1;
	
	while(fsTkn.hasMoreTokens()){
		//System.out.println("while(fsTkn.hasMoreTokens() start");
		sbSysFileNam .replace(0,sbSysFileNam.length()
				,fsTkn.nextToken());
		sbUsrFileNam .replace(0,sbUsrFileNam.length()
				,fmTkn.nextToken());
		
		//System.out.println("■■strDbNam="+strDbNam);
		if((strDbNam.equals("entryopt")||strDbNam.equals("optset"))
				&&request.getParameter("FileRow")!=null){
			//System.out.println("■■strDbNam="+strDbNam);
			
			//System.out.println("★★request.getParameter('FileRow')="+request.getParameter("FileRow"));
			//System.out.println("★★intFileRow="+intFileRow);
			if(Integer.valueOf(request.getParameter("FileRow"))==intFileRow){
				//System.out.println("FileRow が一致しbreak");
				String strSysFileExt=sbSysFileNam
						.substring(sbSysFileNam.lastIndexOf("."),sbSysFileNam.length())
						.toString();
				if(sbUsrFileNam.indexOf(".")<=0 || !strSysFileExt.equals(strSysFileExt)){//20170328
					sbUsrFileNam .append(strSysFileExt);
				}
				break;
			}		
		}else{
	
			// 2009-08-17 mizuno 画像感知器交差点名付加
			if(!strPartNam.equals("")){
				sbUsrFileNam.insert(0, strPartNam .concat("-"));
			}
	
			//拡張子付加
			if(request.getParameter("PDF")!=null
				&&(!strDbNam.equals("entryopt")&& !strDbNam.equals("optset"))){
				//直下ディレクトリのPDF Fileにファイル名変更
				if(sbSysFileNam.indexOf(".")>0){
					sbSysFileNam .replace(0,sbSysFileNam.length()
						,sbTmp .append("pdf\\\\") // あとでへらされるので、
						.append(sbSysFileNam.substring(0,sbSysFileNam.lastIndexOf("."))) 
						.append(".pdf")
						.toString());sbTmp.delete(0,sbTmp.length());
				}else{
					sbSysFileNam .replace(0,sbSysFileNam.length()
						,sbTmp .append("pdf\\\\")  // あとでへらされるので、 
						.append(sbSysFileNam) 
						.append(".pdf") 
						.toString());sbTmp.delete(0,sbTmp.length());
				}
				sbUsrFileNam .append(".pdf");
			}else if(sbSysFileNam.indexOf(".")>0){
				
				String strSysFileExt=sbSysFileNam
									.substring(sbSysFileNam.lastIndexOf("."),sbSysFileNam.length())
									.toString();
				//System.out.println("sbUsrFileNam.toString()="+sbUsrFileNam.toString());
				//String strUsrFileExt=sbUsrFileNam.substring(sbUsrFileNam.lastIndexOf("."),sbUsrFileNam.length()).toString();
				
				if(sbUsrFileNam.indexOf(".")<=0 || !strSysFileExt.equals(strSysFileExt)){//20170328
					sbUsrFileNam .append(strSysFileExt);
				}
			}
	
			//指定がなければ先頭ファイル
			if(request.getParameter("PartNo")==null 
					&& request.getParameter("FileNam")==null){
				break;
			}else{
				StringBuilder sbDspFileNam= new StringBuilder(request.getParameter("FileNam")); 
	
				if(request.getParameter("PartNo")!=null){
					if(request.getParameter("CADNo")!=null){
						if(sbSysFileNam.toString().equals(sbDspFileNam.toString())){
							break;
						}
				//部品表
					}else if(sbSysFileNam.indexOf(request.getParameter("PartNo"))>=0){
						break;
					}
				}else{
					//指定ファイルが自動変換PDFの場合照合ファイル名編集
					if(request.getParameter("PDF")!=null){
						sbDspFileNam .replace(0,sbDspFileNam.length()
							,sbDspFileNam.substring(0,sbDspFileNam.lastIndexOf(".")) .concat(".pdf")
							); 
					}
					if(sbSysFileNam.toString().equals(sbDspFileNam.toString())){
						break;
					}
				}
			}
			// 20170219-20170328 kaneshi 難しいバグフィックスです。	
			//System.out.println("request.getParameter('FileNam')="+request.getParameter("FileNam"));
			//System.out.println("sbSysFileNam.toString()="+sbSysFileNam.toString());
			
			if(strDbNam.equals("drawings")
				&& !request.getParameter("FileNam").equals("")){
	
				String A=("pdf\\\\"+request.getParameter("FileNam")).toUpperCase();
				String B=sbSysFileNam.toString().toUpperCase();
				// A,Bから拡張子をとって比較する。
				A=A.substring(0,A.lastIndexOf("."));
				B=B.substring(0,B.lastIndexOf("."));
				
				//System.out.println("A="+A+",B="+B);
				if(A.equals(B)){
					//System.out.println("一致したぜ");
					break;
				}
				System.out.println();
			}
		}
		intFileRow+=1;
	}// end of while(fsTkn.hasMoreTokens()){

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
	.append( "'") .append(sbSysFileNam) .append("',")
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
	
	
	if((strFileDir.substring(strFileDir.length()-4).equals("pdf\\")
			||strFileDir.substring(strFileDir.length()-4).equals("pdf/"))
		&& sbSysFileNam.substring(0,4).toString().equals("pdf\\")){//20170219
		// パス指定で　pdfが二重にならないように　
		sbSysFileNam .replace(0,sbSysFileNam.length()
					,sbSysFileNam.substring(4).toString());
	}
	
	//System.out.println("inFilePath="+strFileDir .concat(sbSysFileNam.toString()));
	
	File objInFl=new File(
		strFileDir .concat(sbSysFileNam.toString()));

//2007-12-28 mizuno ファイル名「/」回避
//2015-?? kaneshi ファイル名「＃」回避
		
	String strOutFileNam=sbUsrFileNam.toString()
						.replaceAll("/","／")
						.replaceAll(":","：");

	if(strOutFileNam.indexOf("pdf/")==0){
		strOutFileNam = strOutFileNam
					.substring(strOutFileNam.indexOf("/"),strOutFileNam.length());
	}
	strOutFileNam = strOutFileNam.replaceAll("#", "＃");
	//2016-02-03 kaneshi ファイル名に全角スペースがあるときアンダーバーへ変換（ブラウザがＦｉｒｅＦｏｘ時だけ問題がおきていた）
	strOutFileNam=strOutFileNam.replaceAll(" ", "_");//20160203 kaneshi
	strOutFileNam=strOutFileNam.replaceAll("　","_");//全角スペースもアンダーバーへ
	strOutFileNam=strOutFileNam.replaceAll("＿","_");//全角アンダーバーも半角アンダーバーへ
	strOutFileNam=strOutFileNam.replaceAll("__","_");//２つのアンダーバーは１つへ

	File objOutFl=new File(sbTmp //132750\オーダエントリ部品表.pdf (指定されたパスが見つかりません。)
		.append(strEcoTmpDir) .append(strDir) .append("\\") .append(strOutFileNam) 
		.toString());sbTmp.delete(0,sbTmp.length()); 

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
	
	//******************************************************:
	objSql.close();
	db.close();
	
	//ファイルの拡張子に応じて、ＭＩＭＥを自動選別してセットする処理を追加。
	String strExt =strOutFileNam
		.substring(strOutFileNam.lastIndexOf(".")+1,strOutFileNam.length())
		.toLowerCase();
	String strMime="application/octet-stream;charset=Windows-31J";
	if(strExt.equals("txt")){
		strMime="text/plain";
	}
	if(strExt.equals("htm")||strExt.equals("html")){
		strMime="text/html";
	}

	if(strExt.equals("tif")||strExt.equals("tiff")){
		strMime="image/tiff";
	}
	if(strExt.equals("gif")){
		strMime="image/gif";
	}
	if(strExt.equals("jpg")||strExt.equals("jpeg")){
		strMime="image/jpeg";
	}
	if(strExt.equals("png")){
		strMime="image/png";
	}
	if(strExt.equals("doc")||strExt.equals("dot")
			||strExt.equals("wiz")||strExt.equals("rtf")){
		strMime="application/msword";
	}
	if(strExt.equals("docx")){
		strMime="application/vnd.openxmlformats-officedocument.wordprocessingml.document";
	}
	if(strExt.equals("xls")||strExt.equals("csv")){
		strMime="application/vnd.ms-excel";
	}

	if(strExt.equals("xlsx")||strExt.equals("xlsm")){
		strMime="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
	}
	if(strExt.equals("vsd")){
		strMime="application/vnd.visio";
	}
	if(strExt.equals("jsb")||strExt.equals("jxw")||strExt.equals("jaw")
			||strExt.equals("jtw")||strExt.equals("juw")){
		strMime="application/x-js-jxw";
	}
	
	if(strExt.equals("pdf")){
		strMime="application/pdf";
	}
	if(strExt.equals("z")||strExt.equals("tar")
			||strExt.equals("taz")||strExt.equals("arc")||strExt.equals("tgz")){
		strMime="application/x-compress";
	}
	if(strExt.equals("lzh")||strExt.equals("lha")){//20170209
		strMime="application/x-lha";
	}
	if(strExt.equals("zip")){//20170209
		strMime="application/x-zip-compressed";
	}
	if(strExt.equals("dwg")){
		strMime="application/acad";
	}

	//System.out.println("strOutFileNam="+strOutFileNam);
	//System.out.println("URLEncoder.encode(strOutFileNam, 'utf-8')="+URLEncoder.encode(strOutFileNam, "utf-8"));


// 	圧縮文書  .z .gz .tgz .taz .tar .arc .arj .lzh .zip  application/x-compress  
// 	一太郎 .jbw .jxw .jsw.jaw .jtw .juw  application/x-js-jxw 
// 	AutoCAD .dwg application/acad  
	
	// TomcatにURLをわたしてダウンロードではなく、　ＪＡＶＡから直接tomcatへファイルをわたして、ダウンロードする方式へ変更
	response.reset();
	response.setContentType(strMime);

	//日本語が化けない処理にした2017-02-04
	// 2017-03-21 IE11 でMSIE がなくなり　Tridentでみる必要がでてきた.
	
	if (request.getHeader("User-Agent").toLowerCase().indexOf("trident")>0
			||request.getHeader("User-Agent").toLowerCase().indexOf("msie") >=0) {

		if(!strExt.equals("pdf")){
			// IE7, 8, 9
			response.setHeader("Content-Disposition"
				  , String.format(Locale.JAPAN
						  		, "inline; filename=\"%s\""
				  				, new String(strOutFileNam.getBytes("MS932"), "ISO8859_1")));
		}else{
			// ＰＤＦファイルをＩＥでダウンロードするとき名前が化けてしまうことへの対応　とても難関だった　
			response.setContentType("application/pdf; charset=UTF-8");
			response.setCharacterEncoding("UTF-8");
			response.setHeader("Content-Disposition"
					,String.format(Locale.JAPAN
					,"attachment; filename*=utf-8'jp'%s"
					,URLEncoder.encode(strOutFileNam, "utf-8")));
		}	
	}else{
		// Firefox, Opera 11
		response.setHeader("Content-Disposition"
				, String.format(Locale.JAPAN
								, "inline; filename*=utf-8'jp'%s"
								, URLEncoder.encode(strOutFileNam, "utf-8")));
	}

	String strOutFilePath=sbTmp 
			.append(strEcoTmpDir) .append(strDir) .append("\\") .append(strOutFileNam) 
			.toString();sbTmp.delete(0,sbTmp.length());
			
    BufferedInputStream bis = new BufferedInputStream(new FileInputStream(strOutFilePath));

//  byte[] buf = new byte[bis.available()];
// 	bis.read(buf);
	
// 	ServletOutputStream out1 = response.getOutputStream();
// 	//// ↑ここでエラーになるが、ファイルは正常にダウンロードできる

// 	out1.write(buf);
// 	out1.flush();

// 	ファイルがでかくて、ちょっとづつレスポンスに返したい場合の対応へ変更　20170308
	ServletOutputStream out1 = response.getOutputStream();

	byte[] buf = new byte[1024];
	int bytedata = 0;
	while ((bytedata = bis.read(buf, 0, buf.length)) > -1) {
		out1.write(buf, 0, bytedata);
	}
	
	out1.flush();

	bis.close();
	out1.close();
}

%>

<%-- //window.location="<%=strEcoTmpUrl%><%=strDir%>/<%=strOutFileNam%>"; --%>

<!--*********************** End of file_getspc.jsp *****************************-->