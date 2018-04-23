component output="false" {
    
    property name="settings" inject="coldbox:moduleConfig:taxjar" scope="variables";

    public Taxjar function init() output="false" {		
		return this;
    }
    
    /**
    * Lists all tax categories.
    * Returns product categories and corresponding tax codes.
	* @product_tax_code Tax code of the given product category.
	* @name Name of the given product category.
	* @description Description of the given product category.	
    */    
    public struct function categories( string product_tax_code = '', string name = '', string description = '' ) output="false" {		
        var local = {};
        
        try{
           
            local.httpService = new http( 
                method 		= "GET", 
                charset 	= "utf-8", 
                url 		= _getURL('categories')
            ); 
           
            local.httpService.addParam( name = "Authorization", type = "Header", value = _getAuthorization() ); 

            local.result = local.httpService.send().getPrefix();

            if ( local.result.status_code != '200' ){
                return { "success" = false, "message" = "Unable retrive categories. ", "data" = local.result };
            }

            return { "success" = true, "message" = "", "data" = deSerializeJSON( local.result.filecontent ) };            

        }catch(any e){
            return { "success" = false, "message" = "Unable retrive categories. Error : " & e.message & " " & e.detail, "data" = [] };    
        }

        return { "success" = false, "message" = "Unable retrive categories, please try again later", "data" = [] };
    }

    /**
    * Show tax rates for a location.
    * Shows the sales tax rates for a given location.
	* @zip Postal code for given location (5-Digit ZIP or ZIP+4)..
	* @country_code Two-letter ISO country code of the country for given location.
    * @state Two-letter ISO state code for given location.
    * @city City for given location.
    * @street Street address for given location. 
    */    
    public struct function rates( 
        required string zip, 
        string country_code = '', 
        string state = '',
        string city = '',
        string street = ''
    ) output="false" {		
        var local = {};
        
        try{
           
            if ( trim(arguments.zip) == '' ){
                return { "success" = false, "message" = "Unable retrive rates. Zip code not valid", "data" = arguments };
            }

            arguments.country_code = uCase( trim( arguments.country_code ) );
            arguments.state = uCase( trim( arguments.state ) );
            arguments.city = uCase( trim( arguments.city ) );
            arguments.street = uCase( trim( arguments.street ) );

            local.queryParams = "?zip=" & trim( arguments.zip );
            
            if ( arguments.country_code != '' ){
                local.queryParams = listAppend( local.queryParams, "country=" & arguments.country_code, "&" );
            }

            if ( arguments.state != '' ){
                local.queryParams = listAppend( local.queryParams, "state=" & arguments.state, "&" );
            }

            if ( arguments.city != '' ){
                local.queryParams = listAppend( local.queryParams, "city=" & arguments.city, "&" );
            }

            if ( arguments.street != '' ){
                local.queryParams = listAppend( local.queryParams, "street=" & arguments.street, "&" );
            }

           
            local.httpService = new http( 
                method 		= "GET", 
                charset 	= "utf-8", 
                url 		= _getURL('rates/' & local.queryParams )
            ); 
           
            local.httpService.addParam( name = "Authorization", type = "Header", value = _getAuthorization() ); 

            local.result = local.httpService.send().getPrefix();

            if ( local.result.status_code != '200' ){
                return { "success" = false, "message" = "Unable retrive rates. ", "data" = local.result };
            }

            return { "success" = true, "message" = "", "data" = deSerializeJSON( local.result.filecontent ) };            

        }catch(any e){
            return { "success" = false, "message" = "Unable retrive rates. Error : " & e.message & " " & e.detail, "data" = [] };    
        }

        return { "success" = false, "message" = "Unable retrive rates, please try again later", "data" = [] };
    }
    
    /**
    * Calculate sales tax for an order
    * Shows the sales tax that should be collected for a given order.
	* @to_country Two-letter ISO country code of the country where the order shipped to.
	* @shipping Total amount of shipping for the order.
    * @from_country Two-letter ISO country code of the country where the order shipped from
    * @from_zip Postal code where the order shipped from (5-Digit ZIP or ZIP+4).
    * @from_state Two-letter ISO state code where the order shipped from.
    * @from_city City where the order shipped from.
    * @from_street Street address where the order shipped from.
    * @to_zip Postal code where the order shipped to (5-Digit ZIP or ZIP+4).
    * @to_state Two-letter ISO state code where the order shipped to.
    * @to_city City where the order shipped to.
    * @to_street Street address where the order shipped to.
    * @amount Total amount of the order, excluding shipping. 
    * @nexus_addresses Nexus Addresses. Either an address on file, `nexus_addresses` parameter, or `from_` parameters are required to perform tax calculations.
    * @line_items Either `amount` or `line_items` parameters are required to perform tax calculations.
    */    
    public struct function taxes( 
        required string to_country, 
        required numeric shipping, 
        string from_country = '', 
        string from_zip = '',
        string from_state = '',
        string from_city = '',
        string from_street = '',
        string to_zip = '',
        string to_state = '',
        string to_city = '',
        string to_street = '',
        numeric amount = 0,
        array nexus_addresses = [],
        array line_items = []
    ) output="false" {		
        var local = {};
        
        try{
           
            if ( !_countryCodeValid( arguments.to_country ) ){
                return { "success" = false, "message" = "Unable calculate sales tax. Country code of the country where the order shipped to not valid.", "data" = arguments };
            }

            if ( arguments.to_country == 'US' && arguments.to_zip == '' ){
                return { "success" = false, "message" = "Unable calculate sales tax. Postal code where the order shipped required.", "data" = arguments };
            }

            if ( listFindNoCase('US,CA', arguments.to_country) && arguments.to_state == '' ){
                return { "success" = false, "message" = "Unable calculate sales tax. Two-letter ISO state code where the order shipped to required.", "data" = arguments };
            }

            local.req_data = {
                line_items = []
            };
            
            structInsert(local.req_data, "from_country", uCase( trim(arguments.from_country) ) , true );
            structInsert(local.req_data, "from_zip", uCase( trim(arguments.from_zip) ) , true );
            structInsert(local.req_data, "from_state", uCase( trim(arguments.from_state) ) , true );
            structInsert(local.req_data, "from_city", uCase( trim(arguments.from_city) ) , true );
            structInsert(local.req_data, "from_street", uCase( trim(arguments.from_street) ) , true );
            structInsert(local.req_data, "to_country", uCase( trim(arguments.to_country) ) , true );
            structInsert(local.req_data, "to_zip", uCase( trim(arguments.to_zip) ) , true );
            structInsert(local.req_data, "to_state", uCase( trim(arguments.to_state) ) , true );
            structInsert(local.req_data, "to_city", uCase( trim(arguments.to_city) ) , true );
            structInsert(local.req_data, "to_street", uCase( trim(arguments.to_street) ) , true );
            structInsert(local.req_data, "amount", numberFormat( arguments.amount , ".00") , true );
            structInsert(local.req_data, "shipping", numberFormat( arguments.shipping, ".00") , true );
            
            for ( local.i in arguments.line_items ){

                if ( !structKeyExists( local.i, "id" ) ){
                    return { "success" = false, "message" = "Unable calculate sales tax. One of line item missed : id " };
                }
    
                if ( !structKeyExists( local.i, "quantity" ) ){
                    return { "success" = false, "message" = "Unable calculate sales tax. One of line item missed : quantity " };
                }
    
                if ( !structKeyExists( local.i, "product_tax_code" ) ){
                    return { "success" = false, "message" = "Unable calculate sales tax. One of line item missed : product_tax_code " };
                }
    
                if ( !structKeyExists( local.i, "unit_price" ) ){
                    return { "success" = false, "message" = "Unable calculate sales tax. One of line item missed : unit_price " };
                }
    
                if ( !structKeyExists( local.i, "discount" ) ){
                    return { "success" = false, "message" = "Unable calculate sales tax. One of line item missed : discount " };
                }
    
                arrayAppend(
                    local.req_data.line_items,
                    {
                        "id"                = local.i.id,
                        "quantity"          = local.i.quantity,
                        "product_tax_code"  = local.i.product_tax_code,
                        "unit_price"        = numberFormat(local.i.unit_price, ".00"),
                        "discount"          = numberFormat(local.i.discount, ".00")
                    }
                );
            }
              
           local.httpService = new http( 
                method 		= "POST", 
                charset 	= "utf-8", 
                url 		= _getURL('taxes')
            ); 			
            
            local.httpService.addParam( name = "Authorization", type = "Header", value = _getAuthorization() ); 
		    local.httpService.addParam( name = "Content-Type", type = "Header", value = "application/json;");
		    local.httpService.addParam( type = "Body", value = "#serializeJson( local.req_data )#");
		    local.result = local.httpService.send().getPrefix(); 				

            if ( local.result.status_code != '200' ){
                return { "success" = false, "message" = "Unable calculate sales tax. " & _getStatusCodeDescription( local.result.status_code ), "data" = local.result };
            }

            return { "success" = true, "message" = "", "data" = deSerializeJSON( local.result.filecontent ) };            

        }catch(any e){
            return { "success" = false, "message" = "Unable calculate sales tax. Error : " & e.message & " " & e.detail, "data" = [] };    
        }

        return { "success" = false, "message" = "Unable calculate sales tax, please try again later", "data" = [] };
    }

    /**
    * List order transactions
    * Lists existing order transactions created through the API.
	* @transaction_id Unique identifier of the given order transaction.
	* @transaction_date The date the transactions were originally recorded
    * @from_transaction_date Start date of a range for which the transactions were originally recorded.
    * @to_transaction_date End date of a range for which the transactions were originally recorded.    
    */    
    public struct function orders( 
        string transaction_id = '',
        string transaction_date = '',
        string from_transaction_date = '',
        string to_transaction_date = ''
    ) output="false" {		
        var local = {};
        
        try{
           
            local.queryParams = "?";

            if ( trim(arguments.transaction_id) != '' ){
                
                local.queryParams = uCase( trim(arguments.transaction_id) );

            }else{

                if ( isDate(arguments.transaction_date) ){
                    local.queryParams = listAppend(local.queryParams, "transaction_date=" & dateFormat(arguments.transaction_date,"yyyy/mm/dd"), "&" )
                }

                if ( isDate(arguments.from_transaction_date) ){
                    local.queryParams = listAppend(local.queryParams, "from_transaction_date=" & dateFormat(arguments.from_transaction_date,"yyyy/mm/dd") , "&" )
                }

                if ( isDate(arguments.to_transaction_date) ){
                    local.queryParams = listAppend(local.queryParams, "to_transaction_date=" & dateFormat(arguments.to_transaction_date,"yyyy/mm/dd") , "&" )
                }

            }
           
            local.httpService = new http( 
                method 		= "GET", 
                charset 	= "utf-8", 
                url 		= _getURL('transactions/orders/' & local.queryParams )
            ); 
           
            local.httpService.addParam( name = "Authorization", type = "Header", value = _getAuthorization() ); 
            local.result = local.httpService.send().getPrefix();

            if ( local.result.status_code != '200' ){
                return { "success" = false, "message" = "Unable retreive order transactions. " &  _getStatusCodeDescription( local.result.status_code ) , "data" = local.result };
            }

            return { "success" = true, "message" = "", "data" = deSerializeJSON( local.result.filecontent ) };            

        }catch(any e){
            return { "success" = false, "message" = "Unable retreive order transactions. Error : " & e.message & " " & e.detail, "data" = [] };    
        }

        return { "success" = false, "message" = "Unable retreive order transactions, please try again later", "data" = [] };
    }

    /**
    * Create an order transaction
    * Creates a new order transaction.
    * @transaction_id Unique identifier of the given order transaction.
    * @transaction_date The date/time the transaction was originally recorded.
    * @to_country Two-letter ISO country code of the country where the order shipped to.
    * @to_zip Postal code where the order shipped to (5-Digit ZIP or ZIP+4).
    * @to_state Two-letter ISO state code where the order shipped to.
    * @amount Total amount of the order with shipping, excluding sales tax in dollars.
    * @shipping Total amount of shipping for the order in dollars.
    * @sales_tax Total amount of sales tax collected for the order in dollars.
    * @from_country Two-letter ISO country code of the country where the order shipped from.
    * @from_zip Postal code where the order shipped from (5-Digit ZIP or ZIP+4).
    * @from_state Two-letter ISO state code where the order shipped from.
    * @from_city City where the order shipped from.
    * @from_street Street address where the order shipped from.
    * @to_zip Postal code where the order shipped to (5-Digit ZIP or ZIP+4).
    * @to_state Two-letter ISO state code where the order shipped to.
    * @to_city City where the order shipped to.
    * @to_street Street address where the order shipped to.    
    * @line_items array of items { id = 'Unique identifier of the given line item.', quantity = 'Quantity for the item.', product_identifier = 'Product identifier for the item.', description = 'Description of the line item (up to 255 characters).', product_tax_code = 'Product tax code for the item. If omitted, the item will remain fully taxable.', unit_price = 'Unit price for the item in dollars.', discount = 'Total discount (non-unit) for the item in dollars.', sales_tax = 'Total sales tax collected (non-unit) for the item in dollars.' }
    */    
    public struct function createOrder( 
        required string transaction_id,
        required date transaction_date,
        required string to_country,
        required string to_zip,
        required string to_state,
        required number amount,
        required number shipping,
        required number sales_tax,
        string from_country = '', 
        string from_zip = '',
        string from_state = '',
        string from_city = '',
        string from_street = '',                
        string to_city = '',
        string to_street = '',        
        array line_items = []
    ) output="false" {		
        var local = {};
        
        try{
            
            if ( trim(arguments.transaction_id) == '' ){
                return { "success" = false, "message" = "Unable create order transaction. Transaction ID required ", "data" = arguments };
            }

            if ( trim(arguments.to_country) == '' ){
                return { "success" = false, "message" = "Unable create order transaction. To Country required ", "data" = arguments };
            }

            if ( trim(arguments.to_zip) == '' ){
                return { "success" = false, "message" = "Unable create order transaction. To Zip required ", "data" = arguments };
            }

            if ( trim(arguments.to_state) == '' ){
                return { "success" = false, "message" = "Unable create order transaction. To State required ", "data" = arguments };
            }

            local.req_data = {
                "line_items" = []
            };

            for ( local.i in arguments.line_items ){

                if ( !structKeyExists( local.i, "id" ) ){
                    return { "success" = false, "message" = "Unable create order transaction. One of line item missed : id " };
                }
    
                if ( !structKeyExists( local.i, "quantity" ) ){
                    return { "success" = false, "message" = "Unable create order transaction. One of line item missed : quantity " };
                }
    
                if ( !structKeyExists( local.i, "product_tax_code" ) ){
                    return { "success" = false, "message" = "Unable create order transaction. One of line item missed : product_tax_code " };
                }
    
                if ( !structKeyExists( local.i, "unit_price" ) ){
                    return { "success" = false, "message" = "Unable create order transaction. One of line item missed : unit_price " };
                }
    
                if ( !structKeyExists( local.i, "discount" ) ){
                    return { "success" = false, "message" = "Unable create order transaction. One of line item missed : discount " };
                }
    
                if ( !structKeyExists( local.i, "description" ) ){
                    return { "success" = false, "message" = "Unable create order transaction. One of line item missed : description " };
                }
    
                arrayAppend(
                    local.req_data.line_items,
                    {
                        "product_identifier"= local.i.id,
                        "description"       = uCase(trim(local.i.description)),
                        "quantity"          = local.i.quantity,
                        "product_tax_code"  = local.i.product_tax_code,
                        "unit_price"        = numberFormat(local.i.unit_price, ".00"),
                        "discount"          = numberFormat(local.i.discount, ".00")
                    }
                );		
            }
            
            structInsert(local.req_data, "transaction_id", uCase( trim(arguments.transaction_id) ) , true );
            structInsert(local.req_data, "transaction_date", dateFormat(arguments.transaction_date,"yyyy-mm-dd") , true );
            structInsert(local.req_data, "from_country", uCase( trim(arguments.from_country) ) , true );
            structInsert(local.req_data, "from_zip", uCase( trim(arguments.from_zip) ) , true );
            structInsert(local.req_data, "from_state", uCase( trim(arguments.from_state) ) , true );
            structInsert(local.req_data, "from_city", uCase( trim(arguments.from_city) ) , true );
            structInsert(local.req_data, "from_street", uCase( trim(arguments.from_street) ) , true );
            structInsert(local.req_data, "to_country", uCase( trim(arguments.to_country) ) , true );
            structInsert(local.req_data, "to_zip", uCase( trim(arguments.to_zip) ) , true );
            structInsert(local.req_data, "to_state", uCase( trim(arguments.to_state) ) , true );
            structInsert(local.req_data, "to_city", uCase( trim(arguments.to_city) ) , true );
            structInsert(local.req_data, "to_street", uCase( trim(arguments.to_street) ) , true );
            structInsert(local.req_data, "amount", numberFormat( arguments.amount , ".00") , true );
            structInsert(local.req_data, "shipping", numberFormat( arguments.shipping, ".00") , true );
            structInsert(local.req_data, "sales_tax", numberFormat( arguments.sales_tax, ".00") , true );
                       
            local.httpService = new http( 
                method 		= "POST", 
                charset 	= "utf-8", 
                url 		= _getURL('transactions/orders/')
            ); 
           
            local.httpService.addParam( name = "Authorization", type = "Header", value = _getAuthorization() ); 
            local.httpService.addParam( name = "Content-Type", type = "Header", value = "application/json; utf-8");
		    local.httpService.addParam( type = "Body", value = "#serializeJson(local.req_data)#");
            local.result = local.httpService.send().getPrefix();

            if ( local.result.status_code != '201' ){
                return { "success" = false, "message" = "Unable create order transaction. " &  _getStatusCodeDescription( local.result.status_code ) , "data" = local.result };
            }

            return { "success" = true, "message" = "", "data" = deSerializeJSON( local.result.filecontent ) };            

        }catch(any e){
            return { "success" = false, "message" = "Unable create order transaction. Error : " & e.message & " " & e.detail, "data" = [] };    
        }

        return { "success" = false, "message" = "Unable create order transaction, please try again later", "data" = [] };
    }

    /**
    * updateOrder
    * Updates an existing order transaction created through the API.
    * @transaction_id Unique identifier of the given order transaction.
    * @transaction_date The date/time the transaction was originally recorded.
    * @to_country Two-letter ISO country code of the country where the order shipped to.
    * @to_zip Postal code where the order shipped to (5-Digit ZIP or ZIP+4).
    * @to_state Two-letter ISO state code where the order shipped to.
    * @amount Total amount of the order with shipping, excluding sales tax in dollars.
    * @shipping Total amount of shipping for the order in dollars.
    * @sales_tax Total amount of sales tax collected for the order in dollars.
    * @from_country Two-letter ISO country code of the country where the order shipped from.
    * @from_zip Postal code where the order shipped from (5-Digit ZIP or ZIP+4).
    * @from_state Two-letter ISO state code where the order shipped from.
    * @from_city City where the order shipped from.
    * @from_street Street address where the order shipped from.    
    * @to_city City where the order shipped to.
    * @to_street Street address where the order shipped to.    
    * @line_items array of items { id = 'Unique identifier of the given line item.', quantity = 'Quantity for the item.', product_identifier = 'Product identifier for the item.', description = 'Description of the line item (up to 255 characters).', product_tax_code = 'Product tax code for the item. If omitted, the item will remain fully taxable.', unit_price = 'Unit price for the item in dollars.', discount = 'Total discount (non-unit) for the item in dollars.', sales_tax = 'Total sales tax collected (non-unit) for the item in dollars.' }
    */    
    public struct function updateOrder( 
        required string transaction_id,
        string transaction_date = '',
        string to_country  = '',
        string to_zip  = '',
        string to_state  = '',
        number amount = 0,
        number shipping = 0,
        number sales_tax = 0,
        string from_country = '', 
        string from_zip = '',
        string from_state = '',
        string from_city = '',
        string from_street = '',                
        string to_city = '',
        string to_street = '',        
        array line_items = []
    ) output="false" {		
        var local = {};
        
        try{
            
            if ( trim(arguments.transaction_id) == '' ){
                return { "success" = false, "message" = "Unable create order transaction. Transaction ID required ", "data" = arguments };
            }
            
            local.req_data = {
                "line_items" = []
            };

            for ( local.i in arguments.line_items ){

                if ( !structKeyExists( local.i, "id" ) ){
                    return { "success" = false, "message" = "Unable create order transaction. One of line item missed : id " };
                }
    
                if ( !structKeyExists( local.i, "quantity" ) ){
                    return { "success" = false, "message" = "Unable create order transaction. One of line item missed : quantity " };
                }
    
                if ( !structKeyExists( local.i, "product_tax_code" ) ){
                    return { "success" = false, "message" = "Unable create order transaction. One of line item missed : product_tax_code " };
                }
    
                if ( !structKeyExists( local.i, "unit_price" ) ){
                    return { "success" = false, "message" = "Unable create order transaction. One of line item missed : unit_price " };
                }
    
                if ( !structKeyExists( local.i, "discount" ) ){
                    return { "success" = false, "message" = "Unable create order transaction. One of line item missed : discount " };
                }
    
                if ( !structKeyExists( local.i, "description" ) ){
                    return { "success" = false, "message" = "Unable create order transaction. One of line item missed : description " };
                }
    
                arrayAppend(
                    local.req_data.line_items,
                    {
                        "product_identifier"= local.i.id,
                        "description"       = uCase(trim(local.i.description)),
                        "quantity"          = local.i.quantity,
                        "product_tax_code"  = local.i.product_tax_code,
                        "unit_price"        = numberFormat(local.i.unit_price, ".00"),
                        "discount"          = numberFormat(local.i.discount, ".00")
                    }
                );		
            }
            
            structInsert(local.req_data, "transaction_id", uCase( trim(arguments.transaction_id) ) , true );

            if ( isDate(arguments.transaction_date)){
                structInsert(local.req_data, "transaction_date", dateFormat(arguments.transaction_date,"yyyy-mm-dd") , true );
            }
            
            if ( arguments.from_country != '' ){
                structInsert(local.req_data, "from_country", uCase( trim(arguments.from_country) ) , true );
            }

            if ( arguments.from_zip != '' ){
                structInsert(local.req_data, "from_zip", uCase( trim(arguments.from_zip) ) , true );
            }
            
            if ( arguments.from_state != '' ){
                structInsert(local.req_data, "from_state", uCase( trim(arguments.from_state) ) , true );
            }

            if ( arguments.from_city != '' ){
                structInsert(local.req_data, "from_city", uCase( trim(arguments.from_city) ) , true );
            }
            
            if ( arguments.from_street != '' ){
                structInsert(local.req_data, "from_street", uCase( trim(arguments.from_street) ) , true );
            }
            
            if ( arguments.to_country != '' ){
                structInsert(local.req_data, "to_country", uCase( trim(arguments.to_country) ) , true );
            }
            
            if ( arguments.to_zip != '' ){
                structInsert(local.req_data, "to_zip", uCase( trim(arguments.to_zip) ) , true );
            }
            
            if ( arguments.to_state != '' ){
                structInsert(local.req_data, "to_state", uCase( trim(arguments.to_state) ) , true );
            }
            
            if ( arguments.to_city != '' ){
                structInsert(local.req_data, "to_city", uCase( trim(arguments.to_city) ) , true );
            }
            
            if ( arguments.to_street != '' ){
                structInsert(local.req_data, "to_street", uCase( trim(arguments.to_street) ) , true );
            }
            
            if ( arguments.amount ){
                structInsert(local.req_data, "amount", numberFormat( arguments.amount , ".00") , true );
            }
            
            structInsert(local.req_data, "shipping", numberFormat( arguments.shipping, ".00") , true );            
            structInsert(local.req_data, "sales_tax", numberFormat( arguments.sales_tax, ".00") , true );
           
            local.httpService = new http( 
                method 		= "PUT", 
                charset 	= "utf-8", 
                url 		= _getURL('transactions/orders/' & uCase( trim(arguments.transaction_id) ) )
            ); 
           
            local.httpService.addParam( name = "Authorization", type = "Header", value = _getAuthorization() ); 
            local.httpService.addParam( name = "Content-Type", type = "Header", value = "application/json; utf-8");
		    local.httpService.addParam( type = "Body", value = "#serializeJson(local.req_data)#");
            local.result = local.httpService.send().getPrefix();

            if ( local.result.status_code != '200' ){
                return { "success" = false, "message" = "Unable retreive order transactions. " &  _getStatusCodeDescription( local.result.status_code ) , "data" = local.result };
            }

            return { "success" = true, "message" = "", "data" = deSerializeJSON( local.result.filecontent ) };            

        }catch(any e){
            return { "success" = false, "message" = "Unable retreive order transactions. Error : " & e.message & " " & e.detail, "data" = [] };    
        }

        return { "success" = false, "message" = "Unable retreive order transactions, please try again later", "data" = [] };
    }

    /**
    * Delete an order transaction
    * Deletes an existing order transaction created through the API.
    * @transaction_id Unique identifier of the given order transaction.    
    */    
    public struct function deleteOrder( required string transaction_id ) output="false" {		
        var local = {};
        
        try{
            
            if ( trim(arguments.transaction_id) == '' ){
                return { "success" = false, "message" = "Unable delete order. Transaction ID required ", "data" = arguments };
            }
            
            local.httpService = new http( 
                method 		= "DELETE", 
                charset 	= "utf-8", 
                url 		= _getURL('transactions/orders/' & uCase( trim(arguments.transaction_id) ) )
            ); 
           
            local.httpService.addParam( name = "Authorization", type = "Header", value = _getAuthorization() ); 
            local.result = local.httpService.send().getPrefix();

            if ( local.result.status_code != '200' ){
                return { "success" = false, "message" = "Unable delete order. " &  _getStatusCodeDescription( local.result.status_code ) , "data" = local.result };
            }

            return { "success" = true, "message" = "", "data" = deSerializeJSON( local.result.filecontent ) };            

        }catch(any e){
            return { "success" = false, "message" = "Unable delete order. Error : " & e.message & " " & e.detail, "data" = [] };    
        }

        return { "success" = false, "message" = "Unable delete order, please try again later", "data" = [] };
    }

    /**
    * refunds
    * Lists existing refund transactions created through the API.
	* @transaction_id Unique identifier of the given order transaction.
	* @transaction_date The date the transactions were originally recorded
    * @from_transaction_date Start date of a range for which the transactions were originally recorded.
    * @to_transaction_date End date of a range for which the transactions were originally recorded.    
    */    
    public struct function refunds( 
        string transaction_id = '',
        string transaction_date = '',
        string from_transaction_date = '',
        string to_transaction_date = ''
    ) output="false" {		
        var local = {};
        
        try{
           
            local.queryParams = "?";

            if ( trim(arguments.transaction_id) != '' ){
                
                local.queryParams = uCase( trim(arguments.transaction_id) );

            }else{

                if ( isDate(arguments.transaction_date) ){
                    local.queryParams = listAppend(local.queryParams, "transaction_date=" & dateFormat(arguments.transaction_date,"yyyy/mm/dd"), "&" )
                }

                if ( isDate(arguments.from_transaction_date) ){
                    local.queryParams = listAppend(local.queryParams, "from_transaction_date=" & dateFormat(arguments.from_transaction_date,"yyyy/mm/dd") , "&" )
                }

                if ( isDate(arguments.to_transaction_date) ){
                    local.queryParams = listAppend(local.queryParams, "to_transaction_date=" & dateFormat(arguments.to_transaction_date,"yyyy/mm/dd") , "&" )
                }

            }
                      
            local.httpService = new http( 
                method 		= "GET", 
                charset 	= "utf-8", 
                url 		= _getURL('transactions/refunds/' & local.queryParams )
            ); 
           
            local.httpService.addParam( name = "Authorization", type = "Header", value = _getAuthorization() ); 
            local.result = local.httpService.send().getPrefix();

            if ( local.result.status_code != '200' ){
                return { "success" = false, "message" = "Unable retreive refund transactions. " &  _getStatusCodeDescription( local.result.status_code ) , "data" = local.result };
            }

            return { "success" = true, "message" = "", "data" = deSerializeJSON( local.result.filecontent ) };            

        }catch(any e){
            return { "success" = false, "message" = "Unable retreive refund transactions. Error : " & e.message & " " & e.detail, "data" = [] };    
        }

        return { "success" = false, "message" = "Unable retreive refund transactions, please try again later", "data" = [] };
    }

    /**
    * createRefund
    * Creates a new refund transaction.
    * @transaction_id Unique identifier of the given order transaction.
    * @transaction_reference_id Unique identifier of the corresponding order transaction for the refund.
    * @transaction_date The date/time the transaction was originally recorded.
    * @to_country Two-letter ISO country code of the country where the order shipped to.
    * @to_zip Postal code where the order shipped to (5-Digit ZIP or ZIP+4).
    * @to_state Two-letter ISO state code where the order shipped to.
    * @amount Total amount of the order with shipping, excluding sales tax in dollars.
    * @shipping Total amount of shipping for the order in dollars.
    * @sales_tax Total amount of sales tax collected for the order in dollars.
    * @from_country Two-letter ISO country code of the country where the order shipped from.
    * @from_zip Postal code where the order shipped from (5-Digit ZIP or ZIP+4).
    * @from_state Two-letter ISO state code where the order shipped from.
    * @from_city City where the order shipped from.
    * @from_street Street address where the order shipped from.        
    * @to_city City where the order shipped to.
    * @to_street Street address where the order shipped to.    
    * @line_items array of items { id = 'Unique identifier of the given line item.', quantity = 'Quantity for the item.', product_identifier = 'Product identifier for the item.', description = 'Description of the line item (up to 255 characters).', product_tax_code = 'Product tax code for the item. If omitted, the item will remain fully taxable.', unit_price = 'Unit price for the item in dollars.', discount = 'Total discount (non-unit) for the item in dollars.', sales_tax = 'Total sales tax collected (non-unit) for the item in dollars.' }
    */    
    public struct function createRefund( 
        required string transaction_id,
        required string transaction_reference_id,
        required date transaction_date,
        required string to_country,
        required string to_zip,
        required string to_state,
        required number amount,
        required number shipping,
        required number sales_tax,
        string from_country = '', 
        string from_zip = '',
        string from_state = '',
        string from_city = '',
        string from_street = '',                
        string to_city = '',
        string to_street = '',        
        array line_items = []
    ) output="false" {		
        var local = {};
        
        try{
            
            if ( trim(arguments.transaction_id) == '' ){
                return { "success" = false, "message" = "Unable create refund transaction. Transaction ID required ", "data" = arguments };
            }

            if ( trim(arguments.transaction_reference_id) == '' ){
                return { "success" = false, "message" = "Unable create refund transaction. Transaction Reference ID required ", "data" = arguments };
            }

            if ( trim(arguments.to_country) == '' ){
                return { "success" = false, "message" = "Unable create refund transaction. To Country required ", "data" = arguments };
            }

            if ( trim(arguments.to_zip) == '' ){
                return { "success" = false, "message" = "Unable create refund transaction. To Zip required ", "data" = arguments };
            }

            if ( trim(arguments.to_state) == '' ){
                return { "success" = false, "message" = "Unable create refund transaction. To State required ", "data" = arguments };
            }

            local.req_data = {
                "line_items" = []
            };

            for ( local.i in arguments.line_items ){

                if ( !structKeyExists( local.i, "id" ) ){
                    return { "success" = false, "message" = "Unable create refund transaction. One of line item missed : id " };
                }
    
                if ( !structKeyExists( local.i, "quantity" ) ){
                    return { "success" = false, "message" = "Unable create refund transaction. One of line item missed : quantity " };
                }
    
                if ( !structKeyExists( local.i, "product_tax_code" ) ){
                    return { "success" = false, "message" = "Unable create refund transaction. One of line item missed : product_tax_code " };
                }
    
                if ( !structKeyExists( local.i, "unit_price" ) ){
                    return { "success" = false, "message" = "Unable create refund transaction. One of line item missed : unit_price " };
                }
    
                if ( !structKeyExists( local.i, "discount" ) ){
                    return { "success" = false, "message" = "Unable create refund transaction. One of line item missed : discount " };
                }
    
                if ( !structKeyExists( local.i, "description" ) ){
                    return { "success" = false, "message" = "Unable create refund transaction. One of line item missed : description " };
                }
    
                arrayAppend(
                    local.req_data.line_items,
                    {
                        "product_identifier"= local.i.id,
                        "description"       = uCase(trim(local.i.description)),
                        "quantity"          = local.i.quantity,
                        "product_tax_code"  = local.i.product_tax_code,
                        "unit_price"        = numberFormat(local.i.unit_price, ".00"),
                        "discount"          = numberFormat(local.i.discount, ".00")
                    }
                );		
            }
            
            structInsert(local.req_data, "transaction_id", uCase( trim(arguments.transaction_id) ) , true );
            structInsert(local.req_data, "transaction_date", dateFormat(arguments.transaction_date,"yyyy-mm-dd") , true );
            structInsert(local.req_data, "from_country", uCase( trim(arguments.from_country) ) , true );
            structInsert(local.req_data, "from_zip", uCase( trim(arguments.from_zip) ) , true );
            structInsert(local.req_data, "from_state", uCase( trim(arguments.from_state) ) , true );
            structInsert(local.req_data, "from_city", uCase( trim(arguments.from_city) ) , true );
            structInsert(local.req_data, "from_street", uCase( trim(arguments.from_street) ) , true );
            structInsert(local.req_data, "to_country", uCase( trim(arguments.to_country) ) , true );
            structInsert(local.req_data, "to_zip", uCase( trim(arguments.to_zip) ) , true );
            structInsert(local.req_data, "to_state", uCase( trim(arguments.to_state) ) , true );
            structInsert(local.req_data, "to_city", uCase( trim(arguments.to_city) ) , true );
            structInsert(local.req_data, "to_street", uCase( trim(arguments.to_street) ) , true );
            structInsert(local.req_data, "amount", numberFormat( arguments.amount , ".00") , true );
            structInsert(local.req_data, "shipping", numberFormat( arguments.shipping, ".00") , true );
            structInsert(local.req_data, "sales_tax", numberFormat( arguments.sales_tax, ".00") , true );
           
            local.httpService = new http( 
                method 		= "POST", 
                charset 	= "utf-8", 
                url 		= _getURL('transactions/refunds/')
            ); 
           
            local.httpService.addParam( name = "Authorization", type = "Header", value = _getAuthorization() ); 
            local.httpService.addParam( name = "Content-Type", type = "Header", value = "application/json; utf-8");
		    local.httpService.addParam( type = "Body", value = "#serializeJson(local.req_data)#");
            local.result = local.httpService.send().getPrefix();

            if ( local.result.status_code != '201' ){
                return { "success" = false, "message" = "Unable create refund transaction. " &  _getStatusCodeDescription( local.result.status_code ) , "data" = local.result };
            }

            return { "success" = true, "message" = "", "data" = deSerializeJSON( local.result.filecontent ) };            

        }catch(any e){
            return { "success" = false, "message" = "Unable create refund transaction. Error : " & e.message & " " & e.detail, "data" = [] };    
        }

        return { "success" = false, "message" = "Unable create refund transaction, please try again later", "data" = [] };
    }

    /**
    * updateRefund
    * Updates an existing refund transaction created through the API.
    * @transaction_id Unique identifier of the given order transaction.
    * @transaction_reference_id Unique identifier of the corresponding order transaction for the refund.
    * @transaction_date The date/time the transaction was originally recorded.
    * @to_country Two-letter ISO country code of the country where the order shipped to.
    * @to_zip Postal code where the order shipped to (5-Digit ZIP or ZIP+4).
    * @to_state Two-letter ISO state code where the order shipped to.
    * @amount Total amount of the order with shipping, excluding sales tax in dollars.
    * @shipping Total amount of shipping for the order in dollars.
    * @sales_tax Total amount of sales tax collected for the order in dollars.
    * @from_country Two-letter ISO country code of the country where the order shipped from.
    * @from_zip Postal code where the order shipped from (5-Digit ZIP or ZIP+4).
    * @from_state Two-letter ISO state code where the order shipped from.
    * @from_city City where the order shipped from.
    * @from_street Street address where the order shipped from.    
    * @to_city City where the order shipped to.
    * @to_street Street address where the order shipped to.    
    * @line_items array of items { id = 'Unique identifier of the given line item.', quantity = 'Quantity for the item.', product_identifier = 'Product identifier for the item.', description = 'Description of the line item (up to 255 characters).', product_tax_code = 'Product tax code for the item. If omitted, the item will remain fully taxable.', unit_price = 'Unit price for the item in dollars.', discount = 'Total discount (non-unit) for the item in dollars.', sales_tax = 'Total sales tax collected (non-unit) for the item in dollars.' }
    */    
    public struct function updateRefund( 
        required string transaction_id,
        required string transaction_reference_id,
        string transaction_date = '',
        string to_country  = '',
        string to_zip  = '',
        string to_state  = '',
        number amount = 0,
        number shipping = 0,
        number sales_tax = 0,
        string from_country = '', 
        string from_zip = '',
        string from_state = '',
        string from_city = '',
        string from_street = '',                
        string to_city = '',
        string to_street = '',        
        array line_items = []
    ) output="false" {		
        var local = {};
        
        try{
            
            if ( trim(arguments.transaction_id) == '' ){
                return { "success" = false, "message" = "Unable update refund transaction. Transaction ID required ", "data" = arguments };
            }
            
            if ( trim(arguments.transaction_reference_id) == '' ){
                return { "success" = false, "message" = "Unable update refund transaction. Transaction Reference ID required ", "data" = arguments };
            }

            local.req_data = {
                "line_items" = []
            };

            for ( local.i in arguments.line_items ){

                if ( !structKeyExists( local.i, "id" ) ){
                    return { "success" = false, "message" = "Unable update refund transaction. One of line item missed : id " };
                }
    
                if ( !structKeyExists( local.i, "quantity" ) ){
                    return { "success" = false, "message" = "Unable update refund transaction. One of line item missed : quantity " };
                }
    
                if ( !structKeyExists( local.i, "product_tax_code" ) ){
                    return { "success" = false, "message" = "Unable update refund transaction. One of line item missed : product_tax_code " };
                }
    
                if ( !structKeyExists( local.i, "unit_price" ) ){
                    return { "success" = false, "message" = "Unable update refund transaction. One of line item missed : unit_price " };
                }
    
                if ( !structKeyExists( local.i, "discount" ) ){
                    return { "success" = false, "message" = "Unable update refund transaction. One of line item missed : discount " };
                }
    
                if ( !structKeyExists( local.i, "description" ) ){
                    return { "success" = false, "message" = "Unable update refund transaction. One of line item missed : description " };
                }
    
                arrayAppend(
                    local.req_data.line_items,
                    {
                        "product_identifier"= local.i.id,
                        "description"       = uCase(trim(local.i.description)),
                        "quantity"          = local.i.quantity,
                        "product_tax_code"  = local.i.product_tax_code,
                        "unit_price"        = numberFormat(local.i.unit_price, ".00"),
                        "discount"          = numberFormat(local.i.discount, ".00")
                    }
                );		
            }
            
            structInsert(local.req_data, "transaction_id", uCase( trim(arguments.transaction_id) ) , true );
            structInsert(local.req_data, "transaction_reference_id", uCase( trim(arguments.transaction_reference_id) ) , true );

            if ( isDate(arguments.transaction_date)){
                structInsert(local.req_data, "transaction_date", dateFormat(arguments.transaction_date,"yyyy-mm-dd") , true );
            }
            
            if ( arguments.from_country != '' ){
                structInsert(local.req_data, "from_country", uCase( trim(arguments.from_country) ) , true );
            }

            if ( arguments.from_zip != '' ){
                structInsert(local.req_data, "from_zip", uCase( trim(arguments.from_zip) ) , true );
            }
            
            if ( arguments.from_state != '' ){
                structInsert(local.req_data, "from_state", uCase( trim(arguments.from_state) ) , true );
            }

            if ( arguments.from_city != '' ){
                structInsert(local.req_data, "from_city", uCase( trim(arguments.from_city) ) , true );
            }
            
            if ( arguments.from_street != '' ){
                structInsert(local.req_data, "from_street", uCase( trim(arguments.from_street) ) , true );
            }
            
            if ( arguments.to_country != '' ){
                structInsert(local.req_data, "to_country", uCase( trim(arguments.to_country) ) , true );
            }
            
            if ( arguments.to_zip != '' ){
                structInsert(local.req_data, "to_zip", uCase( trim(arguments.to_zip) ) , true );
            }
            
            if ( arguments.to_state != '' ){
                structInsert(local.req_data, "to_state", uCase( trim(arguments.to_state) ) , true );
            }
            
            if ( arguments.to_city != '' ){
                structInsert(local.req_data, "to_city", uCase( trim(arguments.to_city) ) , true );
            }
            
            if ( arguments.to_street != '' ){
                structInsert(local.req_data, "to_street", uCase( trim(arguments.to_street) ) , true );
            }
            
            if ( arguments.amount ){
                structInsert(local.req_data, "amount", numberFormat( arguments.amount , ".00") , true );
            }
            
            structInsert(local.req_data, "shipping", numberFormat( arguments.shipping, ".00") , true );            
            structInsert(local.req_data, "sales_tax", numberFormat( arguments.sales_tax, ".00") , true );
           
            local.httpService = new http( 
                method 		= "PUT", 
                charset 	= "utf-8", 
                url 		= _getURL('transactions/refunds/' & uCase( trim(arguments.transaction_id) ) )
            ); 
           
            local.httpService.addParam( name = "Authorization", type = "Header", value = _getAuthorization() ); 
            local.httpService.addParam( name = "Content-Type", type = "Header", value = "application/json; utf-8");
		    local.httpService.addParam( type = "Body", value = "#serializeJson(local.req_data)#");
            local.result = local.httpService.send().getPrefix();

            if ( local.result.status_code != '200' ){
                return { "success" = false, "message" = "Unable update refund transaction. " &  _getStatusCodeDescription( local.result.status_code ) , "data" = local.result };
            }

            return { "success" = true, "message" = "", "data" = deSerializeJSON( local.result.filecontent ) };            

        }catch(any e){
            return { "success" = false, "message" = "Unable update refund transaction. Error : " & e.message & " " & e.detail, "data" = [] };    
        }

        return { "success" = false, "message" = "Unable update refund transaction, please try again later", "data" = [] };
    }

    /**
    * deleteRefund
    *Deletes an existing refund transaction created through the API.
    * @transaction_id Unique identifier of the given order transaction.    
    */    
    public struct function deleteRefund( required string transaction_id ) output="false" {		
        var local = {};
        
        try{
            
            if ( trim(arguments.transaction_id) == '' ){
                return { "success" = false, "message" = "Unable delete refund. Transaction ID required ", "data" = arguments };
            }
            
            local.httpService = new http( 
                method 		= "DELETE", 
                charset 	= "utf-8", 
                url 		= _getURL('transactions/refunds/' & uCase( trim(arguments.transaction_id) ) )
            ); 
           
            local.httpService.addParam( name = "Authorization", type = "Header", value = _getAuthorization() ); 
            local.result = local.httpService.send().getPrefix();

            if ( local.result.status_code != '200' ){
                return { "success" = false, "message" = "Unable delete refund. " &  _getStatusCodeDescription( local.result.status_code ) , "data" = local.result };
            }

            return { "success" = true, "message" = "", "data" = deSerializeJSON( local.result.filecontent ) };            

        }catch(any e){
            return { "success" = false, "message" = "Unable delete refund. Error : " & e.message & " " & e.detail, "data" = [] };    
        }

        return { "success" = false, "message" = "Unable delete refund, please try again later", "data" = [] };
    }

    /**
    * nexus
    * Lists existing nexus locations for a TaxJar account.    
    */    
    public struct function nexus() output="false" {		
        var local = {};
        
        try{                       
            
            local.httpService = new http( 
                method 		= "GET", 
                charset 	= "utf-8", 
                url 		= _getURL('nexus/regions' )
            ); 
           
            local.httpService.addParam( name = "Authorization", type = "Header", value = _getAuthorization() ); 
            local.result = local.httpService.send().getPrefix();

            if ( local.result.status_code != '200' ){
                return { "success" = false, "message" = "Unable retrieve nexus regions. " &  _getStatusCodeDescription( local.result.status_code ) , "data" = local.result };
            }

            return { "success" = true, "message" = "", "data" = deSerializeJSON( local.result.filecontent ) };            

        }catch(any e){
            return { "success" = false, "message" = "Unable retrieve nexus regions. Error : " & e.message & " " & e.detail, "data" = [] };    
        }

        return { "success" = false, "message" = "Unable retrieve nexus regions, please try again later", "data" = [] };
    }

    /**
    * validateVAT
    * Validates an existing VAT identification number against VIES ( http://ec.europa.eu/taxation_customs/vies/ )
    */    
    public struct function validateVAT( required string vat ) output="false" {		
        var local = {};
        
        try{                       
            
            if ( trim( arguments.vat ) == '' ){
                return { "success" = false, "message" = "Unable validate VAT. VAT identification number required ", "data" = arguments };
            }

            local.httpService = new http( 
                method 		= "GET", 
                charset 	= "utf-8", 
                url 		= _getURL('nexus/validation/?vat=' & trim( arguments.vat )  )
            ); 
           
            local.httpService.addParam( name = "Authorization", type = "Header", value = _getAuthorization() ); 
            local.result = local.httpService.send().getPrefix();

            if ( local.result.status_code != '200' ){
                return { "success" = false, "message" = "Unable validate VAT. " &  _getStatusCodeDescription( local.result.status_code ) , "data" = local.result };
            }

            return { "success" = true, "message" = "", "data" = deSerializeJSON( local.result.filecontent ) };            

        }catch(any e){
            return { "success" = false, "message" = "Unable validate VAT. Error : " & e.message & " " & e.detail, "data" = {} };    
        }

        return { "success" = false, "message" = "Unable validate VAT, please try again later", "data" = {} };
    }

     /**
    * summarizedRates
    * Retrieve minimum and average sales tax rates by region as a backup.
    */    
    public struct function summarizedRates(  ) output="false" {		
        var local = {};
        
        try{                       
            
            local.httpService = new http( 
                method 		= "GET", 
                charset 	= "utf-8", 
                url 		= _getURL('summary_rates' )
            ); 
           
            local.httpService.addParam( name = "Authorization", type = "Header", value = _getAuthorization() ); 
            local.result = local.httpService.send().getPrefix();

            if ( local.result.status_code != '200' ){
                return { "success" = false, "message" = "Unable retrieve minimum and average sales tax rates by region. " &  _getStatusCodeDescription( local.result.status_code ) , "data" = local.result };
            }

            return { "success" = true, "message" = "", "data" = deSerializeJSON( local.result.filecontent ) };            

        }catch(any e){
            return { "success" = false, "message" = "Unable retrieve minimum and average sales tax rates by region. Error : " & e.message & " " & e.detail, "data" = {} };    
        }

        return { "success" = false, "message" = "Unable retrieve minimum and average sales tax rates by region, please try again later", "data" = {} };
    }

    //Private methods *************************************************************************************
    private string function _getURL( string api_request = '' ) output="false" {		
        var settings = _getTaxjarSettings();

        if ( structKeyExists(settings, "url") ){
            return settings.url & arguments.api_request;
        }

        return "";
    }

    /**
    * Authorization code.    
    * TaxJar uses API keys to allow access to the API. If you’re new to TaxJar, you’ll need to https://app.taxjar.com/api_sign_up/basic/ for an account to get your API key.    
    */    
    private string function _getAuthorization() output="false" {		
        var settings = _getTaxjarSettings();

        if ( structKeyExists(settings, "authorization") ){
            return settings.authorization;
        }

        return "";
    }
    
    private struct function _getSettings() output="false" {		
        
        if ( structKeyExists(variables.settings, "settings") && isStruct(variables.settings) ){
            return variables.settings.settings;
        }
        
        return {};
    }

    private struct function _getTaxjarSettings() output="false" {		
        var settings = _getSettings();

        if ( structKeyExists(settings, "taxjar") ){
            return settings.taxjar;
        }
        
        return {};
    }

    private string function _getStatusCodeDescription( required string status_code ) output="false" {		
        
        switch( arguments.status_code ){
            case '400' :
            return 'Bad Request - Your request format is bad.';
            break;
            case '401' :
            return 'Unauthorized - Your API key is wrong.';
            break;
            case '403' :
            return 'Forbidden - The resource requested is not authorized for use.';
            break;
            case '404' :
            return 'Not Found - The specified resource could not be found.';
            break;
            case '405' :
            return 'Method Not Allowed - You tried to access a resource with an invalid method.';
            break;
            case '406' :
            return 'Not Acceptable - Your request is not acceptable.';
            break;
            case '410' :
            return 'Gone - The resource requested has been removed from our servers.';
            break;
            case '422' :
            return 'Unprocessable Entity - Your request could not be processed.';
            break;
            case '429' :
            return 'Too Many Requests - You’re requesting too many resources! Slow down!';
            break;
            case '500' :
            return 'Internal Server Error - We had a problem with our server. Try again later.';
            break;
            case '503' :
            return 'Service Unavailable - We’re temporarily offline for maintenance. Try again later.';
            break;
        }

        return "";
    }

    private boolean function _countryCodeValid( required string country_code ) output="false" {		
        var countries = "US,CA";
        return listFindNoCase( countries , trim( arguments.country_code ) ) ? true : false;
    }
    
}