<cf_PageController>

<cf_layout>
	<cfoutput><script type="text/javascript">sectionid = #URL.section#;</script></cfoutput>
	<script type="text/javascript" src="/lib/engine.js"></script>
	<script type="text/javascript" src="/lib/wddx.js"></script>
	<script type="text/javascript" src="link-edit.js?lu=2011-02-04"></script>
	<style type="text/css">
	label#lbl-URL, span#URL-val, span#URL-val a {color:#666666;text-decoration:none;}
	.sebForm-skin-deepblue label#lbl-URL, .sebForm-skin-deepblue span#URL-val, .sebForm-skin-deepblue span#URL-val a {color:#CCCCCC;}
	/*#row-URL, #div-URL {display:none;}*/
	</style>
<cf_layout showTitle="true">

<cfoutput>
<p><a href="section-list.cfm">Return to Sections</a></p>
<cfif isQuery(qSection)>
	<p><a href="link-list.cfm?section=#URL.section#">Return to #qSection.SectionTitle# link</a></p>
</cfif>
</cfoutput>

<p>You can add or edit a menu item here.</p>
<ul>
	<li><strong>Page</strong>: The page to which the menu item will point</li>
	<li><strong>Label</strong>: What will display for the menu item</li>
</ul>

<cf_sebForm>
	<cfif URL.section>
		<cf_sebField name="SectionID" type="hidden" setValue="#URL.section#">
	<cfelseif qSections.RecordCount>
		<cf_sebField name="SectionID" label="Section" type="select" subquery="qSections" subvalues="SectionID" subdisplays="SectionTitle" required="true">
	<cfelse>
		<cf_sebField name="SectionID" type="hidden" setValue="0">
	</cfif>
	<!--- To add non-CMS page to list: <cfset Application.SitePages.addPage("Page Title",CGI.SCRIPT_NAME)> --->
	<cf_sebField name="LinkURL" label="Page" type="select" topopt="(new page)" subquery="qPages" subvalues="LinkURL" subdisplays="Title" required="false">
	<cf_sebField name="Label" required="true">
	<cf_sebField name="URL" type="plaintext">
	<cf_sebField type="Submit/Cancel" label="Save">
</cf_sebForm>

<cfif PageID>
	<p><cfoutput><a href="page-edit.cfm?id=#PageID#">Edit Page</a></cfoutput></p>
</cfif>

<cf_layout>