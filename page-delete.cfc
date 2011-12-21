<cfcomponent extends="_config.PageController" output="no">

<cfset loadExternalVars(varlist="CMS,SitePages,MissingPages",skipmissing=true)>
<cfset setInherits(variables.CMS)>

<cffunction name="loadData" access="public" returntype="struct" output="no">
	
	<cfset var local = StructNew()>
	<cfset var vars = StructNew()>
	
	<cfset param("URL.section","numeric",0)>
	<cfset param("URL.id","numeric",0)>
	
	<cfset vars.Title = "Page">
	<cfset vars.action = "Delete">
	<cfset vars.qPage = variables.CMS.getPage(PageID=URL.id)>
	<cfset vars["qPages"] = variables.SitePages.getPages()>
	
	<cfset vars.Title = "#vars.action# #vars.Title#">
	
	<cfreturn vars>
</cffunction>

<cffunction name="deletePage" access="public" returntype="void" output="no">
	
	<cfset var qPage = variables.CMS.getPage(PageID=arguments.PageID)>
	
	<cfif StructKeyExists(variables,"MissingPages")>
		<!--- 404 redirection --->
		<cfif Len(Trim(qPage.URLPath)) AND StructKeyExists(arguments,"LinkURL") AND Len(Trim(arguments.LinkURL))>
			<cfinvoke component="#variables.MissingPages#" method="saveMissingPage">
				<cfinvokeargument name="oldFile" value="#qPage.URLPath#">
				<cfinvokeargument name="newURL" value="#arguments.LinkURL#">
			</cfinvoke>
		</cfif>
	</cfif>
	
	<!--- Delete page --->
	<cfset variables.CMS.deletePage(arguments.PageID)>
	
</cffunction>

</cfcomponent>