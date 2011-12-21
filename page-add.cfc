<cfcomponent extends="_config.PageController" output="no">

<cfset loadExternalVars("Pages,Sections,Links,Templates",".CMS")>

<cffunction name="loadData" access="public" returntype="struct" output="no">
	
	<cfset var vars = StructNew()>
	<cfset var local = StructNew()>
	
	<cfset param("URL.section","numeric",0)>
	<cfset param("URL.link","numeric",0)>
	<cfset param("URL.from","string","pages","pages,section")>
	
	<!--- Defaults for local variables --->
	<cfset local["Title"] = "Page">
	
	<!--- Defaults for variables being returned from this method --->
	<cfset vars["Action"] = "Add">
	<cfset vars["Title"] = "#vars.Action# #local.Title#">
	<cfset vars["qLink"] = 0>
	<cfset vars["PageTitle"] = "">
	<cfset vars["qSections"] = variables.Sections.getSections()>
	<cfset vars["qTemplates"] = variables.Templates.getTemplates()>
	
	<cfif URL.link>
		<cfset vars.qLink = variables.Links.getLink(URL.link)>
		<cfif vars.qLink.RecordCount>
			<cfset vars.PageTitle = vars.qLink.Label>
		</cfif>
	</cfif>
	
	<cfreturn vars>
</cffunction>

</cfcomponent>