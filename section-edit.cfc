<cfcomponent extends="_config.PageController" output="no">

<cfset loadExternalVars("CMS,Framework")>

<cffunction name="loadData" access="public" returntype="struct" output="no">
	
	<cfset var local = StructNew()>
	<cfset var vars = getDefaultVars("Section","edit")>
	
	<cfset param("URL.parent","numeric",0)>
	
	<cfset vars.sLinks = StructNew()>
	<cfset vars.sPages = StructNew()>
	<cfset vars.qPages = variables.CMS.Pages.getPages(SectionID=URL.id)>
	<cfset vars.isLinkManager = variables.Framework.Config.getSetting("isMenuManaged")>
	<cfset vars.showMainURL = (vars.qPages.RecordCount GT 0)>
	
	<cfif vars.Action IS "Edit">
		<cfset vars.sLinks["SectionID"] = URL.id>
		<cfset vars.sPages["SectionID"] = URL.id>
	</cfif>
	
	<cfreturn vars>
</cffunction>

</cfcomponent>