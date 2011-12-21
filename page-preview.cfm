<!--- Param form fields --->
<cfset fields = "Title,Description,Keywords,Contents,Contents2,SectionID">
<cfloop index="field" list="#fields#"><cfparam name="Form.#field#" default=""></cfloop>

<cfif StructKeyExists(Form,"PageID") AND StructKeyExists(Form,"PageVersionID")>
	<cfinvoke component="#Application.CMS#" method="getPage" returnvariable="qPage">
		<cfinvokeargument name="PageID" value="#Val(Form.PageID)#">
		<cfinvokeargument name="PageVersionID" value="#val(Form.PageVersionID)#">
	</cfinvoke>
	<cfif qPage.RecordCount>
		<cfloop index="col" list="#fields#">
			<!--- <cfset Form[col] = qPage[col][1]> --->
			<cfset QuerySetCell(qPage,col,Form[col],1)>
		</cfloop>
	</cfif>
<cfelseif StructKeyExists(Form,"pkfield")>
	<cfinvoke component="#Application.CMS#" method="getPage" returnvariable="qPage">
		<cfinvokeargument name="PageID" value="#Val(Form.pkfield)#">
	</cfinvoke>
	<cfif qPage.RecordCount>
		<cfloop index="col" list="#qPage.ColumnList#">
			<cfif StructKeyExists(Form,col) AND Len(Form[col])>
				<cfset QuerySetCell(qPage,col,Form[col],1)>
			<cfelse>
				<cfset Form[col] = qPage[col][1]>
			</cfif>
		</cfloop>
	</cfif>
</cfif>
<cfif NOT ( isDefined("qPage") AND isQuery(qPage) )>
	<cfset qPage = QueryNew(fields)>
</cfif>
<cfif NOT qPage.RecordCount>
	<cfset QueryAddRow(qPage)>
	<cfloop index="col" list="#fields#">
		<cfset QuerySetCell(qPage,col,Form[col],1)>
	</cfloop>
</cfif>

<cf_layout switch="Default">
<cfinclude template="_config/_template.cfm">