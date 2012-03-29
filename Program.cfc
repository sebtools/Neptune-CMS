<cfcomponent output="false">
	
<cffunction name="config" access="public" returntype="void" output="no">
	<cfargument name="Config" type="any" required="yes">
	
	<cfset Config.paramSetting("CMS_CollectionName","#Application.ApplicationName#_CMS")>
	<cfset Config.paramSetting("isMenuManaged",false)>
	<cfif Framework.checkRefresh("CMS",URL.refresh)>
		<cffile action="read" file="#GetDirectoryFromPath(GetCurrentTemplatePath())#_config#Config.getSetting('dirdelim')#_template.cfm" variable="skeleton">
		<cfset Config.setSetting("skeleton",skeleton)>
	</cfif>
	
</cffunction>

<cffunction name="components" access="public" returntype="string" output="no">
	
	<cfset var result = "">
	
	<cfsavecontent variable="result"><cfoutput><?xml version="1.0"?>
	<program name="CMS" description="I manage site content.">
		<components>
			<component name="ContentBlocks" path="com.sebtools.utils.ContentBlocks">
				<argument name="Manager" component="Manager" />
			</component>
			<component name="Settings" path="com.sebtools.utils.Settings">
				<argument name="Manager" component="Manager" />
			</component>
			<component name="CMS" path="[path_component]model.CMS">
				<argument name="Manager" />
				<argument name="RootPath" />
				<argument name="createDefaultSection" value="false" />
				<argument name="Settings" ifmissing="skiparg" />
			</component>
			<component name="SitePages" path="[path_component]model.SitePages">
				<argument name="Manager" />
				<argument name="CMS" />
			</component>
			<component name="CMS_Searcher" path="[path_component]model.Searcher">
				<argument name="CMS" />
				<argument name="Searcher" ifmissing="skipcomp" />
				<argument name="CollectionName" arg="CMS_CollectionName" />
				<argument name="Scheduler" ifmissing="skiparg" />
			</component>
		</components>
	</program>
	</cfoutput></cfsavecontent>
	
	<cfreturn result>
</cffunction>

<cffunction name="links" access="public" returntype="string" output="no">
	
	<cfset var result = "">
	
	<cfsavecontent variable="result"><?xml version="1.0"?>
	<program>
		<link label="Pages" url="page-list.cfm" />
		<link label="Sections" url="section-list.cfm" />
	</program>
	</cfsavecontent>
	
	<cfreturn result>
</cffunction>

</cfcomponent>