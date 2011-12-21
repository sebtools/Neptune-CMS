<cf_PageController>

<cf_Template
	files_css="page-edit.css?lu=2008-10-03"
	files_js="page-edit.js"
	showTitle="true"
>

<cfif NOT Len(ContentEdit)>
	<p>If you have trouble deleting text from the editor, type something into it and try again.</p>
</cfif>

<cf_sebForm
	forward="#forward#"
	CFC_Component="#Application.CMS.Pages#"
	filter="#aFormFilters#"
	CatchErrTypes="CMS"
>
	<cf_sebField name="Title" type="textarea" rows="3">
	<cfif qSections.RecordCount>
		<cf_sebField name="SectionID">
	</cfif>
	<cf_sebField type="custom1">
		<cfoutput><div class="plainlinks"><p><a href="page-edit-meta.cfm?id=#url.id#">Edit Meta Data</a> (including page template)</p></div></cfoutput>
	</cf_sebField>
	<cfif Len(ContentEdit)>
		<cfoutput><div class="plainlinks">#ContentEdit#</div></cfoutput>
		<cf_sebField type="hidden" name="Contents" setValue="#HTMLEditFormat(qPage.Contents)#">
		<input type="button" name="btnPreview" id="btnPreview" value="Preview" />
	<cfelse>
		<cf_sebField type="CKeditor" name="Contents">
		<cfif isQuery(qSiteSettings) AND qSiteSettings.RecordCount>
			Insert Setting Data:
			<select name="ContentFileID" onchange="addSettingMarker(this.options[this.selectedIndex].value);">
				<option value=""></option><cfoutput query="qSiteSettings">
				<option value="#SettingName#">#Settinglabel#</option></cfoutput>
			</select><br/>
		</cfif>
		<cfif isQuery(qContentFiles) AND qContentFiles.RecordCount>
			Insert Content Block:
			<select name="ContentFileID" onchange="addContentFileMarker(this.options[this.selectedIndex].value);">
				<option value=""></option><cfoutput query="qContentFiles">
				<option value="#Label#">#Label#</option></cfoutput>
			</select><br/>
		</cfif>
		<cf_sebField name="VersionDescription" label="Change Notes" setValue="" help="<br/>Enter brief notes about your changes.">
		<cf_sebField name="isPageLive" defaultValue="true">
		<cfif isLinkManager>
			<cf_sebField name="isInMenu" label="In Menu?" type="yesno" help="Will only add page to menu if it is in a section.">
		</cfif>
		<cf_sebField type="hidden" name="VersionBy" setValue="#Author#">
		<cf_sebField type="custom1">
			<input type="button" name="btnPreview" id="btnPreview" value="Preview" />
		</cf_sebField>
		<cf_sebField type="Submit/Cancel" label="Save">
	</cfif>
</cf_sebForm>
<cfoutput><p><a href="version-list.cfm?id=#url.id#">Restore Old Version</a></p></cfoutput>

<cfif Action EQ "edit">
	<cf_layout include="page_link-list.cfm">
	<!---<cf_sebTable isEditable="false" CFC_Component="#Application.CMS.PageLinks#" CFC_GetArgs="#sPageLinks#" CFC_SortMethod="sortPageLinks" CFC_SortListArg="PageLinks" editpage="page_link-add.cfm?page=#URL.id#">
		<cf_sebColumn dbfield="ordernum">
		<cf_sebColumn dbfield="Title">
		<cf_sebColumn label="edit" link="page_link-edit.cfm?page=#URL.id#&id=">
		<cf_sebColumn type="delete">
	</cf_sebTable>--->
</cfif>

</cf_Template>