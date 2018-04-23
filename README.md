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
        "authorization" = "",
        "url" 			= "https://api.taxjar.com/v2/"
    }
};
```