<!--- Go to "Content" under the administration section in order to edit this page --->
<!--- nosearchy --->
<cfif Len(qPage.Layout)>
	<cftry>
		<cf_layout switch="#qPage.Layout#">
	<cfcatch>
	</cfcatch>
	</cftry>
</cfif>

<cf_Template title="#qPage.Title#" meta_description="#qPage.Description#" meta_keywords="#qPage.Keywords#" showTitle="false">

<cfoutput query="qPage">

<h1>#Trim(HTMLEditFormat(Title))#</h1>

<cfif StructKeyExists(Application,"SiteSettings")>#Trim(Application.SiteSettings.populate(Application.CMS.adjustContent(Contents)))#<cfelse>#Application.CMS.adjustContent(Contents)#</cfif>

<!--- #editLink("/admin/content/pages/page-edit.cfm?id=#PageID#")# --->
<cfif Len(IncludeFile)><cfinclude template="#IncludeFile#"></cfif>
</cfoutput>

</cf_Template>