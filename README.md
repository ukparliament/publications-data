# Publications Data Explorer

This is a rails app which is going to talk to the Datagraphs API. 

Currently very much at proof of concept level, including getting the API authentication to work and download the available datasets.

## Generic explorer

As is, by providing the following environment variables in a `.env` file, the application can connect to a Datagraphs instance and be set up to download and locally cache the data, providing a browsable front end for it.

The environment variables are as follows:

```
DATAGRAPHS_API_KEY=<Get this from your Datagraphs project settings>
DATAGRAPHS_CLIENT_SECRET=<Get this from your Datagraphs project settings>
DATAGRAPHS_CLIENT_ID=<Get this from your Datagraphs project settings>
PROJECT_ID=<This is the project ID in datagraphs, what you get in the URL, i.e. publications-data or subject-specialist-finder>
SITE_TITLE=<This is the site title, i.e. Publications data explorer>
```

Once you have these set up you can locally cache the data with a rake task.

### Initial setup

Do the usual for a rails app, install the relevant ruby, then run ```bundle install```, followed by ```db:setup```. Now you should be able to load the data.

### Local data load

First load the datasets for the project (Note, this deletes existing ones and then refreshes via the API)

```
rake load:datasets
```

Then, once the datasets have been imported, you can import all the concepts

```
rake load:concepts
```

### Running the application

Use `bin/dev` to fire up the app and navigate to it at https://localhost:3000


