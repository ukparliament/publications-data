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
### API Endpoints

We use the following three Datagraphs API endpoints:

1. Get Access token - https://support.datagraphs.io/api-docs/overview#get-access-token
2. List datasets - https://support.datagraphs.io/api-docs/overview#list-datasets
3. Search for concepts within a Dataset - https://support.datagraphs.io/api-docs/overview#search-for-concepts-within-a-dataset

So for an initial database population we:

1. Ensure we have an access token, get a fresh one if required
2. List and persist all of the datasets available for the project - in this case:
    1. Collections
    2. Contributions
    3. Disclaimers
    4. Organisations
    5. People
    6. PublicationExpressionStatus
    7. Publications
    8. Withdrawls

4. Each dataset lists the concept types associated with the dataset, we then iterate through those to retrieve all of the concept types and persist them

### API Endpoints

We use the following three Datagraphs API endpoints:

1) Get Access token - https://support.datagraphs.io/api-docs/overview#get-access-token
2) List datasets - https://support.datagraphs.io/api-docs/overview#list-datasets
3) Search for concepts within a Dataset - https://support.datagraphs.io/api-docs/overview#search-for-concepts-within-a-dataset

So for an initial database population we:

1) Ensure we have an access token, get a fresh one if required
2) List and persist all of the datasets available for the project - in this case:

    a) Collections
    b) Contributions
    c) Disclaimers
    d) Organisations
    e) People
    f) PublicationExpressionStatus
    g) Publications
    h) Withdrawls

3) Each dataset lists the concept types associated with the dataset, we then iterate through those to retrieve all of the concept types and persist them



### Running the application

Use `bin/dev` to fire up the app and navigate to it at https://localhost:3000


