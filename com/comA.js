//comA.js 
//　written ｂｙ kaneshi  2014-07-18 
//   Update 
//	2014-07-26 改訂　sc_char_del追加
//	2014-07-30 seiban_chkにtoUpperCase()をいれた。
//	2014-08-10 str_eng_replace追加
// 			ユーザの入力文字列のチェックや変換
//	2017-10-25 kaneshi 品番・図番、型名、製番の入力欄で、　全角のアルファベット・数字・ハイフンを半角へ変換する処理をいれた 

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
      e = e + c;
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
	return(strhan);
}


function partdr_no_chk(a){
  var b = a.value.toUpperCase();
  //b = replace_2to1byte(b);//これはだめだ
  // 全角のアルファベットと数字とハイフンを半角になおす
  b=comeisu_cnv1(b);
  
  //トリムも実施（tabも改行も全角スペースもトリム↓）
  b = b.replace(/^[ 　]+/,"").replace(/[ 　]+$/,"");
  
  var d ="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ- ";//許容文字
  var e ="";
  var blen =b.length;
  for(var i=0;i< blen;i++){
      if(d.indexOf(b.charAt(i))>=0){
    	  e = e + b.charAt(i);
      }
  }
  a.value = e;
}

function modelno_chk(a){
  //トリムも実施（tabも改行も全角スペースもトリム↓）
  var b = a.value.toUpperCase();
  //b = replace_2to1byte(b);
  // 全角のアルファベットと数字とハイフンを半角になおす
  b=comeisu_cnv1(b);
  
  b = b.replace(/^[ 　]+/,"").replace(/[ 　]+$/,"");
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
    	e = e + b.charAt(i);
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
      e = e + b.charAt(i);
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

function trimall(a){
  a.value = a.value.toUpperCase().replace(/^[ 　]+/,"").replace(/[ 　]+$/,"");
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
function replace_kishuizon(text){
	var ngchr = 
		['①'
			,'②'
			,'③'
			,'④'
			,'⑤'
			,'⑥'
			,'⑦'
			,'⑧'
			,'⑨'
			,'⑩'
			,'⑪'
			,'⑫'
			,'⑬'
			,'⑭'
			,'⑮'
			,'⑯'
			,'⑰'
			,'⑱'
			,'⑲'
			,'⑳'
			,'Ⅰ'
			,'Ⅱ','Ⅲ','Ⅳ','Ⅴ','Ⅵ','Ⅶ','Ⅷ','Ⅸ','Ⅹ',
		  '㍉','㌔','㌢','㍍','㌘','㌧','㌃','㌶','㍑','㍗','㌍','㌦','㌣','㌫','㍊','㌻',
		  '㎜','㎝','㎞','㎎','㎏','㏄','㎡','㍻',
		  '〝','〟','№','㏍','℡','㊤','㊥','㊦','㊧','㊨','㈱','㈲','㈹','㍾','㍽','㍼'
		  
		  ];
	var trnchr = 
		['(1)','(2)','(3)','(4)','(5)','(6)','(7)','(8)','(9)','(10)','(11)','(12)','(13)','(14)','(15)',
		 '(16)','(17)','(18)','(19)','(20)','I','II','III','IV','V','VI','VII','VIII','IX','X',
		 'ミリ','キロ','センチ','メートル','グラム','トン','アール','ヘクタール','リットル','ワット','カロリー','ドル','セント','パーセント','ミリバール','ページ',
		 'mm','cm','km','mg','kg','cc','平方メートル','平成',
		 '「','」','No.','K.K.','TEL','(上)','(中)','(下)','(左)','(右)','(株)','(有)','(代)','明治','大正','昭和',
		 
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
	    e = e + c;
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
	 //トリムも実施（tabも改行も全角スペースもトリム↓）
	 b = b.replace(/^[ 　]+/,"").replace(/[ 　]+$/,"");
	 var c="";
	 var d ="0123456789";//許容文字
	 var e ="";
	 var blen = b.length;
	 for(var i=0;i< blen;i++){
	   c = b.charAt(i);
	     if(d.indexOf(c)<0){c="";}
	   e = e + c;
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
	 //トリムも実施（tabも改行も全角スペースもトリム↓）
	 b = b.replace(/^[ 　]+/,"").replace(/[ 　]+$/,"");
	 var c="";
	 var d ="0123456789";//許容文字
	 var e ="";
	 var blen = b.length;
	 for(var i=0;i< blen;i++){
	   c = b.charAt(i);
	     if(d.indexOf(c)<0){c="";}
	   e = e + c;
	 }
	 if(e!=0){
		  e = ("000" + e).slice(-4);
	 }
	 a.value = e;
}

function int_chk(a){
	   //入力値が０or自然数かチェック ,符号はなし
	  a.value = a.value.toUpperCase();
	  var b = a.value;
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
	  e = e + c;
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
	  a.value = a.value.replace(/^[ 　]+/,"").replace(/[ 　]+$/,"");
	  a.value = a.value.toUpperCase();
	  a.value = replace_2to1byte(a.value);
	a.value = replace_to_hankana(a.value);
	//次に半角英(大文字)数カナ以外があったらはじく
	  var hankaku=" -ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
	          +"ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜｦﾝｧｨｩｪｫｯｬｭｮｰﾞﾟ";
	var b="";
	var c="";
	
	var alen = a.value.length;
	for(var i=0; i<alen; i++){
	  if(hankaku.indexOf(a.value.charAt(i))<0){
		  alert("半角カナ（英数）で入力ください");
		  c="";
	  }else {
		  c=a.value.charAt(i);
	  }
	  b += c;
	};
	a.value =b;
}


function kana_chk(item,nam){
	var hankaku=" -abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
					+"ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜｦﾝｧｨｩｪｫｯｬｭｮｰﾞﾟ";
	var itemval = document.forms[0] [item].value;
	itemval = replace_2to1byte(itemval);
	
	var itemvallen = itemval.length;
	
	for(var i=0; i<itemvallen; i++){
		if(hankaku.indexOf(itemval.charAt(i))<0){	
			errmsg=errmsg + nam + "は半角で入力して下さい\n";
			break;
		};
	};
}
