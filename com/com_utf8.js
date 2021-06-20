//　2014-09-08　kaneshi comyear_set で数値入力でないものを排除とした。
//                    文末の;がないものに対処した。
//  2015-03-17 kaneshi 高速化、メモリ節約
//         条件文で ＆ を&&へ、｜を||へ ,画面パラメータを複数回読み取り部分の集約
//  2015-06-05 kaneshi 271行目あたりの変数名間違いを修正
//  2015-09-06 kaneshi com.js,comA.jsをまとめて文字コードをＵＴＦ－８にした
//  2015-10-29 kaneshi "衹"を使用できないため、同音同義語の"祇"へ変換
//  2016-01-08 kaneshi window.onload =  window.focus追加
//  2016-08-29 kaneshi YYYY-MM-DDが正しいかどうかチェックするサブルーチン作成開始
//                     var D = document.all; で簡素化
//	2017-10-25 kaneshi 品番・図番、型名、製番の入力欄で、　全角のアルファベット・数字・ハイフンを半角へ変換する処理をいれた 
//	2018-08-27 kaneshi コード整理のみ、　ｘ＝ｘ＋ｃを x+=c にした。
//
var updsw="";
var errmsg="";

comdocwin="";
comdoc_page=0;
comdoc_top=10;
comdoc_left=10;

//Window Name設定
var comwinnam="subwin0";
if(window.name.indexOf("subwin")==0){
	comwinnam="subwin" + (parseInt(window.name.substring(6,7))+1);
}

//window.openByPost 
window.openByPost = function ( url, param, name ){
	var win = window.open( "about:blank", name );
	
	// formを生成
	//var form = document.createElement("form");
	var form = document.forms[0]; //20170204 kaneshi
	form.target = name;
	form.action = url;
	form.method = 'post';
	
	for( var i = 0; i < param.length; i++ ) 
	{
		var kv = param[i];
		var key = kv["key"];
		var val = kv["value"];
		if (key){
			var input = document.createElement("input");
			val = ( val != null ? val : "" );
			input.type = "hidden";
			input.name = key;
			input.value = val;
			form.appendChild( input );    
		}
	}
	
	// 一時的にbodyへformを追加。サブミット後、formを削除する
	var body = document.getElementsByTagName("body")[0];
	body.appendChild(form);
	form.submit();
	body.removeChild(form); 
	return win;
} //end of window.openByPost = function ( url, param, name )


//リターンキー
function comkey_event(evt,item,nextitem,chk)
{
	var D = document.all;
	evt=(evt) ? evt:event;
	var itemval=D [item].value;
	var itemtype = D [item].type;

	var nextitemtype = D [nextitem].type;
	var nextitemval = D [nextitem].value;

	if(evt.keyCode==13 || evt.keyCode==3){
		if(chk=="SPACE" && itemval==""){
			if(itemtype=="text"){
				alert("値を入力して下さい");
			}else{
				alert("値を選択して下さい");
			}
			document.forms[0] [item].focus();
		}else if(itemtype=="text"
			&& (itemval.indexOf("'")>=0 
					|| itemval.indexOf("\"")>=0 
					|| itemval.indexOf("\\")>=0)){
			var errmsg="";
			if(itemval.indexOf("'")>=0){
				errmsg+="半角「'」は使用不可です\n";
			}
			if(itemval.indexOf("\"")>=0){
				errmsg+="半角「\"」は使用不可です\n";
			}
			if(itemval.indexOf("\\")>=0){
				errmsg+="半角「\\」は使用不可です\n";
			}
			alert(errmsg);
			document.forms[0] [item].focus();
		}else if(chk=="NUM"){
			var str=itemval;
			var num="";
			for(var i=0;i<str.length; i++){
				if(str.charAt(i)!=","){
					num+=str.charAt(i);
				}
			}
			if(num=="" || isNaN(num)==true){
				if(itemtype == "text"){
					alert("数値を入力して下さい");
				}else{
					alert("数値を選択して下さい");
				}
				itemval="";
				document.forms[0] [item].focus();
			}else{
				if(nextitemtype=="button"){
					alert(nextitemval + "に進みます。よろしいですか？");
				}
				document.forms[0] [nextitem].focus();
			}
		}else{
			if(nextitemtype=="button"){
				if(confirm("「" + nextitemval + "ボタン」に進みます。よろしいですか？")){
					document.forms[0] [nextitem].focus();
				}else{
					document.forms[0] [item].focus();
				}
			}else{
				document.forms[0] [nextitem].focus();
			}
		}
	}
}

//入力スキップ
function comitem_skip(keyitem,cond,val,item,nextitem,iniitem,upd)
{
	var D = document.all;
	var keyval="";
	
	if(D [keyitem].type=="text"){
		keyval=D [keyitem].value;
	}else{
		keyval=D [keyitem][D [keyitem].selectedIndex].value;
	}
	if((cond=="EQ" && keyval==val)
		|| (cond=="NEQ" && keyval!=val)
		|| (cond=="LTE" && parseFloat(keyval)<=parseFloat(val))
		|| (cond=="GTE" && parseFloat(keyval)>=parseFloat(val))
		|| (cond=="LT" && parseFloat(keyval)<parseFloat(val))
		|| (cond=="GT" && parseFloat(keyval)>parseFloat(val))
		){
		if(D [item].type=="text"){
			document.forms[0] [item].value="";
		}else{
			document.forms[0] [item][0].selected=true;
		}
		if(D [nextitem].type=="button"){
			alert(D [nextitem].value + "に進みます。よろしいですか？");
		}
		document.forms[0] [nextitem].focus();
	}
}

//更新確認
//softver_inp.jsから読み込めない20151130
function com_sbm(itemlist)
{
	var D = document.all;
	comupd="";
	var updtypetype = D.UpdType.type;

	if(updtypetype==undefined){
		var updtypelen = D.UpdType.length;;
		for(var i=0; i<updtypelen; i++){
			if(D.UpdType[i].checked==true){
				comupd=D.UpdType[i].value;
				break;
			}
		}
	}else if(updtypetype=="select-one"){
		comupd = D.UpdType[D.UpdType.selectedIndex].value;
	}else if(updtypetype=="checkbox"||updtypetype=="radio"){
		if(D.UpdType.checked==true){
			comupd=D.UpdType.value;
		}
	}else{
		comupd=D.UpdType.value;
	}

	if(comupd==""){
		errmsg+="処理未選択\n";
	}
	//alert("com.com_utf8.js :: com_sbm :: updsw="+updsw+",  errmsg="+errmsg);
	
	if(updsw==""){
		if(errmsg!=""){
			alert(errmsg);
		}else{
			//alert("comupd="+comupd);//TEMPだった仮登録  D.UpdType[i].value
			if(comupd=="DEL"){
				if(confirm("削除します。よろしいですか？")){
					updsw="ON";
					document.forms[0].submit();
				}else{
					alert("処理を中止しました。");
				}
			}else{
				//alert("itemlist="+itemlist);//DrNam,DrModelNo,AplNoteだった
				if(itemlist!=""){
					var itemsplit=itemlist.split(",");
					errmsg="";
					var itemlen = itemsplit.length;

					for(var i=0; i<itemlen; i++){
						if(D [itemsplit[i]].value.indexOf("\"")>=0){
							errmsg="入力エリアに「\"」は使用しないで下さい\n";
							break;
						}
					}
					if(errmsg==""){
						for(var i=0; i<itemlen; i++){
							var itemi = itemsplit[i];
							itemval=D [itemi].value;
							setval="";
							var itemvallen = itemval.length;

							for(var j=0; j<itemvallen; j++){
								if(itemval.substring(j,j+1)=="\\"){
									setval+="\\\\";
								}else if(itemval.substring(j,j+1)=="'"){
									if(setval==""){
										setval+="''";
									}else{
										setval+="''";
									}
								}else{
									setval+=itemval.substring(j,j+1);
								}
							}
							//alert("itemi="+itemi+" , setval="+setval);
							document.forms[0] [itemi].value=setval;
						}
					}
				}

				if(errmsg!=""){
					alert(errmsg);
				}else{
					updsw="ON";
					//alert("com_utf8::before submit ");
					document.forms[0].submit();
				}
			}
		}
	}else{
		alert("処理中です");
	}
}

//----------------------------------------------//
//---------------データチェック-----------------//
//----------------------------------------------//
//日付チェック
function comdate_chk(yitem,mitem,ditem,alertnam,spaceok)
{
	var D = document.all;
	var yyyy="";
	var mm="";
	var dd="";

	var yitemtype = D [yitem].type;
	var yitemval = D [yitem].value;

	if(yitem==mitem && mitem==ditem && yitemtype=="text"
		&& yitemval.length!=10){
		errmsg+=alertnam + "日付不正\n";
	}else{
		if(yitemtype=="text"||yitemtype=="hidden"){
			if(yitem==mitem && mitem==ditem){
				yyyy = yitemval.substring(0,4);
			}else{
				yyyy = yitemval;
			}
		}else{
			yyyy = D [yitem][D [yitem].selectedIndex].value;
		}
		var mitemtype = D [mitem].type;

		if(mitemtype=="text" || mitemtype=="hidden"){
			if(yitem==mitem && mitem==ditem){
				mm = D [mitem].value.substring(5,7);
			}else{
				mm = D [mitem].value;
			}
		}else{
			mm = D [mitem][D [mitem].selectedIndex].value;
		}
		var ditemtype = D [ditem].type;
		if(ditemtype=="text"|| ditemtype=="hidden"){
			if(yitem==mitem && mitem==ditem){
				dd = D [ditem].value.substring(8,10);
			}else{
				dd = D [ditem].value;
			}
		}else{
			dd = D [ditem][D [ditem].selectedIndex].value;
		}
		if(yyyy=="" || mm=="" || dd==""){
			if(spaceok=="NG"){
				errmsg+=alertnam + "日付未入力\n";
			}else if(yyyy!="" || mm!="" || dd!=""){
				errmsg+=alertnam + "日付不正\n";
			}
		}else if(isNaN(yyyy) || isNaN(mm) || isNaN(dd)){
			errmsg+=alertnam + "日付≠数値\n";
		}else if(mm>12 || mm<1){
			errmsg+=alertnam + "月不正\n";
		}else if(dd>31 || dd<1){
			errmsg+=alertnam + "日付不正\n";
		}else if(mm==2){
			if(dd>29){
				errmsg+=alertnam + "日付不正\n";
			}else if(yyyy/4!=Math.floor(yyyy/4)){
				if(dd>28){
					errmsg+=alertnam + "日付不正\n";
				}
			}
		}else if(mm==4 || mm==6 || mm==9 || mm==11){
			if(dd>30){
				errmsg+=alertnam + "日付不正\n";
			}
		}
	}
}

function comYYYYMMDD_fmtchk(YYYY_MM_DD){
	//2016-08-29 kaneshi 追加のサブルーチン
	// YYYY-MM-DD（（YYYYMMDDも、YYYY/MM/DD もＯＫ） のユーザ入力値の整合性をチェックする
	// separator はハイフン、スラッシュ、空のどれかを前提とする。
	var alertmsg='';
	var sep ="";// - or / or '' 
	// 数字と-か/のみで構成されている文字列かどうかチェック
	var pmt ="0123456789-/";//許容文字
	
	if(YYYY_MM_DD.indexOf("/")>=0){
		sep="/";
	}
	if(YYYY_MM_DD.indexOf("-")>=0){
		separator="-";
	}
	if(YYYY_MM_DD.length==8){
		separator="";
	}
	
	// すべて数字であるかどうかチェック
	if(alertmsg==""){
		return true;
	}else {
		alert(alertmsg);
		return false;
	}	
}

function comchar_chk(item,nam)
{
	var D = document.all;
	var itemval = D [item].value;

	if(itemval.indexOf("<")>=0){
		errmsg+=nam + "半角「<」は使用不可です\n";
	}
	if(itemval.indexOf(">")>=0){
		errmsg+=nam + "半角「>」は使用不可です\n";
	}
	if(itemval.indexOf("'")>=0){
		errmsg+=nam + "半角「'」は使用不可です\n";
	}
	if(itemval.indexOf("\"")>=0){
		errmsg+=nam + "半角「\"」は使用不可です\n";
	}
	if(itemval.indexOf("\\")>=0){
		errmsg+=nam + "半角「\\」は使用不可です\n";
	}
}

//CORPS伝送禁則文字
function comcorlpschar_chk(item,nam)
{
	var itemval = document.forms[0] [item].value;

	if(itemval.indexOf("~")>=0){
		errmsg+=nam + "半角「~」は使用不可です\n";
	}
	if(itemval.indexOf("|")>=0){
		errmsg+=nam + "半角「|」は使用不可です\n";
	}
	if(itemval.indexOf("{")>=0){
		errmsg+=nam + "半角「{」は使用不可です\n";
	}
	if(itemval.indexOf("}")>=0){
		errmsg+=nam + "半角「}」は使用不可です\n";
	}
	if(itemval.indexOf("'")>=0){
		errmsg+=nam + "半角「'」は使用不可です\n";
	}
	if(itemval.indexOf("\"")>=0){
		errmsg+=nam + "半角「\"」は使用不可です\n";
	}
	if(itemval.indexOf("\\")>=0){
		errmsg+=nam + "半角「\\」は使用不可です\n";
	}
}

//整数チェック
function comint_chk(item,alertnam)
{
	var num="";
	var itemval = document.forms[0] [item].value;
	var itemvallen = itemval.length;

	for(var i=0;i<itemvallen; i++){
		if(itemval.charAt(i)!=","){
			num+=itemval.charAt(i);
		}
	}
	if(num.indexOf(".")>=0){
		errmsg+=alertnam + "整数値を入力して下さい\n";
	}else if(isNaN(num)==true){
		errmsg+=alertnam + "数値を入力して下さい\n";
	}
}

//文字タイプチェック
function comchartype_chk(type,item,alertnam)
{
	var D = document.all;
	var str=D [item].value;
	var letall="";
	var typenm="";

	if(type=="zen-kana"){
		typenm="全角カナ";
		letall="アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲンァィゥェォッャュョーヴガギグゲゴザジズゼゾダヂヅデドバビブベボパピプペポ";
	}else if(type=="han-kana"){
		typenm="半角カナ";
		letall="ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜｦﾝｧｨｩｪｫｯｬｭｮｰﾞﾟ";
	}else if(type=="han-alphabet"){
		str=str.toUpperCase();
		typenm="半角英字";
		letall="ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	}else if(type=="han-numalphabet"){
		str=str.toUpperCase();
		typenm="半角英数字";
		letall="ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
	}
	var strlen = str.length;

	for(var i=0; i<strlen; i++){
		if(letall.indexOf(str.charAt(i))<0){
			errmsg+=alertnam + typenm + "を入力して下さい\n";
			break;
		}
	}
}

//----------------------------------------------//
//-----------------データ操作-------------------//
//----------------------------------------------//
function comdoc_win()
{
	if(comdocwin!=""){
		comdoc_page++;
		if(comdoc_left>200){
			comdoc_top=0;
			comdoc_left=0;
		}
		comdoc_top+=20;
		comdoc_left+=20;
	}
	comdocwinnam="comdocwin" + comdoc_page;
}

//検索ソート
function comsort(item)
{
	var D = document.all;
	sort=D.DatSort.value;
	sortsplit=sort.split(",");

	if(sortsplit[0]==item){
		sort=item+ " desc";
	}else{
		sort=item;
	}
	var sortlen = sortsplit.length;;

	for(var i=0; i<sortlen; i++){
		var sorti = sortsplit[i];

		if(sorti!=item && sorti!=(item+" desc")){
			sort+="," + sorti;
		}
	}
	document.forms[0].DatSort.value=sort;

	if(D.PageCnt.value>1){
		document.forms[0].Page[0].selected=true;
	}
	document.forms[0].submit();
}

//禁止文字変換
function comchar_chg(item)
{
	var itemval = document.forms[0] [item].value;
	var val="?" + itemval + "?";
	var str="";
	var itemvallen = itemval.length;

	for(var i=1; i<itemvallen+1; i++)
	{
		if(val.charAt(i-1)!="\\" && val.charAt(i+1)!="\\"){
			if(val.charAt(i)=="'"){
				str += "\\'";
			}else if(val.charAt(i)=="\""){
				str += "\\\"";
			}else if(val.charAt(i)=="\\" && val.charAt(i+1)!="'"){
				str += "\\\\";
			}else{
				str += val.charAt(i);
			}
		}else{
			str += val.charAt(i);
		}
	}
	document.forms[0] [item].value=str;
}

//英数字小文字→大文字変換
function comuppercase(item)
{
	document.forms[0] [item].value
			=document.forms[0] [item].value.toUpperCase();
}

//英数字大文字→小文字変換
function comlowercase(item)
{
	document.forms[0] [item].value
			=document.forms[0] [item].value.toLowerCase();
}

//英数字全角→半角変換
function comeisu_cnv(item)
{
	var str=document.forms[0] [item].value;
	var strhan="";
	var hankaku="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890,,123456789123456789*{}():;..--=+$%!&\"'#<>\\|?/ ";
	var zenkaku="ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ１２３４５６７８９０、，ⅠⅡⅢⅣⅤⅥⅦⅧⅨ①②③④⑤⑥⑦⑧⑨＊｛｝（）：；。．－ー＝＋＄％！＆”’＃＜＞￥｜？／　";

	var han2="101011121314151617181920";
	var zen2="Ⅹ⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳";
	var strlen = str.length;
	for(var i=0; i<strlen; i++){
		alert("str.charAt(i)="+str.charAt(i));
		n=zenkaku.indexOf(str.charAt(i),0);
		if(n>=0){
			strhan+=hankaku.charAt(n) ;//20171024
		}else{
			n2=zen2.indexOf(str.charAt(i),0);
			if(n2>=0){
				strhan+=han2.substring(n2*2,n2*2+2) ;//20171024
			}else{
				strhan+=str.charAt(i) ;//20171024
			}
		}
	}
	//strhan=strhan.replace(" ","");//20171024
	document.forms[0] [item].value=strhan;
}



//半角カナ→全角変換
function comkana_cnv(item)
{
	var str=document.forms[0] [item].value;
	var strzen="";
	var hankaku="ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜｦﾝｧｨｩｪｫｯｬｭｮｰ";
	var zenkaku ="アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲンァィゥェォッャュョー";
	var zenkaku2="？？ヴ？？ガギグゲゴザジズゼゾダヂヅデド？？？？？バビブベボ？？？？？？？？？？？？？？？？？？？？？？？？？？";
	var zenkaku3="？？？？？？？？？？？？？？？？？？？？？？？？？パピプペポ？？？？？？？？？？？？？？？？？？？？？？？？？？";
	var han2="ﾞﾟ";
	var kanaflg="false";

	for(var i=0; i<str.length; i++)
	{
		if(han2.indexOf(str.charAt(i),0)<0 || kanaflg=="false"){
			n=hankaku.indexOf(str.charAt(i),0);

			if(n>=0){
				if(i==str.length-1){
					strzen+=zenkaku.charAt(n);
				}else if(han2.indexOf(str.charAt(i+1),0)==0){
					strzen+=zenkaku2.charAt(n);
				}else if(han2.indexOf(str.charAt(i+1),0)==1){
					strzen+=zenkaku3.charAt(n);
				}else{
					strzen+=zenkaku.charAt(n);
				}
				kanaflg="true";
			}else{
				strzen+=str.charAt(i);
				kanaflg="false";
			}
		}else{
			kanaflg="false";
		}
	}
	document.forms[0] [item].value=strzen;
}

//全角カナ→半角変換
function comhankana_cnv(item)
{
	var D = document.all;
	var str=document.forms[0] [item].value;
	var strhan="";
	var hankaku="ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜｦﾝｧｨｩｪｫｯｬｭｮｰ";
	var zenkata ="アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲンァィゥェォッャュョー";
	var zenkata2="？？ヴ？？ガギグゲゴザジズゼゾダヂヅデド？？？？？バビブベボ？？？？？？？？？？？？？？？？？？？？？？？？？？";
	var zenkata3="？？？？？？？？？？？？？？？？？？？？？？？？？パピプペポ？？？？？？？？？？？？？？？？？？？？？？？？？？";
	var zenhira ="あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをんぁぃぅぇぉっゃゅょー";
	var zenhira2="？？う゛？がぎぐげござじずぜぞだぢづでど？？？？？ばびぶべぼ？？？？？？？？？？？？？？？？？？？？？？？？？？";
	var zenhira3="？？？？？？？？？？？？？？？？？？？？？？？？？ぱぴぷぺぽ？？？？？？？？？？？？？？？？？？？？？？？？？？";
	var strlen = str.length;

	for(var i=0; i<strlen; i++){
		if(zenkata.indexOf(str.charAt(i))>=0){
			strhan+=hankaku.charAt(zenkata.indexOf(str.charAt(i)));
		}else if(zenkata2.indexOf(str.charAt(i))>=0){
			strhan+=hankaku.charAt(zenkata2.indexOf(str.charAt(i)))+"ﾞ";
		}else if(zenkata3.indexOf(str.charAt(i))>=0){
			strhan+=hankaku.charAt(zenkata3.indexOf(str.charAt(i)))+"ﾟ";
		}else if(zenhira.indexOf(str.charAt(i))>=0){
			strhan+=hankaku.charAt(zenhira.indexOf(str.charAt(i)));
		}else if(zenhira2.indexOf(str.charAt(i))>=0){
			strhan+=hankaku.charAt(zenhira2.indexOf(str.charAt(i)))+"ﾞ";
		}else if(zenhira3.indexOf(str.charAt(i))>=0){
			strhan+=hankaku.charAt(zenhira3.indexOf(str.charAt(i)))+"ﾟ";
		}else{
			strhan+=str.charAt(i);
		}
	}
	document.forms[0] [item].value=strhan;
}

//数値カンマ編集
function comnum_fmt(item)
{
	var str=document.forms[0] [item].value;
	var cnt=0;
	var num="";
	if(str.indexOf(".")<0){
		for(var i=str.length-1; i>=0; i--){
			if(str.charAt(i)!=","){
				cnt++;
				num=str.charAt(i) + num;
				if((cnt % 3)==0 && i!=0 && (str.charAt(0)!="-" || i!=1)){
					num="," + num;
				}
			}
		}
	}else{
		var cntflg="OFF";
		for(var i=str.length-1; i>=0; i--){
			if(str.charAt(i)!=","){
				if(cntflg=="ON"){
					cnt++;
				}
				num=str.charAt(i) + num;
				if((cnt % 3)==0 && i!=0 && cnt!=0
						&& (str.charAt(0)!="-" || i!=1)){
					num="," + num;
				}
			}
			if(str.charAt(i)=="."){
				cntflg="ON";
			}
		}
	}
	document.forms[0] [item].value=num;
}

//西暦１桁、２桁→４桁変換
function comyear_set(item)
{
	var D = document.all;
	// 入力文字チェック
	var b = D [item].value;
	//トリム
	b = b.replace(/^[ 　]+/,"").replace(/[ 　]+$/,"");
	var c="";
	var d ="0123456789";//許可文字
	var e ="";
	var blen = b.length;
	for(var i=0;i< blen;i++){
		c = b.charAt(i);
		//数半角限定
		if(d.indexOf(c)<0){c="";}
		e += c;
	}
	document.forms[0] [item].value = e;
	var now=new Date();
	var year="" + now.getYear();
	//for netscape
	if(year.length==3){
		year="20" + year.substring(1,3);
	}
	var itemval = D [item].value;

	if(itemval.length==1){
			document.forms[0] [item].value=year.substring(0,3) + itemval;
	}else if(itemval.length==2){
		if(itemval<=year.substring(2,4)){
			document.forms[0] [item].value=year.substring(0,2) + itemval;
		}else{
			document.forms[0] [item].value=(year.substring(0,2) - 1) + itemval;
		}
	}else if(itemval.length==3){
		alert("西暦不正");
	}
}
//月１桁→２桁変換
function commonth_set(item)
{
	var itemval = document.forms[0] [item].value;

	if(itemval!=""){
		if(itemval.length>2){
			alert("月桁数不正");
		}else if(isNaN(itemval)){
			alert("月≠数値");
		}else if(itemval>12 || itemval<1){
			alert("月不正");
		}else if(itemval.length==1){
			document.forms[0] [item].value="0" + itemval;
		}
	}
}

//日１桁→２桁変換
function comday_set(yitem,mitem,item)
{
	var D = document.all;
	var itemval = D [item].value;
	
	if(itemval!=""){
		var mitemval = D [mitem].value;
		var yitemval = D [yitem].value;

		if(itemval.length>2){
			alert("日桁数不正");
		}else if(isNaN(itemval)){
			alert("日≠数値");
		}else if(itemval>31 || itemval<1){
			alert("日不正");
		}else if(itemval>30
			&& (mitemval==4 || mitemval==6 || mitemval==9 || mitemval==11)){
			alert("日不正");
		}else if(itemval>29 && mitemval==2){
			alert("日不正");
		}else if(itemval>28 && mitemval==2
				&& Math.floor(yitemval/4)!=Math.ceil(yitemval/4)){
			alert("日不正");
		}else if(itemval.length==1){
			document.forms[0] [item].value="0" + itemval;
		}
	}
}

//時、分１桁→２桁変換
function comhour_set(item)
{
	var itemval = document.forms[0] [item].value;

	if(itemval.length>2){
		alert("時刻不正");
		document.forms[0] [item].value="";
	}else if(isNaN(itemval)){
		alert("時刻不正");
		document.forms[0] [item].value="";
	}else if(itemval>23 || itemval<0){
		alert("時刻不正");
		document.forms[0] [item].value="";
	}else if(itemval.length==1){
		document.forms[0] [item].value="0" + itemval;
	}
}

//分１桁→２桁変換
function commin_set(item)
{
	var itemval = document.forms[0] [item].value;

	if(itemval.length>2){
		alert("時刻不正");
		document.forms[0] [item].value="";
	}else if(isNaN(itemval)){
		alert("時刻不正");
		document.forms[0] [item].value="";
	}else if(itemval>59 || itemval<0){
		alert("時刻不正");
		document.forms[0] [item].value="";
	}else if(itemval.length==1){
		document.forms[0] [item].value="0" + itemval;
	}
}

//部門コード３桁→４桁変換
function bumon_4dig(item)
{
	var bumonclist=document.forms[0] [item].value;
	var bumoncsplit=bumonclist.split(",");

	if(bumonclist.indexOf("+")>=0){
		bomoncsplit=bumonclist.split("+");
	}
	var bumonc="";
	var bumonclen = bumoncsplit.length;

	for(var i=0; i<bumonclen; i++){
		var bumonci = bumoncsplit[i];

		if(bumonci.length==3){
			if(bumonc==""){
				bumonc="0"+bumonci;
			}else{
				bumonc += "+0"+bumonci;
			}
		}else{
			if(bumonc==""){
				bumonc=bumonci;
			}else{
				bumonc += "+"+bumonci;
			}
		}
	}
	document.forms[0] [item].value=bumonc;
}

//テキストエリア改行データclear
function comtext_clr(item)
{
	var dat=document.forms[0] [item].value;
	var datsplit=dat.split("\n");

	var dsp="";
	var rc="";
	var datlen = datsplit.length;

	for(var i=0; i<datlen; i++){
		var dati = datsplit[i];

		if(confirm(dati+"を削除しますか？")){
			dsp=rc;
			for(var j=i+1; j<datlen; j++){
				if(dsp==""){
					dsp=datsplit[j].replace("\r","");
				}else{
					dsp += "\n" + datsplit[j].replace("\r","");
				}
			}
			document.forms[0] [item].value=dsp;
		}else{
			if(rc==""){
				rc=dati.replace("\r","");
			}else{
				rc += "\n" + dati.replace("\r","");
			}
		}
	}
}


//comA.js Javascript　Source　written ｂｙ kaneshi  2014-07-18 
//   Update 2014-07-26 改訂　sc_char_del追加
//          2014-07-30 seiban_chkにtoUpperCase()をいれた。
//          2014-08-10 str_eng_replace追加
//          2015-10-31 全角の英数文字の半角変換を追加
// ユーザの入力文字列のチェックや変換
function str_eng_replace(a){
	//トリムも実施（tabも改行も全角スペースもトリム↓）
	var b = a.value;
	b = replace_2to1byte(b);
	b = b.replace(/^[ 　]+/,"").replace(/[ 　]+$/,"");
	
	var c="";
	var d ="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890*{}:;,.-=+$%!&\#\\|?/@ ･";
	var d1= "<>;'"; //禁止文字　（変換すべきだ）
	var e ="";
	var blen = b.length;
	for(var i=0;i< blen;i++){
		c = b.charAt(i);
		if(d.indexOf(c)<0 || d1.indexOf(c)>=0){
			c="";
			alert("使用不能の文字がありました。");
		}
		e += c;
	}
	//使用禁止文字列　submit()
	a.value = e;
}

//英数字全角→半角変換(その１)　アルファベットと数字とハイフンのみ
function comeisu_cnv1(str)
{
	var strhan="";
	var hankaku="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890- ";
	var zenkaku="ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ１２３４５６７８９０－　";

	var strlen = str.length;
	for(var i=0; i<strlen; i++){
		//alert("str.charAt(i)="+str.charAt(i));
		n=zenkaku.indexOf(str.charAt(i),0);
		if(n>=0){
			strhan+=hankaku.charAt(n) ;
		}else{
			strhan+=str.charAt(i) ;

		}
	}
	//strhan=strhan.replace(" ","");//20171024
	//document.forms[0] [item].value=strhan;
	return(strhan);
}

function partdr_no_chk(a){
	var b = a.value.toUpperCase();
	//b = replace_2to1byte(b);//　これだめだ　20171025
	//ここに全角－＞半角変換　（数字アルファベットバー)
	b=comeisu_cnv1(b);//20171025
	//トリムも実施（tabも改行も全角スペースもトリム↓）
	b = b.replace(/^[ 　]+/,"").replace(/[ 　]+$/,"");
	
	var d ="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ- ";//許容文字
	var e ="";
	var blen =b.length;
	for(var i=0;i< blen;i++){
		if(d.indexOf(b.charAt(i))>=0){
			e += b.charAt(i);
		}
	}
	a.value = e;
}

function modelno_chk(a){
	//トリムも実施（tabも改行も全角スペースもトリム↓）
	var b = a.value.toUpperCase();
	//b = replace_2to1byte(b);
	//ここに全角－＞半角変換　（数字アルファベットバー)
	b=comeisu_cnv1(b);//20171025
	b = b.replace(/^[ 　]+/,"").replace(/[ 　]+$/,"");
	// ここに全角－＞半角変換　（数字アルファベットバー)
	//b=comeisu_cnv1(b);
	var d ="ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890*{}():;,.-+$&\"#\\|?/@ ･";
	// 'と＝と!と%は禁止
	var e ="";
	var blen= b.length;
	for(var i=0;i< blen;i++){
		if(d.indexOf(b.charAt(i))>=0){
			e = e + b.charAt(i);
		}   
	}
	a.value = e;
}

function seiban_chk(a){
	//トリムも実施（tabも改行も全角スペースもトリム↓）
	var b = a.value.toUpperCase();
	//b = replace_2to1byte(b);
	//ここに全角－＞半角変換　（数字アルファベットバー)
	b=comeisu_cnv1(b);//20171025
	b = b.replace(/^[ 　]+/,"").replace(/[ 　]+$/,"");
	
	var d ="0123456789-RH";
	var e ="";
	var blen = b.length;
	for(var i=0;i< blen;i++){
		if(d.indexOf(b.charAt(i))>=0){
			e += b.charAt(i);
		}
	}
	a.value = e;
}

function seibanko_chk(a){
	//トリム
	var b = a.value.replace(/^[ 　]+/,"").replace(/[ 　]+$/,"");
	b = replace_2to1byte(b);
	//数字に限定
	var d ="0123456789";
	var e ="";
	var blen = b.length;
	for(var i=0;i< blen;i++){
		if(d.indexOf(b.charAt(i))>=0){
			e += b.charAt(i);
		}
	}
	b =e;
	//範囲限定　製番子番号は50-79が必須
	if(b<'50' || b>'79'){
		b='';
		alert("製番子番号は５０～７９です。");
	}
	a.value = b;
}

function replace_2to1byte(text){
	var ngchr = 
		[ 'Ａ','Ｂ','Ｃ','Ｄ','Ｅ','Ｆ','Ｇ','Ｈ','Ｉ','J','Ｋ','Ｌ','Ｍ','Ｎ','Ｏ',
		'Ｐ','Ｑ','Ｒ','Ｓ','Ｔ','Ｕ','Ｖ','Ｗ','Ｘ','Ｙ','Ｚ','－','ー','　',
		'ａ','ｂ','ｃ','ｄ','ｅ','ｆ','ｇ','ｈ','ｉ','ｊ','ｋ','ｌ','ｍ','ｎ','ｏ',
		'ｐ','ｑ','ｒ','ｓ','ｔ','ｕ','ｖ','ｗ','ｘ','ｙ','ｚ',
		'０','１','２','３','４','５','６','７','８','９'
		];
	var trnchr = 
		['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O',
		'P','Q','R','S','T','U','V','W','X','Y','Z','-','-',' ',
		'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O',
		'P','Q','R','S','T','U','V','W','X','Y','Z',
		'0','1','2','3','4','5','6','7','8','9'
		];
	var ngchrlen = ngchr.length;
	for(var i=0; i<=ngchrlen;i++){
		text = text.replace( ngchr[i], trnchr[i], 'mg' );
	}
	return text;
}// end of function replace_2to1byte(text)

function trimall(a){
	a.value = a.value.toUpperCase().replace(/^[ 　]+/,"").replace(/[ 　]+$/,"");
}

function sc_char_del(a){
	var b = a.value.replace(/^[ 　]+/,"").replace(/[ 　]+$/,"");
	var c ="";
	var err ="";
	var e="";
	var blen = b.length;
	for(var i=0;i<blen;i++){
		c = b.charAt(i);
		if(c=="'"){c="";err+="'";};
		if(c=="="){c="";err+="=";};
		if(c=="%"){c="";err+="%";};
		e += c;
	}
	//alert("e="+e);
	if(err!=""){
		alert("検索禁止文字"+err+"を削除します。");
	}
	a.value = e;
}

function str_replace(a){
	//alert("str_replace in");
	//改行やタブをトリム
	var b = a.value.replace(/^[ 　]+/,"").replace(/[ 　]+$/,"");
	//ｼﾝｸﾞﾙ・ﾀﾞﾌﾞﾙｸｫｰﾃｰｼｮﾝ　=ｲｺｰﾙや,ｶﾝﾏや、.ﾄﾞｯﾄ、;ｾﾐｺﾛﾝ<、>、|は全角文字へ変換
	var c = "";
	var e = "";
	var err="";
	var blen = b.length;
	for(var i=0; i<blen ;i++){
		c = b.charAt(i);
		if(c=='	'){c=" ";err+='"';};
		if(c=='"'){c="”";err+='"';};
		if(c=="'"){c="’";err+="'";};
		if(c=="="){c="＝";err+="=";};
		if(c==","){c="，";err+=",";};
		if(c=="."){c="．";err+=".";};
		if(c==";"){c="；";err+=";";};
		if(c==">"){c="＞";err+=">";};
		if(c=="<"){c="＜";err+="<";};
		if(c=="|"){c="｜";err+="|";};
		if(c=="&"){c="＆";err+="&";};
		if(c=="#"){c="＃";err+="#";};
		if(c=="%"){c="％";err+="%";};
		if(c=="("){c="（";err+="(";};
		if(c==")"){c="）";err+=")";};
		if(c=="!"){c="！";err+="!";};
		if(c=="/"){c="／";err+="/";};
		e += c;
	};
	if(err!=""){
		alert("制御文字'"+err+"'を全角文字へ変換します。");
	}

	//JISで機種依存文字を変換
	b=e;
	e1 = replace_kishuizon(e);
	if(e1!=e){
		alert("機種依存文字を変換します");
		b =e1;
	}
	//alert(b);
	a.value = b.replace(/^[ 　]+/,"").replace(/[ 　]+$/,"");
	//alert("str_replace out");
}// end of function str_replace(a)

//機種依存文字置換 2014-02-11
// 祇園がないなー
//印刷標準字体
//印刷関係のファイルでは「印刷標準字体」を優先して扱っていることがあります。
//このうちcp932(Shift_JIS)へ単純置換可能な文字は次の表のようになります。

//UTF-8 	 cp932
//俠 	侠
//俱 	倶
//剝 	剥
//吞 	呑
//啞 	唖
//噓 	嘘
//嚙 	噛
//囊 	嚢
//塡 	填
//姸 	妍
//屛 	屏
//屢 	屡
//幷 	并
//搔 	掻
//摑 	掴
//攢 	攅
//杮 	柿
//沪 	濾
//潑 	溌
//瀆 	涜
//焰 	焔
//瞱 	曄
//簞 	箪
//繡 	繍
//繫 	繋
//萊 	莱
//蔣 	蒋
//蟬 	蝉
//蠟 	蝋
//軀 	躯
//醬 	醤
//醱 	醗
//頰 	頬
//顚 	顛
//驒 	騨
//鷗 	鴎
//鹼 	鹸
//麴 	麹
//&#x20b9f;	叱
//unicodeの "叱" はサロゲートペアのためWebページではきちんと表示されないことがあります。

//旧字体
//いわゆる「旧仮名遣い」の文字のうちcp932(Shift_JIS)へ単純置換可能な文字は次の表のようになります。

//UTF-8	 cp932
//䇳 	箋   1
//倂 	併   2
//卽 	即   3
//巢 	巣  4
//徵 	徴  5
//戾 	戻  6
//揭 	掲  7
//擊 	撃  8
//晚 	晩  9
//曆 	暦  10
//槪 	概  11
//步 	歩  12
//歷 	歴  13
//每 	毎  14
//涉 	渉  15
//淚 	涙  16
//渴 	渇  17
//溫 	温  18
//狀 	状  19
//瘦 	痩  29
//硏 	研  21
//禱 	祷  22
//緣 	縁  23
//虛 	虚  24
//錄 	録  25
//鍊 	錬  26
//鬭 	闘  27
//麵 	麺  28
//黃 	黄  29
//欄 	欄  30
//廊 	廊  31
//虜 	虜  32
//殺 	殺  33
//類 	類  34
//侮 	侮  35
//僧 	僧  36
//免 	免  37
//勉 	勉  38
//勤 	勤  39
//卑 	卑  40
//喝 	喝  41
//嘆 	嘆  42
//器 	器  43
//塀 	塀  44
//墨 	墨  45
//層 	層  46
//悔 	悔  47
//慨 	慨  48
//憎 	憎  49
//懲 	懲  50
//敏 	敏  51
//既 	既  52
//暑 	暑  54
//梅 	梅  55
//海 	海  56
//渚 	渚  57
//漢 	漢  58
//煮 	煮  59
//琢 	琢  60
//碑 	碑  61
//社 	社  62
//祉 	祉  63
//祈 	祈  64
//祐 	祐  65
//祖 	祖  66
//祝 	祝  67
//禍 	禍  68
//禎 	禎  69
//穀 	穀  70
//突 	突  71
//節 	節  72
//練 	練  73
//繁 	繁  74
//署 	署  75
//者 	者  76
//臭 	臭  77
//著 	著  78
//褐 	褐  79
//視 	視  80
//謁 	謁  81
//謹 	謹  82
//賓 	賓  83
//贈 	贈  84
//逸 	逸  85
//難 	難  86
//響 	響  87
//頻 	頻  88

function replace_kishuizon(text){
	var ngchr = 
		['①','②','③','④','⑤','⑥','⑦','⑧','⑨','⑩','⑪','⑫','⑬','⑭','⑮',
		'⑯','⑰','⑱','⑲','⑳','Ⅰ','Ⅱ','Ⅲ','Ⅳ','Ⅴ','Ⅵ','Ⅶ','Ⅷ','Ⅸ','Ⅹ',
		'㍉','㌔','㌢','㍍','㌘','㌧','㌃','㌶','㍑','㍗','㌍','㌦','㌣','㌫','㍊','㌻',
		'㎜','㎝','㎞','㎎','㎏','㏄','㎡','㍻',
		'〝','〟','№','㏍','℡','㊤','㊥','㊦','㊧','㊨','㈱','㈲','㈹','㍾','㍽','㍼',
		'衹'
		];
	var trnchr = 
		['(1)','(2)','(3)','(4)','(5)','(6)','(7)','(8)','(9)','(10)','(11)','(12)','(13)','(14)','(15)',
		'(16)','(17)','(18)','(19)','(20)','I','II','III','IV','V','VI','VII','VIII','IX','X',
		'ミリ','キロ','センチ','メートル','グラム','トン','アール','ヘクタール','リットル','ワット','カロリー','ドル','セント','パーセント','ミリバール','ページ',
		'mm','cm','km','mg','kg','cc','平方メートル','平成',
		'「','」','No.','K.K.','TEL','(上)','(中)','(下)','(左)','(右)','(株)','(有)','(代)','明治','大正','昭和',
		'祇'
		];
	var ngchrlen = ngchr.length;
	for(var i=0; i<=ngchrlen;i++){
		text = text.replace( ngchr[i], trnchr[i], 'mg' );
	}
	return text;
}// end of function replace_kishuizon(text)

//20140331
function numeric_chk(a,len){
	var b = a.value.toUpperCase();
	b = replace_2to1byte(b);
	
	if(b.length>len) {
		errmsg = '数値' + len +'桁で入力してください\n';
		alert(errmsg);
		a.value = '';
	return;
	}
	 //トリムも実施（tabも改行も全角スペースもトリム↓）
	b = b.replace(/^[ 　]+/,"").replace(/[ 　]+$/,"");
	var c="";
	var d ="0123456789 ";//許容文字
	var e ="";
	var blen = b.length;
	for(var i=0;i< blen;i++){
		c = b.charAt(i);
		if(d.indexOf(c)<0){c="";}
		e += c;
	}
	a.value = e;
}// end of function numeric_chk(text)

function partnofromsel4_chk(a){
	a = replace_2to1byte(a);
	
	if(a.length>4) {
		errmsg = '数値4桁で入力してください\n';
		alert(errmsg);
		a.value = '';
		return;
	}
	var b = a.value.toUpperCase();
	b = replace_2to1byte(b);
	//トリムも実施（tabも改行も全角スペースもトリム↓）
	b = b.replace(/^[ 　]+/,"").replace(/[ 　]+$/,"");
	var c="";
	var d ="0123456789";//許容文字
	var e ="";
	var blen = b.length;
	
	for(var i=0;i< blen;i++){
		c = b.charAt(i);
		if(d.indexOf(c)<0){c="";}
		e += c;
	}
	if(e!=0){
		e = ("000" + e).slice(-4);
	}
	a.value = e;
}

function partnotosel4_chk(a){
	a = replace_2to1byte(a);
	if(a.length>4) {
		errmsg = '数値4桁で入力してください\n';
		alert(errmsg);
		a.value = '';
		return;
	}
	var b = a.value.toUpperCase();
	b = replace_2to1byte(b);
	//トリムも実施（tabも改行も全角スペースもトリム↓）
	b = b.replace(/^[ 　]+/,"").replace(/[ 　]+$/,"");
	var c="";
	var d ="0123456789";//許容文字
	var e ="";
	var blen = b.length;
	
	for(var i=0;i< blen;i++){
		c = b.charAt(i);
		if(d.indexOf(c)<0){c="";}
		e += c;
	}
	if(e!=0){
		e = ("000" + e).slice(-4);
	}
	 a.value = e;
}

function int_chk(a){
	//入力値が０or自然数かチェック ,符号はなし
	var b = a.value.toUpperCase();
	b = replace_2to1byte(b);
	
	if(!b.match(/^[0-9]+$/)){
		alert("整数（0以上）を入力ください。");
		a.value = '';
	}
}

function dr_eng_nam_chk(a) { //文書名（英）チェッック(削除)
	var b = a.value.toUpperCase();
	//トリムも実施（tabも改行も全角スペースもトリム↓）
	b = b.replace(/^[ 　]+/, "").replace(/[ 　]+$/, "");
	b = replace_2to1byte(b);
	
	var c = "";
	var d = "'\"=<>!|[]  ";//'(ｼﾝｸﾞﾙｺｰﾃｰｼｮﾝ、パイプ、タブも)、
	var e = "";
	var blen = b.length;
	for ( var i = 0; i < blen; i++) {
		c = b.charAt(i);
		if ( d.indexOf(c) >= 0) {
			c = "";
			alert("入力禁止の文字がありました。");
		}
		e += c;
	}
	e = e.replace('SUBMIT(','');
	a.value = e;
}

function replace_to_hankana(text){
	var ngchr = [
		'ア','イ','ウ','エ','オ','カ','キ','ク','ケ','コ','サ','シ','ス','セ','ソ',
		'タ','チ','ツ','テ','ト','ナ','ニ','ヌ','ネ','ノ','ハ','ヒ','フ','ヘ','ホ',
		'マ','ミ','ム','メ','モ','ヤ','ユ','ヨ','ラ','リ','ル','レ','ロ','ワ','ン',
		'ァ','ィ','ゥ','ェ','ォ','ッ','ャ','ュ','ョ','ー','、','。',
		'ガ','ギ','グ','ゲ','ゴ','ザ','ジ','ズ','ゼ','ゾ',
		'ダ','ヂ','ヅ','デ','ド','バ','ビ','ブ','ベ','ボ','パ','ピ','プ','ペ','ポ',
	];
	var trnchr = [
		'ｱ','ｲ','ｳ','ｴ','ｵ','ｶ','ｷ','ｸ','ｹ','ｺ','ｻ','ｼ','ｽ','ｾ','ｿ',
		'ﾀ','ﾁ','ﾂ','ﾃ','ﾄ','ﾅ','ﾆ','ﾇ','ﾈ','ﾉ','ﾊ','ﾋ','ﾌ','ﾍ','ﾎ',
		'ﾏ','ﾐ','ﾑ','ﾒ','ﾓ','ﾔ','ﾕ','ﾖ','ﾗ','ﾘ','ﾙ','ﾚ','ﾛ','ﾜ','ﾝ',
		'ｧ','ｨ','ｩ','ｪ','ｫ','ｯ','ｬ','ｭ','ｮ','ｰ','､','｡',
		'ｶﾞ','ｷﾞ','ｸﾞ','ｹﾞ','ｺﾞ','ｻﾞ','ｼﾞ','ｽﾞ','ｾﾞ','ｿﾞ',
		'ﾀﾞ','ﾁﾞ','ﾂﾞ','ﾃﾞ','ﾄﾞ','ﾊﾞ','ﾋﾞ','ﾌﾞ','ﾍﾞ','ﾎﾞ','ﾊﾟ','ﾋﾟ','ﾌﾟ','ﾍﾟ','ﾎﾟ',
	];
	var ngchrlen = ngchr.length;
	for(var i=0; i<=ngchrlen;i++){
		text = text.replace( ngchr[i], trnchr[i], 'mg' );
	}
	return text;
}// end of function replace_to_hankana(text)

		
function kana_chk1(a){
	//最初にトリム
	var a1 = a.value.replace(/^[ 　]+/,"").replace(/[ 　]+$/,"");
	a1 = a1.toUpperCase();
	a1 = replace_2to1byte(a1);
	a1 = replace_to_hankana(a1);
	//次に半角英(大文字)数カナ以外があったらはじく
	var hankaku=" -ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
			+"ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜｦﾝｧｨｩｪｫｯｬｭｮｰﾞﾟ";
	var b="";
	var c="";
	
	var alen = a1.length;
	for(var i=0; i<alen; i++){
		if(hankaku.indexOf(a1.charAt(i))<0){
			alert("半角カナ（英数）で入力ください");
			c="";
		}else {
			c=a1.charAt(i);
		}
		b += c;
	};
	a.value =b;
}


function kana_chk(item,nam){
	var hankaku=" -abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
					+"ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜｦﾝｧｨｩｪｫｯｬｭｮｰﾞﾟ";
	var itemval = document.forms[0] [item].value;
	itemval = replace_to_hankana(itemval);
	itemval = replace_2to1byte(itemval);
	
	var itemvallen = itemval.length;
	itemval = replace_2to1byte(itemval);
	for(var i=0; i<itemvallen; i++){
		if(hankaku.indexOf(itemval.charAt(i))<0){	
			errmsg += nam + "は半角で入力して下さい\n";
			break;
		};
	};
}

//window.onload = function(){//20160108 SubWが裏から表にでてくるように (大きなプログラムでは動かないようだ）　20160112外した
//	window.focus();
//}

