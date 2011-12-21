<cfcomponent extends="_config.PageController" output="no">

<cfset loadExternalVars("CMS,Framework")>

<cffunction name="loadData" access="public" returntype="struct" output="no">
	
	<cfset var local = StructNew()>
	<cfset var vars = StructNew()>
	
	<cfset param("URL.id","numeric",0)>
	
	<cfscript>
	vars.Title = "Sections";
	vars.SortArgs = StructNew();
	vars.sSections = StructNew();
	vars.sPages = StructNew();
	vars.isLinkManager = variables.Framework.Config.getSetting("isMenuManaged");
	vars.qTemplates = variables.CMS.Templates.getTemplates();
	if ( URL.id GT 0 ) {
		vars.qSection = variables.CMS.getSection(URL.id);
		vars.qSubsections = variables.CMS.getSections(URL.id);
		//vars.qPages = variables.CMS.getPages(URL.id);
		sPages["SectionID"] = URL.id;
		vars.sectionslabel = "Subsection";
		vars.LinkLabel = "pages";
		vars.SortArgs.ParentSectionID = url.id;
		vars.sSections.ParentSectionID = url.id;
		vars.isSectionEditor = true;
		vars.hasMakeLinksOption = false;
	} else {
		vars.qSection = Application.CMS.getSection();
		vars.qSubsections = Application.CMS.getSections(0);
		//vars.qPages = Application.CMS.getPages(0);
		sPages["SectionID"] = 0;
		vars.sectionslabel = "Section";
		vars.LinkLabel = "subsections";
		vars.sSections.ParentSectionID = 0;
		vars.isSectionEditor = true;
		vars.hasMakeLinksOption = ( vars.isLinkManager AND variables.CMS.hasPagesNoLinks() );
	}
	vars.Title = "Site Sections";
	if ( vars.qSection.RecordCount ) {
		vars.Title = '#vars.Title# for "#vars.qSection.SectionTitle#"';
	}
	</cfscript>
	
	<cfreturn vars>
</cffunction>

</cfcomponent>