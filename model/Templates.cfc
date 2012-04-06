<cfcomponent displayname="Templates" extends="com.sebtools.Records" output="no">

<cffunction name="getDefaultTemplateID" access="public" returntype="numeric" output="no">
	
	<cfset var result = 0>
	<cfset var qTemplates = getTemplates(isDefaultTemplate=true,fieldlist="TemplateID")>
	
	<cfif qTemplates.RecordCount>
		<cfset result = qTemplates.TemplateID>
	</cfif>
	
	<cfreturn result>
</cffunction>

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

<cffunction name="setDefaultTemplate" access="public" returntype="any" output="no">
	
	<cfif StructKeyExists(Arguments,"isDefaultTemplate") AND isNumeric(Arguments.isDefaultTemplate) AND hasTemplates(TemplateID=Arguments.isDefaultTemplate)>
		
		<cfquery datasource="#Variables.DataMgr.getDatasource()#">
		UPDATE	#Variables.table#
		SET		isDefaultTemplate = #Variables.DataMgr.getBooleanSQLValue(false)#
		</cfquery>
		
		<cfset saveTemplate(TemplateID=Arguments.isActive,isDefaultTemplate=true)>
	</cfif>
	
</cffunction>

</cfcomponent>