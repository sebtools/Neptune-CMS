<cfcomponent extends="_config.PageController">

<cffunction name="loadData" access="public" output="no">
	<cfset var vars = Super.loadData()>
	
	<cfreturn vars>
</cffunction>

</cfcomponent>