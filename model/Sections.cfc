<cfcomponent displayname="Sections" extends="com.sebtools.Records" output="no">

<cffunction name="getSection" access="public" returntype="query" output="no">
	<cfargument name="SectionID" type="numeric" default="0">
	
	<cfset var qParentSection = 0>
	<cfset var qSection = getRecord(argumentCollection=arguments)>
	
	<cfif ListFindNoCase(qSection.ColumnList,"SectionLabelExt")>
		<cfif qSection.RecordCount>
			<cfif Len(qSection.ParentSectionID) AND qSection.ParentSectionID GT 0>
				<cfset qParentSection = getSection(qSection.ParentSectionID)>
				<cfset QuerySetCell(qSection, "SectionLabelExt", "#qParentSection.SectionLabelExt# --&gt; #qSection.SectionTitle#")>
			<cfelse>
				<cfset QuerySetCell(qSection, "SectionLabelExt", "#qSection.SectionTitle#")>
			</cfif>
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
	<cfset var qSection = 0>
	
	<cfif StructKeyExists(Arguments,"path")>
		<cfset qSection = Variables.CMS.Links.getLinks(LinkURL=Arguments.path,distinct=true,fieldlist="SectionID")>
		<cfif qSection.RecordCount EQ 1 AND Val(qSection.SectionID)>
			<cfreturn qSection.SectionID>
		</cfif>
		
		<cfset qSection = getSections(fieldlist="SectionID",MainPageURL=Arguments.path)>
		<cfif qSection.RecordCount EQ 1 AND Val(qSection.SectionID)>
			<cfreturn qSection.SectionID>
		</cfif>
		
		<cfset Arguments.SectionDir = Arguments.path>
	</cfif>
	
	<cfset qSection = variables.Manager.getRecords(tablename=variables.table,data=arguments,fieldlist="SectionID")>
	
	<cfif qSection.RecordCount EQ 1>
		<cfset SectionID = Val(qSection.SectionID)>
	</cfif>
	
	<cfreturn SectionID>
</cffunction>

<cffunction name="getSectionIDFromDir" access="public" returntype="numeric" output="no">
	<cfargument name="SectionDir" type="string" default="0" required="true">
	
	<!--- %%TODO: code for subsections --->
	<cfset var SectionID = 0>
	<cfset var qSection = 0>
	<cfset var sArgs = StructCopy(Arguments)>
	
	<cfset sArgs.fieldlist="SectionID">
	<cfset sArgs["SectionDir"] = ListFirst(sArgs.SectionDir,"/")>
	
	<cfset qSection = getRecord(argumentCollection=sArgs)>
	
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
	
	<cfif NOT StructKeyExists(Arguments,"OrderBy")>
		<cfset Arguments.OrderBy = "OrderNum,SectionTitle">
	</cfif>
	
	<cfif StructKeyExists(Arguments,"SectionDir") AND Len(Arguments.SectionDir)>
		<cfset Arguments.SectionDir = getDirectoryFromPath(Arguments.SectionDir)>
		<cfset Arguments.SectionDir = Variables.CMS.Manager.FileMgr.convertFolder(Arguments.SectionDir)>
	</cfif>
	
	<cfset qSections = getRecords(ArgumentCollection=Arguments)>
	
	<cfif ListFindNoCase(qSections.ColumnList,"SectionLabelExt") AND ListFindNoCase(qSections.ColumnList,"SectionTitle")>
		<cfloop query="qSections">
			<cfif Len(ParentSectionID) AND isNumeric(ParentSectionID) AND ParentSectionID GT 0>
				<cfset qParentSection = getSection(SectionID=ParentSectionID,fieldlist="SectionTitle,SectionLabelExt")>
				<cfset QuerySetCell(qSections, "SectionLabelExt", "#qParentSection.SectionLabelExt# --&gt; #SectionTitle#",CurrentRow)>
			<cfelse>
				<cfset QuerySetCell(qSections, "SectionLabelExt", "#SectionTitle#",CurrentRow)>
			</cfif>
		</cfloop>
	</cfif>
	
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
	var result = 0;
	</cfscript>
	
	<!--- Save section --->
	<cfset result = saveRecord(ArgumentCollection=Arguments)>
	
	<cfset setPathData(result)>
	
	<cfset variables.CMS.indexSearch()>
	
	<cfreturn result>
</cffunction>

<cffunction name="validateSection" access="public" returntype="struct" output="false" hint="">
	
	<cfscript>
	Arguments = validateSectionID(ArgumentCollection=Arguments);
	Arguments = validateSectionLink(ArgumentCollection=Arguments);
	</cfscript>
	
	<cfreturn Arguments>
</cffunction>

<cffunction name="validateSectionID" access="private" returntype="struct" output="false" hint="">
	
	<cfscript>
	var qGetSection = 0;
	
	if ( StructKeyExists(Arguments,"SectionID") AND NOT Val(Arguments.SectionID) ) {
		StructDelete(Arguments,"SectionID");
	}
	if ( StructKeyExists(Arguments,"ParentSectionID") AND NOT Val(Arguments.ParentSectionID) ) {
		StructDelete(Arguments,"ParentSectionID");
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
			<cfset Arguments.SectionID = qGetSection.SectionID>
		</cfif>
		<cfif NOT StructKeyExists(arguments,"ParentSectionID")>
			<cfset Arguments.ParentSectionID = 0>
		</cfif>
	</cfif>
	
	<cfreturn Arguments>
</cffunction>

<cffunction name="validateSectionLink" access="private" returntype="struct" output="false" hint="">
	
	<cfset var qSection = 0>
	
	<cfif NOT StructKeyExists(Arguments,"SectionID")>
		<cfif NOT ( StructKeyExists(Arguments,"SectionDir") AND Len(Arguments.SectionDir) )> 
			<cfset Arguments.SectionDir = Arguments.SectionTitle>
		</cfif>
		<cfset Arguments.SectionDir = variables.CMS.PathNameFromString(Arguments.SectionDir)>
		<cfset checkDirExists(Arguments.SectionDir)>
		
		<cfif NOT StructKeyExists(Arguments,"SectionLink")>
			<cfif
					StructKeyExists(Arguments,"MainPageURL")
				AND	Len(Trim(Arguments.MainPageURL))
			>
				<cfset Arguments.SectionLink = Arguments.MainPageURL>
			<cfelse>
				<!--- %%TODO: code for subsections --->
				<cfset Arguments.SectionLink = "/" & Arguments.SectionDir & "/">
			</cfif>
		</cfif>
	</cfif>
	
	<cfscript>
	//Get previous state
	if ( StructKeyExists(Arguments,"SectionID") ) {
		qSection = getSection(SectionID=Arguments.SectionID,fieldlist="SectionTitle,SectionDir");
		if ( Len(qSection.SectionTitle) AND NOT Len(qSection.SectionDir) AND NOT StructKeyExists(Arguments,"SectionDir") ) {
			Arguments.SectionDir = variables.CMS.PathNameFromString(qSection.SectionTitle);
		}
	}
	</cfscript>
	
	<cfreturn Arguments>
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

<cffunction name="isIndexSectionCode" access="package" returntype="boolean" output="false" hint="">
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
	
	<cfset var qSection = getSection(SectionID=arguments.SectionID,fieldlist="MainPageURL,SectionTitle,SectionDir")>
	<cfset var path = "">
	
	<!--- If no Main Page URL, set it to page in section with matching title --->
	<cfif NOT Len(qSection.MainPageURL)>
		<cfset qPages = variables.CMS.Pages.getPages(SectionID=arguments.SectionID,Title=qSection.SectionTitle)>
		<cfif qPages.RecordCount EQ 1>
			<cfset saveRecord(SectionID=Arguments.SectionID,MainPageURL=qPages.UrlPath)>
			<cfset qSection = getSection(SectionID=arguments.SectionID,fieldlist="MainPageURL,SectionTitle,SectionDir")>
		</cfif>
	</cfif>
	
	<!--- Try to create new directory --->
	<cfif Variables.CMS.getVariable("UseFiles") AND Len(qSection.SectionDir)>
		<!--- Create directory if it doesn't exist --->
		<cfif NOT DirectoryExists( variables.CMS.getRootPath() & variables.CMS.getSectionPath(Arguments.SectionID) )>
			<cftry>
				<cfdirectory action="CREATE" directory="#ExpandPath('/#variables.CMS.getSectionPath(Arguments.SectionID)#')#" mode="777">
			<cfcatch>
			</cfcatch>
			</cftry>
		</cfif>
		
		<cfset path = "#variables.CMS.getRootPath()##variables.CMS.getSectionPath(arguments.SectionID)#index.cfm">
		<cfif NOT FileExists(ExpandPath("/#variables.CMS.getSectionPath(Arguments.SectionID)#") & "index.cfm")>
			<cfif Len(qSection.MainPageURL) AND qSection.MainPageURL NEQ "/#qSection.SectionDir#/index.cfm">
				<cffile action="write" file="#path#" output="#getIndexCode(Arguments.SectionID)#" addnewline="no">
			<cfelse>
				<cfset Variables.CMS.savePage(SectionID=Arguments.SectionID,Title=qSection.SectionTitle,FileName="index.cfm")>
			</cfif>
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