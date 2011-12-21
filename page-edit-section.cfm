<cf_PageController>

<cf_Template files_css="page-edit.css" showTitle="true">

<p>If you have trouble deleting text from the editor, type something into it and try again.</p>

<cf_sebForm
	forward="page-edit.cfm?id=#URL.page#"
	CFC_Component="#Application.CMS.PageSections#"
	format="semantic"
	CatchErrTypes="CMS"
>
	<cf_sebField name="PageID" type="hidden" defaultValue="#URL.page#">
	<cf_sebField name="TemplateSectionID" type="hidden" defaultValue="#URL.templatesection#">
	<cf_sebField name="ImageFile" label="Image" type="file" destination="#request.UploadPath#page-images" urlpath="/f/page-images/" required="false" nameconflict="MAKEUNIQUE">
	<cf_sebField name="TextImage" label="Text Image" type="file" destination="#request.UploadPath#page-images" urlpath="/f/page-images/" required="false" nameconflict="MAKEUNIQUE">
	<cf_sebField type="FCKeditor" fieldname="Contents" height="300">
	<cf_sebField type="Submit/Cancel" label="Save">
</cf_sebForm>

</cf_Template>