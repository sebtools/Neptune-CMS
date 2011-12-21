<cfcomponent extends="_config.PageController" output="no">

<cfset loadExternalVars("CMS")>

<cffunction name="loadData" access="public" returntype="struct" output="no">
	
	<cfset var local = StructNew()>
	<cfset var vars = StructNew()>
	
	<!--- Defaults for incoming variables --->
	<cfset require("URL.id","numeric","page-list.cfm")>
	<cfset require("URL.page","numeric","page-list.cfm")>
	
	<!--- Defaults for local variables --->
	<cfset local["Action"] = "Restore">
	<cfset local["Title"] = "Version">
	
	<cfset vars["Title"] = "#local.Action# #local.Title#">
	
	<cfreturn vars>
</cffunction>

</cfcomponent>