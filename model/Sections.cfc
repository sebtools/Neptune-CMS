<cfcomponent displayname="Sections" extends="com.sebtools.Records" output="no">

<cffunction name="getSection" access="public" returntype="query" output="no">
	<cfargument name="SectionID" type="numeric" default="0">
	
	<cfset var qParentSection = 0>
	<cfset var qSection = getRecord(argumentCollection=arguments)>
	
	<cfif qSection.RecordCount>
		<cfif Len(qSection.ParentSectionID) AND qSection.ParentSectionID GT 0>
			<cfset qParentSection = getSection(qSection.ParentSectionID)>
			<cfset QuerySetCell(qSection, "SectionLabelExt", "#qParentSection.SectionLabelExt# --&gt; #qSection.SectionTitle#")>
		<cfelse>
			<cfset QuerySetCell(qSection, "SectionLabelExt", "#qSection.SectionTitle#")>
		</cfif>
	</cfif>
	
	<cfreturn qSection>
</cffunction>

<cffunction name="getMainPageURL" access="public" returntype="string" output="false" hint="">
	<cfargument name="SectionID" type="numeric" default="0">
	
	<cfset var qSection = getSection(arguments.SectionID)>
	<cfset var result = qSection.MainPageURL>
	<cfset var qPages = 0>
	
	<cfif NOT Len(result)>
		<cfset qPages = variables.CMS.Pages.getPages(SectionID=arguments.SectionID,Title=qSection.SectionTitle)>
		<cfif qPages.RecordCount EQ 1>
			<cfset result = qPages.UrlPath>
		<cfelse>
			<cfset qPages = variables.CMS.getPages(SectionID=arguments.SectionID)>
			<cfif qPages.RecordCount EQ 1>
				<cfset result = qPages.UrlPath>
			<cfelseif qPages.RecordCount>
				<cfset result = qPages.UrlPath>
			<cfelse>
				<cfset result = "/404.cfm">
			</cfif>
		</cfif>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="getSectionID" access="public" returntype="numeric" output="no">
	<cfargument name="SectionTitle" type="string" required="no">
	
	<cfset var SectionID = 0>
	<cfset var qSection = variables.Manager.getRecords(tablename=variables.table,data=arguments,fieldlist="SectionID")>
	
	<cfif qSection.RecordCount EQ 1>
		<cfset SectionID = qSection.SectionID>
	</cfif>
	
	<cfreturn SectionID>
</cffunction>

<cffunction name="getSectionIDFromDir" access="public" returntype="numeric" output="no">
	<cfargument name="SectionDir" type="string" default="0" required="true">
	
	<!--- %%TODO: code for subsections --->
	<cfset var SectionID = 0>
	<cfset var qSection = getRecord(argumentCollection=arguments)>
	
	<cfif qSection.RecordCount>
		<cfset SectionID = qSection.SectionID>
	</cfif>
	
	<cfreturn SectionID>
</cffunction>

<cffunction name="getPublicSections" access="public" returntype="query" output="false" hint="">
	<cfset arguments.isSectionLive = true>
	
	<cfreturn getSections(argumentCollection=arguments)>
</cffunction>

<cffunction name="getSections" access="public" returntype="query" output="no">
	<cfargument name="ParentSectionID" type="numeric" required="no">
	
	<cfset var qParentSection = 0>
	<cfset var qSections = 0>
	
	<cfset qSections = variables.DataMgr.getRecords(tablename=variables.table,data=arguments,orderby="OrderNum,SectionTitle")>
	
	<cfloop query="qSections">
		<cfif Len(ParentSectionID) AND isNumeric(ParentSectionID) AND ParentSectionID GT 0>
			<cfset qParentSection = getSection(ParentSectionID)>
			<cfset QuerySetCell(qSections, "SectionLabelExt", "#qParentSection.SectionLabelExt# --&gt; #SectionTitle#",CurrentRow)>
		<cfelse>
			<cfset QuerySetCell(qSections, "SectionLabelExt", "#SectionTitle#",CurrentRow)>
		</cfif>
	</cfloop>
	
	<cfreturn qSections>
</cffunction>

<cffunction name="getTopSectionID" access="public" returntype="numeric" output="no">
	<cfargument name="SectionID" type="numeric" default="0">
	
	<cfset var qSection = getSection(arguments.SectionID)>
	<cfset var result = qSection.SectionID>
	<cfset var prevresult = 0>
	
	<cfif isNumeric(qSection.ParentSectionID) AND qSection.ParentSectionID GT 0>
		<cfloop condition="prevresult NEQ result">
			<cfset prevresult = result>
			<cfset result = getTopSectionID(qSection.ParentSectionID)>
		</cfloop>
	</cfif>
	
	<cfreturn Val(result)>
</cffunction>

<cffunction name="removeMainPageURL" access="public" returntype="void" output="false" hint="">
	<cfargument name="MainPageURL" type="string" required="yes">
	
	<cfset var sData = StructNew()>
	
	<cfset sData["MainPageURL"] = "">
	
	<cfset variables.DataMgr.updateRecords(tablename=variables.table,data_set=sData,data_where=arguments)>
	
</cffunction>

<cffunction name="removeSection" access="public" returntype="void" output="no" hint="I delete the given Section.">
	<cfargument name="SectionID" type="string" required="yes">
	
	<cfset var qPages = variables.CMS.Pages.getPages(arguments.SectionID)>
	<cfset var qSubsections = getSections(arguments.SectionID)>
	
	<cfif NOT (qPages.RecordCount OR qSubsections.RecordCount)>
		<cfset removeRecord(argumentCollection=arguments)>
		
		<cfset variables.CMS.indexSearch()>
	</cfif>
	
</cffunction>

<cffunction name="saveSection" access="public" returntype="numeric" output="no" hint="I create or update a section and return the SectionID.">
	<cfargument name="SectionID" type="numeric" hint="New section created if not passed in.">
	<cfargument name="ParentSectionID" type="numeric">
	<cfargument name="OrderNum" type="numeric" hint="Used for ordering query results.">
	<cfargument name="SectionTitle" type="string">
	<cfargument name="Description" type="string">
	<cfargument name="Keywords" type="string">
	<cfargument name="SectionLink" type="string" hint="An optional primary link for this section.">
	<cfargument name="SectionDir" type="string" hint="A folder path for this section.">
	<cfargument name="MainPageURL" type="string" hint="The URL for the main page for this section.">
	
	<cfscript>
	var qSection = 0;
	var qGetSection = 0;
	var result = 0;
	
	if ( StructKeyExists(arguments,"SectionID") AND NOT Val(arguments.SectionID) ) {
		StructDelete(arguments,"SectionID");
	}
	if ( StructKeyExists(arguments,"ParentSectionID") AND NOT Val(arguments.ParentSectionID) ) {
		StructDelete(arguments,"ParentSectionID");
	}
	</cfscript>
	
	<!--- If SectionID isn't passed in, use section with same title and parent --->
	<cfif NOT StructKeyExists(arguments,"SectionID")>
		<cfquery name="qGetSection" datasource="#variables.datasource#">
		SELECT	SectionID
		FROM	#variables.table#
		WHERE	1 = 1
		<cfif StructKeyExists(arguments,"SectionTitle")>
			AND		SectionTitle = <cfqueryparam value="#arguments.SectionTitle#" cfsqltype="CF_SQL_VARCHAR">
		</cfif>
		<cfif StructKeyExists(arguments,"ParentSectionID")>
		AND		ParentSectionID = <cfqueryparam value="#Val(arguments.ParentSectionID)#" cfsqltype="CF_SQL_INTEGER">
		<cfelse>
		AND		( ParentSectionID IS NULL OR ParentSectionID = 0)
		</cfif>
		</cfquery>
		<cfif qGetSection.RecordCount>
			<cfset arguments.SectionID = qGetSection.SectionID>
		</cfif>
		<cfif NOT StructKeyExists(arguments,"ParentSectionID")>
			<cfset arguments.ParentSectionID = 0>
		</cfif>
	</cfif>
	
	<cfif NOT StructKeyExists(arguments,"SectionID")>
		<cfif NOT StructKeyExists(arguments,"SectionDir")> 
			<cfset arguments.SectionDir = variables.CMS.PathNameFromString(arguments.SectionTitle)>
		</cfif>
		<cfset checkDirExists(arguments.SectionDir)>
	</cfif>
	
	<!--- %%TODO: code for subsections --->
	<cfif NOT StructKeyExists(arguments,"SectionID") AND NOT StructKeyExists(arguments,"SectionLink")>
		<cfset arguments.SectionLink = "/" & arguments.SectionDir & "/">
	</cfif>
	
	<cfscript>
	//Get previous state
	if ( StructKeyExists(arguments,"SectionID") ) {
		qSection = getSection(arguments.SectionID);
		if ( Len(qSection.SectionTitle) AND NOT Len(qSection.SectionDir) AND NOT StructKeyExists(arguments,"SectionDir") ) {
			arguments.SectionDir = variables.CMS.PathNameFromString(qSection.SectionTitle);
		}
	}
	</cfscript>
	
	<!--- Save section --->
	<cfset result = saveRecord(argumentCollection=arguments)>
	
	<cfset setPathData(result)>
	
	<cfset variables.CMS.indexSearch()>
	
	<cfif StructKeyExists(arguments,"MainPageURL") AND Len(Trim(arguments.MainPageURL)) AND NOT isIndexSectionCode(result)>
		<cfset throwError("Your changes have been saved, but an index.cfm page is already in use in this folder so the Main Page will not have any effect.","NOTisIndexSectionCode")>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="updateLinkURL" access="public" returntype="void" output="false" hint="">
	<cfargument name="LinkURLFrom" type="string" required="yes">
	<cfargument name="LinkURLTo" type="string" required="yes">
	
	<cfset var sDataSet = StructNew()>
	<cfset var sDataWhere = StructNew()>
	
	<cfset sDataSet["MainPageURL"] = arguments.LinkURLTo>
	<cfset sDataWhere["MainPageURL"] = arguments.LinkURLFrom>
	
	<cfset variables.DataMgr.updateRecords(tablename=variables.table,data_set=sDataSet,data_where=sDataWhere)>
	
</cffunction>

<cffunction name="getIndexCode" access="private" returntype="string" output="false" hint="">
	<cfargument name="SectionID" type="numeric" required="yes">
	
	<cfset var result = "">
	<cfset var aCodeLines = getIndexCodeArray(arguments.SectionID)>
	<cfset var ii = 0>
	<cfset var cr = "
">
	
	<cfloop index="ii" from="1" to="#ArrayLen(aCodeLines)#" step="1">
		<cfset result = "#result##aCodeLines[ii]##cr#">
	</cfloop>
	<cfset result = Trim(result)>
	
	<cfreturn result>
</cffunction>

<cffunction name="getIndexCodeArray" access="private" returntype="array" output="false" hint="">
	<cfargument name="SectionID" type="numeric" required="yes">
	
	<cfset var qSection = getSection(arguments.SectionID)>
	<cfset var aCodeLines = ArrayNew(1)>
	
	<cfset ArrayAppend(aCodeLines,"<cfset MainPageURL = Application.CMS.Sections.getMainPageURL(#arguments.SectionID#)>")>
	<cfset ArrayAppend(aCodeLines,"<cfinclude template=""#chr(35)#MainPageURL#chr(35)#"">")>
	
	<cfreturn aCodeLines>
</cffunction>

<cffunction name="isIndexSectionCode" access="private" returntype="boolean" output="false" hint="">
	<cfargument name="SectionID" type="numeric" required="yes">
	<cfargument name="isrecursed" type="boolean" default="false">
	
	<cfset var result = true>
	<cfset var aCodeLines = getIndexCodeArray(arguments.SectionID)>
	<cfset var path = variables.CMS.getRootPath() & variables.CMS.getSectionPath(arguments.SectionID) & "index.cfm">
	<cfset var IndexCode = "">
	<cfset var ii = 0>
	
	<cfif FileExists(path)>
		<cffile action="read" file="#path#" variable="IndexCode">
		
		<cfloop index="ii" from="1" to="#ArrayLen(aCodeLines)#">
			<cfif NOT FindNoCase(aCodeLines[ii],IndexCode)>
				<cfset result = false>
			</cfif>
		</cfloop>
	<cfelseif NOT arguments.isrecursed>
		<cfset setPathData(arguments.SectionID)>
		<cfset result = isIndexSectionCode(arguments.SectionID,1)>
	<cfelse>
		<cfset result = false>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="setPathData" access="package" returntype="void" output="false" hint="">
	<cfargument name="SectionID" type="numeric" required="yes">
	
	<cfset var qSection = getSection(arguments.SectionID)>
	<cfset var path = "">
	<cfset var sData = StructNew()>
	
	<!--- If no Main Page URL, set it to page in section with matching title --->
	<cfif NOT Len(qSection.MainPageURL)>
		<cfset qPages = variables.CMS.Pages.getPages(SectionID=arguments.SectionID,Title=qSection.SectionTitle)>
		<cfif qPages.RecordCount EQ 1>
			<cfset sData["SectionID"] = arguments.SectionID>
			<cfset sData["MainPageURL"] = qPages.UrlPath>
			<cfset variables.DataMgr.saveRecord(variables.table,sData)>
			<cfset qSection = getSection(arguments.SectionID)>
		</cfif>
	</cfif>
	
	<!--- Try to create new directory --->
	<cfif Len(qSection.SectionDir)>
		<!--- Create directory if it doesn't exist --->
		<cfif NOT DirectoryExists( variables.CMS.getRootPath() & variables.CMS.getSectionPath(arguments.SectionID) )>
			<cftry>
				<cfdirectory action="CREATE" directory="#ExpandPath('/#variables.CMS.getSectionPath(arguments.SectionID)#')#" mode="777">
			<cfcatch>
			</cfcatch>
			</cftry>
		</cfif>
		
		<cfset path = "#variables.CMS.getRootPath()##variables.CMS.getSectionPath(arguments.SectionID)#index.cfm">
		<cfif Len(qSection.MainPageURL) AND NOT FileExists(ExpandPath("/#variables.CMS.getSectionPath(arguments.SectionID)#") & "index.cfm")>
			<cffile action="write" file="#path#" output="#getIndexCode(arguments.SectionID)#" addnewline="no">
		</cfif>
	</cfif>
	
</cffunction>

<cffunction name="checkDirExists" access="private" returntype="void" output="no">
	<cfargument name="SectionDir" type="string" required="true">
	
	<cfif hasSections(argumentCollection=arguments)>
		<cfset throwError("Another section already exists for that directory.","SectionDirExists")>
	</cfif>
	
</cffunction>

</cfcomponent>