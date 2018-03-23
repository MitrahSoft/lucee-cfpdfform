<cfcomponent>

	<cffunction name="install" returntype="struct" output="no" hint="called from Lucee to install application">
		<cfset variables.tags = ListToArray("pdfform.cfc,pdfformparam.cfc")>
		<cfargument name="error" type="struct">
		<cfargument name="path" type="string">
		<cfargument name="config" type="struct">
		
		<cfset var result = {status = true, message = ""} />
		<cfset var serverPath = getContextPath() />
		
		<cftry>
			
			<!--- Export the tag --->
				<cfloop array="#variables.tags#" index="local.tag" >
					<cffile action="copy"
					source="#path#tags/#tag#"
					destination="#serverPath#/library/tag/">
				</cfloop>
				<cfdirectory action="copy" directory="#path#tags/pdfform" destination="#serverPath#/library/tag/" />
			
				<cfsavecontent variable="temp">
					<cfoutput>
						<p>Tag correctly installed. You will need to Restart Lucee for the functions to work.</p>
					</cfoutput>				
				</cfsavecontent>
				
				<cfset result.message = temp />
			
			<cfcatch type="any">            
				<cfset result.status = false />
				<cfset result.message = cfcatch.message />
				<cflog file="lucee_extension_install" text="Error: #cfcatch.message#">
			</cfcatch>
		
		</cftry>
		
		<cfreturn result />
	
	</cffunction>	
	
	<cffunction name="uninstall" returntype="struct" output="no" hint="called by Lucee to uninstall the application">
		<cfargument name="path" type="any"/>
		<cfargument name="config" type="any"/>
		<cfscript>
			var processResult = {
				status = true,
				message = ""};
			var ssDir = "";
			var serverPath = getContextPath();
			processResult.status = deleteAsset("directory", "#serverPath#/library/tag/pdfform");
			processResult.status = deleteAsset("file", "#serverPath#/library/tag/pdfform.cfc");
			processResult.status = deleteAsset("file", "#serverPath#/library/tag/pdfformparam.cfc");
		</cfscript>
		
		<cfif processResult.status>
			<cfset processResult.message = "Uninstall successful" />
		<cfelse>
			<cfset processResult.message = "Error uninstalling: Please see logs and delete manually" />
		</cfif>
		
		<cfreturn processResult />
	</cffunction>
	
	
	<cffunction name="deleteAsset" returntype="boolean" output="no" hint="called in the uninstall process" access="private">
		<cfargument name="type" required="true" hint="Accepts file|directory" />
		<cfargument name="asset" required="true" hint="location of asset to be removed" />
		
		<cfset var status = true />
		
		<cftry>
			<cfif arguments.type EQ "directory">
				<cfdirectory action="delete" directory="#arguments.asset#" recurse="true" />
			<cfelse>
				<cffile action="delete" file="#arguments.asset#" />
			</cfif>
			<cfcatch type="any">
				<cfset local.errMsg = "Cannot delete #arguments.type# #arguments.asset# | #cfcatch.message#" />
				<cflog file="lucee_extension_poi" text="#local.errMsg#" />
				<cfset status = false/>
			</cfcatch>
		</cftry>
		<cfreturn status />
	</cffunction>
	
	<cffunction name="getContextPath" access="private" returntype="string">
		<cfreturn expandPath('{lucee-#request.adminType#-directory}')>
	</cffunction>
	
 </cfcomponent>