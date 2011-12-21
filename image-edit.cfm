<cf_PageController>

<cf_Template showTitle="true">

<cf_sebForm CFC_Component="#Application.CMS.Images#" forward="#forward#">
	<cfif URL.page>
		<cf_sebField name="PageID" type="hidden">
	<cfelse>
		<cf_sebField name="PageID">
	</cfif>
	<cf_sebField name="ImageFile" label="#ImageLabel#">
	<cf_sebField type="Submit/Cancel/Delete">
</cf_sebForm>

</cf_Template>