<cf_PageController>

<cf_Template showTitle="true">

<p>You can add or edit content pages here.<cfif isLinkManager> If you want a link to the page in the menu, that must be done separately.</cfif></p>

<cf_sebTable
	label="Page"
	editpage="page-add.cfm?section=#URL.section#"
	isDeletable="false"
	isEditable="false"
	width="90%"
	CFC_Component="#Application.CMS.Pages#"
	CFC_GetArgs="#sPages#"
>
	<cf_sebColumn dbfield="Title">
	<cfif qTemplates.RecordCount GT 1>
		<cf_sebColumn dbfield="Template" label="Template">
	</cfif>
	<cf_sebColumn dbfield="isPageLive">
	<cf_sebColumn link="page-edit.cfm?section=#URL.section#&id=" label="edit">
	<cf_sebColumn link="page-view.cfm?&id=" label="view" target="_blank">
	<cf_sebColumn link="page-delete.cfm?section=#URL.section#&id=" label="delete">
</cf_sebTable>

</cf_Template>