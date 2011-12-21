<cfcomponent extends="_config.PageController" output="no">

<cfset loadExternalVars("Pages",".CMS")>

<cffunction name="loadData" access="public" returntype="struct" output="no">
	
	<cfset var vars = getDefaultVars("Page","edit")>
	
	<cfset param("URL.id","numeric",0)>
	
	<cfset vars.Title = "Page">
	<cfset vars.Action = "Copy">
	<cfset vars.Title = "#vars.Action# #vars.Title#">
	
	<cfreturn vars>
</cffunction>

</cfcomponent>