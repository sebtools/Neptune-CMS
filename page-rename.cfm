<cf_PageController>

<cf_Template showTitle="true">

<cf_sebForm
	datasource=""
	forward="page-list.cfm"
	CFC_Component="#Application.CMS#"
	CFC_GetMethod="getPage"
	CFC_Method="renamePageFile"
	CatchErrTypes="CMS"
	pkfield="PageID"
>
	<cf_sebField name="Title" type="plaintext">
	<cf_sebField name="FileName_old" dbfield="FileName" label="Old File Name" type="plaintext">
	<cf_sebField name="FileName" label="New File Name">
	<cf_sebField type="Submit/Cancel" label="Rename">
</cf_sebForm>

</cf_Template>