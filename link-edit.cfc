<cfcomponent extends="_config.PageController" output="no">

<cfset loadExternalVars("SitePages")>
<cfset loadExternalVars("Links,Sections",".CMS",true,1)>

<cffunction name="loadData" access="public" returntype="struct" output="no">
	
	<cfset var local = StructNew()>
	<cfset var vars = getDefaultVars("Link","edit")>
	
	<cfset param("URL.id","numeric",0)>
	<cfset param("URL.section","numeric",0)>
	
	<cfset vars["qPages"] = getSitePages()><!--- To add non-CMS page to list: <cfset Application.SitePages.addPage("Page Title",CGI.SCRIPT_NAME)> --->
	<cfset vars["qSections"] = variables.Sections.getSections()>
	<cfset vars["qSection"] = 0>
	<cfset vars["Action"] = "">
	<cfset vars["forward"] = "link-list.cfm">
	<cfset vars["PageID"] = variables.Links.getPageID(URL.id)>
	
	<cfif URL.section>
		<cfset vars.qSection = variables.Sections.getSection(URL.section)>
		<cfset vars.Title = "#vars.Title# in #vars.qSection.SectionTitle#">
		<cfset vars.forward = "link-list.cfm?section=#URL.section#">
	<cfelseif vars.qSections.RecordCount>
		<cfset vars.forward = "section-list.cfm">
	</cfif>
	
	<!--- sebForm settings --->
	<cfscript>
	vars.sebFormAttributes.CFC_Component = This;
	vars.sebFormAttributes.forward = "#vars.forward#";
	</cfscript>
	
	<cfreturn vars>
</cffunction>

<cffunction name="getSitePages" access="remote" returntype="query" output="false" hint="">
	<cfif StructKeyExists(arguments,"SectionID") AND NOT ( isNumeric(arguments.SectionID) AND arguments.SectionID GT 0 )>
		<cfset StructDelete(arguments,"SectionID")>
	</cfif>
	<cfreturn variables.SitePages.getPages(argumentCollection=arguments)>
</cffunction>

<cffunction name="saveLink" access="public" returntype="any" output="false">
	
	<cfset var result = 0>
	
	<cfset result = variables.Links.saveLink(argumentCollection=arguments)>
	
	<!--- If no LinkURL, send to create page --->
	<cfif NOT Len(arguments.LinkURL)>
		<cfset go("page-add.cfm?section=#arguments.SectionID#&link=#result#")>
	</cfif>
	
	<cfreturn result>
</cffunction>

</cfcomponent>