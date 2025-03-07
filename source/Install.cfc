component {

	function install(struct error, string path, struct config) returnstruct {
		/**
		 * Called from Lucee to install application
		 * @error {struct} Error structure
		 * @path {string} Path to the installation directory
		 * @config {struct} Configuration structure
		 * @return {struct} Result structure with status and message
		 */
		var local = {};
		local.result = {status = true, message = ""};
		local.serverPath = getContextPath();
		local.tags = ListToArray("pdfform.cfc,pdfformparam.cfc");

		try {
			// Export the tag
			for (local.tag in local.tags) {
				fileCopy(arguments.path & "tags/" & local.tag, local.serverPath & "/library/tag/");
			}
			directoryCopy(arguments.path & "tags/pdfform/", local.serverPath & "/library/tag/pdfform/", true);

			local.temp = "<p>Tag correctly installed. You will need to Restart Lucee for the functions to work.</p>";
			local.result.message = local.temp;
		} catch (any e) {
			local.result.status = false;
			local.result.message = e.message;
			log("Error: " & e.message, "lucee_extension_install");
		}

		return local.result;
	}

	function uninstall(any path, any config) returnstruct {
		/**
		 * Called by Lucee to uninstall the application
		 * @path {any} Path to the installation directory
		 * @config {any} Configuration structure
		 * @return {struct} Result structure with status and message
		 */
		var local = {};
		local.processResult = {status = true, message = ""};
		local.serverPath = getContextPath();

		local.processResult.status = deleteAsset("directory", local.serverPath & "/library/tag/pdfform");
		local.processResult.status = deleteAsset("file", local.serverPath & "/library/tag/pdfform.cfc");
		local.processResult.status = deleteAsset("file", local.serverPath & "/library/tag/pdfformparam.cfc");

		if (local.processResult.status) {
			local.processResult.message = "Uninstall successful";
		} else {
			local.processResult.message = "Error uninstalling: Please see logs and delete manually";
		}

		return local.processResult;
	}

	private boolean function deleteAsset(required string type, required string asset) {
		/**
		 * Called in the uninstall process
		 * @type {string} Accepts file|directory
		 * @asset {string} Location of asset to be removed
		 * @return {boolean} Status of the deletion process
		 */
		var local = {};
		local.status = true;

		try {
			if (arguments.type == "directory") {
				directoryDelete(arguments.asset, true);
			} else {
				fileDelete(arguments.asset);
			}
		} catch (any e) {
			local.errMsg = "Cannot delete " & arguments.type & " " & arguments.asset & " | " & e.message;
			log(local.errMsg, "lucee_extension_poi");
			local.status = false;
		}

		return local.status;
	}

	private string function getContextPath() {
		/**
		 * Get the context path
		 * @return {string} Expanded path
		 */
		return expandPath('{lucee-' & request.adminType & '-directory}');
	}
}