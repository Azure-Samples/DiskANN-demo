# DiskANN Vector Index in Azure Database for PostgreSQL
[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure-Samples%2FDiskANN-demo%2Frefs%2Fheads%2Fmain%2Fsetup%2Fpostgres-infra%2Ftemplate.json%3F)

We're thrilled to announce DiskANN, a leading vector indexing algorithm, on Azure Database for PostgreSQL - Flexible Server! Developed by [Microsoft Research](https://www.microsoft.com/en-us/research/project/project-akupara-approximate-nearest-neighbor-search-for-large-scale-semantic-search/) and used extensively at Microsoft in global services such as Bing and Microsoft 365, DiskANN enables developers to build highly accurate, performant and scalable Generative AI applications surpassing pgvector’s HNSW and IVFFlat in both latency and accuracy. DiskANN also overcomes a long-standing limitation of pgvector in filtered vector search, where it occasionally [returns incorrect results](https://github.com/pgvector/pgvector/tree/103ac50f1a90b47a72003e8e8628a55ec372f202?tab=readme-ov-file#why-are-there-less-results-for-a-query-after-adding-an-hnsw-index).

https://github.com/user-attachments/assets/6866effa-2bc5-44e0-aaee-d824241a8d0e

[Sample Website](https://diskann-demo-dwgxbdfpgrakcmgf.westus2-01.azurewebsites.net/). This sample application show a sample AirBNB dataset search page:
* It illustrate the **improved recall** of using DiskANN vs using HNSW. 
* When a filter is apply you will notice `HNSW index` **doesn't return** the same amount of results as `DiskANN` or `No Index`.

# Table of Content
* [Documentation](#documentation)
* [Getting started](#getting-started)
    * [Enable `pg_diskann` extension](#enable-pg_diskann-extension)
    * [Setup Seattle AirBnb Data](#setup-seattle-airbnb-data-and-test-diskann)
    *  [Build Sample Application Locally](#build-sample-application-locally)
* [Explore Indexes with Python Notebook](#explore-indexes-with-python-notebook)

# Documentation
Read more on how to use DiskANN in the Microsoft Docs: [Docs](https://aka.ms/pg-diskann-docs)

Check out the blog: [Blog](https://aka.ms/pg-diskann-blog)

# Getting started

First step will be to setup the data on the new Postgres Database you just created.

Make sure the following tools are installed:

* [Python 3.10+](https://www.python.org/downloads/)
* [PostgreSQL 16+ and PSQL](https://www.postgresql.org/download/)
* [Git](https://git-scm.com/downloads)

## Enable `pg_diskann` extension

Follow Microsoft documentation for [enabling DiskANN](https://review.learn.microsoft.com/en-us/azure/postgresql/flexible-server/how-to-use-pgdiskann?branch=pr-en-us-388#enable-pg_diskann-extension)

## Setup Seattle AirBnb Data and test DiskANN
This demo app will show you how DiskANN Index works better that HNSW.

### 0. Set up Git Repo and Update your .env file

1. In a Shell prompt, enter the following to clone the GitHub repo containing exercise resources:

    ```
        git clone https://github.com/Azure-Samples/DiskANN-demo.git
    ```

    Enter the repo directory

    ```
    cd DiskANN-demo
    ```

2. Update your .env with the following:

    ```bash
    AZURE_OPENAI_API_KEY ="***sample***key****"
    AZURE_OPENAI_ENDPOINT="https://sample.openai.azure.com/"
    AZURE_PG_CONNECTION="dbname={DB_NAME} host={HOST} port=5432 sslmode=require user={USER_NAME} password={PASSWORD}"
    ```

### 1. Set up Data

Connect to the database and run commands in the file `setup/sql-scripts/1_PGAI-Demo_setup.sql` in `psql` or your favorite Postgres Editor

> **NOTE:** This command has to be run from the root directory of the repo. In order to correctly locate the `setup/sql-scripts/1_PGAI-Demo_setup.sql` file.

**If running from `psql`:**
```sql
\i setup/sql-scripts/1_PGAI-Demo_setup.sql
```

### 2. Set up OpenAI endpoint, embed data and create indexes

Run commands in the file `setup/sql-scripts/2_PGAI-Demo_endpoint_and_embedding_config.sql` in `psql` or your favorite Postgres Editor

> **NOTE:** You will need to update **Line 21-22**, with out OpenAI credentials. 
```sql
select azure_ai.set_setting('azure_openai.endpoint', '');
select azure_ai.set_setting('azure_openai.subscription_key', '');
```

**If running from `psql`:**
```sql
\i setup/sql-scripts/2_PGAI-Demo_endpoint_and_embedding_config.sql
```
> **TIP:** This will take around 2-5 minutes to run.

### 3. Test out sample vector queries

Run commands in the file `setup/sql-scripts/3_PGAI-Demo_pgai_queries.sql` in `psql` or your favorite Postgres Editor

**If running from `psql`:**
```sql
\i setup/sql-scripts/3_PGAI-Demo_pgai_queries.sql
```

## Build Sample Application Locally

### Setting up the environment file

Since the local app uses OpenAI models, you should first deploy it for the optimal experience.

1. Copy `.env.sample` into a `.env` file.
2. To use Azure OpenAI, fill in the values of `AZURE_OPENAI_ENDPOINT` and `AZURE_OPENAI_API_KEY` based on the deployed values.
3. Fill in the connection string value for `AZURE_PG_CONNECTION`, You can find this in the [Azure Portal](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/connect-python?tabs=bash%2Cpassword#add-authentication-code)

### Install dependencies
Install required Python packages and streamlit application:

```python
python3 -m venv .diskann
source .diskann/bin/activate
```

```bash
pip install -r requirements.txt
```

### Running the application
From root directory

```bash
cd src/app
streamlit run app.py
```

When run locally run looking for website at http://localhost:8501/


# Explore Indexes with Python Notebook

Explore [Python Notebook](src/notebook/Recall_experiement_for_Indices.ipynb)
