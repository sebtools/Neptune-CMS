<cfcomponent extends="_config.PageController" output="no">

<cfset loadExternalVars("PageSections,Templates",".CMS")>

<cffunction name="loadData" access="public" returntype="struct" output="no">
	
	<cfset var local = StructNew()>
	<cfset var vars = StructNew()>
	
	<!--- Defaults for incoming variables --->
	<cfset param("URL.id","numeric",0)>
	<cfset param("URL.page","numeric",0)>
	<cfset param("URL.templatesection","numeric",0)>
	
	<!--- If no value for URL.id, try to determine it --->
	<cfif NOT URL.id>
		<cfif URL.page AND URL.templatesection>
			<cfset local.qPageTemplates = variables.PageSections.getPageSections(PageID=URL.page,TemplateSectionID=URL.templatesection)>
			<cfif local.qPageTemplates.RecordCount EQ 1>
				<cfset URL.id = local.qPageTemplates.PageSectionID>
			</cfif>
		<cfelse>
			<cfset go("page-list.cfm")>
		</cfif>
	</cfif>
	
	<!--- Defaults for local variables --->
	<cfset local["Action"] = "Edit">
	<cfset local["Title"] = "Page Section">
	
	<!--- Defaults for variables being returned from this method --->
	<cfset vars["Title"] = "#local.Action# #local.Title#">
	
	<cfreturn vars>
</cffunction>

</cfcomponent>