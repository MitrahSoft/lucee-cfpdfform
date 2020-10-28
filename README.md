# **\<cfpdfform /\> for Lucee**
\<cfpdfform /\> tag for Lucee Server. Read and Populate PDF Form Fields

# WIP
- Basic read and populate PDF Form Fields are implemented
- stream to browser implemented
- retrieve the form field value into xmlData or exported to FDF file format
- populate the form field value from xmlData or FDF file

# **PDF Box**
This tag created using [PDF Box](http://pdfbox.apache.org/)


## Installation
- Download the `.lex` file from the repository directory [`/lucee-cfpdfform/target/`](https://github.com/MitrahSoft/lucee-cfpdfform/tree/master/target)
- Then either:
  - Copy the `.lex` file into the `deploy` directory for either the server, `WEB-INF/lucee-server/deploy/`, or the web context, `WEB-INF/lucee-context/deploy/`
  - ...or...
  - Open the the Lucee Administrator for the server or web context. Navigate to `Extension > Applications > Upload new extension (experimental)` and upload the selected `.lex` file. Ignore the note `Extension zip file` as a `.lex` file is just a renamed `.zip` file.
- It is not necessary to restart Lucee after you have added this extension.

# **Sample usage**
````cfml
<cftry>

	<cfset pdfForm = ExpandPath('./my-pdf-form.pdf')>
	<cfoutput><p>#pdfForm#</p></cfoutput>

	<h4>Read</h4>
	<cfpdfform action="read" source="#pdfForm#" result="stFormFields">
	<cfdump var="#stFormFields#" label="stFormFields">

	<hr>
	<h4>Read the form field value in XML format</h4>
	<cfpdfform action="read" source="#pdfForm#" xmlData="myXMLData" result="stFormFields">
	<cfdump var="#myXMLData#" label="XMLData">

	<hr>
	<h4>Read the form field value and exported in FDF fileformat</h4>
	<cfpdfform action="read" source="#pdfForm#" fdfData="populated-pdf-form.fdf">
	<cfdump var="#myXMLData#" label="XMLData">

	<hr>
	<h4>Populate</h4>
	<cfpdfform action="populate" source="#pdfForm#" destination="#ExpandPath('./populated-pdf-form.pdf')#" >
		<cfpdfformparam name="Name"    value="CF Mitrah">
		<cfpdfformparam name="Account" value="MitrahSoft">
	</cfpdfform>

	<hr>
	<h4>Populate and remove form fields</h4>
	<cfpdfform action="populate" source="#pdfForm#" destination="#ExpandPath('./populated-pdf-form.pdf')#" flatten="true">
		<cfpdfformparam name="Name"    value="CF Mitrah">
		<cfpdfformparam name="Account" value="MitrahSoft">
	</cfpdfform>

	<hr>
	<h4>Populate & write to browser</h4>
	<cfpdfform action="populate" source="#pdfForm#">
		<cfpdfformparam name="Name"    value="CF Mitrah">
		<cfpdfformparam name="Account" value="MitrahSoft">
	</cfpdfform>

	<hr>
	<h4>Populate the form field value from XMLData string or XML file </h4>
	<cfpdfform action="populate" source="#pdfForm#" XMLData="#ExpandPath('./Example.xml')#" destination="#ExpandPath('./populated-pdf-form.pdf')#" overwrite="true">
	</cfpdfform>

	<hr>
	<h4>Populate the form field value from FDF file </h4>
	<cfpdfform action="populate" source="#pdfForm#" fdfData="populated-pdf-form.fdf" destination="#ExpandPath('./populated-pdf-form.pdf')#" overwrite="true">
	</cfpdfform>

	<hr>
	<h4>Unicode Support using embedded font</h4>
	<cfpdfform action="populate" source="#pdfForm#" font="#expandpath('./font.ttf')#" fontsize="10">
		<cfpdfformparam name="Name"    value="CF Mitrāh">
		<cfpdfformparam name="Account" value="MitrāhSoft">
	</cfpdfform>

	<cfcatch>
		<cfdump var="#cfcatch#">
	</cfcatch>
</cftry>
````
## **Contributors**

Idea & base code adapted from https://github.com/webonix/lucee-cfpdfform
lucee-cfpdfform is authored by **[CF Mitrah](http://www.MitrahSoft.com/)** and everyone is welcome to contribute.

## **Downsides webonix cfpdfform implementation**

Webonix done a very good job, but he used iText jars, which is licensed as [AGPL](https://github.com/itext/itextpdf/blob/master/LICENSE.md) software. Buying a license is mandatory as soon as you develop commercial activities distributing the iText software inside your product or deploying it on a network without disclosing the source code of your own applications under the AGPL license. These activities include:
- offering paid services to customers as an ASP
- serving PDFs on the fly in the cloud or in a web application
- shipping iText with a closed source product

### Pricing of iText on Dec-2015, [Reference](http://itextpdf.com/Pricing/unit-based)
#### Server - $2,640 USD
- One license per server, virtual machine or node installation, independent of number of end-users
- 50% discount for non-production servers (e.g. testing, development, Q&A, UAT, BA or DR)

#### End-user - $1,590 USD
- One license per desktop, laptop or other end-user device installation



## **Problems**

If you experience any problems with this tag please:

* [submit a ticket to our issue tracker](https://github.com/mitrahsoft/lucee-cfpdfform/issues)
* fix the error yourself and send us a pull request

## **Social Media**

You'll find us on [Twitter](https://twitter.com/MitrahSoft), [Facebook](http://www.facebook.com/MitrahSoft) and [Google+](https://plus.google.com/+MitrahsoftKovilpatti).
