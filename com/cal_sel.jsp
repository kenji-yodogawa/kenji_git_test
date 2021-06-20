<!-- *************************************************************************
	＜カレンダー＞　in　みえるっち
	File Name	:cal_sel.jsp　（製造履歴照会と部品表展開から参照）
	Author    :k-mizuno
    Date    :2008-01-21
		呼出元：
		design/estimate_inp.jsp
		design/mustdrans_inp.jsp
		design/pl_cost.jsp
		design/pl_dsp.jsp
		design/ploptset_sc.jsp
		sales/lineplan_inp.jsp
		sales/posting_inp.jsp
		sales/softverrec_inp.jsp
		seikan/assyplan_sc.jsp
		seikan/despatchdate_decision_inp.jsp
		seikan/eqp_sc.jsp
		seikan/kanban_isu.jsp
		seikan/linedayplan_sc.jsp
		seikan/lineplan_inp.jsp
		seikan/lockpch_inp.jsp
		seikan/plandate_sc.jsp
		seikan/uncmpplan_inp.jsp
		sys/realorgapl_inp.jsp

		------------------------------------------------------
	Update	
	2013-09-09 kaneshi	 note ECLIPSEのアラームを消す
	　　　　　　　　　　月を選択するとsubmit、年選択時はsubmitせず。
	2014-03-24 kaneshi ＜　と　＞のクリックで３ヶ月戻ったり、３ヶ月先に移る処理
	2014-04-04 kaneshi 全般整理
	
	2014-05-23 kaneshi
	　（1）onload=init  onsubmit=processを追加
	   (2)CSSを外部化
	2014-08-01 moriwaki 生管改善対応
	　　　　　　呼出元：despatchdate_decision_inp
	2014-09-20 CSS調整　＜font をなくした。　IEのバージョンをEDGEへ
	2014-10-03 kaneshi 本日の色（CSS)を調整、日付を中央よせ。
	
	2014-11-10 kaneshi　＜＜で一年前、＞＞で一年後にうつる。年度と月のセレクトをなくす。
	2014-11-12 kaneshi
	          Windowのリサイズを少し広げた。
	
	2014-11-13 kaneshi 一ヶ月先、一ヶ月前へのボタンを追加
	2014-11-21 kaneshi 森脇さんのIE９でみると横幅が狭くはみだすので調整
	2016-04-04 kaneshi page contentType="text/html;charset=utf-8 ー＞UTF-8
	2016-04-16　kaneshi drinfo_folderへ対応,　未来ではなく、今月以前のカレンダーをひらくこと
	2018-08-02 kaneshi　本年以外の　当月当日が緑色文字にならないように処理
              課題：直前に開いた年月でひらく。
              １０年前までさかのぼるのは特定の人に。
	2018-11-06　kaneshi システム稼働開始日修正
	　　　2016-12-1  ー＞　2006-12-01 


******************************************************************************* -->
<%@ page contentType="text/html;charset=UTF-8"
	import="java.io.*,java.sql.*,java.net.*,java.util.*,java.text.*"%>

<% String strRight="USER"; %>
<%@ include file="../header_utf8.jsp"%>

<%

Calendar wrkCal=Calendar.getInstance();
DecimalFormat df2Fmt=new DecimalFormat("00");
//SimpleDateFormat dateFmt=new SimpleDateFormat("yyyy-MM-dd");

int intSetYear=nowCal.get(Calendar.YEAR);
int intSetMonth=nowCal.get(Calendar.MONTH)+1;

if(request.getParameter("SetYear")!=null){
	intSetYear=Integer.parseInt(request.getParameter("SetYear"));
	intSetMonth=Integer.parseInt(request.getParameter("SetMonth"));
}
if(request.getParameter("SetYear")!=null){
	intSetYear=Integer.parseInt(request.getParameter("SetYear"));
	intSetMonth=Integer.parseInt(request.getParameter("SetMonth"));
}
%>
<!doctype html>
<html lang="ja">
<head>
<title>カレンダー</title>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta http-equiv="Content-Style-Type" content="text/css">
<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
<link href="../com/mierucchics.css" rel="stylesheet" type="text/css">

<style type="text/css">
table.monthcal{
	border-collapse:collapse;
}
table.monthcal th{
	text-align:center;
}
table.monthcal td{
	text-align:center;
}
</style>
</head>

<body onblur="focus()">

<br style="line-height:0.8em;">

<form name="cal_sel" action="cal_sel.jsp" method="post">
<div style="text-align:center">
<input name="Before1year" type="button" value="12＜" onclick="before1year();">
----
<input name="Before3mon" type="button" value="3＜" onclick="before3mon();">
<input name="Before1mon" type="button" value="  ＜  " onclick="before1mon();">
--

<input name="SetYear" type="hidden" value="<%=intSetYear%>">

<input name="SetMonth" type="hidden" value="<%=intSetMonth%>">

--
<input name="After1mon" type="button" value="  ＞  " onclick="after1mon();">
<input name="After3mon" type="button" value="＞3" onclick="after3mon();">
-----
<input name="After3mon" type="button" value="＞12" onclick="after1year();">

</div>
<div align="center">
<table class="noborder">
<tr>
<%
StringBuilder sbTmp = new StringBuilder();

wrkCal.set(intSetYear,intSetMonth-1,1);
String strUndDateList="";

for(int i=0; i<3; i++){//横並びに３ヶ月分のカレンダをセット
	String strYM=sbTmp .append(String.valueOf(wrkCal.get(Calendar.YEAR))) 
			.append("-") .append(df2Fmt.format(wrkCal.get(Calendar.MONTH)+1))
			.toString();sbTmp.delete(0,sbTmp.length());
%>
<td style="vertical-align:top">
	<table class="monthcal">
	<tr>
		<th colspan="7" >
			<%=wrkCal.get(Calendar.YEAR)%>年
			<%=wrkCal.get(Calendar.MONTH)+1%>月
		</th>
	</tr>
	<tr>
		<th style="background-color:#B9B9B9;color:red;" >日</th>
		<th style="background-color:#A9A9A9;color:white;" >月</th>
		<th style="background-color:#A9A9A9;color:white;" >火</th>
		<th style="background-color:#A9A9A9;color:white;" >水</th>
		<th style="background-color:#A9A9A9;color:white;" >木</th>
		<th style="background-color:#A9A9A9;color:white;" >金</th>
		<th style="background-color:#B9B9B9;color:blue;" >土</th>
	</tr>
	<%
	String strBgColor;
	String strFntColor;
	int intWeekCnt=0;
	int intMonSum=0;
	int intCalMonth=wrkCal.get(Calendar.MONTH);
	if((wrkCal.getActualMaximum(Calendar.DAY_OF_MONTH) + wrkCal.get(Calendar.DAY_OF_WEEK)-1) > 35){
		intWeekCnt=6;
	}else if((wrkCal.getActualMaximum(Calendar.DAY_OF_MONTH) + wrkCal.get(Calendar.DAY_OF_WEEK)-1) > 28){
		intWeekCnt=5;
	}else{
		intWeekCnt=4;
	}

	intCnt=0;
	for(int m=0; m < intWeekCnt; m++){%>
	<tr>
		<%
		for(int n=0; n<7; n++){
			intCnt++;
			if(m==0 && intCnt<wrkCal.get(Calendar.DAY_OF_WEEK)){%>
				<td style="background-color:F9FBE0;"><br></td>
			<%
			}else if(wrkCal.get(Calendar.MONTH)!=intCalMonth){%>
				<td style="background-color:F9FBE0;"><br></td>
			<%
			}else{
				if(nowCal.get(Calendar.YEAR)			 == wrkCal.get(Calendar.YEAR)
					&& nowCal.get(Calendar.MONTH)		 == wrkCal.get(Calendar.MONTH)
					&& nowCal.get(Calendar.DAY_OF_MONTH) == wrkCal.get(Calendar.DAY_OF_MONTH)){

					if(wrkCal.get(Calendar.DAY_OF_WEEK)	== 1){
						strBgColor="red";
						strFntColor="lightpink";
					}else if(wrkCal.get(Calendar.DAY_OF_WEEK) == 7){
						strBgColor="blue";
						strFntColor="lightblue";
					}else{
						strBgColor="darkgreen";
						strFntColor="mintcream";
					}
				}else{
					if(wrkCal.get(Calendar.DAY_OF_WEEK) == 1){
						strBgColor="lightpink";
						strFntColor="red";
					}else if(wrkCal.get(Calendar.DAY_OF_WEEK) == 7){
						strBgColor="lightblue";
						strFntColor="blue";
					}else{
						strBgColor="lavender";
						strFntColor="darkgreen";
					}
				}

				if(wrkCal.get(Calendar.YEAR)==Integer.parseInt(strNowDate.substring(0,4))
						&& wrkCal.get(Calendar.MONTH)+1==Integer.parseInt(strNowDate.substring(5,7))
						&& wrkCal.get(Calendar.DATE)==Integer.parseInt(strNowDate.substring(8,10))
						){
					strFntColor="blue";
					strBgColor="lightgreen";
				}
			%>
		<td nowrap style="background-color:<%=strBgColor%>;color:<%=strFntColor%>;" >
			<a href="javaScript:cal_set('<%=dateFmt.format(wrkCal.getTime())%>');">
					<%=wrkCal.get(Calendar.DATE)%>
			</a>
			<br>
		</td>
		<% wrkCal.add(Calendar.DATE,1);%>
		<%}
		}
	}
	%>
	</table><%
	if(i < 2){%> <td width="20"></td> <%}
	}%>

</tr>
</table>

<% if(request.getParameter("OpnProg")!=null){ %>
	<input name="OpnProg" type="hidden" value="TRUE">
<%}%>

<input name="FormItem" type="hidden" value="<%=request.getParameter("FormItem")%>">
</div>
</form>

<script type="text/javaScript">
<!--

function before1year(){
	var D = document.all;
	document.forms[0].SetYear.value=D.SetYear.value*1-1;
	document.forms[0].submit();
}

function after1year(){
	var D = document.all;
	document.forms[0].SetYear.value=D.SetYear.value*1+1;
	document.forms[0].submit();
}

function before3mon(){
	var D = document.all;
	var year = D.SetYear.value*1;
	var month = D.SetMonth.value*1;

	if(month >=4){
		month = month-3;
	}else{
		year = year - 1;
		month = month + 9;
	}
	document.forms[0].SetYear.value=year;
	document.forms[0].SetMonth.value=month;
	document.forms[0].submit();
}

function before2mon(){
	var D = document.all;
	var year = D.SetYear.value*1;
	var month = D.SetMonth.value*1;

	if(month >=3){
		month = month-2;
	}else{
		year = year - 1;
		month = month + 10;
	}
	document.forms[0].SetYear.value=year;
	document.forms[0].SetMonth.value=month;
	document.forms[0].submit();
}


function after3mon(){
	var D = document.all;
	var year = D.SetYear.value*1;
	var month = D.SetMonth.value*1;
	
	if(month <=9){
		month = month +3;
	}else{
		year = year + 1;
		month = month +3-12;
	}
	document.forms[0].SetYear.value=year;
	document.forms[0].SetMonth.value=month;
	document.forms[0].submit();
}

function before1mon(){
	var year = document.forms[0].SetYear.value*1;
	var month = document.forms[0].SetMonth.value*1;
	
	if(month ==1){
		month = 12;
		year -=1;
	}else{
		month -=1;
	}
	document.forms[0].SetYear.value=year;
	document.forms[0].SetMonth.value=month;
	document.forms[0].submit();
}


function after1mon(){
	var D = document.all;
	var year = D.SetYear.value*1;
	var month = D.SetMonth.value*1;
	
	if(month ==12){
		month = 1;
		year +=1;
	}else{
		month +=1;
	}
	document.forms[0].SetYear.value=year;
	document.forms[0].SetMonth.value=month;
	document.forms[0].submit();
}

function cal_set(yyyymmdd){
	var D = document.all;
	
	if(window.opener.name=="fr_main"){
		var pgnam=window.opener.parent.fr_main.pgnam;
		window.opener.parent.fr_main.document [pgnam] ["<%=request.getParameter("FormItem")%>"].value=yyyymmdd;	    

		if(pgnam=="lineplan_inp"){
			line= D.FormItem.value;
			line=line.replace("PlanDate","");
			line=line.replace("despatchDate","");
			line=line.substring(0,line.indexOf("-"));
			
			var a = D.FormItem.value.lastIndexOf("-")+1;
			var b = D.FormItem.value.length;
			seq= D.FormItem.value.substring(a ,b );
			
			window.opener.dateset_win(line,seq);
			// 20140801window.opener.suryo_area(line);
		}else if(pgnam=="drinfo_folder") {
			if("<%=strNowDate%>"<yyyymmdd || yyyymmdd<"2006-12-01"){
				window.opener.parent.fr_main.document.drinfo_folder ["<%=request.getParameter("FormItem")%>"].value="";
				alert("未来日やシステム稼働以前はセットしません。");
			}else {
				window.opener.parent.fr_main.document.drinfo_folder ["<%=request.getParameter("FormItem")%>"].value=yyyymmdd;
			}
		}else if(pgnam=="posting_kanban_partreq"||pgnam=="posting_partreq") {
			//alert("yyyymmdd="+yyyymmdd)
			if("<%=strNowDate%>">yyyymmdd ){	
				window.opener.parent.fr_main.document [pgnam] ["<%=request.getParameter("FormItem")%>"].value="";				
				alert("過去日はセットできません");

			}else{
				window.opener.parent.fr_main.document [pgnam] ["<%=request.getParameter("FormItem")%>"].value=yyyymmdd;				
			}
		
		};
	}else{// end of if(window.opener.name=="fr_main")
		var pgnam=window.opener.parent.pgnam;
		if(window.opener.parent.document [pgnam] ["<%=request.getParameter("FormItem")%>"].size== 8) {
			window.opener.parent.document [pgnam] ["<%=request.getParameter("FormItem")%>"].value=yyyymmdd.substring(0, 7);
		} else {
			window.opener.parent.document [pgnam] ["<%=request.getParameter("FormItem")%>"].value=yyyymmdd;
		};
		
		if(pgnam=="linedayplan_sc"){
			line= D.FormItem.value.replace("PlanDate","");
			line=line.replace("despatchDate","");
			line=line.substring(0,line.indexOf("-"));
			
			var a = D.FormItem.value.lastIndexOf("-")+1;
			var b= D.FormItem.value.length;
			seq= D.FormItem.value.substring(a , b);
			
			window.opener.dateset_win(line,seq);
		
		} else if(pgnam=="despatchdate_decision_inp"){
			line = D.FormItem.value.replace("despatchDate","");
			window.opener.dateset_win(line);
		
		} else if(pgnam=="kanban_isu"){
			window.opener.monlot_set();
		
		} else if(pgnam=="uncmpplan_inp"){
			line= D.FormItem.value.replace("outplanDate","");
			line=line.replace("noukiplan_ymd","");
			line=line.substring(0,line.indexOf("-"));
			var a = D.FormItem.value.lastIndexOf("-")+1;
			var b= D.FormItem.value.length;
			seq = D.FormItem.value.substring(a , b);
			
			window.opener.dateset_win(line,seq);
		};
	};// end of else of if(window.opener.name=="fr_main")
	window.opener.parent.focus();
	window.close();
};

function process(){
    document.forms[0].setAttribute('disabled','disabled');
}
document.forms[0].onsubmit = process;

moveTo(20,20);
resizeTo(770,400);

if("<%=request.getParameter("SetYear")%>" =="null"){//最初に開くとき、特定の親画面からの場合、当月と過去２ヶ月のカレンダにする
	var pgnam=window.opener.parent.fr_main.pgnam;
	
	if(pgnam=="drinfo_folder"
		||	pgnam=="assyplan_sc"
			||	pgnam=="eqp_sc"
				||	pgnam=="accesslogexcel") {
		before2mon();
	}
}

document.forms[0].removeAttribute('disabled');

//-->
</script>

</body>
</html>

<%
objSql.close();
db.close();
%>

<!------------------------------ End of cal_sel.jsp ------------------------------>