function linkeditInsertAfter(newElement,targetElement) {
	var parent = targetElement.parentNode;
	if ( parent.lastChild == targetElement ) {
		parent.appendChild(newElement);
	} else {
		parent.insertBefore(newElement,targetElement.nextSibling);
	}
}
function chooseLink() {
	if ( !document.getElementById ) return false;
	if ( !document.getElementById('LinkURL') ) return false;
	if ( !document.getElementById('Label') ) return false;
	
	var oLink = document.getElementById('LinkURL');
	
	if ( oLink.options[oLink.selectedIndex].value.length > 0 ) {
		document.getElementById('Label').value = oLink.options[oLink.selectedIndex].text;
		if ( document.getElementById('row-URL') ) {
			setStyleById('row-URL', 'display', '');
		}
		if ( document.getElementById('div-URL') ) {
			setStyleById('div-URL', 'display', 'block');
		}
		document.getElementById('URL-val').innerHTML = '<a href="' + oLink.options[oLink.selectedIndex].value + '" target="_blank">' + oLink.options[oLink.selectedIndex].value + '</a>';
	} else {
		document.getElementById('Label').value = '';
		if ( document.getElementById('row-URL') ) {
			setStyleById('row-URL', 'display', 'none');
		}
		if ( document.getElementById('div-URL') ) {
			setStyleById('div-URL', 'display', 'none');
		}
		document.getElementById('URL-val').innerHTML = '';
	}
	
	//alert(oLink.options[oLink.selectedIndex].text);
}
function loadChooseLink() {
	if ( !document.getElementById ) return false;
	if ( !document.getElementById('LinkURL') ) return false;
	
	addEventToId('LinkURL','change',chooseLink);
}
function chooseSection() {
	if ( !document.getElementById ) return false;
	if ( !document.getElementById('SectionID') ) return false;
	
	var oSection = document.getElementById('SectionID');
	
	sectionid = oSection.options[oSection.selectedIndex].value;
	
	filterSections();
	
}
function loadChooseSection() {
	if ( !document.getElementById ) return false;
	if ( !document.getElementById('SectionID') ) return false;
	
	addEventToId('SectionID','change',chooseSection);
}
function loadSectionFilter() {
	var inFilter = document.createElement('input');
	var lbFilter = document.createElement('label');
	var txFilter = document.createTextNode(' this section only');
	var oLinkURL = document.getElementById('LinkURL');
	
	inFilter.setAttribute('type','checkbox');
	inFilter.setAttribute('name','filter-section');
	inFilter.setAttribute('id','filter-section');
	
	addEvent(inFilter,'click',filterSections);
	
	lbFilter.setAttribute('id','filter-section-label');
	lbFilter.setAttribute('for','filter-section');
	lbFilter.appendChild(txFilter);
	
	linkeditInsertAfter(lbFilter,oLinkURL);
	linkeditInsertAfter(inFilter,oLinkURL);
	
}
function filterSections() {
	if ( !document.getElementById('filter-section') || document.getElementById('filter-section').checked ) {
		http('GET','link-edit.cfc?method=getSitePages&SectionID=' + sectionid, runSitePages);
		//alert('Filtering Sections');
	} else {
		http('GET','link-edit.cfc?method=getSitePages', runSitePages);
		//alert('Not Filtering Sections');
	}
}
function runSitePages(obj) {
	var oLink = document.getElementById('LinkURL');
	var pageid = oLink.options[oLink.selectedIndex].value;
	var row = 0;
	var oOption = 0
	var oSection = 0;
	var selected = false;
	
	oLink.options.length = 0;
	
	if ( document.getElementById('SectionID') ) {
		oOption = new Option();
		oOption.value = '';
		oOption.text = '(new page)';
		oLink.options[oLink.options.length] = oOption;
		
	}
	
	for (row=0; row < obj.linkurl.length; row++) {
		selected = false;
		oOption = new Option();
		oOption.value = obj.linkurl[row];
		oOption.text = obj.title[row];
		if ( pageid.length ) {
			if ( obj.linkurl[row] == pageid ) {
				selected = true;
			}
		} else {
			if ( document.getElementById('SectionID') && document.getElementById('SectionID').options ) {
				oSection = document.getElementById('SectionID');
				if ( oSection.options[oSection.selectedIndex] ) {
					selected = true;
				}
			}
		}
		if ( selected ) {
			oOption.selected = true;
		}
		oLink.options[oLink.options.length] = oOption;
	}
	 
	//alert('run pages 2');
}
addEvent(window,'load',loadChooseLink);
addEvent(window,'load',chooseLink);
if ( sectionid > 0 ) {
	addEvent(window,'load',loadSectionFilter);
} else {
	addEvent(window,'load',loadChooseSection);
}
