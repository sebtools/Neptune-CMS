<cfcomponent extends="_framework.layout" hint="This just hold ready-to-use methods that you can copy into your own layout.cfc file.">

<cffunction name="switchLayout" access="public" returntype="layout" output="no">
	<cfargument name="layout" type="string" required="yes">
	
	<cfset var result = CreateObject("component",layout)>
	
	<cfset result.init(variables.CGI,variables.Factory)>
	
	<cfset result.setMe(variables.me)>
	<cfset this = result>
	
	<cfreturn result>
</cffunction>

<cffunction name="nav" access="public" returntype="void" output="yes">
	<cfset var qSections = Variables.Factory.CMS.Sections.getSections(fieldlist="SectionTitle,SectionLink,")>
	<div class="nav">
		<ul><cfoutput query="qSections">
			<li><a href="#SectionLink#">#SectionTitle#</a></li></cfoutput>
		</ul>
	</div>
</cffunction>

</cfcomponent>