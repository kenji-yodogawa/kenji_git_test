<%--2012-11-28 author M.Kaneshi ‰æ–Ê‰º‚É“úŽž‚ð•\Ž¦ 
         12-04 dispTime ‚ðC³@IE‚Å‚à“®ì‚·‚é‚æ‚¤‚É‚µ‚½B
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