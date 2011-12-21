<cfparam name="URL.id" default="0">
<cfset qPage = Application.CMS.getPage(Val(URL.id))>
<cfif qPage.RecordCount AND Len(qPage.URLPath)>
	<cflocation url="#qPage.URLPath#" addtoken="no">
<cfelse>
	<p>Page Not Found</p>
</cfif>