component {

    // Constructor function to initialize the component
    public any function init() {
        VARIABLES.Loader = createObject("java", "org.apache.pdfbox.Loader");
        VARIABLES.pdtype0font = createObject("java", "org.apache.pdfbox.pdmodel.font.PDType0Font");
        return THIS;
    }

    // Function to check if a path is absolute
    private boolean function isAbsolutePath(string path) {
        return ReFind("^[a-zA-Z]:\\", path) or Left(path, 1) == "/";
    }

    // Function to get form fields from a PDF
    // @param source - The path to the PDF file
    public Struct function getFormFields(required string source) {
        var stFormFields = structNew("linked");
        var local = {};

        try {
            local.fileInput = createObject("java", "java.io.File").init(ARGUMENTS.source);
            local.pdf = VARIABLES.Loader.loadPDF(local.fileInput);
            local.pdfForm = local.pdf.getDocumentCatalog().getAcroForm();
            local.stFields = local.pdfForm.getFieldIterator();
            while (local.stFields.hasNext()) {
                var fieldName = local.stFields.next();
                stFormFields[fieldName.getPartialName()] = fieldName.getValueAsString();
            }
        } 
        catch (any e) {
            writeDump(e);
        } finally {
            if (structKeyExists(local, "pdf") && isObject(local.pdf)) local.pdf.close();
        }

        return stFormFields;
    }

    // Function to convert form fields to XML data
    // @param stFormFields - A struct containing form fields
    public Struct function getXmlData(required struct stFormFields) {
        var exFormFields = structNew("linked");
        var local = {}; 

        local.xmlData = '<?xml version="1.0" encoding="UTF-8"?><xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve"><fields>';
        for (key in arguments.stFormFields) {
            local.xmlData &= '<field name="' & key & '"';
            if (arguments.stFormFields[key] != "") {
                local.xmlData &= '><value>' & arguments.stFormFields[key] & '</value></field>';
            } else {
                local.xmlData &= '/>';
            }
        }
        local.xmlData &= '</fields></xfdf>';        
        exFormFields["xmlData"] = local.xmlData;

        return exFormFields;
    }

    // Function to get FDF data from a PDF
    // @param source - The path to the PDF file
    // @param fdfData - The path to save the FDF data
    public Struct function getFDFData(required string source, required string fdfData) {
        var local = {};
        var exportFDFData = structNew("linked");

        try {
            local.fileInput = createObject("java", "java.io.File").init(ARGUMENTS.source);
            local.pdf = VARIABLES.Loader.loadPDF(local.fileInput);
            local.pdfForm = local.pdf.getDocumentCatalog().getAcroForm();

            // Determine the correct path
            local.fdfPath = isAbsolutePath(arguments.fdfData) ? arguments.fdfData : getDirectoryFromPath(cgi.cf_template_path) & arguments.fdfData;

            local.pdfForm.exportFDF().save(local.fdfPath);
        } catch (any e) {
            writeDump(e);
        } finally {
            if (structKeyExists(local, "pdf") && isObject(local.pdf)) local.pdf.close();
        }

        exportFDFData["fdfData"] = "Success";
        return exportFDFData;
    }

    // Function to set form fields in a PDF
    // @param source - The path to the source PDF file
    // @param destination - The path to save the modified PDF file
    // @param stFormFields - A struct containing form fields to set
    // @param overwrite - Whether to overwrite the existing PDF file
    // @param flatten - Whether to flatten the form fields
    // @param fdfdata - The path to the FDF data file
    // @param XMLdata - The XML data to set in the form fields
    // @param font - The path to the font file
    // @param fontsize - The font size to use for the form fields
    public boolean function setFormFields(
        required string source,           
        string destination,         
        required struct stFormFields, 
        boolean overwrite = true,
        boolean flatten = false,
        string fdfdata,
        string XMLdata,
        string font,
        string fontsize
    ) {
        var local = {};
        local.ok = true;

        try {
            local.fileInput = createObject("java", "java.io.File").init(ARGUMENTS.source);
            local.newPDF = (structKeyExists(arguments, "destination") && arguments.destination != "") ? arguments.destination : expandpath(getTempDirectory()) & createUUID() & ".pdf";
            local.fileOutput = createObject("java", "java.io.FileOutputStream").init(local.newPDF);
            local.pdf = VARIABLES.Loader.loadPDF(local.fileInput);
            local.pdfForm = local.pdf.getDocumentCatalog().getAcroForm();
            
            if (structKeyExists(arguments, "font") && arguments.font != "") {
                local.pdfFont = PDType0Font.load(local.pdf, createObject("java", "java.io.FileInputStream").init(ARGUMENTS.font), false);
                local.fontName = local.pdfForm.getDefaultResources().add(local.pdfFont).getName();
            }

            // For populating with fdfdata
            if (structKeyExists(arguments, "fdfdata") && arguments.fdfdata != "") {

                // Create Java objects
                FDFParser = createObject("java", "org.apache.pdfbox.pdfparser.FDFParser");
                RandomAccessReadBuffer = createObject("java", "org.apache.pdfbox.io.RandomAccessReadBuffer");
                Files = createObject("java", "java.nio.file.Files");

                // Read file as byte array
                File = createObject("java", "java.io.File");
                filePath = File.init(arguments.fdfdata).toPath();
                fileBytes = Files.readAllBytes(filePath);

                // Parse FDF file
                readBuffer = RandomAccessReadBuffer.init(fileBytes);
                parser = FDFParser.init(readBuffer);
                fdf = parser.parse();

                // Get fields from FDF document
                fields = fdf.getCatalog().getFDF().getFields();

                // Iterate through fields and extract values
                for (i = 0; i < fields.size(); i++) {
                    field = fields.get(i);
                    fieldName = field.getPartialFieldName();
                    fieldValue = IsNull(field.getValue()) ? "" : field.getValue();
                    arguments.stFormFields[fieldName] = fieldValue.toString();
                }
            }
        
            // For populating with xmldata
            if (structKeyExists(arguments, "XMLdata") && arguments.XMLdata != "") {
                if (find("\", arguments.XMLdata)) {
                    local.argXMLData = xmlParse(arguments.XMLdata);
                } else {
                    local.argXMLData = arguments.XMLdata;
                }
                var testXML = XMLSearch(local.argXMLData, '//*[@name!='''']');
                for (xml in testXML) {
                    if (isDefined("xml.XmlText")) {
                        arguments.stFormFields[xml.XmlAttributes.Name] = xml.XmlText;
                    }
                }
            }

            local.stFields = local.pdfForm.getFieldIterator();
            while (local.stFields.hasNext()) {
                var fieldName = local.stFields.next();
                if (StructKeyExists(ARGUMENTS.stFormFields, fieldName.getPartialName())) {
                    if (structKeyExists(arguments, "font") && arguments.font != "") {
                        fieldName.setDefaultAppearance("/" & local.fontName & " " & ARGUMENTS.fontsize & " Tf 0 g");
                    }
                    fieldName.setValue(ARGUMENTS.stFormFields[fieldName.getPartialName()]);
                }
            }

            if (ARGUMENTS.flatten) {
                local.pdfForm.flatten();
            }

            local.pdf.save(local.fileOutput);
        } catch (any e) {
            local.ok = false;
            writeDump(e);
        } finally {
            if (structKeyExists(local, "pdf") && isObject(local.pdf)) local.pdf.close();
            if (structKeyExists(local, "fdf") && isObject(local.fdf)) local.fdf.close();
            if (structKeyExists(local, "fileOutput") && isObject(local.fileOutput)) local.fileOutput.close();
        }

        if (structKeyExists(arguments, "destination") && arguments.destination == "") {
            cfcontent(type = "application/pdf", file = local.newPDF, DeleteFile = "Yes");
            cfheader(name = "Content-Disposition", value = "inline; filename=Example.pdf");
        }

        return local.ok;
    }
}