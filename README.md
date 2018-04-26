# Taxjar
A CFML wrapper for the Taxjar API. Sales Tax for Developers

Taxjar API reference can be found here: <https://developers.taxjar.com/api/reference/>.

## LICENSE

Apache License, Version 2.0.

## IMPORTANT LINKS

*   https://developers.taxjar.com/api/reference/
*   https://www.taxjar.com/

## SYSTEM REQUIREMENTS

*   Lucee 4.5+
*   Adobe ColdFusion 10+

## Setup

Configure your Taxjar credentials in the `ModuleConfig.cfc` file.

```
settings = {
    taxjar = {
        "authorization" = "Bearer 9e0cd62a22f451701f29c3bde214",
        "url" 			= "https://api.taxjar.com/v2/"
    }
};
```
You must replace 9e0cd62a22f451701f29c3bde214 with your personal API key. 

## Methods
* categories  - Lists all tax categories.
* rates - Shows the sales tax rates for a given location.
* taxes - Calculate sales tax for an order
* orders - List order transactions or Show an order transaction created through the API
* createOrder - Create an order transaction
* updateOrder - Update an order transaction
* deleteOrder - Delete an order transaction
* refunds - List refund transactions
* createRefund - Create a refund transaction
* updateRefund - Update a refund transaction
* deleteRefund -  Delete a refund transaction
* nexus - List nexus regions
* validateVAT - Validate a VAT number
* summarizedRates - Summarize tax rates for all regions