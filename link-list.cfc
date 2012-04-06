<cfcomponent extends="_config.PageController" output="no">

<cfset loadExternalVars("Links,Sections",".CMS",true,1)>

<cffunction name="loadData" access="public" returntype="struct" output="no">
	
	<cfset var local = StructNew()>
	<cfset var vars = getDefaultVars("Links","list")>
	
	<cfset default("URL.section","integer",0)>
	
	<cfset vars.qSections = variables.Sections.getSections()>
	<cfset vars.sLinks = StructNew()>
	<cfset vars.Title = vars.TitleBase>
	<cfif URL.section>
		<cfset local.qSection = variables.Sections.getSection(URL.section)>
		<cfset vars.Title = '#vars.Title# for <a href="section-edit.cfm?id=#URL.section#">#local.qSection.SectionTitle#</a>'>
	<cfelse>
		<cfset URL.menu = 0>
	</cfif>
	<cfset vars.sLinks.SectionID = URL.section>
	
	<cfscript>
	vars.SebTableAttributes.label="Link";
	vars.SebTableAttributes.editpage="link-edit.cfm?section=#URL.section#";
	vars.SebTableAttributes.isDeletable="false";
	vars.SebTableAttributes.isEditable="false";
	vars.SebTableAttributes.CFC_Component="#variables.Links#";
	vars.SebTableAttributes.CFC_GetArgs="#vars.sLinks#";
	</cfscript>
	
	<cfreturn vars>
</cffunction>

</cfcomponent>