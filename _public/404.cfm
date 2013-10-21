<cf_PageController>

<cfif PageID>
	<cf_layout setScriptName="#TargetURL#">
	<cfinclude template="/admin/cms/_config/_template.cfm">
	<cfabort>
<cfelseif Len(RedirectUrl)>
	<cfheader statuscode="301" statustext="Moved permanently">
	<cfheader name="Location" value="#RedirectUrl#">
	<cfabort>
</cfif>

<cf_Template title="#Application.ContentBlocks.getContentBlockText('Missing Page Title')#" showTitle="true">

<cfoutput>
#Application.ContentBlocks.getContentBlockHTML('Missing Page Text')#
</cfoutput>

</cf_Template>