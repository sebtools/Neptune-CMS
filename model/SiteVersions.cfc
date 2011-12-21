<cfcomponent displayname="Site Versions" extends="com.sebtools.Records" output="no">

<cffunction name="saveSiteVersion" access="public" returntype="numeric" output="no" hint="I create/update a site version and return the SiteVersionID. A version of a site could represent a language or other variations of the same site.">
	<cfargument name="SiteVersionID" type="numeric" hint="New site version created if not passed in.">
	<cfargument name="SiteName" type="string" required="yes">
	<cfargument name="DomainRoot" type="string">
	<cfargument name="isDefault" type="boolean">
	
	<cfset var result = 0>
	<cfset var sDataSet = 0>

	<!--- If this site version is the default, set all site versions as not default (this one will then be set as default later in this method) --->
	<cfif StructKeyExists(arguments,"isDefault") AND arguments.isDefault>
		<cfset sDataSet = StructNew()>
		<cfset sDataSet["isDefault"] = 0>
		<cfset variables.DataMgr.updateRecords(tablename=variables.table,data_set=sDataSet)>
	</cfif>
	
	<cfset result = saveRecord(argumentCollection=arguments)>
	
	<cfreturn result>
</cffunction>

</cfcomponent>