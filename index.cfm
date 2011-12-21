<cfif Application.CMS.Sections.hasSections()>
	<cfinclude template="section-list.cfm">
<cfelse>
	<cfinclude template="page-list.cfm">
</cfif>