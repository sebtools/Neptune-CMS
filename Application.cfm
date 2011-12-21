<cfsilent>
<cfinclude template="../Application.cfm">

<!--- <cfset Author = Application.SessionMgr.getValue("FullName")> --->
<cfset Author = "">

<!--- <cfif NOT application.security.checkUserAllowed("Pages")>
	<cflocation url="/admin/login.cfm">
</cfif> --->

<!---
To add non-CMS page to list:
<cfset Application.SitePages.addPage("Page Title",CGI.SCRIPT_NAME)>
--->
</cfsilent>