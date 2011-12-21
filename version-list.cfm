<cf_PageController>

<cfparam name="url.id" type="numeric">
<cfset qPage = Application.CMS.getPage(url.id)>
<!---<cfset qVersions = Application.CMS.getPageVersions(url.id)>--->
<cfset sVersions = StructNew()>
<cfset sVersions["PageID"] = URL.id>

<!--- Start Output --->
<cf_Template title="Page Versions">

<div class="pagehead">
	<h1><cfoutput>"#qPage.Title#": Versions</cfoutput></h1>
</div>
<div class="pagecontent">
	<cf_sebTable
		CFC_Component="#Application.CMS.PageVersions#"
		CFC_GetArgs="#sVersions#"
		isAddble="false"
		isEditable="false"
		isDeletable="false"
	>
		<cf_sebColumn dbfield="WhenCreated">
		<cf_sebColumn dbfield="VersionBy">
		<cf_sebColumn dbfield="VersionDescription">
		<cf_sebColumn link="version-restore.cfm?page=#url.id#&amp;id=" label="view">
	</cf_sebTable>
	<cfoutput>
	<p><a href="page-edit.cfm?id=#url.id#">Return to "#qPage.Title#"</a></p>
	</cfoutput>
</div>

</cf_Template>