<cf_PageController>

<cf_Template showTitle="true">

<cf_sebForm CFC_Component="#Application.CMS.PageLinks#" CFC_Method="addPageLinks" sendback="true">
	<cf_sebField name="PageID" type="hidden" setValue="#URL.page#">
	<cf_sebField name="LinkedPages" type="checkbox" subquery="qPages" subvalues="PageID" subdisplays="Title" required="true" setValue="#PageLinks#">
	<cf_sebField type="Submit/Cancel/Delete">
</cf_sebForm>

</cf_Template>