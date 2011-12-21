<cf_PageController>

<cf_Template showTitle="true">

<cf_sebForm>
	<cfif URL.page>
		<cf_sebField name="PageID" type="hidden" setValue="#URL.page#">
	<cfelse>
		<cf_sebField name="PageID">
	</cfif>
	<cf_sebField name="LinkedPageID">
	<cf_sebField type="Submit/Cancel/Delete">
</cf_sebForm>

</cf_Template>