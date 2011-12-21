<cfcomponent extends="_config.PageController" output="no">

<cfset loadExternalVars("CMS")>

<cffunction name="loadData" access="public" returntype="struct" output="no">
	
	<cfset var local = StructNew()>
	<cfset var vars = getDefaultVars("Page","edit")>
	
	<cfset param("URL.id","numeric",0)>
	
	<cfset vars.qPage = variables.CMS.getPage(PageID=URL.id)>
	
	<cfset vars.Title = "Page">
	<cfset vars.Action = "Rename">
	<cfset vars.Title = "#vars.Action# #vars.Title#">
	
	<cfreturn vars>
</cffunction>

</cfcomponent>