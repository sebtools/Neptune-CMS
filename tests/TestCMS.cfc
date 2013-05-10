<cfcomponent displayname="CMS" extends="com.sebtools.RecordsTester" output="no">

<cffunction name="setUp" access="public" returntype="void" output="no">
	
	<cfset loadExternalVars("CMS")>
</cffunction>

<cffunction name="shouldAddPageAddNewPage" access="public" output="false" returntype="void" 
	mxunit:transaction="rollback"
	hint="I check to see if the addPage method adds a new page."
>
	
	<cfset var qExistingPages = Variables.CMS.Pages.getPages(fieldList="URLPath,PageID")>
	<cfset var UUID = createUUID()>
	<cfset var sArgs = StructNew()>
	<cfset var PageID = 0>
	
	<cfset sArgs.Title=UUID>
	<cfset sArgs.Contents="My Contents">
	<cfset sArgs.URLPath='/' & UUID & '.cfm'>
	
	<cftry>		
		<cfset PageID = variables.CMS.Pages.addPage(ArgumentCollection=sArgs)>
		<cfcatch type="any">
			<cfset fail("The page wasn't added.")>
		</cfcatch> 
	</cftry>
	<cfif PageID EQ 0>
		<cfset fail("The page wasn't added.")>
	</cfif>
	
</cffunction> 

<cffunction name="shouldAddPagePreventDuplicateURLPath" access="public" output="false" returntype="void" 
	mxunit:transaction="rollback"
	hint="I check to see if the addPage method correctly prevents a duplicate URLPath."
>
				
	<cfset var TestPageID = saveTestRecord(Variables.CMS.Pages)>
	<cfset var qExistingPage = Variables.CMS.Pages.getPage(PageID=TestPageID)>
	<cfset var sArgs = StructNew()>
	<cfset var NewPageID = 0>
	
	<cfset sArgs.URLPath = qExistingPage.URLPath>
	<cfset sArgs.Title = "My Title">
	<cfset sArgs.Contents = "My Contents">
	
	<cfset NewPageID = variables.CMS.Pages.addPage(ArgumentCollection=sArgs)>
	<cfset assertTrue(NewPageID EQ TestPageID,"A page with a duplicated URLPath was added.")>
	
</cffunction> 
	
</cfcomponent>