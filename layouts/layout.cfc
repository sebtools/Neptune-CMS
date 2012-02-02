<cfcomponent hint="This just hold ready-to-use methods that you can copy into your own layout.cfc file.">

<cffunction name="nav" access="public" returntype="void" output="yes">
	<cfset var qSections = Variables.Factory.CMS.Sections.getSections(fieldlist="SectionTitle,SectionLink,")>
	<div class="nav">
		<ul><cfoutput query="qSections">
			<li><a href="#SectionLink#">#SectionTitle#</a></li></cfoutput>
		</ul>
	</div>
</cffunction>

</cfcomponent>