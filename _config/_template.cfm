<!--- Go to "Content" under the administration section in order to edit this page --->
<!-- nosearchy -->
<cfif Len(qPage.Layout)>
	<cftry>
		<cf_layout switch="#qPage.Layout#">
	<cfcatch>
	</cfcatch>
	</cftry>
</cfif>

<cf_layout title="#qPage.Title#"><cfif Len(qPage.Description)>
	<cfoutput><meta name="Description" content="#qPage.Description#" /></cfoutput></cfif><cfif Len(qPage.Keywords)>
	<cfoutput><meta name="Keywords" content="#qPage.Keywords#" /></cfoutput></cfif>
<cf_layout>

<cfoutput query="qPage">

<cfif Len(ImageFileName)>
	<div><img src="/f/page-images/#ImageFileName#" alt="" /></div>
</cfif>

<h1>#Trim(HTMLEditFormat(Title))#</h1>

<cfif StructKeyExists(Application,"SiteSettings")>#Trim(Application.SiteSettings.populate(Application.CMS.adjustContent(Contents)))#<cfelse>#Contents#</cfif>

<!--- #editLink("/admin/content/pages/page-edit.cfm?id=#PageID#")# --->
<cfif Len(IncludeFile)><cfinclude template="#IncludeFile#"></cfif>
</cfoutput>

<cf_layout>