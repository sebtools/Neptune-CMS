<cfcomponent displayname="Content Files" extends="com.sebtools.Records" output="no">

<cffunction name="saveContentFile" access="public" returntype="numeric" output="no">
	<cfargument name="Label" type="string" required="yes">
	<cfargument name="PathBrowser" type="string" required="no">
	<cfargument name="PathFile" type="string" required="no">
	
	<cfif StructKeyExists(arguments,"PathBrowser") AND NOT StructKeyExists(arguments,"PathFile")>
		<cfset arguments.PathFile = arguments.PathBrowser>
		<cfif Left(arguments.PathFile,1) EQ "/">
			<cfset arguments.PathFile = Right(arguments.PathFile,Len(arguments.PathFile)-1)>
		</cfif>
		<cfset arguments.PathFile = ExpandPath(arguments.PathFile)>
	</cfif>
	
	<cfreturn saveRecord(argumentCollection=arguments)>
</cffunction>

</cfcomponent>