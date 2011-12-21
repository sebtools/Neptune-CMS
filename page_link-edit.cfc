<cfcomponent extends="_config.PageController" output="no">

<cfset loadExternalVars("PageLinks",".CMS",true,1)>

<cffunction name="loadData" access="public" returntype="struct" output="no">
	
	<!--- local variables: local for internal data, vars will be returned as variables scope on the page --->
	<cfset var local = StructNew()>
	<cfset var vars = getDefaultVars("Page Link","edit")>
	
	<!--- Param URL variables --->
	<cfset param("URL.page","numeric",0)>
	
	<cfreturn vars>
</cffunction>

</cfcomponent>