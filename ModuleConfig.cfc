component output="false" {
	
	this.title 				= "taxjar";
	this.author 			= "Misha Mishyn";
	this.webURL 			= "";
	this.description 		= "TaxJar API wrapper";
	this.version			= "1.0.0";
	this.viewParentLookup 	= true;
	this.layoutParentLookup = true;
	this.entryPoint			= "taxjar";
	this.modelNamespace		= "taxjar";
	this.cfmapping			= "taxjar";
	this.autoMapModels		= true;
	this.dependencies 		= [];

	function configure(){

		// parent settings
		parentSettings = {

		};

		// module settings - stored in modules.name.settings
		settings = {
			taxjar = {
				"authorization" = "",
				"url" 			= "https://api.taxjar.com/v2/"
			}
		};

		// Layout Settings
		layoutSettings = {
			defaultLayout = ""
		};

		// SES Routes
		routes = [
			// Module Entry Point
			{ pattern="/", handler="home", action="index" },
			// Convention Route
			{ pattern="/:handler/:action?" }
		];

		// Custom Declared Points
		interceptorSettings = {
			customInterceptionPoints = ""
		};

		// Custom Declared Interceptors
		interceptors = [
		];

		

	}

	/**
	* Fired when the module is registered and activated.
	*/
	function onLoad(){

	}

	/**
	* Fired when the module is unregistered and unloaded
	*/
	function onUnload(){

	}

}
