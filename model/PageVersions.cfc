<cfcomponent displayname="Page Versions" extends="com.sebtools.Records" output="no">

<cffunction name="getPageVersions" access="public" returntype="query" output="no" hint="I return every version (archived and current) for the given page.">
	<cfargument name="PageID" type="numeric" required="yes">
	<cfargument name="SiteVersionID" type="numeric">
	
	<cfset var qVersions = getRecords(argumentCollection=arguments)>
	
	<cfif qVersions.RecordCount AND Not Len(qVersions.VersionDescription[1])>
		<cfset QuerySetCell(qVersions, "VersionDescription", "(original)", 1)>
	</cfif>
	
	<cfreturn qVersions>
</cffunction>

<cffunction name="restoreVersion" access="public" returntype="any" output="no" hint="I restore an old version of a page.">
	<cfargument name="PageID" type="numeric" required="yes" hint="The PageID of the page being restored.">
	<cfargument name="PageVersionID" type="numeric" required="yes" hint="The PageVersion ID of the version being restored.">
	<cfargument name="SiteVersionID" type="numeric" required="no" hint="The Site Version for this page. Use as default if left blank.">
	
	<cfset Variables.CMS.restoreVersion(argumentCollection=arguments)>
	
</cffunction>

</cfcomponent>