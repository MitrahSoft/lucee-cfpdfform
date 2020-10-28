component {

    VARIABLES.reader  = createObject("java","org.apache.pdfbox.pdmodel.PDDocument",  "lib/pdfbox/pdfbox-app-2.0.8.jar");
    VARIABLES.fdf  = createObject("java","org.apache.pdfbox.pdmodel.fdf.FDFDocument",  "lib/pdfbox/pdfbox-app-2.0.8.jar");
    VARIABLES.pdtype0font  = createObject("java","org.apache.pdfbox.pdmodel.font.PDType0Font",  "lib/pdfbox/pdfbox-app-2.0.8.jar");

    public any function init()

    {
        VARIABLES.reader  = createObject("java","org.apache.pdfbox.pdmodel.PDDocument",  "lib/pdfbox/pdfbox-app-2.0.8.jar");
        VARIABLES.fdf  = createObject("java","org.apache.pdfbox.pdmodel.fdf.FDFDocument",  "lib/pdfbox/pdfbox-app-2.0.8.jar");
        VARIABLES.pdtype0font  = createObject("java","org.apache.pdfbox.pdmodel.font.PDType0Font",  "lib/pdfbox/pdfbox-app-2.0.8.jar");

        return THIS;
    }

    public Struct function getFormFields
        (
            required string source
        )
    {
        var stFormFields = structNew("linked");
        var local = {};

        local.fileIO   = createObject("java","java.io.FileInputStream").init(ARGUMENTS.source);
        local.pdf = VARIABLES.reader.load(local.fileIO);
        local.pdfForm = local.pdf.getDocumentCatalog().getAcroForm();
        local.stFields = local.pdfForm.getFieldIterator();
        while (local.stFields.hasNext()) {
            var fieldName = stFields.next();
                stFormFields[fieldName.getPartialName()] = fieldName.getValueAsString();
            }
        local.pdf.close();
        local.fileIO.close();

        return stFormFields

    }

    public Struct function getXmlData
        (
            required struct stFormFields
        )
    {
        var exFormFields = structNew("linked");
        var local = {};

        local.xmlData = '<?xml version="1.0" encoding="UTF-8"?><xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve"><fields>';
        for (key in arguments.stFormFields) {
            local.xmlData = local.xmlData & '<field name=' & '"#key#"';
            if (arguments.stFormFields[key] != ""){
                local.xmlData = local.xmlData & '><value>' & #arguments.stFormFields[key]# & '</value></field>';
            }
            else {
                local.xmlData = local.xmlData & '/>';           
            }
        }
        local.xmlData = local.xmlData & '</fields></xfdf>';        
        exFormFields["xmlData"] = local.xmlData;

        return exFormFields
    }

    public Struct function getFDFData
        (
            required string source,
            required string fdfData
        )
    {
        var local = {};
        var exportFDFData = structNew("linked");
        local.fileIO   = createObject("java","java.io.FileInputStream").init(ARGUMENTS.source);
        
        local.pdf = VARIABLES.reader.load(local.fileIO);
        local.pdfForm = local.pdf.getDocumentCatalog().getAcroForm();
        local.pdfForm.exportFDF().save(getDirectoryFromPath( cgi.cf_template_path ) & arguments.fdfData);

        local.pdf.close();
        local.fileIO.close();

        exportFDFData["fdfData"] = "Success";
        return exportFDFData
    }

    public boolean function setFormFields
        (
            required string source,           
            string destination,         
            required struct stFormFields, 
            boolean overwrite = true,
            boolean flatten = false,
            string fdfdata,
            string XMLdata,
            string font,
            string fontsize
        )
    {
        var local = {};

        local.ok = true;

        local.fileIO   = createObject("java","java.io.FileInputStream").init(ARGUMENTS.source);
        
        if ( structKeyExists(arguments, "destination") && arguments.destination != ""){
            local.newPDF = ARGUMENTS.destination;
        }
        else {
            local.newPDF = expandpath( getTempDirectory() ) & createUUID() & ".pdf";
        }

        local.fileIOS   = createObject("java","java.io.FileOutputStream").init(local.newPDF);  
        
        local.pdf = VARIABLES.reader.load(local.fileIO);

        local.pdfForm = local.pdf.getDocumentCatalog().getAcroForm();

        // Set font appearance
        if ( structKeyExists(arguments, "font") && arguments.font!= ""){
            local.pdfFont = PDType0Font.load(local.pdf, createObject("java","java.io.FileInputStream").init(ARGUMENTS.font), false);
            local.fontName = local.pdfForm.getDefaultResources().add(local.pdfFont).getName();
            local.pdfForm.setDefaultAppearance("/" & local.fontName & " " & ARGUMENTS.fontsize & " Tf 0 g");
        }

        // For populating with fdfdata
        if ( structKeyExists(arguments, "fdfdata") && arguments.fdfdata != ""){
            local.fdfFile = getDirectoryFromPath( cgi.cf_template_path ) & arguments.fdfdata;
            local.fdf = VARIABLES.fdf.load(local.fdfFile);
            local.pdfForm.importFDF(local.fdf);
            local.stFields = local.pdfForm.getFieldIterator();
            while (local.stFields.hasNext()) {
                var fieldName = stFields.next();
                if ( fieldName.getValueAsString() != "")        
                arguments.stFormFields[fieldName.getPartialName()] = fieldName.getValueAsString();
            }
        }
        
        // For populating with xmldata
        if (structKeyExists(arguments, "XMLdata") && arguments.XMLdata != ""){
            if (find("\", arguments.XMLdata)){
                local.argXMLData = xmlParse(arguments.XMLdata);
            }
            else {
                local.argXMLData = arguments.XMLdata;
            }
            var testXML = XMLSearch( local.argXMLData, '//*[@name!='''']' );

            for (xml in testXML){
                if (arrayLen(xml.XmlChildren)){
                    arguments.stFormFields[xml.XmlAttributes.Name] = xml.XmlChildren[1].XmlText;
                }
            }          
        }
        
        local.stFields = local.pdfForm.getFieldIterator();
        
        while (local.stFields.hasNext()) {
            var fieldName = stFields.next();
            if (StructKeyExists(ARGUMENTS['stFormFields'], fieldName.getPartialName())) {
                fieldName.setValue(ARGUMENTS['stFormFields'][fieldName.getPartialName()]);
            }
        }

        if (ARGUMENTS.flatten) {
            local.pdfForm.flatten(); // remove form fields; cannot be edited
        }

        local.pdf.save(local.fileIOS);
        local.pdf.close();
        local.fileIO.close();
        local.fileIOS.close();
        
        if ( structKeyExists(arguments, "destination") && arguments.destination == ""){        
            cfcontent( type = "application/pdf", file = local.newPDF, DeleteFile = "Yes" );
            cfheader ( name="Content-Disposition", value="inline; filename=Example.pdf");
        }

        return local.ok
    }
}
