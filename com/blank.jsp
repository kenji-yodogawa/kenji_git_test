<%@ page language="java" contentType="text/html;charset=UTF-8"
	import="java.io.*,java.sql.*,java.net.*,java.util.*,java.text.*"
    pageEncoding="UTF-8"%>

<%--    *********************************************************************
   プログラム名：blank.jsp in みえるっち
   author M.Kaneshi
   みえるっちシステムのお知らせ　目次
	2014-10-01 kaneshi (blank.html から書換)
	2014-11-25 kaneshi ブラウザの低いバージョンであった場合のアラームを
	　　　　　　　　ＳＥＩ情シ部推奨がかわったため、変更
	　　　　　　　　スタイルシートへ書き換え
	2015-02-26 kaneshi IEの互換設定へ対応、名前がmsieでなくmozillaになる。
	2017-11-17 kaneshi ログイン後８時間がたって、クッキーが無効になると、この画面が開くので
					ユーザが、何がおこったのか理解できずに、問合せがくｋるので、それをなくすため
					ログインクッキーが無くなった（無効になった）ら、
					ここから、ログイン画面へのリンクをつけ、１０秒後には、ログイン画面へリンク移動する。
  
**************************************************************************  --%>
<%-- <% String strRight="USER"; %> --%>
<%-- <%@ include file="../header_utf8.jsp" %> --%>
<html>
<head>
	<title>お知らせ</title>
	<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="non-cache">
	<meta http-equiv="expires" content="0">
	<link href="mierucchics.css" rel="stylesheet" type="text/css">
</head>

<body>

<table class="header" style="margin:4;">
<tr><th>「みえるっち」お知らせ</th></tr>
</table>

<table style="margin-left:5;">
<tr><td>

<script type="text/javascript"><!--
var browser = "";
var appVersion = window.navigator.appVersion.toLowerCase();
var appNam = navigator.appName.toLowerCase();
var ua = navigator.userAgent.toLowerCase();

//document.write("appVersion = "+appVersion+"<br><br>");
//document.write("appNam = "+appNam+"<br><br>");
//document.write("ua = "+ua+"<br><br>");

if(appVersion.indexOf("msie ") >=0 || appNam.indexOf("internet explorer") >=0){
    if(appVersion.indexOf("msie 5.") >=0 
        || appVersion.indexOf("msie 6.") >=0 
        || appVersion.indexOf("msie 7.") >=0
        || appVersion.indexOf("msie 8.") >=0  ) {
      
//       if(ua.indexOf("mozilla/5") ==-1){
// 	      document.write(
// 	          "<b><font color=\"red\" size=\"5\">"
// 	          +"ご利用のブラウザをIE9以上へアップデートしてください。"
// 	          +"</font></b>");
// 	      browser = "msie 8.以下";
// 	    }
    }  
}
 //alert("ua=" + ua);
 
//FireFoxのバージョンが31未満ならアラームをだす
if(appName="netscape"){
	if(ua.indexOf("firefox")>=0){
		var ffposi = ua.indexOf("firefox/");
		var a = Number(ua.slice(ffposi+"firefox/".length));
		if(a < 31.0){
			document.write("<span style='color:red; font-size:large; font-weight:bold;'>"
			   +"FireFoxのバージョンを３１以上にしてください。</span>");
			browser = "firefox/" + a;
		}
	}
}

//GoogleChromeアラーム
if(navigator.userAgent.indexOf("Chrome/") >=0){
	  alert("Google Chrome ブラウザはSEI、SSSでは利用禁です。。");
	  document.write("<span style='color:red; font-size:large; font-weight:bold;'>"
	  +"Google Chromeブラウザは利用禁です。</span>");
	  //fr_menu.top_menu.style.display = "none";//動作しない
}

if(navigator.cookieEnabled == false){
	document.write("cookie許可:"+navigator.cookieEnabled+"<br>");
	document.write("<span style='color:red; font-size:large; font-weight:bold;'>"
	+"ﾌﾞﾗｳｻﾞにcookie受入を許可してください</span>");
}

//document.write("<br>ご利用ブラウザ：" + browser);
//-->
</script>

<%

String strLoginUserNo="";   //ユーザーNo
//Id CHECK
Cookie[] aryLogCookie=request.getCookies();

if(aryLogCookie!=null){
	int logcookielen = aryLogCookie.length;

	for(int i=0; i<logcookielen; i++){
		if(aryLogCookie[i].getName().equals("UserNo")
				&& !aryLogCookie[i].getValue().equals("")){
		  strLoginUserNo=aryLogCookie[i].getValue();
		  break;
		}
	}

}

//ログインクッキーが無効なら、ログイン画面のリンクをつける
 if(strLoginUserNo.equals("")){

 	String strLoginUrl= "../login.jsp";
	
	%>
	<span style="color:red; font-weight:bold; font-size:large;">
	<br>
	<a href="<%=strLoginUrl%>" target="_top">
	再ログインしてください。（14時間を超過）<br>
	</a>
	</span>

<% }%>


<pre>




【2018-02-22掲示】設計要望、アドレス帳申込のコマンドが動作しておらず、
　　　　　　　　　修理が完了するまでメニューから一時外します。　



<a href="blank_history.html" target="_blank"
  style="color:#00006F;font-size:medium;">
過去のお知らせ
</a>


<a href="../manual/mie_manual_index.jsp" 
  style="font-size:large;font-weight:bold;"
  target="_blank">
取説ほか</a>


</pre>
</td></tr></table>

<br>
<br>
<br>
<br>
<div style="text-align:center;vertical-align:baseline;">
<%@ include file="DispTime.inc" %>
</div>


</BODY>
</HTML>
