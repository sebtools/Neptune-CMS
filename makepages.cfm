<cf_Template
	title="Recreate Pages"
	showTitle="true"
	head_css="##sebForm {width:220px;height:28px;}"
>

<p>Warning! This will write the file for each page. Consult your programmer before taking this action.</p>

<cf_sebForm
	forward="#CGI.SCRIPT_NAME#?done=1"
	CFC_Component="#Application.CMS#"
	CFC_Method="makeFiles"
	CatchErrTypes="CMS"
>
	<cf_sebField type="Submit/Cancel" label="Recreate Pages,Cancel">
</cf_sebForm>

<cfif isDefined("URL.done")>
	<p class="sebMessage">Files have been recreated.</p>
</cfif>

</cf_Template>