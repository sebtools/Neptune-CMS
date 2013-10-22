<cfcomponent extends="com.sebtools.Records" displayname="Site Pages">

<cffunction name="init" access="public" returntype="any" output="no">
	<cfargument name="Manager" type="any" required="yes">
	<cfargument name="CMS" type="any" required="no">

	<cfset initInternal(ArgumentCollection=Arguments)>

	<cfset variables.Components = StructNew()>

	<cfif StructKeyExists(Arguments,"CMS")>
		<cfinvoke method="setComponent">
			<cfinvokeargument name="Name" value="CMS">
			<cfinvokeargument name="Component" value="#Arguments.CMS#">
			<cfinvokeargument name="MethodName" value="getLivePages">
			<cfinvokeargument name="LinkURL" value="UrlPath">
			<cfinvokeargument name="Title" value="Title">
			<cfinvokeargument name="SectionID" value="SectionID">
		</cfinvoke>
	</cfif>

	<cfset removeMissingPages()>

	<cfreturn This>
</cffunction>

<cffunction name="addPage" access="public" returntype="numeric" output="no">
	<cfargument name="Title" type="string" required="yes">
	<cfargument name="ScriptName" type="string" required="yes">
	<cfargument name="Section" type="string" required="no">

	<cfset var sPage = StructNew()>

	<!--- Insert a page record for this URL --->
	<cfset sPage["ScriptName"] = Arguments.ScriptName>
	<cfset sPage["PageID"] = Variables.DataMgr.insertRecord(variables.table,arguments,"skip")>

	<!--- Update page title and (optionally) section --->
	<cfset sPage["Title"] = Arguments.Title>

	<!--- Set section if it is passed in --->
	<cfif StructKeyExists(Arguments,"Section")>
		<!--- Use numeric section or get section from section name --->
		<cfif isNumeric(Arguments.Section)>
			<cfset sPage["SectionID"] = Arguments.Section>
		<cfelseif StructKeyExists(variables,"CMS")>
			<cfset sPage["SectionID"] = Variables.CMS.Sections.getSectionID(SectionTitle=Arguments.Section,isSectionLive=1)>
		</cfif>
		<cfif StructKeyExists(sPage,"SectionID") AND NOT( isNumeric(sPage["SectionID"]) AND sPage["SectionID"] )>
			<cfset StructDelete(sPage,"SectionID")>
		</cfif>
	</cfif>

	<!--- Update page title and (optionally) section --->
	<cfset variables.DataMgr.updateRecord(variables.table,sPage)>

	<cfreturn sPage["PageID"]>
</cffunction>

<cffunction name="getComponents" access="public" returntype="struct" output="no">

	<cfreturn variables.Components>
</cffunction>

<cffunction name="getPage" access="public" returntype="query" output="no">
	<cfargument name="PageID" type="numeric" required="yes">

	<cfreturn getRecord(ArgumentCollection=Arguments)>
</cffunction>

<cffunction name="getPages" access="public" returntype="query" output="no">

	<cfset var qPages = 0>
	<cfset var qSitePages = getRecords(ArgumentCollection=Arguments)>
	<cfset var sPageQueries = StructNew()>
	<cfset var CompName = "">

	<cfloop collection="#variables.Components#" item="CompName">
		<cfinvoke returnvariable="sPageQueries.#CompName#" method="getRemotePages">
			<cfinvokeargument name="CompName" value="#CompName#">
			<cfinvokeargument name="args" value="#Arguments#">
		</cfinvoke>
	</cfloop>

	<cfquery name="qPages" dbtype="query">
	SELECT		ScriptName AS LinkURL, Title, SectionID
	FROM		qSitePages
	<cfloop collection="#variables.Components#" item="CompName"><cfif sPageQueries[CompName].RecordCount>
	UNION
	SELECT		LinkURL, Title, SectionID
	FROM		sPageQueries.#CompName#
	</cfif></cfloop>
	ORDER BY	Title
	</cfquery>
	
	<cfif StructCount(Arguments)>
		<cfquery name="qPages" dbtype="query">
		SELECT		*
		FROM		qPages
		WHERE		1 = 1
		<cfif StructKeyExists(Arguments,"LinkURL") AND isSimpleValue(Arguments.LinkURL) AND Len(Arguments.LinkURL)>
			AND		LinkURL = <cfqueryparam value="#Arguments.LinkURL#" cfsqltype="CF_SQL_VARCHAR">
		</cfif>
		<cfif StructKeyExists(Arguments,"PageURL") AND isSimpleValue(Arguments.PageURL) AND Len(Arguments.PageURL)>
			AND		LinkURL = <cfqueryparam value="#Arguments.PageURL#" cfsqltype="CF_SQL_VARCHAR">
		</cfif>
		<cfif StructKeyExists(Arguments,"PageFile") AND isSimpleValue(Arguments.PageFile) AND Len(Arguments.PageFile)>
			AND		LinkURL LIKE <cfqueryparam value="%/#ListLast(Arguments.PageFile,'/')#" cfsqltype="CF_SQL_VARCHAR">
		</cfif>
		<cfif StructKeyExists(Arguments,"LinkLike") AND isSimpleValue(Arguments.LinkLike) AND Len(Arguments.LinkLike)>
			AND		LinkURL LIKE <cfqueryparam value="%#Arguments.LinkLike#%" cfsqltype="CF_SQL_VARCHAR">
		</cfif>
		<cfif StructKeyExists(Arguments,"SectionID") AND isSimpleValue(Arguments.SectionID) AND Val(Arguments.SectionID)>
			AND		SectionID = <cfqueryparam value="#Arguments.SectionID#" cfsqltype="CF_SQL_INTEGER">
		</cfif>
		<cfif StructKeyExists(Arguments,"Title") AND isSimpleValue(Arguments.Title) AND Len(Arguments.Title)>
			AND		Title LIKE <cfqueryparam value="%#Arguments.Title#%" cfsqltype="CF_SQL_VARCHAR">
		</cfif>
		ORDER BY	Title
		</cfquery>
	</cfif>

	<cfreturn qPages>
</cffunction>

<cffunction name="getRemotePages" access="public" returntype="query" output="no">
	<cfargument name="CompName" type="string" required="no">
	<cfargument name="args" type="struct" default="#StructNew()#">

	<cfset var comp = variables.Components[arguments.CompName]>
	<cfset var qRawPages = 0>
	<cfset var qPages =  QueryNew("LinkURL,Title,SectionID")>
	<cfset var col = "">
	<cfset var temp = "">

	<cfinvoke returnvariable="qRawPages" component="#comp.Component#" method="#comp.MethodName#" argumentcollection="#arguments.args#"></cfinvoke>

	<cfoutput query="qRawPages">
		<cfset QueryAddRow(qPages)>

		<!--- Set LinkURL --->
		<cfif ListFindNoCase(qRawPages.ColumnList, comp.LinkURL)>
			<cfset temp = qRawPages[comp.LinkURL][CurrentRow]>
		<cfelse>
			<cfset temp = comp.LinkURL>
			<cfloop index="col" list="#qRawPages.ColumnList#">
				<cfif FindNoCase("[#col#]", temp)>
					<cfset temp = ReplaceNoCase(temp, "[#col#]", qRawPages[col][CurrentRow], "ALL")>
				</cfif>
			</cfloop>
		</cfif>
		<cfset QuerySetCell(qPages, "LinkURL", temp)>

		<!--- Set Title --->
		<cfif ListFindNoCase(qRawPages.ColumnList, comp.Title)>
			<cfset temp = qRawPages[comp.Title][CurrentRow]>
		<cfelse>
			<cfset temp = comp.LinkURL>
			<cfloop index="col" list="#qRawPages.ColumnList#">
				<cfif FindNoCase("[#col#]", temp)>
					<cfset temp = ReplaceNoCase(temp, "[#col#]", qRawPages[col][CurrentRow], "ALL")>
				</cfif>
			</cfloop>
		</cfif>
		<cfset QuerySetCell(qPages, "Title", temp)>

		<!--- Set SectionID --->
		<cfif ListFindNoCase(qRawPages.ColumnList, comp.SectionID)>
			<cfset temp = qRawPages[comp.SectionID][CurrentRow]>
		<cfelse>
			<cfset temp = comp.SectionID>
			<cfloop index="col" list="#qRawPages.ColumnList#">
				<cfif FindNoCase("[#col#]", temp)>
					<cfset temp = ReplaceNoCase(temp, "[#col#]", qRawPages[col][CurrentRow], "ALL")>
				</cfif>
			</cfloop>
		</cfif>
		<cfset QuerySetCell(qPages, "SectionID", temp)>
	</cfoutput>

	<cfreturn qPages>
</cffunction>

<cffunction name="getSiteMap" access="public" returntype="any" output="false" hint="">

	<cfset var qPages = getPages()>
	<cfset var qSections = variables.CMS.getSections(fieldlist="SectionID,SectionTitle")>
	<cfset var qSiteMap = 0>
	
	<cfquery name="qSiteMap" dbtype="query">
	SELECT		CAST(qPages.SectionID AS BIGINT) AS SectionID,
				qPages.LinkURL,
				qPages.Title,
				qSections.SectionTitle
	FROM		qPages,	qSections
	WHERE		CAST(qPages.SectionID AS BIGINT) = CAST(qSections.SectionID AS BIGINT)
	UNION		
	SELECT		0 AS SectionID,qPages.LinkURL,qPages.Title,'' AS SectionTitle
	FROM		qPages
	WHERE		CAST(qPages.SectionID AS BIGINT) = CAST(0 AS BIGINT)
	</cfquery>

	<cfreturn qSiteMap>
</cffunction>

<cffunction name="removeMissingPages" access="public" returntype="void" output="false" hint="">

	<cfset var qPages = getRecords(fieldlist="PageID,ScriptName")>

	<cfloop query="qPages">
		<cfif Left(ScriptName,1) EQ "/" AND NOT FileExists(ExpandPath(ScriptName))>
			<cfset removePage(PageID)>
		</cfif>
	</cfloop>

</cffunction>

<cffunction name="savePage" access="public" returntype="numeric" output="no">
	<cfargument name="PageID" type="string" required="no">
	<cfargument name="Title" type="string" required="no">
	<cfargument name="ScriptName" type="string" required="no">

	<cfreturn saveRecord(ArgumentCollection=Arguments)>
</cffunction>

<cffunction name="setComponent" access="public" returntype="void" output="no">
	<cfargument name="Name" type="string" required="yes">
	<cfargument name="Component" type="any" required="yes">
	<cfargument name="MethodName" type="string" required="yes">
	<cfargument name="LinkURL" type="string" required="yes">
	<cfargument name="Title" type="string" required="yes">

	<cfset variables.Components[arguments.Name] = arguments>

</cffunction>

<cffunction name="xml" access="public" output="yes">
<tables prefix="site">
	<table entity="Page">
		<field name="SectionID" type="integer" />
		<field name="Title" type="text" Length="50" />
		<field name="ScriptName" type="text" Length="150" />
		<field name="DateEntered" type="date" Special="CreationDate" />
		<field name="DateUpdated" type="date" Special="LastUpdatedDate" />
	</table>
	<!--- <data table="sitePages">
		<row Title="Home" ScriptName="/" />
	</data> --->
</tables>
</cffunction>

</cfcomponent>