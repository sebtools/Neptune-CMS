<cfcomponent displayname="Pages" extends="com.sebtools.Records" output="no">

<cffunction name="addPage" access="public" returntype="numeric" output="false" hint="I add a page after checking for its existence.">
	<cfargument name="URLPath" type="string" required="true" >
	<cfargument name="Title" type="string" required="true" >
	<cfargument name="Contents" type="string" required="true" >
	
	<cfset var result = 0>
	
	<cfif NOT hasPages(URLPath=Arguments.URLPath)>
		<cfset result = savePage(ArgumentCollection=Arguments)>
	</cfif>
	
	<cfreturn result>
</cffunction>
	
<cffunction name="copyPage" access="public" returntype="void" output="no">
	<cfargument name="PageID" type="numeric" required="yes">
	<cfargument name="FileName" type="string" required="yes">
	<cfargument name="SectionID" type="string" required="no">
	<cfargument name="URLPath" type="string" required="no">
	
	<cfset var qPage = getPage(arguments.PageID)>
	<cfset var sPage = variables.CMS.QueryRowToStruct(qPage)>
	
	<cfif isFileExisting(argumentCollection=arguments)>
		<cfset throwError("The entered file name is already in use for another page.")>
	</cfif>
	
	<cfset sPage["FileName"] = arguments.FileName>
	<cfset sPage["PageName"] = ListFirst(arguments.FileName,".")>
	
	<cfif StructKeyExists(arguments,"SectionID")>
		<cfset sPage.SectionID = arguments.SectionID>
	</cfif>
	
	<cfif StructKeyExists(arguments,"URLPath")>
		<cfset sPage.URLPath = arguments.URLPath>
	</cfif>
	
	<!--- Take advantage of new "copyRecord" method (which copies files as well) if it is available --->
	<cfif StructKeyExists(variables.Manager,"copyRecord")>
		<cfset variables.Manager.copyRecord(variables.table,sPage)>
	<cfelse>
		<cfset StructDelete(sPage,"PageID")>
		<cfset savePage(argumentCollection=sPage)>
	</cfif>
	
</cffunction>

<cffunction name="getAllPages" access="public" returntype="query" output="no" hint="I return all of the pages in the given section.">
	<cfargument name="skeleton" type="string" required="no" hint="The HTML skeleton to feed the contents of the page into. The name of any field can be placed in brackets and will be replaced by the contents of that field for the given page. For example, to place the contents of the page, use [Contents] as place-holder.">
	
	<cfset var sArgs = StructNew()>
	
	<cfset sArgs["tablename"] = variables.table>
	<cfset sArgs["data"] = arguments>
	<cfif StructKeyExists(arguments,"fieldlist") AND Len(arguments.fieldlist)>
		<cfset sArgs["fieldlist"] = arguments.fieldlist>
	</cfif>
	
	<cfreturn convertPageQuery(variables.Manager.getRecords(argumentCollection=convertPageArgs(sArgs)))>
</cffunction>

<cffunction name="getPagePreview" access="public" returntype="any" output="false" hint="">
	<cfargument name="data" type="struct" required="yes">
	
	<cfset var qPage = 0>
	<cfset var sData = Duplicate(arguments.data)>
	<cfset var col = "">
	
	<cfif isDefined("sData.PageID") AND isDefined("sData.PageVersionID")>
		<cfinvoke method="getPage" returnvariable="qPage">
			<cfinvokeargument name="PageID" value="#Val(sData.PageID)#">
			<cfinvokeargument name="PageVersionID" value="#val(sData.PageVersionID)#">
		</cfinvoke>
		<cfif qPage.RecordCount>
			<cfloop index="col" list="#qPage.ColumnList#">
				<!--- <cfset Form[col] = qPage[col][1]> --->
				<cfif StructKeyExists(sData,col) AND Len(sData[col])>
					<cfset QuerySetCell(qPage,col,sData[col],1)>
				</cfif>
			</cfloop>
		</cfif>
	<cfelseif StructKeyExists(sData,"PageID")>
		<cfinvoke component="#Application.CMS#" method="getPage" returnvariable="qPage">
			<cfinvokeargument name="PageID" value="#Val(sData.PageID)#">
		</cfinvoke>
		<cfif qPage.RecordCount>
			<cfloop index="col" list="#qPage.ColumnList#">
				<cfif StructKeyExists(sData,col) AND Len(sData[col])>
					<cfset QuerySetCell(qPage,col,sData[col],1)>
				<cfelse>
					<cfset Form[col] = qPage[col][1]>
				</cfif>
			</cfloop>
		</cfif>
	</cfif>
	<cfif NOT ( isDefined("qPage") AND isQuery(qPage) )>
		<cfset qPage = getPage(0)>
	</cfif>
	<cfif NOT qPage.RecordCount>
		<cfset QueryAddRow(qPage)>
		<cfloop index="col" list="#fields#">
			<cfset QuerySetCell(qPage,col,sData[col],1)>
		</cfloop>
	</cfif>
	
	<cfset qPage = convertPageQuery(qPages=qPage,fixContents=true,process=true)>
	
	<cfreturn qPage>
</cffunction>

<cffunction name="getPage" access="public" returntype="query" output="no" hint="I get all of the information for the given page.">
	<cfargument name="PageID" type="numeric" required="yes">
	<cfargument name="SiteVersionID" type="numeric" required="no">
	<cfargument name="PageVersionID" type="numeric" required="no">
	<cfargument name="process" type="boolean" default="true">
	
	<cfreturn convertPageQuery(qPages=getRecord(argumentCollection=arguments),fixContents=true,process=arguments.process)>
</cffunction>

<cffunction name="getPages" access="public" returntype="query" output="no" hint="I return all of the pages in the given section.">
	<cfargument name="SectionID" type="numeric" required="no">
	
	<cfreturn convertPageQuery(getRecords(argumentCollection=convertPageArgs(arguments)))>
</cffunction>

<cffunction name="makeFileName" access="public" returntype="void" output="no">
	<cfargument name="PageID" type="numeric" required="yes">
	
	<cfset var qPage = getPage(arguments.PageID)>
	<cfset var sPage = StructNew()>
	
	<cfset sPage["PageID"] = arguments.PageID>
	<cfset sPage.FileName = "">
	
	<cfif Len(Trim(qPage.FileName))>
		<cfif qPage.FileName NEQ variables.CMS.FileNameFromString(qPage.FileName)>
			<cfset sPage.FileName = variables.CMS.FileNameFromString(qPage.FileName)>
		</cfif>
	<cfelse>
		<cfset sPage.FileName = variables.CMS.FileNameFromString(qPage.Title)>
	</cfif>
	
	<cfif Len(Trim(sPage.FileName))>
		<cfset variables.DataMgr.updateRecord(variables.table,sPage)>
	</cfif>
	
</cffunction>

<cffunction name="makePageName" access="public" returntype="void" output="no">
	<cfargument name="PageID" type="numeric" required="yes">
	
	<cfset var qPage = getPage(arguments.PageID)>
	<cfset var sPage = StructNew()>
	
	<cfset sPage["PageID"] = arguments.PageID>
	<cfset sPage.PageName = "">
	
	<cfif NOT Len(Trim(qPage.PageName))>
		<cfset sPage.PageName = qPage.FileName>
		<cfset variables.DataMgr.updateRecord(variables.table,sPage)>
	</cfif>
	
</cffunction>

<cffunction name="removePage" access="public" returntype="void" output="no" hint="I delete the given Page.">
	<cfargument name="PageID" type="string" required="yes">
	
	<cfset var qPage = getPage(arguments.pageID)>
	<cfset var precode = "">
	<cfset var isCmsPage = false>
	
	<cfset removeRecord(argumentCollection=arguments)>
	
	<cfif Len(qPage.FullFilePath) AND FileExists(qPage.FullFilePath)>
		<cffile action="READ" file="#qPage.FullFilePath#" variable="precode">
		<cfif FindNoCase("CMS", precode) AND FindNoCase("nosearchy", precode)>
			<cfset isCmsPage = true>
		</cfif>
		<!--- Delete if a valid CMS page --->
		<cfif isCmsPage AND NOT FindNoCase("nowritey", precode)>
			<cffile action="delete" file="#qPage.FullFilePath#">
		</cfif>
	</cfif>
	
	<!--- Remove any links to this page --->
	<cfset variables.CMS.Links.removeLinkURL(variables.CMS.getUrlPath(Val(qPage.SectionID),qPage.FileName))>
	
	<cfset variables.CMS.PageLinks.removePageLinks(arguments.PageID)>
	
	<!--- Make sure no section has this as a main page --->
	<cfset variables.CMS.Sections.removeMainPageURL(qPage.UrlPath)>
	
	<cfset variables.CMS.indexSearch()>
	
</cffunction>

<cffunction name="renamePageFile" access="public" returntype="void" output="no">
	<cfargument name="PageID" type="numeric" required="yes">
	<cfargument name="FileName" type="string" required="yes">
	
	<cfset var qPageOld = getPage(arguments.PageID)>
	<cfset var qPageNew = 0>
	<cfset var TargetPath = "">
	
	<cfset arguments.FileName = variables.CMS.FileNameFromString(arguments.FileName)>
	
	<cfif isFileExisting(ArgumentCollection=Arguments)>
		<cfset throwError("The entered file name is already in use for another page.")>
	</cfif>
	
	<cfset variables.DataMgr.updateRecord("cmsPages",arguments)>
	<cfset qPageNew = getPage(arguments.PageID)>
	
	<cftry>
		<cffile action="RENAME" source="#qPageOld.FullFilePath#" destination="#qPageNew.FullFilePath#">
	<cfcatch>
	</cfcatch>
	</cftry>
	<cfif Len(variables.CMS.getSkeleton())>
		<cfset variables.CMS.writeFile(arguments.PageID,variables.CMS.getSkeleton(),true)>
	</cfif>
	
	<cfinvoke component="#variables.CMS.Links#" method="updateLinkURL">
		<cfinvokeargument name="LinkURLFrom" value="#variables.CMS.getUrlPath(Val(qPageOld.SectionID),qPageOld.FileName)#">
		<cfinvokeargument name="LinkURLTo" value="#variables.CMS.getUrlPath(Val(qPageNew.SectionID),qPageNew.FileName)#">
	</cfinvoke>
	
	<cfinvoke component="#variables.CMS.Sections#" method="updateLinkURL">
		<cfinvokeargument name="LinkURLFrom" value="#variables.CMS.getUrlPath(Val(qPageOld.SectionID),qPageOld.FileName)#">
		<cfinvokeargument name="LinkURLTo" value="#variables.CMS.getUrlPath(Val(qPageNew.SectionID),qPageNew.FileName)#">
	</cfinvoke>
	
	<cfset variables.CMS.indexSearch()>
	
</cffunction>

<cffunction name="savePage" access="public" returntype="numeric" output="no" hint="I create or update a page and return the PageID.">
	<cfargument name="SectionID" type="string" required="no" default="0">
	<cfargument name="PageID" type="numeric" hint="New page created if this value is not passed in.">
	<cfargument name="SiteVersionID" type="numeric">
	<cfargument name="Title" type="string">
	<cfargument name="PageName" type="string">
	<cfargument name="OrderNum" type="numeric" hint="Used for ordering query results.">
	<cfargument name="FileName" type="string" hint="The file name for this page. To be used with makeFiles(). May include folder. Will be placed below RootPath and below any folder for section.">
	<cfargument name="Contents" type="string" hint="The contents of this page.">
	<cfargument name="Contents2" type="string" hint="Any secondary contents for this page.">
	<cfargument name="Description" type="string">
	<cfargument name="Keywords" type="string">
	<cfargument name="ImageFileName" type="string" hint="A file name for an image being used on this page.">
	<cfargument name="VersionDescription" type="string" hint="Any comments on the changes being made.">
	<cfargument name="VersionBy" type="string" hint="The person making the change.">
	<cfargument name="skeleton" type="string" default="#variables.CMS.getSkeleton()#">
	
	<cfscript>
	var liVersionItems = "PageID,SiteVersionID,Title,Description,Keywords,Contents,Contents2,VersionDescription,VersionBy";
	var col = "";
	
	var sPage = StructNew();
	var sVersion = StructNew();
	
	var qPage = 0;
	var output = "";
	
	var isManuallyChosenFileName = true;
	var isExistingFile = 0;
	
	if ( NOT StructKeyExists(arguments,"skeleton") ) {
		arguments.skeleton = variables.CMS.getSkeleton();
	}
	
	//If PageID is not valid, make sure this is clearly a new page
	if ( StructKeyExists(arguments,"PageID") AND NOT Val(arguments.PageID) ) {
		StructDelete(arguments,"PageID");
	}
	
	//Force SectionID to numeric
	if ( StructKeyExists(arguments,"SectionID") ) {
		arguments.SectionID = Val(arguments.SectionID);
	}
	if ( StructKeyExists(Arguments,"Section") AND isSimpleValue(Arguments.Section) AND Len(Arguments.Section) AND NOT Arguments.SectionID ) {
		Arguments.SectionID = Variables.CMS.Sections.getSectionID(Arguments.Section);
	}
	
	//If a file name is passed in that doesn't match the existing name for this page, then make this a new page.
	if ( StructKeyExists(arguments,"PageID") ) {
		qPage = getPage(arguments.PageID);
		if ( StructKeyExists(arguments,"FileName") AND variables.CMS.FileNameFromString(arguments.FileName) NEQ variables.CMS.FileNameFromString(qPage.FileName) ) {
			StructDelete(arguments,"PageID");
		}
	}
	
	//New files should have FileName and pageName
	if ( NOT StructKeyExists(arguments,"PageID") ) {
		//Make File Name
		if ( NOT StructKeyExists(arguments,"FileName") OR NOT Len(arguments.FileName) ) {
			if ( StructKeyExists(Arguments,"URLPath") AND Len(Arguments.URLPath) ) {
				Arguments.FileName = ListLast(Arguments.URLPath,"/");
			} else {
				arguments.FileName = arguments.Title;
				isManuallyChosenFileName = false;
			}
		}
		if ( NOT StructKeyExists(arguments,"PageName") OR NOT Len(arguments.PageName) ) {
			arguments.PageName = ReplaceNoCase(arguments.Title, " ", "_", "ALL");
		}
		if ( NOT ( StructKeyExists(Arguments,"TemplateID") AND Val(Arguments.TemplateID) ) ) {
			Arguments.TemplateID = Variables.CMS.Templates.getDefaultTemplateID();
		}
	}
	if ( StructKeyExists(arguments,"FileName") ) {
		arguments.FileName = variables.CMS.FileNameFromString(arguments.FileName);
	}
	if ( StructKeyExists(arguments,"PageName") AND NOT Len(arguments.PageName) ) {
		StructDelete(arguments,"PageName");
	}
	</cfscript>
	
	<!--- No longer allow "index.cfm" or "default.cfm", so that can be used by section --->
	<cfif
			StructKeyExists(arguments,"FileName")
		AND (
					ListFirst(arguments.FileName,".") EQ "index"
				OR	ListFirst(arguments.FileName,".") EQ "default"
			)
		AND	(
					StructKeyExists(arguments,"SectionID")
				AND	Variables.CMS.Sections.isIndexSectionCode(arguments.SectionID,true)
			)
	>
		<cfset arguments.FileName = "my#arguments.FileName#">
	</cfif>
	
	<!--- Make sure we have a value for UrlPath for new pages --->
	<cfif
			StructKeyExists(Arguments,"FileName")
		AND	NOT StructKeyExists(arguments,"PageID")
		AND	NOT (
					StructKeyExists(Arguments,"UrlPath")
				AND	Len(Arguments.UrlPath)
			)
	>
		<cfset Arguments.UrlPath = Variables.CMS.getUrlPath(Val(Arguments.SectionID),Arguments.FileName)>
	</cfif>
	
	<!--- Make sure that the URLPath matches the file name --->
	<cfif StructKeyExists(Arguments,"UrlPath") AND Len(Arguments.UrlPath) AND StructKeyExists(Arguments,"FileName")>
		<cfset Arguments.UrlPath = ListSetAt(Arguments.UrlPath,ListLen(Arguments.UrlPath,"/"),Arguments.FileName,"/")>
		<cfif Left(Arguments.UrlPath,1) NEQ "/">
			<cfset Arguments.UrlPath = "/#Arguments.UrlPath#">
		</cfif>
	</cfif>
	
	<cfscript>
	for ( col in Arguments ) {
		if (
				isSimpleValue(Arguments[col])
			AND	Len(Arguments[col]) GT 200
		) {
			Arguments[col] = Variables.CMS.cleanMSWord(Arguments[col]);
		}
	}
	</cfscript>

	<!--- Check if file name already exists --->
	<cfif StructKeyExists(arguments,"FileName")>
		<cfset isExistingFile = isFileExisting(ArgumentCollection=Arguments)>
		<cfif isExistingFile>
			<!--- If file exists, err if chosen manually. If automatically chosen just fix it. --->
			<cfif isManuallyChosenFileName>
				<cfset throwError("The entered file name is already in use for another page.")>
			<cfelse>
				<cfinvoke returnvariable="arguments.FileName" method="findAvailableFileName">
					<cfinvokeargument name="FileName" value="#arguments.FileName#">
					<cfif StructKeyExists(arguments,"PageID")>
						<cfinvokeargument name="PageID" value="#arguments.PageID#">
					</cfif>
					<cfif StructKeyExists(arguments,"SectionID")>
						<cfinvokeargument name="SectionID" value="#arguments.SectionID#">
					</cfif>
				</cfinvoke>
			</cfif>
			
		</cfif>
	</cfif>
	
	<!--- Set structure for page keys --->
	<cfset sPage = Duplicate(arguments)>
	<!--- <cfloop index="col" list="#liPageItems#">
		<cfif StructKeyExists(arguments,col)>
			<cfset sPage[col] = arguments[col]>
		</cfif>
	</cfloop> --->
	
	<!--- Don't delete a page on save (in fact, undelete it if it is deleted) --->
	<cfset sPage["isDeleted"] = false>
	<!--- Set version information --->
	<cfloop index="col" list="#liVersionItems#">
		<cfif StructKeyExists(arguments,col)>
			<cfset sPage[col] = arguments[col]>
			<cfset sVersion[col] = arguments[col]>
		<cfelseif isQuery(qPage) AND ListFindNoCase(qPage.ColumnList,col)>
			<cfset sPage[col] = qPage[col][1]>
			<cfset sVersion[col] = qPage[col][1]>
		</cfif>
	</cfloop>
	<cfset sVersion["WhenCreated"] = now()>
	<cfset sVersion["isLive"] = now()>
	
	<cftransaction>
		<!--- Update page --->
		<cfset sPage["PageID"] = saveRecord(argumentCollection=sPage)>
		
		<!--- Add page version --->
		<cfset sVersion["PageID"] = sPage["PageID"]>
		<cfset sVersion["PageVersionID"] = variables.DataMgr.insertRecord("cmsPageVersions",sVersion)>
		
		<!--- Always set the updated information as the live version --->
		<cfinvoke component="#variables.CMS#" method="restoreVersion">
			<cfinvokeargument name="PageID" value="#sVersion.PageID#">
			<cfinvokeargument name="PageVersionID" value="#sVersion.PageVersionID#">
			<cfif StructKeyExists(arguments,"SiteVersionID")><cfinvokeargument name="SiteVersionID" value="#arguments.SiteVersionID#"></cfif>
		</cfinvoke>
	</cftransaction>
	
	<!--- If a LinkID is passed, set that URL of that link to this page --->
	<cfif StructKeyExists(arguments,"LinkID")>
		<cfinvoke component="#variables.CMS.Links#" method="saveLink">
			<cfinvokeargument name="LinkID" value="#arguments.LinkID#">
			<cfinvokeargument name="LinkURL" value="#variables.CMS.getUrlPath(arguments.SectionID,arguments.FileName)#">
		</cfinvoke>
	</cfif>
	
	<!--- Is section is changing, delete page file in old section --->
	<cfif
			( isQuery(qPage) AND qPage.RecordCount )
		AND	( StructKeyExists(arguments,"SectionID") AND isNumeric(arguments.SectionID) )
		AND	qPage.SectionID NEQ arguments.SectionID
	>
		<cffile action="delete" file="#qPage.FullFilePath#">
	</cfif>
	
	<!--- Write page file --->
	<cfif Len(arguments.skeleton) AND ReFindNoCase("\[.*\]",arguments.skeleton)>
		<cfset variables.CMS.writeFile(sPage["PageID"],arguments.skeleton,true)>
	</cfif>
	
	<!---<cfif StructKeyExists(arguments,"SectionID") AND arguments.SectionID GT 0>
		<cfset variables.CMS.Sections.setPathData(arguments.SectionID)>
	</cfif>--->
	
	<!--- Add to menu if indicated for new page --->
	<cfscript>
	if ( StructKeyExists(arguments,"SectionID") AND arguments.SectionID GT 0 ) {
		if ( StructKeyExists(arguments,"isInMenu") AND isBoolean(arguments.isInMenu) ) {
			//Need separate method
			setPageInMenu(sPage["PageID"],arguments.isInMenu);
			//variables.CMS.Links.saveLink(SectionID=SectionID,LinkURL=UrlPath,Label=Title);
		}
	}
	</cfscript>
	
	<cfset variables.CMS.indexSearch()>
	
	<cfreturn sPage["PageID"]>
</cffunction>

<cffunction name="setPageInMenu" access="private" returntype="void" output="false">
	<cfargument name="PageID" type="numeric" required="true">
	<cfargument name="isInMenu" type="boolean" default="true">
	
	<cfset var qPage = getPage(arguments.PageID)>
	
	<cfif arguments.isInMenu AND qPage.isPageLive IS true>
		<cfset variables.CMS.Links.addLink(SectionID=qPage.SectionID,LinkURL=qPage.UrlPath,Label=qPage.Title)>
	<cfelse>
		<cfset variables.CMS.Links.removeLinkURL(qPage.UrlPath)> 
	</cfif>
	
</cffunction>
<cffunction name="convertPageArgs" access="private" returntype="struct" output="false" hint="">
	
	<cfset var sArgs = arguments[1]>
	
	<cfif StructKeyExists(sArgs,"fieldlist") AND ListFindNoCase(sArgs.fieldlist,"urlpath")>
		<cfif NOT ListFindNoCase(sArgs.fieldlist,"SectionID")>
			<cfset sArgs.fieldlist = ListAppend(sArgs.fieldlist,"SectionID")>
		</cfif>
		<cfif NOT ListFindNoCase(sArgs.fieldlist,"FileName")>
			<cfset sArgs.fieldlist = ListAppend(sArgs.fieldlist,"FileName")>
		</cfif>
	</cfif>
	
	<cfreturn sArgs>
</cffunction>

<cffunction name="convertPageQuery" access="private" returntype="query" output="false" hint="">
	<cfargument name="qPages" type="query" required="yes">
	<cfargument name="fixContents" type="boolean" default="false">
	<cfargument name="process" type="boolean" default="true">
	
	<cfset var col = "">
	<cfset var contentAdjusted = "">
	<cfset var isContentChanged = false>
	<cfset var LinksHTML = "">
	<cfset var aIsInMenu = ArrayNew(1)>
	
	<cfoutput query="qPages">
		<!--- Calculate file paths, if appropriate data is present --->
		<cfif ListFindNoCase(qPages.ColumnList,"UrlPath")>
			<cfif ListFindNoCase(qPages.ColumnList,"FullFilePath")>
				<cfset QuerySetCell(
					qPages,
					"FullFilePath",
					variables.CMS.getFullFilePath(SectionID=0,FileName="",URLPath=URLPath),
					CurrentRow
				)>
			</cfif>
		</cfif>
		<!--- Adjust Contents if that column exists --->
		<cfif ListFindNoCase(qPages.ColumnList,"Contents")>
			<cfset isContentChanged = false>
			<cfset contentAdjusted = Contents>
			<cfif arguments.fixContents>
				<!--- Strip out some junk MS styling --->
				<cfset contentAdjusted = ReReplaceNoCase(contentAdjusted,"http://[ \n\r\t]*/","/","ALL")>
				<cfset contentAdjusted = ReReplaceNoCase(contentAdjusted, '<span([^>]*) style="FONT-SIZE[^"]*"([^>]*)>', "<span\1\2>", "all")>
				<cfset contentAdjusted = ReReplaceNoCase(contentAdjusted, '<div([^>]*) style="MARGIN[^"]*"([^>]*)>', "<div\1\2>", "all")>
				<cfset isContentChanged = true>
			</cfif>
			<cfif arguments.process>
				<!--- Add page links to content --->
				<cfif FindNoCase("[Links]",Contents) OR ( ListFindNoCase(qPages.ColumnList,"NumPageLinks") AND NumPageLinks GT 0 )>
					<cfset LinksHTML = variables.CMS.PageLinks.getPageLinksHTML(PageID)>
					<cfif FindNoCase("[Links]",Contents)>
						<cfset contentAdjusted = ReplaceNoCase(contentAdjusted,"[Links]",LinksHTML,"ALL")>
					<cfelse>
						<cfset contentAdjusted = contentAdjusted & LinksHTML>
					</cfif>
				</cfif>
			</cfif>
			<cfif isContentChanged>
				<cfset QuerySetCell(qPages, "Contents", contentAdjusted, CurrentRow)>
			</cfif>
		</cfif>
		<!--- Create full FileOutput --->
		<cfif ListFindNoCase(qPages.ColumnList,"FileOutput") AND StructKeyExists(arguments,"skeleton")>
			<cfset QuerySetCell(qPages, "FileOutput", arguments.skeleton, CurrentRow)>
			<cfloop index="col" list="#ColumnList#">
				<cfset QuerySetCell(qPages, "FileOutput", ReplaceNoCase(FileOutput, "[#col#]", qPages[col][CurrentRow], "ALL"), CurrentRow)>
			</cfloop>
		</cfif>
	</cfoutput>
	<cfif ArrayLen(aIsInMenu)>
		<cfset QueryAddColumn(qPages,"isInMenu","Bit",aIsInMenu)>
	</cfif>
	
	<cfreturn qPages>
</cffunction>

<cffunction name="findAvailableFileName" access="private" returntype="string" output="false" hint="">
	<cfargument name="FileName" type="string" required="yes">
	<cfargument name="PageID" type="numeric" required="no">
	<cfargument name="SectionID" type="numeric" required="no">
	
	<cfset var FilePrefix = reverse(ListRest(reverse(arguments.FileName),"."))>
	<cfset var FileSuffix = reverse(ListFirst(reverse(arguments.FileName),"."))>
	<cfset var ii = 1>
	
	<cfloop condition="#ii# LTE 1000 AND #isFileExisting(argumentCollection=arguments)#">
		<cfset arguments.FileName = "#FilePrefix#_#ii#.#FileSuffix#">
		<cfset ii = ii + 1>
	</cfloop>
	
	<cfreturn arguments.FileName>
</cffunction>

<cffunction name="isFileExisting" access="private" returntype="boolean" output="false" hint="">
	<cfargument name="FileName" type="string" required="yes">
	<cfargument name="PageID" type="numeric" required="no">
	<cfargument name="SectionID" type="numeric" required="no">
	<cfargument name="URLPath" type="string" required="no">
	
	<cfset var qCheckFileName = 0>
	<cfset var qPageOld = 0>
	<cfset var TargetPath = "">
	<cfset var result = false>
	<cfset var FileContents = "">
	
	<cfset arguments.FileName = variables.CMS.FileNameFromString(arguments.FileName)>
	
	<cfif NOT StructKeyExists(arguments,"SectionID")>
		<cfif StructKeyExists(arguments,"PageID")>
			<cfset qPageOld = getPage(arguments.PageID)>
			<cfset arguments.SectionID = qPageOld.SectionID>
		<cfelse>
			<cfset arguments.SectionID = 0>
		</cfif>
	</cfif>
	
	<cfset TargetPath = variables.CMS.getFullFilePath(ArgumentCollection=Arguments)>
	
	<cfif FileExists(TargetPath)>
		<cfif StructKeyExists(arguments,"PageID")>
			<cffile action="read" file="#TargetPath#" variable="FileContents">
			<cfif NOT FindNoCase("getPage(#arguments.PageID#)",FileContents)>
				<cfset result = true>
			</cfif>
		<cfelse>
			<cfset result = true>
		</cfif>
	</cfif>
	
	<cfif NOT result>
		<cfquery name="qCheckFileName" datasource="#variables.datasource#">
		SELECT	PageID,SectionID,FileName,URLPath
		FROM	cmsPages
		WHERE	FileName = <cfqueryparam value="#arguments.FileName#" cfsqltype="CF_SQL_VARCHAR">
		<cfif StructKeyExists(arguments,"PageID")>
			AND	PageID <> <cfqueryparam value="#arguments.PageID#" cfsqltype="CF_SQL_INTEGER">
		</cfif>
			AND	(isDeleted = #variables.DataMgr.getBooleanSqlValue(false)# OR isDeleted IS NULL)
		</cfquery>
		
		<cfif qCheckFileName.RecordCount>
			<cfif TargetPath EQ variables.CMS.getFullFilePath(SectionID=Val(qCheckFileName.SectionID),FileName=qCheckFileName.FileName,URLPath=qCheckFileName.URLPath)>
				<cfset isExistingFile = true>
			</cfif>
		</cfif>
	</cfif>
	
	<cfreturn result>
</cffunction>

</cfcomponent>