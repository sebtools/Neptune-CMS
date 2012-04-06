<cf_PageController>

<cf_Template files_css="page-edit.css" files_js="page-edit.js" showTitle="true">

<cfoutput>
<p><a href="page-edit.cfm?id=#URL.page#">Return to Main Edit Page</a></p>
</cfoutput>

<cf_sebForm
	forward="page-edit.cfm?id=#URL.page#"
	CFC_Component="#Application.CMS.PageVersions#"
	CFC_Method="restoreVersion"
	format="semantic"
	>
	<cf_sebField name="PageID" type="hidden" defaultValue="#URL.page#">
	<cf_sebField name="Title">
	<cf_sebField name="FileName" label="File Name" type="plaintext">
	<cf_sebField name="Description" type="textarea" Length="240" rows="3">
	<cf_sebField name="Keywords" type="textarea" Length="240" rows="3">
	<cf_sebField name="VersionDescription" label="Change Notes" setValue="" help="<br/>Enter brief notes about your changes.">
	<cf_sebField name="Contents" type="FCKeditor" height="300">
	<cf_sebField name="VersionDescription" label="Change Notes" setValue="" help="<br/>Enter brief notes about your changes.">
	<cf_sebField name="VersionBy" type="hidden">
	<input type="button" name="btnPreview" id="btnPreview" value="Preview" />
	<cf_sebField type="Submit/Cancel" label="Restore">
</cf_sebForm>

</cf_Template>