<cf_PageController>

<cf_Template showTitle="true" files_css="page-edit.css">

<cf_sebForm
	formname="frmAddPage"
	forward="page-edit.cfm?id={result}&section=#URL.section#&do=add&from=#URL.from#"
	CFC_Component="#Application.CMS.Pages#"
>
	<cfif URL.section OR NOT qSections.RecordCount>
		<cf_sebField name="SectionID" type="hidden" setValue="#URL.section#">
	<cfelse>
		<cf_sebField name="SectionID" subquery="qSections" subvalues="SectionID" subdisplays="SectionTitle">
	</cfif>
	<cfif URL.link>
		<cf_sebField name="LinkID" type="hidden" setValue="#URL.link#">
	</cfif>
	<cf_sebField name="Title" defaultValue="#PageTitle#">
	<cfif qTemplates.RecordCount EQ 1>
		<cf_sebField name="TemplateID" type="hidden" setValue="#qTemplates.TemplateID#" required="true">
	<cfelse>
		<cfsavecontent variable="templatehelp"><p><a href="template-list.cfm">Manage Templates</a></p></cfsavecontent>
		<cf_sebField name="TemplateID" help="#templatehelp#">
	</cfif>
	<!--- <cf_sebField name="FileName">(<strong>Optional</strong>: Only letters,numbers,underscores,dashes. Must end with ".cfm") --->
	<cf_sebField type="Submit/Cancel" label="Continue">
</cf_sebForm>

<script type="text/javascript">document.forms.frmAddPage.Title.focus();</script>

</cf_Template>