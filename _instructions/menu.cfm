By default, the CMS does not manage menus on the site.
It is easy, however, to have it do so.

First, edit the code in your layouts to get menu information from the CMS.

Add the following immediately after the "cffunction" tag with a name of "body":
<cfset var qSections = variables.Factory.CMS.getPublicSections()>
<cfset var CurrentSectionID = variables.Factory.CMS.getSectionIDFromDir(ListFirst(variables.SCRIPT_NAME,"/"))>
<cfset var qLinks = variables.Factory.CMS.getLinks(CurrentSectionID)>

To output your sections, use code similar to the following (your HTML may vary):
<cfoutput query="qSections">
	<li><a href="#SectionLink#"<cfif SectionID EQ CurrentSectionID> id="active"</cfif>>#SectionTitle#</a></li>
</cfoutput>

Then, use code similar to the following to output your menu HTML (not your code may vary):
<cfoutput query="qLinks">
	<li><a href="#LinkURL#"<cfif variables.SCRIPT_NAME EQ LinkURL> id="active"</cfif>>#Label#</a></li>
</cfoutput>

The important thing to not here is your are surrounding the code for each link with a <cfoutput />
block that uses the query of links for the current section.

Then add the following line inside the cfscript block in /_config/config.cfm:
setSetting("isMenuManaged",true);