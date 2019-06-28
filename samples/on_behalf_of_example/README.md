# Authenticating On Behalf of a User

This sample consists of two applications that each use ADAL.

The native application uses a username and password flow to obtain an access
token and then uses that access token to access a resource: the web api.

The web api takes the access token and exchanges it for an access token for
the graph.windows.net resource and uses it to retrieve graph data, which it
then sends back to the native app.

Before running these applications, follow the instructions below to configure
them to your tenant.


## Configuring the Native Application
1. In the Azure portal, register a new Web Application. Take note of the client
   id and client secret. The application identifier can be anything, but take
   note of what you choose for a future step.
2. Give this application permission to use the web application that you create
   in the next step. (You can't do this step until you've configured the Web
   Application.)
3. In `web_api.rb`, fill in the tenant, client id and client secret fields.

## Configuring the Web Application
1. In the Azure portal, register a new Native Application. Take note of the
   client id.
2. Give this application permission to `Read directory data.`.
3. In `native_app.rb`, fill in the tenant and client id field. Fiell in the
   `WEB_API_RESOURCE` field with the application identifier that you used
   previously.

## Running the application
1. Start the web application with `ruby web_api.rb`.
2. Run the native application with `ruby native_app.rb`.
