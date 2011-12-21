<cfcomponent extends="_config.PageController" output="no">

<cfset loadExternalVars("Images,Pages",".CMS",true,1)>

<cffunction name="loadData" access="public" returntype="struct" output="no">
	
	<cfset var local = StructNew()>
	<cfset var vars = getDefaultVars("Page Image","edit")>
	
	<cfset param("URL.page","numeric",0)>
	
	<cfif URL.page>
		<cfset vars.forward = "page-edit.cfm?id=#URL.page#">
		<cfset vars.qPage = variables.Pages.getPage(URL.page)>
		<cfset vars.Title = "#vars.Title# for #vars.qPage.Title#">
	<cfelse>
		<cfset vars.forward = "image-list.cfm">
	</cfif>
	
	<cfset vars.ImageLabel = "Image/Photo">
	
	<cfreturn vars>
</cffunction>

</cfcomponent>