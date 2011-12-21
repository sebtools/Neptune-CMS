<cf_PageController>

<cf_Template showTitle="true"><!--- section-list.cfm?id=#qPage.SectionID# --->

<cf_sebForm
	forward="page-list.cfm"
	CFC_Component="#Application.CMS.Pages#"
	CFC_Method="copyPage"
>
	<cf_sebField name="Title" type="plaintext">
	<cf_sebField name="FileNameOld" dbfield="FileName" label="Old File Name" type="plaintext">
	<cf_sebField name="FileName" label="New File Name">
	<cf_sebField type="Submit/Cancel" label="Copy">
</cf_sebForm>

</cf_Template>