<cf_PageController>

<cf_Template files_css="page-edit.css" showTitle="true">

<cfoutput>
<p><a href="page-edit.cfm?id=#URL.id#">Return to Main Edit Page</a></p>
</cfoutput>

<cf_sebForm
	forward="page-edit.cfm?id=#URL.id#"
	CFC_Component="#Application.CMS.Pages#"
>
	<cf_sebField name="Title">
	<cfif hasTemplates>
		<cf_sebField name="TemplateID">
	</cfif>
	<cf_sebField name="FileName" type="plaintext">
	<cfoutput><div class="plainlinks"><a href="page-copy.cfm?id=#url.id#">copy</a> / <a href="page-rename.cfm?id=#url.id#">rename</a></div></cfoutput>
	<cf_sebField name="Description" type="textarea" rows="3">
	<cf_sebField name="Keywords" type="textarea" rows="3">
	<cf_sebField name="VersionDescription" label="Change Notes" setValue="" help="<br/>Enter brief notes about your changes.">
	<cf_sebField name="VersionBy" type="hidden" setValue="#Author#">
	<cf_sebField type="Submit/Cancel" label="Save">
</cf_sebForm>

</cf_Template>