component 
	name="pdfform"
	output=true
{
       
	this.metadata.hint="(partial) implementation of cfpdform using pdfbox"; // http://pdfbox.apache.org
	this.metadata.attributetype="fixed";
	this.metadata.attributes={
		action: { required:true, type:"string", hint="[read|populate]"},
		source: { required:true, type:"string", hint="pathname (Todo: byte array)"},
		result: { required:false, type:"string", hint="read - structure containing form field values"},
		destination: { required:false, type:"string", hint="pathname"},
		overwrite: { required:false, type:"boolean", hint="overwrite the destination file. default no"},
		flatten: { required:false, type:"boolean", hint="remove form fields. default no"},
		XMLdata: { required:false, type:"string", hint="that returns XML data"},
		fdfdata: { required:false, type:"string", hint="filename to be exported to"},
		font: { required:false, type:"string", hint="pathname to embedable font. defaults to pdf source"},
		fontsize: { required:false, type:"string", hint="font size. defaults to 0 for auto"}
	};

	/** custom tag interface method */
	void function init(boolean hasEndTag=false, component parent) {
		variables.hasEndTag = arguments.hasEndTag;
		variables.pdfForm = new pdfform.pdfform();
		variables.stFormFields = {};
	}

	public boolean function onStartTag(required struct attributes, required struct caller) {
		// check for action
		if (! StructKeyExists(arguments.attributes, 'action')) {
			throw(type="application", message="missing parameter", detail="'action' not passed in");
		}
		
		// check for source
		switch(arguments.attributes.action) {
			case "read":
				
				//check passing attributes passed in
				if ( StructKeyExists(arguments.attributes, 'fdfdata') && (StructKeyExists(arguments.attributes, 'xmlData') || StructKeyExists(arguments.attributes, 'result'))) {
					throw(type="application", message="Attribute validation error", detail="It has an invalid attribute combination.");
				} else if ( !StructKeyExists(arguments.attributes, 'fdfdata') && ! StructKeyExists(arguments.attributes, 'result')) {
					throw(type="application", message="missing parameter", detail="'result or fdfdata' was not passed in");
				}
				
				if (! variables.hasEndTag) {
					if ( StructKeyExists(arguments.attributes, 'result')){
						arguments.caller[arguments.attributes.result] = variables.pdfForm.getFormFields(arguments.attributes.source);
					}
					if ( StructKeyExists(arguments.attributes, 'xmlData')) {
						arguments.caller[arguments.attributes.xmlData] = variables.pdfForm.getXmlData(arguments.caller[arguments.attributes.result]);
					}
					if ( StructKeyExists(arguments.attributes, 'fdfdata')) {
						arguments.caller[arguments.attributes.fdfdata] = variables.pdfForm.getFDFData(arguments.attributes.source, arguments.attributes.fdfdata);
					}
				}
				break;
			case "populate":
				//check passing attributes passed in
				if ( StructKeyExists(arguments.attributes, 'fdfdata') && StructKeyExists(arguments.attributes, 'xmlData')) {
					throw(type="application", message="Attribute validation error", detail="It has an invalid attribute combination.");
				}

				// check attributes for destination
				if ( StructKeyExists(arguments.attributes, 'destination') && arguments.attributes.destination == "") {
					throw(type="application", message="missing parameter", detail="'destination' not passed in");
				}

				// check overwrite
				if (! StructKeyExists(arguments.attributes, 'overwrite')) {
					arguments.attributes.overwrite = false;
				}
				if (! arguments.attributes.overwrite && StructKeyExists(arguments.attributes, 'destination') && arguments.attributes.destination != "" && FileExists(arguments.attributes.destination) ) {
					throw(type="application", message="Destination file exists", detail="#arguments.attributes.destination#");
				}
				
				// flatten: default to false
				if (! StructKeyExists(arguments.attributes, 'flatten')) {
					arguments.attributes.flatten = false;
				}
				break;
			default: 
				throw(type="application", message="unsupported action", detail="action=[read|populate]");
		}

		return true;
	}
	
	public boolean function onEndTag(required struct attributes, required struct caller, required string generatedContent) {
		switch(arguments.attributes.action) {
			case "read":			
				if ( StructKeyExists(arguments.attributes, 'result')){
					arguments.caller[arguments.attributes.result] = variables.pdfForm.getFormFields(arguments.attributes.source);
				}
				if ( StructKeyExists(arguments.attributes, 'xmlData')) {
					arguments.caller[arguments.attributes.xmlData] = variables.pdfForm.getXmlData(arguments.caller[arguments.attributes.result]);
				}
				if ( StructKeyExists(arguments.attributes, 'fdfdata')) {
					arguments.caller[arguments.attributes.fdfdata] = variables.pdfForm.getFDFData(arguments.attributes.source, arguments.attributes.fdfdata);
				}
				break;
			case "populate":
				if (!isDefined("arguments.attributes.destination")){
					arguments.attributes.destination = "";
				}
				if (!isDefined("arguments.attributes.fdfdata")){
					arguments.attributes.fdfdata = "";					
				}
				if (!isDefined("arguments.attributes.XMLdata")){
					arguments.attributes.XMLdata = "";
				}
				if (!isDefined("arguments.attributes.font")){
					arguments.attributes.font = "";
				}
				if (!isDefined("arguments.attributes.fontsize")){
					arguments.attributes.fontsize = "0";
				}
				variables.pdfForm.setFormFields(
					source = arguments.attributes.source, 
					destination = arguments.attributes.destination, 
					stFormFields = variables.stFormFields, 
					flatten = arguments.attributes.flatten, 
					fdfdata = arguments.attributes.fdfdata, 
					XMLdata = arguments.attributes.XMLdata, 
					font = arguments.attributes.font, 
					fontsize = arguments.attributes.fontsize
				);
				break;
			default: 
				throw(type="application", message="unsupported action", detail="action=[read|populate]");
		}
		WriteOutput(generatedContent);
		return false;
	}

	public void function setFormField(required string name, required string value, integer index) {
		variables.stFormFields[ARGUMENTS.name] = ARGUMENTS.value;
	}
}