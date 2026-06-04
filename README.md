# Publications Data Explorer

This is a rails app which is going to talk to the Datagraphs API.

It requires a database to store the token used for getting the Datagraphs OAuth token.

## The following environment variables need to be set

The environment variables are as follows:

```
DATAGRAPHS_API_KEY=<Get this from your Datagraphs project settings>
DATAGRAPHS_CLIENT_SECRET=<Get this from your Datagraphs project settings>
DATAGRAPHS_CLIENT_ID=<Get this from your Datagraphs project settings>
DATAGRAPHS_PROJECT_ID=<This is the project ID in datagraphs, what you get in the URL, i.e. publications-data or subject-specialist-finder>
SITE_TITLE=<This is the site title, i.e. Publications data explorer>
```

### Initial setup

Do the usual for a rails app, install the relevant ruby, then run `bundle install`, followed by `db:setup`. Now you should be able to load the data.

### API Endpoints

We use the following two Datagraphs API endpoints:

1. [Get Access token](https://support.datagraphs.io/api-docs/overview#get-access-token)
2. [Graph Search (using Cypher)](https://support.datagraphs.io/api-docs/overview#graph-search-with-cypher)

### Running the application

Use `bin/dev` to fire up the app and navigate to it at https://localhost:3000

## Notes on SAML Set up

### Set up on ShedCode Azure

1. Log in to Azure and go to [Entra page](https://portal.azure.com/#view/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/~/Overview)
2. Open Manage menu on left and find [Enterprise applications](https://portal.azure.com/#view/Microsoft_AAD_IAM/StartboardApplicationsMenuBlade/~/AppAppsPreview/menuId~/null)
3. Select "Local SAML SSO test app" this is already set up for local dev
4. If creating a new app for running on local host, you can set the following:

Basic SAML Configuration

Identifier (Entity ID) http://localhost:3000/saml/metadata
Reply URL (Assertion Consumer Service URL) http://localhost:3000/saml/callback

5. Either way get the following environment variables and set them

ENTRA_APP_FEDERATION_METADATA_URL=<You can get this from the app single sign on settings in Azure - the field is called "App Federation Metadata Url">
ENTRA_APP_LOGIN_CALLBACK_URL=http://localhost:3000/saml/callback
ENTRA_APP_ENTITY_ID=http://localhost:3000/saml/metadata
