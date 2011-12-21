<cfset qSitemap = Application.SitePages.getSiteMap()>

<cf_Template title="Sitemap" showTitle="true">

<cfoutput query="qSitemap" group="SectionID">
	<h2>#SectionTitle#</h2>
	<ul>
	<cfoutput>
		<li><a href="#LinkURL#">#Title#</a></li>
	</cfoutput>
	</ul>
</cfoutput>

</cf_Template>