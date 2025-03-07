component 
	name="pdfformparam"
	output=true
{

	this.metadata.hint="child of of cfpdform using pdfbox"; // http://pdfbox.apache.org
	this.metadata.attributetype="fixed";
	this.metadata.attributes={
		name: { required:true,   type:"string",  hint="form field name"},
		value: { required:true,  type:"string",  hint="form field value"},
		index: { required:false, type:"integer", hint="for cases for multiple form fields with same name"}
	};


	/** custom tag interface method */
	void function init(boolean hasEndTag=false, component parent) {
		variables.hasEndTag = arguments.hasEndTag;
		variables.parent = arguments.parent;
	}

	public boolean function onStartTag(required struct attributes, required struct caller) {
		variables.parent.setFormField(arguments.attributes.name, arguments.attributes.value);
		return true;
	}
	
	public boolean function onEndTag(required struct attributes, required struct caller, required string generatedContent) {
		WriteOutput(generatedContent);
		return false;
	}

}
