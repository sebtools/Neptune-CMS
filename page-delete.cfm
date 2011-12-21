<cf_PageController>

<cf_Template showTitle="true"><!--- section-list.cfm?id=#qPage.SectionID# --->

<cf_sebForm
	datasource=""
	query="qPage"
	forward="page-list.cfm?section=#URL.section#"
	CFC_Component="#Controller#"
	CFC_Method="deletePage"
	CatchErrTypes="CMS"
	pkfield="PageID"
>
	<cf_sebField name="Title" type="plaintext">
	<cfif StructKeyExists(Application,"MissingPages")>
		<cf_sebField name="LinkURL" label="Replacement Page" type="select" subquery="qPages" subvalues="LinkURL" subdisplays="Title" required="false">
	</cfif>
	<cf_sebField type="Submit/Cancel" label="Delete">
</cf_sebForm>

</cf_Template>