component displayname="extension provider" output="false" {

	remote struct function getInfo() {
		var local = {};
		local.info = {
			title = "pdfform",
			description = "PDF extension for Lucee 4.5",
			url = "https://github.com/MitrahSoft/lucee-cfpdfform/",
			mode = "develop"
		};
		return local.info;
	}

	remote query function listApplications() {
		var local = {};
		local.apps = queryNew('type,id,name,label,description,version,category,download,author','varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar');
		local.rootURL = getInfo().url;
		local.desc = "cfpdfform";
		
		QueryAddRow(local.apps);
		QuerySetCell(local.apps, 'id', 'A6393D14-42D4-4195-8AC71429');
		QuerySetCell(local.apps, 'version', '1.0.0.0');
		QuerySetCell(local.apps, 'name', 'pdfform');
		QuerySetCell(local.apps, 'type', 'all');
		QuerySetCell(local.apps, 'label', '&lt;cfpdfform /&gt;');
		QuerySetCell(local.apps, 'description', local.desc);
		QuerySetCell(local.apps, 'author', 'Mitrahsoft');
		QuerySetCell(local.apps, 'download', 'https://github.com/MitrahSoft/lucee-cfpdfform/raw/master/target/extension.zip');

		return local.apps;
	}
}
