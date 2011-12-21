<cfcomponent displayname="Links" extends="com.sebtools.Records" output="no">

<cffunction name="addLink" access="public" returntype="string" output="no" hint="I save one Link.">
	<cfargument name="LinkURL" type="string" required="yes">
	<cfargument name="Label" type="string" required="yes">
	<cfargument name="SectionID" type="numeric" required="no">
	
	<cfset var qLinks = getLinks(LinkURL=arguments.LinkURL,fieldlist="LinkID")>
	
	<cfif qLinks.RecordCount>
		<cfoutput query="qLinks">
			<cfinvoke method="saveLink">
				<cfinvokeargument name="LinkID" value="#LinkID#">
				<cfinvokeargument name="Label" value="#arguments.Label#">
				<cfif StructKeyExists(arguments,"SectionID")>
					<cfinvokeargument name="SectionID" value="#arguments.SectionID#">
				</cfif>
			</cfinvoke>
		</cfoutput>
	<cfelse>
		<cfinvoke method="saveLink">
			<cfinvokeargument name="Label" value="#arguments.Label#">
			<cfinvokeargument name="LinkURL" value="#arguments.LinkURL#">
			<cfif StructKeyExists(arguments,"SectionID")>
				<cfinvokeargument name="SectionID" value="#arguments.SectionID#">
			</cfif>
		</cfinvoke>
	</cfif>
	
</cffunction>

<cffunction name="getLinksCount" access="public" returntype="any" output="false" hint="">
	<cfreturn numLinks(argumentCollection=arguments)>
</cffunction>

<cffunction name="getPageID" access="public" returntype="any" output="false" hint="">
	<cfargument name="LinkID" type="numeric" required="yes">
	
	<cfset var qLink = getLink(arguments.LinkID)>
	<cfset var qPages = 0>
	<cfset var result = 0>
	
	<cfif qLink.RecordCount AND Len(qLink.LinkURL)>
		
		<cfset qPages = variables.CMS.Pages.getPages(FileName=ListLast(qLink.LinkURL,"/"))>
		
		<cfquery name="qPages" dbtype="query">
		SELECT	PageID
		FROM	qPages
		WHERE	UrlPath = '#qLink.LinkURL#'
		</cfquery>
		
		<cfif qPages.RecordCount EQ 1>
			<cfset result = qPages.PageID>
		</cfif>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="removeLinkURL" access="public" returntype="any" output="false" hint="">
	<cfargument name="LinkURL" type="any" required="yes">
	
	<cfset variables.DataMgr.deleteRecords(variables.table,arguments)>
	
</cffunction>

<cffunction name="updateLinkURL" access="public" returntype="any" output="false" hint="">
	<cfargument name="LinkURLFrom" type="string" required="yes">
	<cfargument name="LinkURLTo" type="string" required="yes">
	
	<cfset var sDataSet = StructNew()>
	<cfset var sDataWhere = StructNew()>
	
	<cfset sDataSet["LinkURL"] = arguments.LinkURLTo>
	<cfset sDataWhere["LinkURL"] = arguments.LinkURLFrom>
	
	<cfset variables.DataMgr.updateRecords(tablename=variables.table,data_set=sDataSet,data_where=sDataWhere)>
	
</cffunction>

</cfcomponent>