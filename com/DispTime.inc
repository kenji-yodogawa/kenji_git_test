<%--2012-11-28 author M.Kaneshi 画面下に日時を表示 
         12-04 dispTime を修正　IEでも動作するようにした。
--%>
<%@ page pageEncoding="utf-8" %>
<div id="dispTime"></div>
<script type="text/javascript">
var TagList = document.getElementsByTagName("div");
var dispTime = TagList[0];


function getServerTime(){
	req = new XMLHttpRequest();
	req.onreadystatechange = funcDisp;
	req.open('GET','GetTime.jsp',true);
	req.send("");
}

function funcDisp(){
	if(req.readyState == 4){
		if(req.status == 200) {
			dispTime.innerHTML = req.responseText;
		}
	}
}

getServerTime();
setInterval('getServerTime()' ,1000);
</script>