function preview() {
	if ( !document.getElementById ) {return false;}
	if ( !document.getElementById('frmSebform') ) {return false;}
	
	var frm = document.getElementById('frmSebform');
	var action = frm.action;
	var target = frm.target;

	frm.action = "page-preview.cfm";
	frm.target = "_blank";

	//<!--- <cfif url.ver eq 0> --->
	//updateWysis();
	//alert( document.getElementById('Contents').value );
	//<!--- </cfif> --->
	frm.submit();

	frm.action = action;
	frm.target = target;
}
function loadPreview() {
	addEventToId('btnPreview', 'click', preview);
}
addEvent(window,'load',loadPreview);
function addSettingMarker(val) {
	var oEditor = FCKeditorAPI.GetInstance('Contents');
	if ( val.length ) {
		oEditor.InsertHtml('[' + val + ']')
	}
}
function addContentFileMarker(val) {
	var oEditor = FCKeditorAPI.GetInstance('Contents');
	if ( val.length ) {
		oEditor.InsertHtml('<div>{' + val + '}</div>')
	}
}