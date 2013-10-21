<cf_PageController>

<cf_Template title="Sections" showTitle="false">

<cfif qSection.RecordCount>
<p><a href="section-list.cfm">Return to Top</a></p>
</cfif>

<h1><cfoutput>Site Sections <cfif qSection.RecordCount>for "#qSection.SectionTitle#"</cfif></cfoutput></h1>

<cfif hasMakeLinksOption>
	<div style="border:1px solid gray;padding:4px;">
		<p>This site has pages, but no links. You can automatically create links for all of the pages, if you want.</p>
		<cf_sebForm skin="plain" CFC_Component="#Application.CMS#" CFC_Method="makeLinks">
			<cf_sebField type="submit" label="Make Links">
		</cf_sebForm>
	</div>
</cfif>

<p>Manage sections and menu links for those sections here.</p>

<cf_sebTable
	label="#sectionslabel#"
	query="qSubsections"
	pkfield="SectionID"
	editpage="section-edit.cfm?parent=#url.id#"
	isAddable="#isSectionEditor#"
	isDeletable="false"
	isEditable="false"
	width="90%"
	orderby="OrderNum"
	CFC_Component="#Application.CMS.Sections#"
	CFC_SortListArg="Sections"
	CFC_SortArgs="#SortArgs#"
	>
	<cf_sebColumn dbfield="OrderNum" label=" " type="sorter">
	<cf_sebColumn dbfield="SectionTitle" label="Section">
	<cf_sebColumn dbfield="isSectionLive">
	<cf_sebColumn link="link-list.cfm?section=" label="links">
	<cf_sebColumn link="page-list.cfm?section=" label="pages">
	<!--- <cf_sebColumn link="section-list.cfm?id=" label="subsections"> --->
	<cfif isSectionEditor>
		<cf_sebColumn link="section-edit.cfm?parent=#url.id#&id=" label="edit">
	</cfif>
	<cf_sebColumn type="delete" label="Delete" show="!NumPages">
</cf_sebTable>

</cf_Template>
