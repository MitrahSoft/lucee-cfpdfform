<cfcomponent>

	<cffunction name="getInfo" access="remote" returntype="struct">
    	<cfset var info=struct()>
        <cfset info.title="Pdf form extension">
        <cfset info.mode="develop">
        <cfset info.description="Pdfform Extension">
        <cfset info.url="http://" & cgi.HTTP_HOST>
    	<cfreturn info>
    </cffunction>
        
    <cffunction name="listApplications" access="remote" returntype="query">
		<cfset var apps=queryNew('type,id,name,label,description,version,category,image,download,paypal,author,codename,video,support,documentation,forum,mailinglist,network,created')>
            <cfset populateCOM(apps)>
        <cfreturn apps>
    </cffunction>    
    
	<cffunction name="populateCOM" access="private" returntype="void">
    	<cfargument name="apps" type="query" required="yes">
        <cfset var exp="this extension is experimental and will no longer work with the final release of railo 3.1, it is not allowed to use this extension in a productve enviroment.">
        
        <cfset var rootURL=getInfo().url & "/extensions/">
        <cfset var zipFileLocation = 'extension.zip'>
		
		<cffile action="read" file="zip://#expandPath(zipFileLocation)#!/config.xml" variable="config">
		<cfset info = XMLParse(config)>

        <cfset QueryAddRow(apps)>
      	<cfset QuerySetCell(apps,'download',rootURL & zipFileLocation)>
        <cfset QuerySetCell(apps,'id', info.config.info.id.XMLtext)>
        <cfset QuerySetCell(apps,'name',info.config.info.name.XMLtext)>
        <cfset QuerySetCell(apps,'type',info.config.info.type.XMLtext)>
        <cfset QuerySetCell(apps,'label',info.config.info.label.XMLtext)>
	</cffunction>

</cfcomponent>
