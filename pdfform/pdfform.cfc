component {

    VARIABLES.reader  = createObject("java","org.apache.pdfbox.pdmodel.PDDocument",  "lib/pdfbox/pdfbox-app-2.0.0-RC2.jar");

    public any function init()

    {
        VARIABLES.reader  = createObject("java","org.apache.pdfbox.pdmodel.PDDocument",  "lib/pdfbox/pdfbox-app-2.0.0-RC2.jar");

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

    public boolean function setFormFields
        (
            required string source,
            required string destination,
            required struct stFormFields,
            boolean overwrite = true
        )
    {
        var local = {};

        local.ok = true;

        local.fileIO   = createObject("java","java.io.FileInputStream").init(ARGUMENTS.source);  
        local.fileIOS   = createObject("java","java.io.FileOutputStream").init(ARGUMENTS.destination);  
        
        local.pdf = VARIABLES.reader.load(local.fileIO);

        local.pdfForm = local.pdf.getDocumentCatalog().getAcroForm();               
        local.stFields = local.pdfForm.getFieldIterator();
        
        while (local.stFields.hasNext()) {
            var fieldName = stFields.next();
            if (StructKeyExists(ARGUMENTS['stFormFields'], fieldName.getPartialName())) {
                fieldName.setValue(ARGUMENTS['stFormFields'][fieldName.getPartialName()]);
            }
        }

        local.pdf.save(local.fileIOS);        
        local.pdf.close();
        local.fileIO.close();
        local.fileIOS.close();

        return local.ok

    }
}
