<cfcomponent displayname="Templates" extends="com.sebtools.Records" output="no">

<cffunction name="getTemplate" access="public" returntype="query" output="no">
	<cfargument name="TemplateID" type="numeric" required="yes">
	
	<cfset var qTemplate = getRecord(argumentCollection=arguments)>
	<cfset var qTemplateSections = variables.CMS.TemplateSections.getTemplateSections()>
	<cfset var TemplateEdit = qTemplate.TemplateText>
	<cfset var aTemplateEdit = ArrayNew(1)>
	
	<cfloop query="qTemplateSections">
		<cfif FindNoCase("[#Marker#]",TemplateEdit)>
			<cfset TemplateEdit = ReplaceNoCase(TemplateEdit, "[#Marker#]", "<a href=""[page]?page=[id]&templatesection=#TemplateSectionID#"">Edit #Label#</a>", "ALL")>
		</cfif>
		<cfif FindNoCase("[#Label#]",TemplateEdit)>
			<cfset TemplateEdit = ReplaceNoCase(TemplateEdit, "[#Label#]", "<a href=""[page]?page=[id]&templatesection=#TemplateSectionID#"">Edit #Label#</a>", "ALL")>
		</cfif>
	</cfloop>
	
	<cfset ArrayAppend(aTemplateEdit,TemplateEdit)>
	
	<cfset QueryAddColumn(qTemplate, "TemplateEdit", aTemplateEdit)>
	
	<cfreturn qTemplate>
</cffunction>

</cfcomponent>