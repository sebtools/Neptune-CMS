<cfcomponent extends="_config.PageController" output="no">

<cfset loadExternalVars("CMS,Framework")>
<cfset loadExternalVars("Pages,Images,Templates","CMS")>
<cfset loadExternalVars(varlist="SiteSettings,WysiFilter,SessionMgr,Settings,ContentBlocks",skipmissing=true)>
<cfset setInherits(variables.CMS)>

<cffunction name="loadData" access="public" returntype="struct" output="no">
	
	<cfset var vars = getDefaultVars("Page","edit")>
	<cfset var local = StructNew()>
	
	<!--- Defaults for incoming variables --->
	<cfset require("URL.id","numeric","page-list.cfm")>
	<cfset param("URL.section","numeric",0)>
	<cfset param("URL.do","string","Edit","Add,Edit")>
	<cfset param("URL.from","string","pages","pages,section")>
	
	<!--- Defaults for local variables --->
	<cfset local["Title"] = "Page">
	
	<!--- Defaults for variables being returned from this method --->
	<cfset vars["Action"] = "Edit">
	<cfset vars["qPage"] = 0>
	<cfset vars["Title"] = "#vars.Action# #local.Title#">
	<cfset vars["sImages"] = StructNew()>
	<cfset vars["sBoxes"] = StructNew()>
	<cfset vars["sPageLinks"] = StructNew()>
	<cfset vars["qTemplate"] = 0>
	<cfset vars["qImages"] = 0>
	<cfset vars["qSiteSettings"] = 0>
	<cfset vars["qSettings"] = 0>
	<cfset vars["qContentFiles"] = variables.CMS.getContentFiles()>
	<cfset vars["ContentEdit"] = "">
	<cfset vars["isImageAddable"] = false>
	<cfset vars["hasImages"] = true>
	<cfset vars["hasTemplates"] = false>
	<cfset vars["aFormFilters"] = ArrayNew(1)>
	<cfset vars["qSections"] = variables.CMS.Sections.getSections()>
	<cfset vars.author = "">
	<cfset vars.forward = "page-list.cfm">
	<cfset vars.isLinkManager = variables.Framework.Config.getSetting("isMenuManaged")>
	
	<cfif StructKeyExists(Variables,"SessionMgr")>
		<cfif Variables.SessionMgr.exists("FullName")>
			<cfset vars.author = Variables.SessionMgr.getValue("FullName")>
		<cfelseif Variables.SessionMgr.exists("FirstName") AND Variables.SessionMgr.exists("LastName")>
			<cfset vars.author = Variables.SessionMgr.getValue("FirstName") & " " & Variables.SessionMgr.getValue("LastName")>
		</cfif>
	</cfif>
	
	<cfif URL.from EQ "section" AND URL.section>
		<cfset vars.forward = "section-edit.cfm?id=#URL.section#">
	<cfelse>
		<cfset vars.forward = "page-list.cfm?section=#URL.section#">
	</cfif>
	
	<cfset vars.forward = "#vars.forward#&done=#URL.do#">
	
	<!--- Load Site Settings if that component is running --->
	<cfif StructKeyExists(variables,"SiteSettings")>
		<cfset vars.qSiteSettings = variables.SiteSettings.getSettingRecords()>
	</cfif>
	
	<!--- Load Settings if that component is running (newer than "Site Settings") --->
	<cfif StructKeyExists(variables,"Settings")>
		<cfset vars.qSettings = variables.Settings.getSettings(fieldlist="SettingID,SettingName,SettingLabel")>
	</cfif>
	
	<!--- Load Site Settings if that component is running --->
	<cfif StructKeyExists(variables,"Templates")>
		<cfset vars.hasTemplates = variables.Templates.hasTemplates()>
	</cfif>
	
	<cfinvoke component="#variables.CMS#" method="getPage" returnvariable="vars.qPage">
		<cfinvokeargument name="PageID" value="#Val(url.id)#">
		<cfinvokeargument name="process" value="false">
	</cfinvoke>
	
	<cfif Len(vars.qPage.Title)>
		<cfset vars["Title"] = "#vars.Action# #vars.qPage.Title#">
	</cfif>
	
	<cfset vars.sImages["PageID"] = URL.id>
	<cfset vars.sBoxes["PageID"] = URL.id>
	<cfset vars.sPageLinks["PageID"] = URL.id>
	
	<!--- Get template information if one exists for this page. --->
	<cfif isNumeric(vars.qPage.TemplateID) AND StructKeyExists(variables,"Templates")>
		<cfset vars.qTemplate = variables.Templates.getTemplate(vars.qPage.TemplateID)>
		<cfif vars.qTemplate.NumTemplateSections>
			<cfset vars.hasImages = false>
		</cfif>
	</cfif>
	
	<cfif StructKeyExists(variables,"Images")>
		<cfset vars.qImages = variables.Images.getImages(argumentCollection=vars.sImages)>
		<cfif NOT vars.qImages.RecordCount OR ( isQuery(vars.qTemplate) AND vars.qTemplate.hasMultipleImages EQ 1 )>
			<cfset vars.isImageAddable = true>
		<cfelse>
			<cfset vars.isImageAddable = false>
		</cfif>
	</cfif>
	
	<cfif isQuery(vars.qTemplate) AND Len(vars.qTemplate.TemplateEdit)>
		<cfset vars.ContentEdit = vars.qTemplate.TemplateEdit>
		<cfset vars.ContentEdit = ReplaceNoCase(vars.ContentEdit, "[page]", "page-edit-section.cfm", "ALL")>
		<cfset vars.ContentEdit = ReplaceNoCase(vars.ContentEdit, "[id]", URL.id, "ALL")>
	</cfif>
	
	<!--- Add WysiFilter if it is running --->
	<cfif StructKeyExists(variables,"WysiFilter")>
		<cfset ArrayAppend(aFormFilters,variables.WysiFilter)>
	</cfif>
	
	<cfif isDefined("URL.do") AND URL["do"] EQ "add">
		<cfset vars.Action = "Add">
	</cfif>
	
	<cfreturn vars>
</cffunction>

</cfcomponent>