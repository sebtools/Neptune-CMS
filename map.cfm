<cfset qSiteMap = Application.CMS.getSiteMap()>

<cf_layout title="Site Content">
<cf_layout showTitle="true">

<p><a href="section-list.cfm">Manage Sections/Menu</a></p>
<p><a href="page-list.cfm">Manage Pages</a></p>

<cfdump var="#Application.CMS.getSiteMap()#">

<!---<cfoutput query="qSiteMap" group="SectionID">--->

<cf_layout>