To add a page to the pages drop-down, use this code in the page (replacing [Page Title] with the title of the page:

<cfset Title = "[Page Title]">
<cfset FrontController.call(component="SitePages",method="addPage",Title=Title,ScriptName=CGI.SCRIPT_NAME)>