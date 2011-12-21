<cfcomponent displayname="Site Pages">

<cffunction name="init" access="public" returntype="any" output="no">
	<cfargument name="DataMgr" type="any" required="yes">
	<cfargument name="CMS" type="any" required="no">

	<cfset variables.DataMgr = arguments.DataMgr>

	<cfset variables.datasource = variables.DataMgr.getDatasource()>
	<cfset variables.DataMgr.loadXml(getDbXml(),true,true)>

	<cfset variables.Components = StructNew()>

	<cfset variables.table = "sitePages">

	<cfif StructKeyExists(arguments,"CMS")>
		<cfset variables.CMS = arguments.CMS>
		<cfinvoke method="setComponent">
			<cfinvokeargument name="Name" value="CMS">
			<cfinvokeargument name="Component" value="#arguments.CMS#">
			<cfinvokeargument name="MethodName" value="getLivePages">
			<cfinvokeargument name="LinkURL" value="UrlPath">
			<cfinvokeargument name="Title" value="Title">
			<cfinvokeargument name="SectionID" value="SectionID">
		</cfinvoke>
	</cfif>

	<cfset removeMissingPages()>

	<cfreturn this>
</cffunction>

<cffunction name="addPage" access="public" returntype="numeric" output="no">
	<cfargument name="Title" type="string" required="yes">
	<cfargument name="ScriptName" type="string" required="yes">
	<cfargument name="Section" type="string" required="no">

	<cfset var sPage = StructNew()>

	<!--- Insert a page record for this URL --->
	<cfset sPage["ScriptName"] = arguments.ScriptName>
	<cfset sPage["PageID"] = variables.DataMgr.insertRecord(variables.table,arguments,"skip")>

	<!--- Update page title and (optionally) section --->
	<cfset sPage["Title"] = arguments.Title>

	<!--- Set section if it is passed in --->
	<cfif StructKeyExists(arguments,"Section")>
		<!--- Use numeric section or get section from section name --->
		<cfif isNumeric(arguments.Section)>
			<cfset sPage["SectionID"] = arguments.Section>
		<cfelseif StructKeyExists(variables,"CMS")>
			<cfset sPage["SectionID"] = variables.CMS.Sections.getSectionID(SectionTitle=arguments.Section,isSectionLive=1)>
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
	<cfargument name="PageID" type="numeric">

	<cfreturn variables.DataMgr.getRecord(variables.table,arguments)>
</cffunction>

<cffunction name="getPages" access="public" returntype="query" output="no">

	<cfset var qPages = 0>
	<cfset var qSitePages = variables.DataMgr.getRecords(variables.table,arguments)>
	<cfset var sPageQueries = StructNew()>
	<cfset var CompName = "">

	<cfloop collection="#variables.Components#" item="CompName">
		<cfinvoke returnvariable="sPageQueries.#CompName#" method="getRemotePages">
			<cfinvokeargument name="CompName" value="#CompName#">
			<cfinvokeargument name="args" value="#arguments#">
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
	<cfset var qSections = variables.CMS.getSections()>
	<cfset var qSiteMap = 0>

	<cfquery name="qSiteMap" dbtype="query">
	SELECT		qPages.SectionID,qPages.LinkURL,qPages.Title,
				qSections.SectionTitle
	FROM		qPages,	qSections
	WHERE		qPages.SectionID = qSections.SectionID
	UNION		
	SELECT		SectionID,qPages.LinkURL,qPages.Title,'' AS SectionTitle
	FROM		qPages
	WHERE		qPages.SectionID = 0
	<!---SELECT		0 AS SectionID,qPages.LinkURL,qPages.Title,'' AS SectionTitle
	FROM		qPages
	WHERE		qPages.SectionID NOT IN (#ValueList(qSections.SectionID)#)--->
	</cfquery>

	<cfreturn qSiteMap>
</cffunction>

<cffunction name="removeMissingPages" access="public" returntype="void" output="false" hint="">

	<cfset var qPages = variables.DataMgr.getRecords(variables.table)>
	<cfset var sPage = StructNew()>

	<cfloop query="qPages">
		<cfif Left(ScriptName,1) EQ "/" AND NOT FileExists(ExpandPath(ScriptName))>
			<cfset sPage["PageID"] = PageID>
			<cfset variables.DataMgr.deleteRecord(variables.table,sPage)>
		</cfif>
	</cfloop>

</cffunction>

<cffunction name="savePage" access="public" returntype="numeric" output="no">
	<cfargument name="PageID" type="string" required="no">
	<cfargument name="Title" type="string" required="no">
	<cfargument name="ScriptName" type="string" required="no">

	<cfreturn variables.DataMgr.saveRecord(variables.table,arguments)>
</cffunction>

<cffunction name="setComponent" access="public" returntype="void" output="no">
	<cfargument name="Name" type="string" required="yes">
	<cfargument name="Component" type="any" required="yes">
	<cfargument name="MethodName" type="string" required="yes">
	<cfargument name="LinkURL" type="string" required="yes">
	<cfargument name="Title" type="string" required="yes">

	<cfset variables.Components[arguments.Name] = arguments>

</cffunction>

<cffunction name="getDbXml" access="public" returntype="string" output="no" hint="I return the XML for the tables needed for Searcher to work.">

	<cfset var tableXML = "">

	<cfsavecontent variable="tableXML">
	<tables>
		<table name="sitePages">
			<field ColumnName="PageID" CF_DataType="CF_SQL_INTEGER" PrimaryKey="true" Increment="true" />
			<field ColumnName="SectionID" CF_DataType="CF_SQL_INTEGER" Default="0" />
			<field ColumnName="Title" CF_DataType="CF_SQL_VARCHAR" Length="50" />
			<field ColumnName="ScriptName" CF_DataType="CF_SQL_VARCHAR" Length="150" />
			<field ColumnName="DateEntered" CF_DataType="CF_SQL_DATE" Special="CreationDate" />
			<field ColumnName="DateUpdated" CF_DataType="CF_SQL_DATE" Special="LastUpdatedDate" />
		</table>
		<!--- <data table="sitePages">
			<row Title="Home" ScriptName="/" />
		</data> --->
	</tables>
	</cfsavecontent>

	<cfreturn tableXML>
</cffunction>

</cfcomponent>