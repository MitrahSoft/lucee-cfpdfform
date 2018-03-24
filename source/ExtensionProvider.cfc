component displayname="extension provider" output="false" {

    remote struct function getInfo(){
        var info = {
            title="pdfform",
            description="PDF extension for Lucee 4.5",
            url="https://github.com/MitrahSoft/lucee-cfpdfform/",
            mode="develop"
        };
        return info;
    }

    remote query function listApplications(){
        var apps = queryNew('type,id,name,label,description,version,category,download,author','varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar');
        var rootURL=getInfo().url;
        var desc = "cfpdfform";
        QueryAddRow(apps);
        QuerySetCell(apps,'id','A6393D14-42D4-4195-8AC71429');
        QuerySetCell(apps,'version','1.0.0.0');
        QuerySetCell(apps,'name','pdfform');
        QuerySetCell(apps,'type','all');
        QuerySetCell(apps,'label','&lt;cfpdfform /&gt;');
        QuerySetCell(apps,'description',desc);
        QuerySetCell(apps,'author','Mitrahsoft');
        QuerySetCell(apps,'download','https://github.com/MitrahSoft/lucee-cfpdfform/raw/master/target/extension.zip
');

        return apps;
    }
}
