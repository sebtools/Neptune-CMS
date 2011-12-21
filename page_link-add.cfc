<cfcomponent extends="_config.PageController" output="no">

<cfset loadExternalVars("CMS")>

<cffunction name="loadData" access="public" returntype="struct" output="no">
	
	<!--- local variables: local for internal data, vars will be returned as variables scope on the page --->
	<cfset var local = StructNew()>
	<cfset var vars = StructNew()>
	
	<!--- Param URL variables --->
	<cfset param("URL.id","numeric",0)>
	<cfset require("URL.page","numeric",0)>
	
	<!--- Set default values for vars variables --->
	<cfset vars["Title"] = "Page Links">
	<cfset vars["Action"] = "Add">
	<cfset vars["qPages"] = variables.CMS.Pages.getPages()>
	<cfset vars["qPageLinks"] = variables.CMS.PageLinks.getPageLinks(url.page)>
	<cfset vars["PageLinks"] = ValueList(vars.qPageLinks.LinkedPageID)>
	
	<cfscript>
	vars.sebFormAttributes = StructNew();
	if ( StructKeyExists(Form,"sebForm_Forward") ) {
		local.forward = Form.sebForm_Forward;
	} else {
		local.forward = CGI.HTTP_REFERER;
	}
	if ( NOT FindNoCase("##",local.forward) ) {
		local.forward = "#local.forward###sebTable";
	}
	vars.sebFormAttributes.forward = local.forward;
	</cfscript>
	
	<cfset vars.Title = "#vars.Action# #vars.Title#">
	
	<cfreturn vars>
</cffunction>

</cfcomponent>