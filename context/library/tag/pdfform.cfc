component 
	name="pdfform"
	output=true
{

	this.metadata.hint="(partial) implementation of cfpdform using pdfbox"; // http://pdfbox.apache.org
	this.metadata.attributetype="fixed";
	this.metadata.attributes={
		action: { required:true, type:"string", hint="[read|populate]"},
		source: { required:true, type:"string", hint="pathname (Todo: byte array)"},
		result: { required:false, type:"string",    hint="read - structure containing form field values"},
		
		destination: { required:false, type:"string", hint="pathname"},
		overwrite: { required:false, type:"boolean", hint="overwrite the destination file. default no"},
		flatten: { required:false, type:"boolean", hint="remove form fields. default no"}
	};


	/** custom tag interface method */
	void function init(boolean hasEndTag=false, component parent) {

		variables.hasEndTag = arguments.hasEndTag;
		
		variables.pdfForm = new pdfform.pdfform();

		variables.stFormFields = {};
	}

	public boolean function onStartTag
		(
			required struct attributes, 
			required struct caller
		)
	{
		// check for action
		if (! StructKeyExists(arguments.attributes, 'action')) {
			throw(type="application", message="missing parameter", detail="'action' not passed in");
		}
		
		// check for source
		switch(arguments.attributes.action) {
			case "read":
				
				//check result passed in
				if (! StructKeyExists(arguments.attributes, 'result')) {
					throw(type="application", message="missing parameter", detail="'result' not passed in");
				}
				
				if (! variables.hasEndTag) {
					arguments.caller[arguments.attributes.result] = variables.pdfForm.getFormFields(arguments.attributes.source);
				}
				
				break;
			case "populate":
				// check attributes for destination
				if ( StructKeyExists(arguments.attributes, 'destination') AND arguments.attributes.destination == "") {
					throw(type="application", message="missing parameter", detail="'destination' not passed in");
				}

				
				// check overwrite
				if (! StructKeyExists(arguments.attributes, 'overwrite')) {
					arguments.attributes.overwrite = false;
				}
				if (! arguments.attributes.overwrite AND FileExists(arguments.attributes.destination) ) {
					throw(type="application", message="Destination file exists", detail="#arguments.attributes.destination#");
				}
				
				// flatten: default to false
				if (! StructKeyExists(arguments.attributes, 'flatten')) {
					arguments.attributes.flatten = false;
				}
				
				// check for cfpdformparm
				 break;
			default: 
				throw(type="application", message="unsupported action", detail="action=[read|populate]");
		}

		return true;
	}
	

	public boolean function onEndTag
		(
			required struct attributes, 
			required struct caller,
			required string generatedContent
		)
	{
		switch(arguments.attributes.action) {
			case "read":			

				arguments.caller[arguments.attributes.result] = variables.pdfForm.getFormFields(arguments.attributes.source);

				break;
			case "populate":
				if ( isDefined("arguments.attributes.destination")){
					variables.pdfForm.setFormFields(source = arguments.attributes.source, destination = arguments.attributes.destination, stFormFields = variables.stFormFields, flatten=arguments.attributes.flatten);
				}
				else {
					variables.pdfForm.setFormFields(source = arguments.attributes.source, stFormFields = variables.stFormFields);
				}
				break;
			default: 
				throw(type="application", message="unsupported action", detail="action=[read|populate]");
		}
		WriteOutput(generatedContent);
		return false;
	}

	public void function setFormField
		(
			required string name,
			required string value,
			         integer index // TODO
		)
	{
		variables.stFormFields[ARGUMENTS.name] = ARGUMENTS.value;
	}
}
