<cfcomponent displayname="Content Management System" hint="I manage the content and pages for a site." extends="com.sebtools.ProgramManager">

<cfset variables.prefix = "cms">

<cffunction name="init" access="public" returntype="any" output="no" hint="I initialize and return this object.">
	<cfargument name="Manager" type="any" required="yes">
	<cfargument name="RootPath" type="string" hint="The absolute path to the root directory in which any files should be saved.">
	<cfargument name="createDefaultSection" type="boolean" default="true">
	<cfargument name="SiteMapMgr" type="any" required="no" hint="An instantiated SiteMapMgr component.">
	<cfargument name="skeleton" type="string" default="">
	<cfargument name="OnlyOverwriteCMS" type="boolean" default="true">
	<cfargument name="Searcher" type="any" required="false">
	<cfargument name="Settings" type="any" required="false">
	
	<cfif NOT Len(Arguments.skeleton)>
		<cfset Arguments.skeleton = '<!--- nosearchy ---><cfset qPage = Application.CMS.getPage([PageID])>
<cfinclude template="/admin/cms/_config/_template.cfm">'>
	</cfif>
	
	<cfset initInternal(argumentCollection=arguments)>
	
	<!--- If SiteMapMgr is passed, set some observers on it --->
	<cfif StructKeyExists(arguments,"SiteMapMgr")>
		<cfset throwError("Interaction with SiteMapMgr is no longer supported in this version of CMS, sorry.","NoSiteMapMgr")>
	</cfif>
	
	<cfset loadInitialData()>
	
	<cfreturn This>
</cffunction>

<cffunction name="getComponentsList" access="public" returntype="string" output="false" hint="">
	
	<cfreturn "">
</cffunction>

<cffunction name="loadInitialData" access="private" returntype="void" output="false" hint="">
	
	<cfif NOT This.SiteVersions.hasSiteVersions()>
		<cfinvoke method="setSiteVersion">
			<cfinvokeargument name="SiteName" value="main">
			<cfinvokeargument name="isDefault" value="True">
		</cfinvoke>
	</cfif>
	
	<cfif variables.createDefaultSection AND NOT This.Sections.hasSections()>
		<cfinvoke method="setSection">
			<cfinvokeargument name="SectionTitle" value="main">
		</cfinvoke>
	</cfif>
	
</cffunction>

<cffunction name="setSearcher" access="public" returntype="void" output="false" hint="">
	<cfargument name="Searcher" type="any" required="yes">
	
	<cfset variables.Searcher = arguments.Searcher>
	
</cffunction>

<cffunction name="adjustContent" access="public" returntype="string" output="no">
	<cfargument name="Contents" types="string" required="yes">
	
	<cfset var qContentFiles = getContentFiles()>
	<cfset var ContentFileCode = "">
	<cfset var output = arguments.Contents>
	
	<cfloop query="qContentFiles">
		<cfif FindNoCase("{#Label#}",output)>
			<cfsavecontent variable="ContentFileCode"><cfinclude template="#PathBrowser#"></cfsavecontent>
			<cfset output = ReplaceNoCase(output, "{#Label#}", ContentFileCode, "ALL")>
		</cfif>
	</cfloop>
	
	<cfif StructKeyExists(Variables,"Settings") AND StructKeyExists(Variables.Settings,"populate")>
		<cfset output = Variables.Settings.populate(output)>
	</cfif>
	
	<cfreturn output>
</cffunction>

<cffunction name="getFullFilePath" access="public" returntype="string">
	<cfargument name="SectionID" type="numeric" required="yes">
	<cfargument name="FileName" type="string" required="yes">
	<cfargument name="UrlPath" type="string" required="no">
	
	<cfset var result = variables.RootPath>
	
	<cfif StructKeyExists(Arguments,"UrlPath") AND Len(Arguments.UrlPath)>
		<cfset result = result & Right(UrlPath,Len(UrlPath)-1)>
	<cfelse>
		<cfset result = result & getSectionPath(SectionID) & FileName>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="getRootPath" access="public" returntype="string" output="no">
	<cfreturn variables.RootPath>
</cffunction>

<cffunction name="getSiteLinks" access="public" returntype="query" output="no">
	
	<cfset var qLinks = 0>
	
	<cf_DMQuery name="qLinks">
	SELECT		cmsSections.SectionID,SectionTitle,SectionLink,
				LinkID,Label,LinkURL
	FROM		cmsSections
	LEFT JOIN	cmsLinks
		ON		cmsSections.SectionID = cmsLinks.SectionID
	WHERE		1 = 1
	<cf_DMSQL tablename="cmsSections" method="getWhereSQL" data="#Arguments#">
	ORDER BY	cmsSections.ordernum, cmsLinks.ordernum
	</cf_DMQuery>
	
	<cfreturn qLinks>
</cffunction>

<cffunction name="getSiteMap" access="public" returntype="query" output="false" hint="">
	
	<cfset var qSitemap = QueryNew("SectionID,PageID,SectionTitle,Title")>
	<cfset var TblPages = This.Pages.getTableVariable()>
	<cfset var TblSections = This.Sections.getTableVariable()>
	
	<cfif variables.DataMgr.getDatabase() NEQ "Sim">
		<cfquery name="qSitemap" datasource="#variables.datasource#">
		SELECT		Sections.SectionID,
					Sections.SectionTitle,
					Pages.PageID,
					Pages.Title
		FROM		#TblSections# Sections
		LEFT JOIN	#TblPages# Pages
			ON		Sections.SectionID = Pages.SectionID
		ORDER BY	Sections.OrderNum
		</cfquery>
	</cfif>
	
	<cfreturn qSitemap>
</cffunction>

<cffunction name="getSkeleton" access="package" returntype="string" output="no">
	<cfreturn variables.skeleton>
</cffunction>

<cffunction name="getUrlPath" access="public" returntype="string" output="no">
	<cfargument name="SectionID" type="numeric" required="yes">
	<cfargument name="FileName" type="string" required="yes">
	
	<cfset var result = ReplaceNoCase(getSectionPath(arguments.SectionID), "\", "/", "ALL") & arguments.FileName>
	
	<cfif Left(result,1) NEQ "/">
		<cfset result = "/" & result>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="getSectionPath" access="public" returntype="string" output="no">
	<cfargument name="SectionID" type="numeric" required="yes">
	
	<cfset var qSection = variables.DataMgr.getRecord(tablename=This.Sections.getTableVariable(),data=arguments,fieldlist="SectionID,SectionDir,ParentSectionID")>
	<cfset var result = qSection.SectionDir>
	
	<cfif Len(qSection.ParentSectionID) AND qSection.ParentSectionID GT 0>
		<cfset result = getSectionPath(qSection.ParentSectionID) & result>
	</cfif>
	
	<cfif Len(result)>
		<cfset result = result & "/">
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="hasPagesNoLinks" access="public" returntype="boolean" output="no" hint="I return all of the links in the given section.">
	
	<cfset var result = false>
	
	<cfif This.Links.numLinks() EQ 0 AND This.Pages.hasPages() GT 0>
		<cfset result = true>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="makeFiles" access="public" returntype="void" output="no" hint="I make a file for each active page. Each file will be placed in the RootPath given to this component (or a subdirectory thereof).">
	<cfargument name="skeleton" type="string" required="false" hint="The HTML skeleton to feed the contents of the page into. The name of any field can be placed in brackets and will be replaced by the contents of that field for the given page. For example, to place the contents of the page, use [Contents] as place-holder.">
	<cfargument name="overwrite" type="boolean" default="true" hint="Should an existing file be overwritten. If false, makeFiles() will not create a file if it already exists.">
	
	<cfif NOT StructKeyExists(arguments,"skeleton")>
		<cfset arguments.skeleton = getSkeleton()>
	</cfif>
	
	<cfset writeFiles(skeleton=skeleton,overwrite=overwrite)>
	
</cffunction>

<cffunction name="makeLinks" access="public" returntype="void" output="no">
	
	<cfset var qSections = 0>
	<cfset var qPages = 0>
	
	<cfif NOT hasPagesNoLinks()>
		<cfset throwError("This can only be done if the site does not already have links.","MakeLinksOnlyWithNoLinks")>
	</cfif>
	
	<cfset qSections = This.Sections.getSections(fieldlist="SectionID")>
	
	<cfloop query="qSections">
		<cfset qPages = This.Pages.getPages(SectionID=SectionID)>
		<cfoutput query="qPages">
			<cfset This.Links.saveLink(SectionID=SectionID,LinkURL=UrlPath,Label=Title)>
		</cfoutput>
	</cfloop>
	
</cffunction>

<cffunction name="restoreVersion" access="public" returntype="any" output="no" hint="I restore an old version of a page.">
	<cfargument name="PageID" type="numeric" required="yes" hint="The PageID of the page being restored.">
	<cfargument name="PageVersionID" type="numeric" required="yes" hint="The PageVersion ID of the version being restored.">
	<cfargument name="SiteVersionID" type="numeric" required="no" hint="The Site Version for this page. Use as default if left blank.">
	
	<cfset var qPage = 0>
	<cfset var sPage = StructNew()>
	
	<!--- Make this version the live version --->
	<cftry>
		<cfquery datasource="#variables.datasource#">
		INSERT INTO #variables.prefix#Pages2Versions
		SELECT	#Val(arguments.PageID)#,
				<cfif StructKeyExists(arguments,"SiteVersionID")>#Val(arguments.SiteVersionID)#<cfelse>0</cfif>,
				#Val(arguments.PageVersionID)#
		<cfif variables.DataMgr.getDatabase() NEQ "MYSQL">
		WHERE	NOT EXISTS (
					SELECT	PageVersionID
					FROM	#variables.prefix#Pages2Versions
					WHERE	PageID = #Val(arguments.PageID)#
						AND	PageVersionID = #Val(arguments.PageVersionID)#
					<cfif StructKeyExists(arguments,"SiteVersionID")>
						AND	SiteVersionID = #Val(arguments.SiteVersionID)#
					<cfelse>
						AND	(SiteVersionID IS NULL OR SiteVersionID = 0)
					</cfif>
				)
		</cfif>
		</cfquery>
		<cfcatch>
		</cfcatch>
	</cftry>
	<cfquery datasource="#variables.datasource#">
	DELETE
	FROM	#variables.prefix#Pages2Versions
	WHERE	PageID = #Val(arguments.PageID)#
		AND	PageVersionID <> #Val(arguments.PageVersionID)#
	<cfif StructKeyExists(arguments,"SiteVersionID")>
		AND	SiteVersionID = #Val(arguments.SiteVersionID)#
	<cfelse>
		AND	(SiteVersionID IS NULL OR SiteVersionID = 0)
	</cfif>
	</cfquery>
	<cfquery datasource="#variables.datasource#">
	UPDATE	#variables.prefix#Pages2Versions
	SET		PageVersionID = #Val(arguments.PageVersionID)#
	WHERE	PageID = #Val(arguments.PageID)#
	<cfif StructKeyExists(arguments,"SiteVersionID")>
		AND	SiteVersionID = #Val(arguments.SiteVersionID)#
	<cfelse>
		AND	(SiteVersionID IS NULL OR SiteVersionID = 0)
	</cfif>
	</cfquery>
	
	<cfquery name="qPage" datasource="#variables.datasource#">
	SELECT	Title,Description,Keywords,Contents,Contents2
	FROM	#variables.prefix#PageVersions
	WHERE	PageVersionID = #Val(arguments.PageVersionID)#
	</cfquery>
	<cfset sPage["PageID"] = arguments.PageID>
	<cfset sPage["Title"] = qPage.Title>
	<cfset sPage["Description"] = qPage.Description>
	<cfset sPage["Keywords"] = qPage.Keywords>
	<cfset sPage["Contents"] = qPage.Contents>
	<cfset sPage["Contents2"] = qPage.Contents2>
	
	<cfset variables.DataMgr.updateRecord(This.Pages.getTableVariable(),sPage)>
	
</cffunction>

<cffunction name="LineBreaker" access="public" returntype="string" output="false">
	<cfargument name="str" type="string" required="yes">
	
	<cfset var result = arguments.str>
	
	<cfset result = ReplaceNoCase(result,"#chr(13)##chr(10)#","<br />","ALL")>
	<cfset result = ReplaceNoCase(result,"#chr(10)##chr(13)#","<br />","ALL")>
	<cfset result = ReplaceNoCase(result,"#chr(10)#","<br />","ALL")>
	<cfset result = ReplaceNoCase(result,"#chr(13)#","<br />","ALL")>
	
	<cfreturn result>
</cffunction>

<cffunction name="PathNameFromString" access="public" returntype="string" output="false" hint="">
	<cfargument name="string" type="string" required="yes">
	
	<cfset var reChars = "([0-9]|[a-z]|[A-Z])">
	<cfset var ii = 0>
	<cfset var result = "">
	
	<cfloop index="ii" from="1" to="#Len(string)#" step="1">
		<cfif REFindNoCase(reChars, Mid(string,ii,1))>
			<cfset result = result & Mid(string,ii,1)>
		<cfelse>
			<cfset result = result & "-">
		</cfif>
	</cfloop>
	
	<cfset result = REReplaceNoCase(result, "_{2,}", "_", "ALL")>
	<cfset result = REReplaceNoCase(result, "-{2,}", "-", "ALL")>
	<cfset result = REReplaceNoCase(result, "-$", "", "ALL")>
	<cfset result = REReplaceNoCase(result, "^-", "", "ALL")>
	
	<cfreturn LCase(result)>
</cffunction>

<cffunction name="FileNameFromString" access="public" returntype="string" output="no">
	<cfargument name="string" type="string" required="yes">
	
	<cfset var reChars = "([0-9]|[a-z]|[A-Z])">
	<cfset var exts = "cfm,htm,html">
	<cfset var ii = 0>
	<cfset var result = "">
	<cfset var ext = ListLast(string,".")>
	
	<cfif Len(ext) AND ListFindNoCase(exts,ext) AND (Len(string)-Len(ext)-1) gt 0>
		<cfset string = Left(string,Len(string)-Len(ext)-1)>
	</cfif>
	
	<cfset result = PathNameFromString(arguments.string)>

	<cfif Len(result)>
		<cfif Len(ext) AND ListFindNoCase(exts,ext)>
			<cfset result = "#result#.#ext#">
		<cfelse>
			<cfset result = "#result#.#ListFirst(exts)#">
		</cfif>
	</cfif>
	
	<cfreturn LCase(result)>
</cffunction>

<cffunction name="indexSearch" access="public" returntype="any" output="false" hint="">
	
	<cfif StructKeyExists(variables,"Searcher")>
		<cfset variables.Searcher.scheduleIndex()>
	</cfif>
	
</cffunction>

<cffunction name="writeFile" access="public" returntype="void" output="no" hint="I make a file for each active page. Each file will be placed in the RootPath given to this component (or a subdirectory thereof).">
	<cfargument name="PageID" type="numeric" required="yes">
	<cfargument name="skeleton" type="string" required="no" hint="The HTML skeleton to feed the contents of the page into. The name of any field can be placed in brackets and will be replaced by the contents of that field for the given page. For example, to place the contents of the page, use [Contents] as place-holder.">
	<cfargument name="overwrite" type="boolean" default="true" hint="Should an existing file be overwritten. If false, makeFiles() will not create a file if it already exists.">
	
	<cfset var qPage = getPage(arguments.PageID)>
	<cfset var output = "">
	<cfset var col = "">
	
	<cfset var precode = "">
	<cfset var isCmsPage = false>
	<cfset var queryline = "<cfset qPage = Application.CMS.getPage([PageID])>">
	<cfset var CRLF = "
">
	
	<cfif NOT StructKeyExists(arguments,"skeleton")>
		<cfset arguments.skeleton = getSkeleton()>
	</cfif>
	<cfset output = arguments.skeleton>
	
	<cfif NOT FindNoCase(queryline,output)>
		<cfset output = "#queryline##CRLF##output#">
	</cfif>
	
	<cfloop index="col" list="#qPage.ColumnList#">
		<cfset output = ReplaceNoCase(output, "[#col#]", qPage[col][1], "ALL")>
	</cfloop>
	
	<cfif Len(qPage.FileName) AND Len(output)>
		<cfif FileExists(qPage.FullFilePath)>
			<!--- Only overwrite existing pages if overwrite argument is true and page is a CMS page --->
			<cfif arguments.overwrite>
				<cfset isCmsPage = false>
				<cffile action="READ" file="#qPage.FullFilePath#" variable="precode">
				<cfif FindNoCase("CMS", precode) AND FindNoCase("nosearchy", precode)>
					<cfset isCmsPage = true>
				</cfif>
				<!--- Overwrite CMS pages, otherwise delete --->
				<cfif isCmsPage OR NOT variables.OnlyOverwriteCMS>
					<cfif NOT FindNoCase("nowritey", precode)>
						<cffile action="WRITE" file="#qPage.FullFilePath#" output="#output#">
					</cfif>
				<cfelse>
					<cfset deletePage(arguments.PageID)>
				</cfif>
			</cfif>
		<cfelse>
			
			<cfif NOT DirectoryExists(getDirectoryFromPath(qPage.FullFilePath))>
				<cfdirectory directory="#getDirectoryFromPath(qPage.FullFilePath)#" action="create">
			</cfif>
			
			<cffile action="WRITE" file="#qPage.FullFilePath#" output="#output#">
		</cfif>
	</cfif>
	
</cffunction>

<!--- *** Present for backwards compatibility with old CMS installations *** --->
<cffunction name="deletePage" access="public" returntype="void" output="no">
	<cfargument name="PageID" type="numeric" required="yes">
	
	<cfreturn This.Pages.removePage(argumentCollection=arguments)>
</cffunction>

<cffunction name="deleteSection" access="public" returntype="void" output="no">
	<cfargument name="SectionID" type="numeric" required="yes">
	
	<cfreturn This.Sections.removeSection(argumentCollection=arguments)>
</cffunction>

<cffunction name="getContentFiles" access="public" returntype="query" output="no">
	<cfreturn This.ContentFiles.getContentFiles(argumentCollection=arguments)>
</cffunction>

<cffunction name="addPage" access="public" returntype="numeric" output="false" hint="I add a page after checking for its existence.">
	<cfreturn Variables.Pages.addPage(ArgumentCollection=Arguments)>
</cffunction>

<cffunction name="getPage" access="public" returntype="query" output="no" hint="I get all of the information for the given page.">
	<cfargument name="PageID" type="numeric" required="yes">
	<cfargument name="SiteVersionID" type="numeric" required="no">
	<cfargument name="PageVersionID" type="numeric" required="no">
	
	<cfreturn This.Pages.getPage(argumentCollection=arguments)>
</cffunction>

<cffunction name="getAllPages" access="public" returntype="query" output="no" hint="I return all of the pages in the given section.">
	<cfargument name="skeleton" type="string" required="no" hint="The HTML skeleton to feed the contents of the page into. The name of any field can be placed in brackets and will be replaced by the contents of that field for the given page. For example, to place the contents of the page, use [Contents] as place-holder.">

	<cfreturn This.Pages.getAllPages(argumentCollection=arguments)>
</cffunction>

<cffunction name="getLivePages" access="public" returntype="query" output="no" hint="I return all of the pages in the given section.">
	<cfargument name="SectionID" type="numeric" required="no">
	
	<cfreturn getPublicPages(argumentCollection=arguments)>
</cffunction>

<cffunction name="getLiveSections" access="public" returntype="query" output="no" hint="I return all of the pages in the given section.">
	
	<cfreturn getPublicSections(argumentCollection=arguments)>
</cffunction>

<cffunction name="getPublicPages" access="public" returntype="query" output="no" hint="I return all of the pages in the given section.">
	<cfargument name="SectionID" type="numeric" required="no">
	
	<cfset arguments.isLive = true>
	
	<cfreturn This.Pages.getPages(argumentCollection=arguments)>
</cffunction>

<cffunction name="getPublicSections" access="public" returntype="query" output="no" hint="I return all of the pages in the given section.">
	
	<cfset arguments.isSectionLive = true>
	<cfset arguments.hasLinks = true>
	
	<cfreturn This.Sections.getSections(argumentCollection=arguments)>
</cffunction>

<cffunction name="getPages" access="public" returntype="query" output="no" hint="I return all of the pages in the given section.">
	<cfargument name="SectionID" type="numeric" required="no">
	
	<cfreturn This.Pages.getPages(argumentCollection=arguments)>
</cffunction>

<cffunction name="getPageVersion" access="public" returntype="query" output="no" hint="I return every version (archived and current) for the given page.">
	<cfargument name="PageVersionID" type="numeric" required="yes">
	
	<cfreturn This.PageVersions.getPageVersion(argumentCollection=arguments)>
</cffunction>

<cffunction name="getPageVersions" access="public" returntype="query" output="no" hint="I return every version (archived and current) for the given page.">
	<cfargument name="PageID" type="numeric" required="yes">
	<cfargument name="SiteVersionID" type="numeric">
	
	<cfreturn This.PageVersions.getPageVersions(argumentCollection=arguments)>
</cffunction>

<cffunction name="getTopSectionID" access="public" returntype="numeric" output="no">
	<cfargument name="SectionID" type="numeric" default="0">
	
	<cfreturn This.Sections.getTopSectionID(argumentCollection=arguments)>
</cffunction>

<cffunction name="getSection" access="public" returntype="query" output="no">
	<cfargument name="SectionID" type="numeric" default="0">
	
	<cfreturn This.Sections.getSection(argumentCollection=arguments)>
</cffunction>

<cffunction name="getSectionIDFromDir" access="public" returntype="numeric" output="no">
	<cfargument name="SectionDir" type="string" default="0">
	
	<cfreturn This.Sections.getSectionIDFromDir(argumentCollection=arguments)>
</cffunction>

<cffunction name="getSections" access="public" returntype="query" output="no">
	<cfargument name="ParentSectionID" type="numeric" required="no">
	
	<cfreturn This.Sections.getSections(argumentCollection=arguments)>
</cffunction>

<cffunction name="getLinks" access="public" returntype="query" output="no" hint="I return all of the links in the given section.">
	<cfargument name="SectionID" type="numeric" required="no">
	
	<cfreturn This.Links.getLinks(argumentCollection=arguments)>
</cffunction>

<cffunction name="saveContentFile" access="public" returntype="numeric" output="no">
	<cfargument name="Label" type="string" required="yes">
	<cfargument name="PathBrowser" type="string" required="no">
	<cfargument name="PathFile" type="string" required="no">
	
	<cfreturn This.ContentFiles.saveContentFile(argumentCollection=arguments)>
</cffunction>

<cffunction name="savePage" access="public" returntype="numeric" output="no" hint="I create or update a page and return the PageID.">
	<cfreturn setPage(argumentCollection=arguments)>
</cffunction>

<cffunction name="setPage" access="public" returntype="numeric" output="no" hint="I create or update a page and return the PageID.">
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
	<cfargument name="skeleton" type="string" default="#variables.skeleton#">
	
	<cfreturn This.Pages.savePage(argumentCollection=arguments)>
</cffunction>

<cffunction name="copyPage" access="public" returntype="void" output="no">
	<cfargument name="PageID" type="numeric" required="yes">
	<cfargument name="FileName" type="string" required="yes">
	<cfargument name="SectionID" type="string" required="no">
	
	<cfreturn This.Pages.copyPage(argumentCollection=arguments)>
</cffunction>

<cffunction name="renamePageFile" access="public" returntype="void" output="no">
	<cfargument name="PageID" type="numeric" required="yes">
	<cfargument name="FileName" type="string" required="yes">
	
	<cfreturn This.Pages.renamePageFile(argumentCollection=arguments)>
</cffunction>

<cffunction name="makeFileName" access="public" returntype="void" output="no">
	<cfargument name="PageID" type="numeric" required="yes">
	
	<cfreturn This.Pages.makeFileName(argumentCollection=arguments)>
</cffunction>

<cffunction name="makePageName" access="public" returntype="void" output="no">
	<cfargument name="PageID" type="numeric" required="yes">
	
	<cfreturn This.Pages.makePageName(argumentCollection=arguments)>
</cffunction>

<cffunction name="setSection" access="public" returntype="numeric" output="no" hint="I create or update a section and return the SectionID.">
	<cfargument name="SectionID" type="numeric" hint="New section created if not passed in.">
	<cfargument name="ParentSectionID" type="numeric">
	<cfargument name="OrderNum" type="numeric" hint="Used for ordering query results.">
	<cfargument name="SectionTitle" type="string">
	<cfargument name="Description" type="string">
	<cfargument name="Keywords" type="string">
	<cfargument name="SectionLink" type="string" hint="An optional primary link for this section.">
	<cfargument name="SectionDir" type="string" hint="A folder path for this section.">
	<cfargument name="SectionImage2" type="string" hint="A Level 2 section header.">
	<cfargument name="SectionImage3" type="string" hint="A Level 3 section header.">
	<cfargument name="SectionSubnavHead" type="string" hint="A background for the section subnav header.">
	
	<cfreturn This.Sections.saveSection(argumentCollection=arguments)>
</cffunction>

<cffunction name="setSiteVersion" access="public" returntype="numeric" output="no" hint="I create/update a site version and return the SiteVersionID. A version of a site could represent a language or other variations of the same site.">
	<cfargument name="SiteVersionID" type="numeric" hint="New site version created if not passed in.">
	<cfargument name="SiteName" type="string" required="yes">
	<cfargument name="DomainRoot" type="string">
	<cfargument name="isDefault" type="boolean">
	
	<cfreturn This.SiteVersions.saveSiteVersion(argumentCollection=arguments)>
</cffunction>

<cffunction name="orderSections" access="public" returntype="void" output="no" hint="I save the order of the given sections.">
	<cfargument name="ParentSectionID" type="numeric" required="no">
	<cfargument name="Sections" type="string" required="no">
	
	<cfset This.Sections.sortSections(argumentCollection=arguments)>
	
</cffunction>

<cffunction name="writeFiles" access="public" returntype="void" output="no" hint="I make a file for each active page. Each file will be placed in the RootPath given to this component (or a subdirectory thereof).">
	<cfargument name="skeleton" type="string" required="yes" hint="The HTML skeleton to feed the contents of the page into. The name of any field can be placed in brackets and will be replaced by the contents of that field for the given page. For example, to place the contents of the page, use [Contents] as place-holder.">
	<cfargument name="overwrite" type="boolean" default="true" hint="Should an existing file be overwritten. If false, makeFiles() will not create a file if it already exists.">
	
	<cfset var qPages = getAllPages(arguments.skeleton)>
	
	<cfloop query="qPages">
		<cfset writeFile(PageID=PageID,skeleton=arguments.skeleton,overwrite=arguments.overwrite)>
	</cfloop>
	
</cffunction>

<cffunction name="upgrade" access="public" returntype="any" output="false" hint="">
	
	<cfset upgradeParentSections()>
	<cfset upgradeURLPaths()>
	
</cffunction>

<cffunction name="upgradeParentSections" access="public" returntype="any" output="false" hint="">
	
	<cfset var sSet = StructNew()>
	<cfset var sWhere = StructNew()>
	
	<cfif This.Sections.hasSections(ParentSectionID="")>
		<cfset sSet["ParentSectionID"] = 0>
		<cfset sWhere["ParentSectionID"] = "">
		
		<cfset variables.DataMgr.updateRecords(tablename=This.Sections.getTableVariable(),data_set=sSet,data_where=sWhere)>
	</cfif>
	
</cffunction>

<cffunction name="upgradeURLPaths" access="public" returntype="any" output="false" hint="">
	
	<cfset var qPages = 0>
	
	<cfif NOT Variables.Pages.hasPages(hasUrlPath=true)>
		<cfset qPages = Variables.Pages.getPages(UrlPath="",fieldlist="PageID,SectionID,FileName")>
		
		<cfoutput query="qPages">
			<cfset Variables.Pages.saveRecord(
				PageID=PageID,
				UrlPath=getUrlPath(Val(SectionID),FileName)
			)>
		</cfoutput>
		
	</cfif>
	
</cffunction>

<cffunction name="cleanMSWord" access="public" returntype="string" output="false">
	<cfargument name="str" stype="string" required="yes">
<!---
Credits:
http://enabofaisal.wordpress.com/2011/07/28/cf-function-to-clean-ms-word-html-mess/
--->
	<cfset var result = Arguments.str>
	<cfset var start = 0>
	<cfset var end = 0>
	
	<cfif NOT Len(Trim(result))><cfreturn "" /></cfif>
	
	<!--- Remove MS Word's comments while allowing other comments --->
	<cfset result = ReReplaceNoCase(result,"(<!--\[if).*?(<!\[endif\]-->)","","ALL")>
	
	<!--- remove most of the unwanted HTML attributes with their values --->
	<cfset result = ReReplaceNoCase(result,'[ ]+(style|align|valign|dir|class|id|lang|width|height|nowrap)=".*?"',"","ALL")>
	
	<cfset result = ReReplace(result,"Mso.*?[#chr(34)#]",'"',"ALL")>
	<cfset result = Replace(result," class=''","","ALL")>
	<cfset result = Replace(result,' class=""',"","ALL")>
	
 	<cfset result = Replace(result,"&lsquo;","'","ALL")>
	<cfset result = Replace(result,"&rsquo;","'","ALL")>
	
	<cfset result = Replace(result,"&middot;","","ALL")>
	
	<cfscript>
	/*
	while ( FindNoCase("<span> </span>",result) ) {
		result = REReplace(result, "<span> </span>", " ", "ALL");
	}
	*/
	while ( FindNoCase("<span>",result) ) {
		start = FindNoCase("<span>",result);
		end = FindNoCase("</span>",result,start-1);
		result = Left(result,end-1) & Right(result,Len(result)-end-Len("</span>")+1);
		result = Left(result,start-1) & Right(result,Len(result)-start-Len("<span>")+1);
	}
	</cfscript>
	
	<!--- clean extra spaces & tabs --->
	<cfset result = REReplace(result, "(&nbsp;)", " ", "ALL")>
	<cfset result = REReplace(result, "\s{2,}", " ", "ALL")>
	
	<!--- remove empty <b> empty tags --->
 	<cfset result = REReplace(result, "<b>\s*</b>", "", "ALL") />
	<!--- remove empty <b> empty tags --->
 	<cfset result = REReplace(result, "<strong>\s*</strong>", "", "ALL") />
 	
 	<!--- remove empty <p> empty tags --->
 	<cfset result = REReplace(result, "<p>\s*", "<p>", "ALL") />
 	<cfset result = REReplace(result, "\s*</p>", "</p>", "ALL") />
 	<cfset result = REReplace(result, "<p></p>", "", "ALL") />
	 
	<cfreturn result>
</cffunction>

<cffunction name="xml" access="public" output="yes">
<tables prefix="#variables.prefix#">
	<table entity="Page" labelField="Title" folder="pages">
		<field fentity="Section" />
		<field fentity="Template" onRemoteDelete="Error" />
		<field name="PageName" Label="Page" type="text" Length="180" />
		<field name="FileName" Label="File Name" type="text" Length="240" />
		<field name="MapPageID" Label="Map Page" type="integer" />
		<field name="ImageFileName" Label="Image File Name" type="text" Length="180" />
		<field name="isDeleted" Label="is Deleted" type="DeletionMark" />
		<field name="Title" Label="Title" type="text" Length="250" required="true" />
		<field name="WhenCreated" Label="When Created" type="CreationDate" />
		<field name="Description" Label="Description" type="text" Length="240" />
		<field name="Keywords" Label="Keywords" type="text" Length="240" useInMultiRecordsets="false" />
		<field name="Contents" Label="Contents" type="html" useInMultiRecordsets="false" />
		<field name="Contents2" Label="Contents2" type="memo" useInMultiRecordsets="false" />
		<field name="isPageLive" Label="Live?" type="boolean" default="1" />
		<field name="IncludeFile" Label="Include File" type="text" Length="240" useInMultiRecordsets="false" />
		<field name="hasFileName">
			<relation type="has" field="FileName" />
		</field>
		<field name="FullFilePath">
			<relation type="custom" />
		</field>
		<field name="UrlPath" label="URL Path" type="text" Length="500" />
		<field name="hasUrlPath">
			<relation type="has" field="UrlPath" />
		</field>
		<field name="FileOutput" useInMultiRecordsets="false">
			<relation type="custom" />
		</field>
		<field name="WhenLastUpdated" useInMultiRecordsets="false">
			<relation type="max" entity="Page Version" field="WhenCreated" join-field="PageID" />
		</field>
		<field name="TemplateName" useInMultiRecordsets="false">
			<relation type="label" entity="Template" field="TemplateName" join-field="TemplateID" />
		</field>
		<field name="Layout" useInMultiRecordsets="false">
			<relation type="label" entity="Template" field="Layout" join-field="TemplateID" />
		</field>
		<field name="isLive" Label="Live?">
			<relation
				type="custom"
				sql="
					CASE
						WHEN	(
										isPageLive = #variables.DataMgr.getBooleanSqlValue(1)#
									AND	(
														SectionID = 0
													OR	EXISTS (
															SELECT	1
															FROM	#variables.prefix#Sections
															WHERE	SectionID = #variables.prefix#Pages.SectionID
																AND	SectionID > 0
																AND	isSectionLive = #variables.DataMgr.getBooleanSqlValue(1)#
													)
										)
								)
						THEN #variables.DataMgr.getBooleanSqlValue(1)#
						ELSE #variables.DataMgr.getBooleanSqlValue(0)#
					END
				"
				CF_DataType="CF_SQL_BIT"
			/>
		</field>
	</table>
	<table entity="Page Version" labelField="Title">
		<field fentity="Page" />
		<field fentity="Site Version" />
		<field name="Title" Label="Title" type="text" Length="250" />
		<field name="WhenCreated" Label="Date Created" type="CreationDate" />
		<field name="Description" Label="Description" type="text" Length="240" />
		<field name="Keywords" Label="Keywords" type="text" Length="240" />
		<field name="Contents" Label="Contents" type="memo" useInMultiRecordsets="false" />
		<field name="Contents2" Label="Contents2" type="memo" useInMultiRecordsets="false" />
		<field name="VersionDescription" label="Change Notes" type="text" Length="240" />
		<field name="VersionBy" Label="Creator/Editor" type="text" Length="80" />
	</table>
	<table entity="Section" labelField="SectionTitle">
		<field fentity="Section" Default="0" />
		<field name="parent" Label="Parent Section">
			<relation
				type="label"
				entity="Section"
				field="SectionTitle"
				join-field-local="ParentSectionID"
				join-field-remote="SectionID"
			/>
		</field>
		<field name="SectionTitle" Label="Section Title" type="text" Length="60" required="true" />
		<field name="Description" Label="Description" type="text" Length="240" />
		<field name="Keywords" Label="Keywords" type="text" Length="240" />
		<field name="SectionDir" Label="Section Dir" type="text" Length="240" />
		<field name="SectionLink" Label="Section Link" type="text" Length="240" />
		<field name="MainPageURL" Label="Main Page" type="text" Length="240" />
		<field name="MapSectionID" Label="Map Section" type="integer" />
		<field name="OrderNum" Label="Order Num" type="Sorter" />
		<field name="SectionLabelExt" Label="Section Label Ext" type="text" Length="240" />
		<field name="isSectionLive" Label="Live?" type="boolean" default="true" />
	</table>
	<table entity="Site Version" labelField="SiteName">
		<field name="SiteName" Label="Site Name" type="text" Length="80" />
		<field name="DomainRoot" Label="Domain Root" type="text" Length="140" />
		<field name="isDefault" Label="Is Default?" type="boolean" />
	</table>
	<table name="#variables.prefix#Pages2Versions">
		<field name="PageID" type="pk:integer" />
		<field name="SiteVersionID" type="pk:integer" />
		<field name="PageVersionID" type="pk:integer" />
	</table>
	<table entity="Content File" labelField="Label">
		<field name="Label" Label="Label" type="text" Length="120" />
		<field name="PathBrowser" Label="Path Browser" type="text" Length="240" />
		<field name="PathFile" Label="Path File" type="text" Length="240" />
		<field name="DateAdded" Label="Date Added" type="CreationDate" />
	</table>
	<table entity="Image" labelField="ImageFile" Specials="Sorter">
		<field fentity="Page" />
		<field name="ImageFile" Label="Image/Photo" type="image" Length="180" folder="page-images" nameconflict="MAKEUNIQUE" required="true" />
	</table>
	<table entity="Link" labelField="Label" Specials="CreationDate,LastUpdatedDate,Sorter">
		<field fentity="Section" required="true" />
		<field name="LinkURL" Label="Link" type="text" Length="120" />
		<field name="Label" Label="Link" type="text" Length="120" />
	</table>
	<table entity="Page Link" labelField="Title" Specials="CreationDate,LastUpdatedDate,Sorter">
		<field fentity="Page" required="true" />
		<field name="LinkedPageID" type="fk:integer" label="Linked Page" subcomp="Pages" required="true" />
		<field name="Title">
			<relation
				type="label"
				entity="Page"
				field="Title"
				join-field-local="LinkedPageID"
				join-field-remote="PageID"
			/>
		</field>
		<field name="Description">
			<relation
				type="label"
				entity="Page"
				field="Description"
				join-field-local="LinkedPageID"
				join-field-remote="PageID"
			/>
		</field>
		<field name="SectionID">
			<relation
				type="label"
				entity="Page"
				field="SectionID"
				join-field-local="LinkedPageID"
				join-field-remote="PageID"
			/>
		</field>
		<field name="FileName">
			<relation
				type="label"
				entity="Page"
				field="FileName"
				join-field-local="LinkedPageID"
				join-field-remote="PageID"
			/>
		</field>
		<field name="isLive">
			<relation
				type="label"
				entity="Page"
				field="isLive"
				join-field-local="LinkedPageID"
				join-field-remote="PageID"
			/>
		</field>
		<field name="UrlPath">
			<relation type="custom" />
		</field>
	</table>
	<table entity="Page Section" labelField="ImageFile">
		<field fentity="Page" />
		<field fentity="Template Section" />
		<field name="Contents" Label="Contents" type="memo" />
		<field name="Contents_Adjusted" Label="Contents_ Adjusted" type="memo" />
		<field name="ImageFile" Label="Image File" type="text" Length="120" />
	</table>
	<table entity="Template" labelField="TemplateName">
		<field name="TemplateName" Label="Template" type="text" Length="50" />
		<field name="Layout" Label="Layout" type="text" Length="50" />
		<field name="TemplateText" Label="Template Text" type="memo" />
		<field name="ImageSize" Label="Image Size" type="text" Length="50" />
		<field name="hasMultipleImages" Label="has Multiple Images" type="boolean" />
		<field name="NumContentAreas" Label="Num Content Areas" type="integer" />
		<field name="isDefaultTemplate" Label="Default Templatea" type="boolean" default="false" />
		<data>
			<row TemplateName="Default" isDefaultTemplate="true" />
		</data>
	</table>
	<table entity="Template Section" labelField="Marker">
		<field fentity="Template" onRemoteDelete="Cascade" />
		<field name="Marker" Label="Marker" type="text" Length="50" />
		<field name="Label" Label="Label" type="text" Length="80" />
		<field name="TemplateText" Label="Template Text" type="memo" />
		<field name="sort" Label="sort" type="Sorter" />
	</table>
</tables>
</cffunction>

<cfscript>
/**
 * Makes a row of a query into a structure.
 * 
 * @param query 	 The query to work with. 
 * @param row 	 Row number to check. Defaults to row 1. 
 * @return Returns a structure. 
 * @author Nathan Dintenfass (nathan@changemedia.com) 
 * @version 1, December 11, 2001 
 */
function queryRowToStruct(query) {
	var row = 1;//by default, do this to the first row of the query
	var ii = 1;//a var for looping
	var cols = listToArray(query.columnList);//the cols to loop over
	var stReturn = structnew();//the struct to return
	//if there is a second argument, use that for the row number
	if(arrayLen(arguments) GT 1)
		row = arguments[2];
	//loop over the cols and build the struct from the query row
	for(ii = 1; ii lte arraylen(cols); ii = ii + 1){
		stReturn[cols[ii]] = query[cols[ii]][row];
	}
	//return the struct
	return stReturn;
}
</cfscript>

<cffunction name="loadComponent" access="private" returntype="any" output="no" hint="I load a component into memory in this component.">
	<cfargument name="name" type="string" required="yes">
	
	<cfset var ext = getCustomExtension()>
	<cfset var extpath = "">
	
	<cfif NOT StructKeyExists(arguments,"path")>
		<cfset arguments.path = arguments.name>
	</cfif>
	
	<cfset extpath = "#getDirectoryFromPath(getCurrentTemplatePath())##arguments.path#_#ext#.cfc">
	
	<cfif Len(ext) AND FileExists(extpath)>
		<cfset arguments.path = "#arguments.path#_#ext#">
	</cfif>
	
	<cfset arguments["Manager"] = variables.Manager>
	<cfset arguments["Parent"] = This>
	<cfset arguments[variables.me.name] = This>
	
	<!---<cfinvoke component="#variables.me.path#.#arguments.path#" method="init" returnvariable="this.#name#" argumentCollection="#arguments#"></cfinvoke>--->
	<cfinvoke component="#arguments.path#" method="init" returnvariable="this.#name#" argumentCollection="#arguments#"></cfinvoke>
	
	<cfset variables[arguments.name] = This[arguments.name]>
	
</cffunction>

</cfcomponent>