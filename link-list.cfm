<cf_PageController>

<cf_Template showTitle="true">

<cfif qSections.RecordCount>
	<p><a href="section-list.cfm">Return to Sections</a></p>
</cfif>

<p>You can control the site menu from here.</p>

<cf_sebTable width="90%">
	<cf_sebColumn dbfield="ordernum">
	<cf_sebColumn dbfield="Label">
	<cf_sebColumn link="link-edit.cfm?section=#URL.section#&id=" label="edit">
	<cf_sebColumn type="delete">
</cf_sebTable>

</cf_Template>