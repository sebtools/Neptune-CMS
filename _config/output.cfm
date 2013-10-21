<cf_layout title="#qPage.Title#"><cfif Len(qPage.Description)>
	<cfoutput><meta name="Description" content="#qPage.Description#" /></cfoutput></cfif><cfif Len(qPage.Keywords)>
	<cfoutput><meta name="Keywords" content="#qPage.Keywords#" /></cfoutput></cfif>
<cf_layout>

<cfoutput query="qPage">

<cfif Len(ImageFileName)>
	<div><img src="#Application.FileMgr.getFileURL(ImageFileName,'page-images')#" alt="" /></div>
</cfif>

<h1>#Trim(XmlFormat(Title))#</h1>

#Trim(Application.SiteSettings.populate(Contents))#

<!--- #editLink("/admin/content/pages/page-edit.cfm?id=#PageID#")# --->
</cfoutput>

<cf_layout>