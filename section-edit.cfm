<cf_PageController>

<cf_Template showTitle="true">

<cf_sebForm
	forward="section-list.cfm"
	CFC_Component="#Application.CMS.Sections#"
>
	<cf_sebField name="ParentSectionID" type="hidden" setvalue="#Val(URL.parent)#">
	<cf_sebField name="SectionTitle">
	<cfif showMainURL>
		<cf_sebField name="MainPageURL" type="select" size="1" subquery="qPages" subvalues="URLPath" subdisplays="Title">
	</cfif>
	<cf_sebField name="isSectionLive">
	<cf_sebField type="Submit/Cancel/Delete" label="Save">
</cf_sebForm>

<cfif Action IS "edit">
	<!---<cf_layout include="link-list.cfm">
	<cf_layout include="page-list.cfm">--->
	<cf_sebTable
		editpage="link-edit.cfm?section=#URL.id#"
		CFC_Component="#Application.CMS.Links#"
		CFC_GetArgs="#sLinks#"
		width="90%"
		>
		<cf_sebColumn dbfield="ordernum">
		<cf_sebColumn dbfield="Label">
		<cf_sebColumn link="link-edit.cfm?section=#URL.id#&id=" label="edit">
		<cf_sebColumn type="delete">
	</cf_sebTable>
	
	<p>&nbsp;</p>
	
	<cf_sebTable
		editpage="page-edit.cfm?section=#URL.id#"
		CFC_Component="#Application.CMS.Pages#"
		CFC_GetArgs="#sPages#"
		width="90%"
		>
		<cf_sebColumn dbfield="Title">
		<cf_sebColumn dbfield="isPageLive">
		<cf_sebColumn link="page-edit.cfm?section=#URL.id#&id=" label="edit">
		<cf_sebColumn type="delete">
	</cf_sebTable>
	
</cfif>

</cf_Template>