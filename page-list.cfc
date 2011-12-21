<cfcomponent extends="_config.PageController" output="no">

<cfset loadExternalVars("CMS,Framework")>

<cffunction name="loadData" access="public" returntype="struct" output="no">
	
	<cfset var local = StructNew()>
	<cfset var vars = StructNew()>
	
	<cfset param("URL.section","numeric",0)>
	
	<cfset vars.sPages = StructNew()>
	<cfset vars.qTemplates = variables.CMS.Templates.getTemplates()>
	<cfset vars.Title = "Pages">
	<cfset vars.isLinkManager = variables.Framework.Config.getSetting("isMenuManaged")>
	
	<cfif URL.section>
		<cfset local.qSection = variables.CMS.Sections.getSection(URL.section)>
		<cfif local.qSection.RecordCount>
			<cfset vars.sPages["SectionID"] = URL.section>
			<cfset vars.Title = "#vars.Title# in ""#local.qSection.SectionTitle#"" section">
		</cfif>
	</cfif>
	
	<cfreturn vars>
</cffunction>

</cfcomponent>