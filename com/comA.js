//comA.js 
//�@written ���� kaneshi  2014-07-18 
//   Update 
//	2014-07-26 �����@sc_char_del�ǉ�
//	2014-07-30 seiban_chk��toUpperCase()�����ꂽ�B
//	2014-08-10 str_eng_replace�ǉ�
// 			���[�U�̓��͕�����̃`�F�b�N��ϊ�
//	2017-10-25 kaneshi �i�ԁE�}�ԁA�^���A���Ԃ̓��͗��ŁA�@�S�p�̃A���t�@�x�b�g�E�����E�n�C�t���𔼊p�֕ϊ����鏈�������ꂽ 

//window.openByPost 
window.openByPost = function ( url, param, name ){
    var win = window.open( "about:blank", name );

    // form�𐶐�
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

    // �ꎞ�I��body��form��ǉ��B�T�u�~�b�g��Aform���폜����
    var body = document.getElementsByTagName("body")[0];
    body.appendChild(form);
    form.submit();
    body.removeChild(form); 

    return win;
} //end of window.openByPost = function ( url, param, name )


function str_eng_replace(a){
    //�g���������{�itab�����s���S�p�X�y�[�X���g�������j
    var b = a.value;
    b = replace_2to1byte(b);
    b = b.replace(/^[ �@]+/,"").replace(/[ �@]+$/,"");
    var c="";
    var d ="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890*{}:;,.-=+$%!&\#\\|?/@ �";
    var d1= "<>;'"; //�֎~�����@�i�ϊ����ׂ����j
    var e ="";
    var blen = b.length;
    for(var i=0;i< blen;i++){
      c = b.charAt(i);
      if(d.indexOf(c)<0 || d1.indexOf(c)>=0){
        c="";
        alert("�g�p�s�\�̕���������܂����B");
      }
      e = e + c;
    }
    //�g�p�֎~������@submit()
    a.value = e;
}

//�p�����S�p�����p�ϊ�(���̂P)�@�A���t�@�x�b�g�Ɛ����ƃn�C�t���̂�
function comeisu_cnv1(str)
{
	var strhan="";
	var hankaku="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890- ";
	var zenkaku="�����������������������������������������������������`�a�b�c�d�e�f�g�h�i�j�k�l�m�n�o�p�q�r�s�t�u�v�w�x�y�P�Q�R�S�T�U�V�W�X�O�|�@";

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
  //b = replace_2to1byte(b);//����͂��߂�
  // �S�p�̃A���t�@�x�b�g�Ɛ����ƃn�C�t���𔼊p�ɂȂ���
  b=comeisu_cnv1(b);
  
  //�g���������{�itab�����s���S�p�X�y�[�X���g�������j
  b = b.replace(/^[ �@]+/,"").replace(/[ �@]+$/,"");
  
  var d ="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ- ";//���e����
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
  //�g���������{�itab�����s���S�p�X�y�[�X���g�������j
  var b = a.value.toUpperCase();
  //b = replace_2to1byte(b);
  // �S�p�̃A���t�@�x�b�g�Ɛ����ƃn�C�t���𔼊p�ɂȂ���
  b=comeisu_cnv1(b);
  
  b = b.replace(/^[ �@]+/,"").replace(/[ �@]+$/,"");
  var d ="ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890*{}():;,.-+$&\"#\\|?/@ �";
  // '�Ɓ���!��%�͋֎~
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
  //�g���������{�itab�����s���S�p�X�y�[�X���g�������j
  var b = a.value.toUpperCase();
  //b = replace_2to1byte(b);
  //�����ɑS�p�|�����p�ϊ��@�i�����A���t�@�x�b�g�o�[)
  b=comeisu_cnv1(b);//20171025
  
  b = b.replace(/^[ �@]+/,"").replace(/[ �@]+$/,"");
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
  //�g����
  var b = a.value.replace(/^[ �@]+/,"").replace(/[ �@]+$/,"");
  b = replace_2to1byte(b);
  //�����Ɍ���
  var d ="0123456789";
  var e ="";
  var blen = b.length;
  for(var i=0;i< blen;i++){
    if(d.indexOf(b.charAt(i))>=0){
      e = e + b.charAt(i);
    }
  }
  b =e;
  //�͈͌���@���Ԏq�ԍ���50-79���K�{
  if(b<'50' || b>'79'){
	  b='';
	  alert("���Ԏq�ԍ��͂T�O�`�V�X�ł��B");
  }
  a.value = b;
}

function trimall(a){
  a.value = a.value.toUpperCase().replace(/^[ �@]+/,"").replace(/[ �@]+$/,"");
}

function replace_2to1byte(text){
	var ngchr = 
		[ '�`','�a','�b','�c','�d','�e','�f','�g','�h','J','�j','�k','�l','�m','�n',
		  '�o','�p','�q','�r','�s','�t','�u','�v','�w','�x','�y','�|','�[','�@',
		  '��','��','��','��','��','��','��','��','��','��','��','��','��','��','��',
		  '��','��','��','��','��','��','��','��','��','��','��',
		  '�O','�P','�Q','�R','�S','�T','�U','�V','�W','�X'
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
  var b = a.value.replace(/^[ �@]+/,"").replace(/[ �@]+$/,"");
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
	  alert("�����֎~����"+err+"���폜���܂��B");
  }
  a.value = e;
}

function str_replace(a){
	  //alert("str_replace in");
	  //���s��^�u���g����
	  var b = a.value.replace(/^[ �@]+/,"").replace(/[ �@]+$/,"");
	  //�ݸ�فE����ٸ��ð��݁@=���ق�,��ς�A.�ޯāA;�к��<�A>�A|�͑S�p�����֕ϊ�
	  var c = "";
	  var e = "";
	  var err="";
	  var blen = b.length;
	  for(var i=0; i<blen ;i++){
	    c = b.charAt(i);
	    if(c=='	'){c=" ";err+='"';};
	    if(c=='"'){c="�h";err+='"';};
	    if(c=="'"){c="�f";err+="'";};
	    if(c=="="){c="��";err+="=";};
	    if(c==","){c="�C";err+=",";};
	    if(c=="."){c="�D";err+=".";};
	    if(c==";"){c="�G";err+=";";};
	    if(c==">"){c="��";err+=">";};
	    if(c=="<"){c="��";err+="<";};
	    if(c=="|"){c="�b";err+="|";};
	    if(c=="&"){c="��";err+="&";};
	    if(c=="#"){c="��";err+="#";};
	    if(c=="%"){c="��";err+="%";};
	    if(c=="("){c="�i";err+="(";};
	    if(c==")"){c="�j";err+=")";};
	    if(c=="!"){c="�I";err+="!";};
	    if(c=="/"){c="�^";err+="/";};
	    e += c;
	  };
	  if(err!=""){
		  alert("���䕶��'"+err+"'��S�p�����֕ϊ����܂��B");
	  }

	  //JIS�ŋ@��ˑ�������ϊ�
	  b=e;
	  e1 = replace_kishuizon(e);
	  if(e1!=e){
		  alert("�@��ˑ�������ϊ����܂�");
		  b =e1;
	  }
	  //alert(b);
	  a.value = b.replace(/^[ �@]+/,"").replace(/[ �@]+$/,"");
	  //alert("str_replace out");
}// end of function str_replace(a)

//�@��ˑ������u�� 2014-02-11
function replace_kishuizon(text){
	var ngchr = 
		['�@'
			,'�A'
			,'�B'
			,'�C'
			,'�D'
			,'�E'
			,'�F'
			,'�G'
			,'�H'
			,'�I'
			,'�J'
			,'�K'
			,'�L'
			,'�M'
			,'�N'
			,'�O'
			,'�P'
			,'�Q'
			,'�R'
			,'�S'
			,'�T'
			,'�U','�V','�W','�X','�Y','�Z','�[','�\','�]',
		  '�_','�`','�a','�b','�c','�d','�e','�f','�g','�h','�i','�j','�k','�l','�m','�n',
		  '�o','�p','�q','�r','�s','�t','�u','�~',
		  '��','��','��','��','��','��','��','��','��','��','��','��','��','��','��','��'
		  
		  ];
	var trnchr = 
		['(1)','(2)','(3)','(4)','(5)','(6)','(7)','(8)','(9)','(10)','(11)','(12)','(13)','(14)','(15)',
		 '(16)','(17)','(18)','(19)','(20)','I','II','III','IV','V','VI','VII','VIII','IX','X',
		 '�~��','�L��','�Z���`','���[�g��','�O����','�g��','�A�[��','�w�N�^�[��','���b�g��','���b�g','�J�����[','�h��','�Z���g','�p�[�Z���g','�~���o�[��','�y�[�W',
		 'mm','cm','km','mg','kg','cc','�������[�g��','����',
		 '�u','�v','No.','K.K.','TEL','(��)','(��)','(��)','(��)','(�E)','(��)','(�L)','(��)','����','�吳','���a',
		 
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
		errmsg = '���l' + len +'���œ��͂��Ă�������\n';
		alert(errmsg);
		a.value = '';
	return;
	}
	 //�g���������{�itab�����s���S�p�X�y�[�X���g�������j
	b = b.replace(/^[ �@]+/,"").replace(/[ �@]+$/,"");
	var c="";
	var d ="0123456789 ";//���e����
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
		errmsg = '���l4���œ��͂��Ă�������\n';
		alert(errmsg);
		a.value = '';
		return;
	}
	var b = a.value.toUpperCase();
	 //�g���������{�itab�����s���S�p�X�y�[�X���g�������j
	 b = b.replace(/^[ �@]+/,"").replace(/[ �@]+$/,"");
	 var c="";
	 var d ="0123456789";//���e����
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
		errmsg = '���l4���œ��͂��Ă�������\n';
		alert(errmsg);
		a.value = '';
		return;
	}
	  var b = a.value.toUpperCase();
	 //�g���������{�itab�����s���S�p�X�y�[�X���g�������j
	 b = b.replace(/^[ �@]+/,"").replace(/[ �@]+$/,"");
	 var c="";
	 var d ="0123456789";//���e����
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
	   //���͒l���Oor���R�����`�F�b�N ,�����͂Ȃ�
	  a.value = a.value.toUpperCase();
	  var b = a.value;
	  b = replace_2to1byte(b);
	  if(!b.match(/^[0-9]+$/)){
		  alert("�����i0�ȏ�j����͂��������B");
	    a.value = '';
	  }
}

function dr_eng_nam_chk(a) { //�������i�p�j�`�F�b�b�N(�폜)
	var b = a.value.toUpperCase();
	//�g���������{�itab�����s���S�p�X�y�[�X���g�������j
	b = b.replace(/^[ �@]+/, "").replace(/[ �@]+$/, "");
	b = replace_2to1byte(b);
	
	var c = "";
	var d = "'\"=<>!|[]  ";//'(�ݸ�ٺ�ð��݁A�p�C�v�A�^�u��)�A
	var e = "";
	var blen = b.length;
	for ( var i = 0; i < blen; i++) {
	  c = b.charAt(i);
	  if ( d.indexOf(c) >= 0) {
		  c = "";
		  alert("���͋֎~�̕���������܂����B");
		}
	  e = e + c;
	}
	e = e.replace('SUBMIT(','');
	a.value = e;
}

function replace_to_hankana(text){
    var ngchr = [
        '�A','�C','�E','�G','�I','�J','�L','�N','�P','�R','�T','�V','�X','�Z','�\',
        '�^','�`','�c','�e','�g','�i','�j','�k','�l','�m','�n','�q','�t','�w','�z',
        '�}','�~','��','��','��','��','��','��','��','��','��','��','��','��','��',
        '�@','�B','�D','�F','�H','�b','��','��','��','�[','�A','�B',
        '�K','�M','�O','�Q','�S','�U','�W','�Y','�[','�]',
        '�_','�a','�d','�f','�h','�o','�r','�u','�x','�{','�p','�s','�v','�y','�|',
    ];
    var trnchr = [
         '�','�','�','�','�','�','�','�','�','�','�','�','�','�','�',
         '�','�','�','�','�','�','�','�','�','�','�','�','�','�','�',
         '�','�','�','�','�','�','�','�','�','�','�','�','�','�','�',
         '�','�','�','�','�','�','�','�','�','�','�','�',
         '��','��','��','��','��','��','��','��','��','��',
         '��','��','��','��','��','��','��','��','��','��','��','��','��','��','��',
    ];
    var ngchrlen = ngchr.length;
    for(var i=0; i<=ngchrlen;i++){
        text = text.replace( ngchr[i], trnchr[i], 'mg' );
    }
    return text;
}// end of function replace_to_hankana(text)

		
function kana_chk1(a){
	//�ŏ��Ƀg����
	  a.value = a.value.replace(/^[ �@]+/,"").replace(/[ �@]+$/,"");
	  a.value = a.value.toUpperCase();
	  a.value = replace_2to1byte(a.value);
	a.value = replace_to_hankana(a.value);
	//���ɔ��p�p(�啶��)���J�i�ȊO����������͂���
	  var hankaku=" -ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
	          +"�������������������������������������������ܦݧ�����������";
	var b="";
	var c="";
	
	var alen = a.value.length;
	for(var i=0; i<alen; i++){
	  if(hankaku.indexOf(a.value.charAt(i))<0){
		  alert("���p�J�i�i�p���j�œ��͂�������");
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
					+"�������������������������������������������ܦݧ�����������";
	var itemval = document.forms[0] [item].value;
	itemval = replace_2to1byte(itemval);
	
	var itemvallen = itemval.length;
	
	for(var i=0; i<itemvallen; i++){
		if(hankaku.indexOf(itemval.charAt(i))<0){	
			errmsg=errmsg + nam + "�͔��p�œ��͂��ĉ�����\n";
			break;
		};
	};
}
