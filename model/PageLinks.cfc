<cfcomponent displayname="Page Links" extends="com.sebtools.Records" output="no">

<cffunction name="addPageLinks" access="public" returntype="string" output="false" hint="">
	<cfargument name="PageID" type="numeric" required="no">
	<cfargument name="LinkedPages" type="string" required="no">
	
	<cfset var qPageLinks = getPageLinks(arguments.PageID)>
	<cfset var LinkedPageID = 0>
	<cfset var PageLinks = ValueList(qPageLinks.LinkedPageID)>
	<cfset var PageLinkID = "">
	<cfset var NewPageLinks = "">
	
	<cfloop list="#arguments.LinkedPages#" index="LinkedPageID">
		<cfif NOT ListFindNoCase(PageLinks,LinkedPageID)>
			<cfset PageLinkID = savePageLink(PageID=arguments.PageID,LinkedPageID=LinkedPageID)>
			<cfset NewPageLinks = ListAppend(NewPageLinks,PageLinkID)>
		</cfif>
	</cfloop>
	
	<!--- Put new links first --->
	<cfif Len(ValueList(qPageLinks.PageLinkID)) AND Len(NewPageLinks)>
		<cfset sortPageLinks("#NewPageLinks#,#ValueList(qPageLinks.PageLinkID)#")>
	</cfif>
	
</cffunction>

<cffunction name="getPageLinks" access="public" returntype="query" output="no" hint="I return all of the Links.">
	<cfargument name="PageID" type="numeric" required="no">
	
	<cfset var qPageLinks = 0>
	
	<cfset arguments.isLive = true>
	
	<cfset qPageLinks = getRecords(argumentCollection=arguments)>
	
	<cfloop query="qPageLinks">
		<cfset QuerySetCell(qPageLinks, "UrlPath", variables.CMS.getUrlPath(Val(SectionID),FileName), CurrentRow)>
	</cfloop>
	
	<cfreturn qPageLinks>
</cffunction>

<cffunction name="getPageLinksHTML" access="public" returntype="string" output="no" hint="I return all of the Links.">
	<cfargument name="PageID" type="numeric" required="yes">
	
	<cfset var qPageLinks = getPageLinks(arguments.PageID)>
	<cfset var result = "">
	<cfset var LinkHTML = "">
	
	<cfoutput query="qPageLinks">
		<cfsavecontent variable="LinkHTML"><p><a href="#UrlPath#">#Title#</a><br />#Description#</p></cfsavecontent>
		<cfset result = result & LinkHTML>
	</cfoutput>
	
	<cfreturn result>
</cffunction>

<cffunction name="removePageLinks" access="public" returntype="void" output="false" hint="">
	<cfargument name="PageID" type="any" required="yes">
	
	<cfset var sLinks = StructNew()>
	<cfset sLinks["LinkedPageID"] = arguments.PageID>
	
	<cfset variables.DataMgr.deleteRecords(variables.table,arguments)>
	<cfset variables.DataMgr.deleteRecords(variables.table,sLinks)>
	
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