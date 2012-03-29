<cfcomponent displayname="CMS Searcher">

<cffunction name="init" access="public" returntype="any" output="no" hint="I initialize and return this object.">
	<cfargument name="CMS" type="any" required="yes"/>
	<cfargument name="Searcher" type="any" required="yes"/>
	<cfargument name="CollectionName" type="string" required="yes"/>
	<cfargument name="Scheduler" type="any" required="no">
	
	<cfscript>
	variables.CMS = arguments.CMS;
	variables.Searcher = arguments.Searcher;
	variables.CollectionName = arguments.CollectionName;
	if ( StructKeyExists(arguments,"Scheduler") ) {
		variables.Scheduler = arguments.Scheduler;
	}
	
	//Just defaulting to indicate that no index is pending
	variables.isIndexPending = false;
	
	//Make sure CMS has an instance of this Searcher
	variables.CMS.setSearcher(this);
	
	//Make sure collection is created and indexed
	create();
	index();
	</cfscript>
	
	<cfreturn this>
</cffunction>

<cffunction name="create" access="public" returntype="void" output="no" hint="I create the CMS Search collection if doesn't already exist.">

	<cfset variables.Searcher.create(variables.CollectionName)>
	<cfset variables.Searcher.addCollection(variables.CollectionName)>

</cffunction>

<cffunction name="getCollectionName" access="public" returntype="string" output="no">
	<cfreturn variables.CollectionName>
</cffunction>

<cffunction name="index" access="public" returntype="void" output="no" hint="I index the CMS Search collection.">

	<cfset var qPages = variables.CMS.getAllPages(isLive=1,fieldlist="PageID,Title,Description,Contents,Contents2,UrlPath,FileName,SectionID")>
	
	<cfinvoke component="#variables.Searcher#" method="indexQuery">
		<cfinvokeargument name="CollectionName" value="#variables.CollectionName#">
		<cfinvokeargument name="query" value="#qPages#">
		<cfinvokeargument name="Key" value="PageID">
		<cfinvokeargument name="Title" value="Title">
		<cfinvokeargument name="Body" value="Description,Contents,Contents2">
		<cfinvokeargument name="URLPath" value="UrlPath">
	</cfinvoke>

</cffunction>

<cffunction name="runScheduledIndex" access="public" returntype="void" output="false" hint="">
	
	<cfif variables.isIndexPending>
		<cfset variables.isIndexPending = false>
		<cflock timeout="120" throwontimeout="yes" name="Searcher_IndexQuery_#variables.CollectionName#" type="EXCLUSIVE">
			<cfset index()>
		</cflock>
	</cfif>
	
</cffunction>

<cffunction name="scheduleIndex" access="public" returntype="void" output="false" hint="">
	
	<cfset var IndexHour = 1>
	
	<cfif Hour(now()) EQ IndexHour>
		<cfset IndexHour = (IndexHour + 2) MOD 24>
	</cfif>
	
	<cfif StructKeyExists(variables,"Scheduler")>
		<cfif NOT variables.isIndexPending>
			<cfinvoke component="#variables.Scheduler#" method="setTask">
				<cfinvokeargument name="Name" value="runScheduledIndex">
				<cfinvokeargument name="ComponentPath" value="admin.cms.Searcher">
				<cfinvokeargument name="Component" value="#this#">
				<cfinvokeargument name="MethodName" value="runScheduledIndex">
				<cfinvokeargument name="Interval" value="once">
				<cfinvokeargument name="hours" value="#IndexHour#">
			</cfinvoke>
		</cfif>
		<cfset variables.isIndexPending = true>
	<cfelse>
		<cfset variables.isIndexPending = true>
		<cfset runScheduledIndex()>
	</cfif>
	
</cffunction>

</cfcomponent>