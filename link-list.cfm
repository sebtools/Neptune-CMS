<cf_PageController>

<cf_Template showTitle="true">

<cfif qSections.RecordCount>
	<p><a href="section-list.cfm">Return to Sections</a></p>
</cfif>

<p>You can control the site menu from here.</p>

<cf_sebTable width="90%" isEditable="true" isDeletable="true">
	<cf_sebColumn dbfield="ordernum">
	<cf_sebColumn dbfield="Label">
</cf_sebTable>

</cf_Template>