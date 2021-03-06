﻿ï»¿<cfcomponent extends="_config.PageController" output="no">

<cfset loadExternalVars(varlist="CMS,OrphanedLinks",skipmissing=true)>

<cffunction name="loadData" access="public" returntype="struct" output="no">
	<cfargument name="VariablesScope" type="struct" required="true">
	
	<cfset loc = StructNew()>
	<cfset vars = StructNew()>
	
	<cfset vars.TargetUrl = "">
	<cfset vars.RedirectUrl = "">
	<cfset vars.PageID = 0>
	
	<cfif StructKeyExists(VariablesScope,"TargetUrl")>
		<cfset vars.TargetUrl = VariablesScope.TargetUrl>
	<cfelseif StructKeyExists(Variables,"OrphanedLinks")>
		<cfset vars.TargetUrl = Variables.OrphanedLinks.getTargetURL(SCRIPT_NAME=CGI.SCRIPT_NAME,PATH_INFO=CGI.PATH_INFO,QUERY_STRING=CGI.QUERY_STRING,SERVER_NAME=CGI.SERVER_NAME)>
	<cfelse>
		<cfset vars.TargetUrl = getTargetURL(SCRIPT_NAME=CGI.SCRIPT_NAME,PATH_INFO=CGI.PATH_INFO,QUERY_STRING=CGI.QUERY_STRING,SERVER_NAME=CGI.SERVER_NAME)>
	</cfif>
	<cfif Right(vars.TargetUrl,1) EQ "/">
		<cfset vars.TargetUrl = "#vars.TargetUrl#index.cfm">
	</cfif>
	<cfset vars.Extension = ListLast(ListLast(ListFirst(vars.TargetUrl,"?"),"/"),".")>


	<cfif NOT ListFindNoCase("cfm,htm,html",vars.Extension)>
		<cfreturn vars>
	</cfif>
	
	<cfif StructKeyExists(Variables,"CMS")>
		<cfset vars.PageID = Variables.CMS.getPageID(vars.TargetURL)>
	</cfif>
	
	<cfif vars.PageID>
		<cfset vars.qPage = Application.CMS.Pages.getPage(PageID=vars.PageID,fieldlist="PageID,layout,SectionID,Title,Description,Keywords,Contents,IncludeFile")>
	<cfelseif StructKeyExists(Variables,"OrphanedLinks")>
		<cfset vars.RedirectUrl = Variables.OrphanedLinks.getNewURL(vars.TargetUrl)>
	</cfif>
	
	<cfreturn vars>
</cffunction>

<cffunction name="getTargetURL" access="public" returntype="string" output="no" hint="I get the Target URL for a 404 page with arguments matching CGI keys.">
	<cfargument name="SCRIPT_NAME" type="string" required="true">
	<cfargument name="PATH_INFO" type="string" required="true">
	<cfargument name="QUERY_STRING" type="string" required="true">
	<cfargument name="SERVER_NAME" type="string" required="true">
	
	<cfset var result = "">
	
	<cfif Arguments.PATH_INFO NEQ Arguments.SCRIPT_NAME>
		<cfset result = Arguments.PATH_INFO> 
	<cfelseif Len(Arguments.QUERY_STRING)>
		<cfset result = ReReplaceNoCase(Arguments.QUERY_STRING,"^(404;)?https?://#Arguments.SERVER_NAME#(:\d*)?","","ONE")>
	</cfif>
	
	<cfreturn result>
</cffunction>

</cfcomponent>