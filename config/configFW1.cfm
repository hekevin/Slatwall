<cfset variables.framework=structNew() />
<cfset variables.framework.applicationKey="SlatwallFW1" />
<cfset variables.framework.base="/Slatwall" />
<cfset variables.framework.baseURL = replace(replace(replace( getDirectoryFromPath(getCurrentTemplatePath()) , expandPath('/'), '/' ), '\', '/', 'all'),'/config/','/') />
<cfset variables.framework.action="slatAction" />
<cfset variables.framework.error="admin:main.error" />
<cfset variables.framework.home="admin:main.default" />
<cfset variables.framework.defaultSection="main" />
<cfset variables.framework.defaultItem="default" />
<cfset variables.framework.usingsubsystems=true />
<cfset variables.framework.defaultSubsystem = "admin" />
<cfset variables.framework.subsystemdelimiter=":" />
<cfset variables.framework.generateSES = true />
<cfset variables.framework.SESOmitIndex = true />
<cfset variables.framework.reload = "reload" />