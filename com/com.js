//�@2014-09-08�@kaneshi comyear_set �Ő��l���͂łȂ����̂�r���Ƃ����B
//                    ������;���Ȃ����̂ɑΏ������B
//  2015-03-17 kaneshi �������A�������ߖ�
//         �������� �� ��&&�ցA�b��||�� ,��ʃp�����[�^�𕡐���ǂݎ�蕔���̏W��
//  2015-06-05 kaneshi 271�s�ڂ�����̕ϐ����ԈႢ���C��
//
//  2016-01-08 kaneshi window.onload =  window.focus�ǉ�
//     �{�Ԃœ��삵�Ȃ������Blineplan_inp�Ł@�S�V�O�s�ڂ�����ŕ����������������B�@
var updsw="";
var errmsg="";

comdocwin="";
comdoc_page=0;
comdoc_top=10;
comdoc_left=10;

//Window Name�ݒ�
var comwinnam="subwin0";
if(window.name.indexOf("subwin")==0){
	comwinnam="subwin" + (parseInt(window.name.substring(6,7))+1);
}
//���^�[���L�[
function comkey_event(evt,item,nextitem,chk)
{
	evt=(evt) ? evt:event;
	var itemval=document.forms[0] [item].value;
	var itemtype = document.forms[0] [item].type;

	var nextitemtype = document.forms[0] [nextitem].type;
	var nextitemval = document.forms[0] [nextitem].value;

	if(evt.keyCode==13 || evt.keyCode==3){
		if(chk=="SPACE" && itemval==""){
			if(itemtype=="text"){
				alert("�l����͂��ĉ�����");
			}else{
				alert("�l��I�����ĉ�����");
			}
			document.forms[0] [item].focus();
		}else if(itemtype=="text"
			&& (itemval.indexOf("'")>=0 || itemval.indexOf("\"")>=0 || itemval.indexOf("\\")>=0)){
			var errmsg="";
			if(itemval.indexOf("'")>=0){
				errmsg+="���p�u'�v�͎g�p�s�ł�\n";
			}
			if(itemval.indexOf("\"")>=0){
				errmsg+="���p�u�h�v�͎g�p�s�ł�\n";
			}
			if(itemval.indexOf("\\")>=0){
				errmsg+="���p�u\\�v�͎g�p�s�ł�\n";
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
					alert("���l����͂��ĉ�����");
				}else{
					alert("���l��I�����ĉ�����");
				}
				itemval="";
				document.forms[0] [item].focus();
			}else{
				if(nextitemtype=="button"){
					alert(nextitemval + "�ɐi�݂܂��B��낵���ł����H");
				}
				document.forms[0] [nextitem].focus();
			}
		}else{
			if(nextitemtype=="button"){
				if(confirm("�u" + nextitemval + "�{�^���v�ɐi�݂܂��B��낵���ł����H")){
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

//���̓X�L�b�v
function comitem_skip(keyitem,cond,val,item,nextitem,iniitem,upd)
{
	var keyval="";
	if(document.forms[0] [keyitem].type=="text"){
		keyval=document.forms[0] [keyitem].value;
	}else{
		keyval=document.forms[0] [keyitem][document.forms[0] [keyitem].selectedIndex].value;
	}
	if((cond=="EQ" && keyval==val)
	| (cond=="NEQ" && keyval!=val)
	| (cond=="LTE" && parseFloat(keyval)<=parseFloat(val))
	| (cond=="GTE" && parseFloat(keyval)>=parseFloat(val))
	| (cond=="LT" && parseFloat(keyval)<parseFloat(val))
	| (cond=="GT" && parseFloat(keyval)>parseFloat(val))
	){
		if(document.forms[0] [item].type=="text"){
			document.forms[0] [item].value="";
		}else{
			document.forms[0] [item][0].selected=true;
		}
		if(document.forms[0] [nextitem].type=="button"){
			alert(document.forms[0] [nextitem].value + "�ɐi�݂܂��B��낵���ł����H");
		}
		document.forms[0] [nextitem].focus();
	}
}

//�X�V�m�F
function com_sbm(itemlist)
{
	comupd="";
	var updtypetype = document.forms[0].UpdType.type;

	if(updtypetype==undefined){
		var updtypelen = document.forms[0].UpdType.length;;
		for(var i=0; i<updtypelen; i++){
			if(document.forms[0].UpdType[i].checked==true){
				comupd=document.forms[0].UpdType[i].value;
				break;
			}
		}
	}else if(updtypetype=="select-one"){
		comupd = document.forms[0].UpdType[document.forms[0].UpdType.selectedIndex].value;
	}else if(updtypetype=="checkbox"||updtypetype=="radio"){
		if(document.forms[0].UpdType.checked==true){
			comupd=document.forms[0].UpdType.value;
		}
	}else{
		comupd=document.forms[0].UpdType.value;
	}

	if(comupd==""){
		errmsg+="�������I��\n";
	}
	if(updsw==""){
		if(errmsg!=""){
			alert(errmsg);
		}else{
			if(comupd=="DEL"){
				if(confirm("�폜���܂��B��낵���ł����H")){
					updsw="ON";
					document.forms[0].submit();
				}else{
					alert("�����𒆎~���܂����B");
				}
			}else{
				if(itemlist!=""){
					var itemsplit=itemlist.split(",");
					errmsg="";
					var itemlen = itemsplit.length;

					for(var i=0; i<itemlen; i++){
						if(document.forms[0] [itemsplit[i]].value.indexOf("\"")>=0){
							errmsg="���̓G���A�Ɂu���p�h�v�͎g�p���Ȃ��ŉ�����\n";
							break;
						}
					}
					if(errmsg==""){
						for(var i=0; i<itemlen; i++){
							var itemi = itemsplit[i];
							itemval=document.forms[0] [itemi].value;
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
							document.forms[0] [itemi].value=setval;
						}
					}
				}

				if(errmsg!=""){
					alert(errmsg);
				}else{
					updsw="ON";
					document.forms[0].submit();
				}
			}
		}
	}else{
		alert("�������ł�");
	}
}

//----------------------------------------------//
//---------------�f�[�^�`�F�b�N-----------------//
//----------------------------------------------//
//���t�`�F�b�N
function comdate_chk(yitem,mitem,ditem,alertnam,spaceok)
{
	var yyyy="";
	var mm="";
	var dd="";

	var yitemtype = document.forms[0] [yitem].type;
	var yitemval = document.forms[0] [yitem].value;

	if(yitem==mitem && mitem==ditem && yitemtype=="text"
		&& yitemval.length!=10){
		errmsg+=alertnam + "���t�s��\n";
	}else{
		if(yitemtype=="text"||yitemtype=="hidden"){
			if(yitem==mitem && mitem==ditem){
				yyyy = yitemval.substring(0,4);
			}else{
				yyyy = yitemval;
			}
		}else{
			yyyy = document.forms[0] [yitem][document.forms[0] [yitem].selectedIndex].value;
		}
		var mitemtype = document.forms[0] [mitem].type;

		if(mitemtype=="text" || mitemtype=="hidden"){
			if(yitem==mitem && mitem==ditem){
				mm = document.forms[0] [mitem].value.substring(5,7);
			}else{
				mm = document.forms[0] [mitem].value;
			}
		}else{
			mm = document.forms[0] [mitem][document.forms[0] [mitem].selectedIndex].value;
		}
		var ditemtype = document.forms[0] [ditem].type;
		if(ditemtype=="text"|| ditemtype=="hidden"){
			if(yitem==mitem && mitem==ditem){
				dd = document.forms[0] [ditem].value.substring(8,10);
			}else{
				dd = document.forms[0] [ditem].value;
			}
		}else{
			dd = document.forms[0] [ditem][document.forms[0] [ditem].selectedIndex].value;
		}
		if(yyyy=="" || mm=="" || dd==""){
			if(spaceok=="NG"){
				errmsg+=alertnam + "���t������\n";
			}else if(yyyy!="" || mm!="" || dd!=""){
				errmsg+=alertnam + "���t�s��\n";
			}
		}else if(isNaN(yyyy) || isNaN(mm) || isNaN(dd)){
			errmsg+=alertnam + "���t�����l\n";
		}else if(mm>12 || mm<1){
			errmsg+=alertnam + "���s��\n";
		}else if(dd>31 || dd<1){
			errmsg+=alertnam + "���t�s��\n";
		}else if(mm==2){
			if(dd>29){
				errmsg+=alertnam + "���t�s��\n";
			}else if(yyyy/4!=Math.floor(yyyy/4)){
				if(dd>28){
					errmsg+=alertnam + "���t�s��\n";
				}
			}
		}else if(mm==4 || mm==6 || mm==9 || mm==11){
			if(dd>30){
				errmsg+=alertnam + "���t�s��\n";
			}
		}
	}
}

function comchar_chk(item,nam)
{
	var itemval = document.forms[0] [item].value;

	if(itemval.indexOf("<")>=0){
		errmsg+=nam + "���p�u<�v�͎g�p�s�ł�\n";
	}
	if(itemval.indexOf(">")>=0){
		errmsg+=nam + "���p�u>�v�͎g�p�s�ł�\n";
	}
	if(itemval.indexOf("'")>=0){
		errmsg+=nam + "���p�u'�v�͎g�p�s�ł�\n";
	}
	if(itemval.indexOf("\"")>=0){
		errmsg+=nam + "���p�u�h�v�͎g�p�s�ł�\n";
	}
	if(itemval.indexOf("\\")>=0){
		errmsg+=nam + "���p�u\\�v�͎g�p�s�ł�\n";
	}
}

//CORPS�`���֑�����
function comcorlpschar_chk(item,nam)
{
	var itemval = document.forms[0] [item].value;

	if(itemval.indexOf("~")>=0){
		errmsg+=nam + "���p�u~�v�͎g�p�s�ł�\n";
	}
	if(itemval.indexOf("|")>=0){
		errmsg+=nam + "���p�u|�v�͎g�p�s�ł�\n";
	}
	if(itemval.indexOf("{")>=0){
		errmsg+=nam + "���p�u{�v�͎g�p�s�ł�\n";
	}
	if(itemval.indexOf("}")>=0){
		errmsg+=nam + "���p�u}�v�͎g�p�s�ł�\n";
	}
	if(itemval.indexOf("'")>=0){
		errmsg+=nam + "���p�u'�v�͎g�p�s�ł�\n";
	}
	if(itemval.indexOf("\"")>=0){
		errmsg+=nam + "���p�u�h�v�͎g�p�s�ł�\n";
	}
	if(itemval.indexOf("\\")>=0){
		errmsg+=nam + "���p�u\\�v�͎g�p�s�ł�\n";
	}
}

//�����`�F�b�N
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
		errmsg+=alertnam + "�����l����͂��ĉ�����\n";
	}else if(isNaN(num)==true){
		errmsg+=alertnam + "���l����͂��ĉ�����\n";
	}
}

//�����^�C�v�`�F�b�N
function comchartype_chk(type,item,alertnam)
{
	var str=document.forms[0] [item].value;
	var letall="";
	var typenm="";

	if(type=="zen-kana"){
		typenm="�S�p�J�i";
		letall="�A�C�E�G�I�J�L�N�P�R�T�V�X�Z�\�^�`�c�e�g�i�j�k�l�m�n�q�t�w�z�}�~�����������������������������@�B�D�F�H�b�������[���K�M�O�Q�S�U�W�Y�[�]�_�a�d�f�h�o�r�u�x�{�p�s�v�y�|";
	}else if(type=="han-kana"){
		typenm="���p�J�i";
		letall="�������������������������������������������ܦݧ�����������";
	}else if(type=="han-alphabet"){
		str=str.toUpperCase();
		typenm="���p�p��";
		letall="ABCDEFGHIJKLMNOPQRSTUVWXYZ";
	}else if(type=="han-numalphabet"){
		str=str.toUpperCase();
		typenm="���p�p����";
		letall="ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
	}
	var strlen = str.length;

	for(var i=0; i<strlen; i++){
		if(letall.indexOf(str.charAt(i))<0){
			errmsg+=alertnam + typenm + "����͂��ĉ�����\n";
			break;
		}
	}
}

//----------------------------------------------//
//-----------------�f�[�^����-------------------//
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

//�����\�[�g
function comsort(item)
{
	sort=document.forms[0].DatSort.value;
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

	if(document.forms[0].PageCnt.value>1){
		document.forms[0].Page[0].selected=true;
	}
	document.forms[0].submit();
}

//�֎~�����ϊ�
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
				str=str + "\\'";
			}else if(val.charAt(i)=="\""){
				str=str + "\\\"";
			}else if(val.charAt(i)=="\\" && val.charAt(i+1)!="'"){
				str=str + "\\\\";
			}else{
				str=str + val.charAt(i);
			}
		}else{
			str=str + val.charAt(i);
		}
	}
	document.forms[0] [item].value=str;
}

//�p�������������啶���ϊ�
function comuppercase(item)
{
	document.forms[0] [item].value=document.forms[0] [item].value.toUpperCase();
}

//�p�����啶�����������ϊ�
function comlowercase(item)
{
	document.forms[0] [item].value=document.forms[0] [item].value.toLowerCase();
}

//�p�����S�p�����p�ϊ�
function comeisu_cnv(item)
{
	var str=document.forms[0] [item].value;
	var strhan="";
	var hankaku="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890,,123456789123456789*{}():;..--=+$%!&\"'#<>\\|?/ ";
	var zenkaku="�����������������������������������������������������`�a�b�c�d�e�f�g�h�i�j�k�l�m�n�o�p�q�r�s�t�u�v�w�x�y�P�Q�R�S�T�U�V�W�X�O�A�C�T�U�V�W�X�Y�Z�[�\�@�A�B�C�D�E�F�G�H���o�p�i�j�F�G�B�D�|�[���{�����I���h�f���������b�H�^�@";

	var han2="101011121314151617181920";
	var zen2="�]�I�J�K�L�M�N�O�P�Q�R�S";
	var strlen = str.length;
	for(var i=0; i<strlen; i++)
	{
		n=zenkaku.indexOf(str.charAt(i),0);
		if(n>=0){
			strhan+=hankaku.charAt(n);
		}else{
			n2=zen2.indexOf(str.charAt(i),0);
			if(n2>=0){
				strhan+=han2.substring(n2*2,n2*2+2);
			}else{
				strhan+=str.charAt(i);
			}
		}
	}
	document.forms[0] [item].value=strhan;
}

//���p�J�i���S�p�ϊ�
function comkana_cnv(item)
{
	var str=document.forms[0] [item].value;
	var strzen="";
	var hankaku="�������������������������������������������ܦݧ���������";
	var zenkaku ="�A�C�E�G�I�J�L�N�P�R�T�V�X�Z�\�^�`�c�e�g�i�j�k�l�m�n�q�t�w�z�}�~�����������������������������@�B�D�F�H�b�������[";
	var zenkaku2="�H�H���H�H�K�M�O�Q�S�U�W�Y�[�]�_�a�d�f�h�H�H�H�H�H�o�r�u�x�{�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H";
	var zenkaku3="�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�p�s�v�y�|�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H";
	var han2="��";
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

//�S�p�J�i�����p�ϊ�
function comhankana_cnv(item)
{
	var str=document.forms[0] [item].value;
	var strhan="";
	var hankaku="�������������������������������������������ܦݧ���������";
	var zenkata ="�A�C�E�G�I�J�L�N�P�R�T�V�X�Z�\�^�`�c�e�g�i�j�k�l�m�n�q�t�w�z�}�~�����������������������������@�B�D�F�H�b�������[";
	var zenkata2="�H�H���H�H�K�M�O�Q�S�U�W�Y�[�]�_�a�d�f�h�H�H�H�H�H�o�r�u�x�{�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H";
	var zenkata3="�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�p�s�v�y�|�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H";
	var zenhira ="�����������������������������������ĂƂȂɂʂ˂̂͂Ђӂւق܂݂ނ߂�������������񂟂�������������[";
	var zenhira2="�H�H���J�H�������������������������ÂłǁH�H�H�H�H�΂тԂׂځH�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H";
	var zenhira3="�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�ς҂Ղ؂ہH�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H�H";
	var strlen = str.length;

	for(var i=0; i<strlen; i++){
		if(zenkata.indexOf(str.charAt(i))>=0){
			strhan+=hankaku.charAt(zenkata.indexOf(str.charAt(i)));
		}else if(zenkata2.indexOf(str.charAt(i))>=0){
			strhan+=hankaku.charAt(zenkata2.indexOf(str.charAt(i)))+"�";
		}else if(zenkata3.indexOf(str.charAt(i))>=0){
			strhan+=hankaku.charAt(zenkata3.indexOf(str.charAt(i)))+"�";
		}else if(zenhira.indexOf(str.charAt(i))>=0){
			strhan+=hankaku.charAt(zenhira.indexOf(str.charAt(i)));
		}else if(zenhira2.indexOf(str.charAt(i))>=0){
			strhan+=hankaku.charAt(zenhira2.indexOf(str.charAt(i)))+"�";
		}else if(zenhira3.indexOf(str.charAt(i))>=0){
			strhan+=hankaku.charAt(zenhira3.indexOf(str.charAt(i)))+"�";
		}else{
			strhan+=str.charAt(i);
		}
	}
	document.forms[0] [item].value=strhan;
}

//���l�J���}�ҏW
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

//����P���A�Q�����S���ϊ�
function comyear_set(item)
{
	// ���͕����`�F�b�N
	var b = document.forms[0] [item].value;
	//�g����
	b = b.replace(/^[ �@]+/,"").replace(/[ �@]+$/,"");
	var c="";
	var d ="0123456789";//������
	var e ="";
	var blen = b.length;
	for(var i=0;i< blen;i++){
		c = b.charAt(i);
		//�����p����
		if(d.indexOf(c)<0){c="";}
		e = e + c;
	}
	document.forms[0] [item].value = e;
	var now=new Date();
	var year="" + now.getYear();
	//for netscape
	if(year.length==3){
		year="20" + year.substring(1,3);
	}
	var itemval = document.forms[0] [item].value;

	if(itemval.length==1){
			document.forms[0] [item].value=year.substring(0,3) + itemval;
	}else if(itemval.length==2){
		if(itemval<=year.substring(2,4)){
			document.forms[0] [item].value=year.substring(0,2) + itemval;
		}else{
			document.forms[0] [item].value=(year.substring(0,2) - 1) + itemval;
		}
	}else if(itemval.length==3){
		alert("����s��");
	}
}
//���P�����Q���ϊ�
function commonth_set(item)
{
	var itemval = document.forms[0] [item].value;

	if(itemval!=""){
		if(itemval.length>2){
			alert("�������s��");
		}else if(isNaN(itemval)){
			alert("�������l");
		}else if(itemval>12 || itemval<1){
			alert("���s��");
		}else if(itemval.length==1){
			document.forms[0] [item].value="0" + itemval;
		}
	}
}

//���P�����Q���ϊ�
function comday_set(yitem,mitem,item)
{
	var itemval = document.forms[0] [item].value;
	if(itemval!=""){
		var mitemval = document.forms[0] [mitem].value;
		var yitemval = document.forms[0] [yitem].value;

		if(itemval.length>2){
			alert("�������s��");
		}else if(isNaN(itemval)){
			alert("�������l");
		}else if(itemval>31 || itemval<1){
			alert("���s��");
		}else if(itemval>30
			&& (mitemval==4 || mitemval==6 || mitemval==9 || mitemval==11)){
			alert("���s��");
		}else if(itemval>29 && mitemval==2){
			alert("���s��");
		}else if(itemval>28 && mitemval==2
				&& Math.floor(yitemval/4)!=Math.ceil(yitemval/4)){
			alert("���s��");
		}else if(itemval.length==1){
			document.forms[0] [item].value="0" + itemval;
		}
	}
}

//���A���P�����Q���ϊ�
function comhour_set(item)
{
	var itemval = document.forms[0] [item].value;

	if(itemval.length>2){
		alert("�����s��");
		document.forms[0] [item].value="";
	}else if(isNaN(itemval)){
		alert("�����s��");
		document.forms[0] [item].value="";
	}else if(itemval>23 || itemval<0){
		alert("�����s��");
		document.forms[0] [item].value="";
	}else if(itemval.length==1){
		document.forms[0] [item].value="0" + itemval;
	}
}

//���P�����Q���ϊ�
function commin_set(item)
{
	var itemval = document.forms[0] [item].value;

	if(itemval.length>2){
		alert("�����s��");
		document.forms[0] [item].value="";
	}else if(isNaN(itemval)){
		alert("�����s��");
		document.forms[0] [item].value="";
	}else if(itemval>59 || itemval<0){
		alert("�����s��");
		document.forms[0] [item].value="";
	}else if(itemval.length==1){
		document.forms[0] [item].value="0" + itemval;
	}
}

//����R�[�h�R�����S���ϊ�
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
				bumonc=bumoc+"+0"+bumonci;
			}
		}else{
			if(bumonc==""){
				bumonc=bumonci;
			}else{
				bumonc=bumoc+"+"+bumonci;
			}
		}
	}
	document.forms[0] [item].value=bumonc;
}

//�e�L�X�g�G���A���s�f�[�^clear
function comtext_clr(item)
{
	var dat=document.forms[0] [item].value;
	var datsplit=dat.split("\n");

	var dsp="";
	var rc="";
	var datlen = datsplit.length;

	for(var i=0; i<datlen; i++){
		var dati = datsplit[i];

		if(confirm(dati+"���폜���܂����H")){
			dsp=rc;
			for(var j=i+1; j<datlen; j++){
				if(dsp==""){
					dsp=datsplit[j].replace("\r","");
				}else{
					dsp=dsp + "\n" + datsplit[j].replace("\r","");
				}
			}
			document.forms[0] [item].value=dsp;
		}else{
			if(rc==""){
				rc=dati.replace("\r","");
			}else{
				rc=rc + "\n" + dati.replace("\r","");
			}
		}
	}
}

//window.onload = function(){//20160108 SubW��������\�ɂłĂ���悤�� (�傫�ȃv���O�����ł͓����Ȃ��悤���j�@20160112 �O����
//	window.focus();
//}
