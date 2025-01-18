/************************************************************
Title: SCRIPT 2 - AI DEMO SETUP
Desc: SETUP SEATTLE AIRBNB DATA SET
Date: 8/26/2024
************************************************************/
-- SHOW server_version;

-- Check installed extensions
SHOW azure.extensions;
--or
SELECT * FROM pg_available_extensions
WHERE name IN ('azure_ai','vector', 'pg_diskann');


-- Create the extensions in the pgai database
CREATE EXTENSION vector;
CREATE EXTENSION pg_diskann;
CREATE EXTENSION azure_ai;

-- Setup Azure OpenAI endpoint
select azure_ai.set_setting('azure_openai.endpoint', '');
select azure_ai.set_setting('azure_openai.subscription_key', '');

-- Add vector - should take about 5 mins if Azure openAI and Flex are in same region
ALTER TABLE listings
ADD COLUMN description_vector vector(1536) --OPEN AI embeddings are 1536 dimensions
GENERATED ALWAYS AS (
	azure_openai.create_embeddings (
	'text-embedding-3-small', -- example deployment name in Azure OpenAI which CONTAINS text-embedding-ADA-003-small-model
	name || description || summary,
	max_attempts => 5, retry_delay_ms => 500)::vector) STORED; -- TEXT strings concatenated AND sent TO Azure OpenAI

-- Create the diskann index and table
CREATE TABLE listings_hnsw AS TABLE listings;
CREATE INDEX listing_cosine_hnsw ON listings_hnsw USING hnsw (description_vector vector_cosine_ops);

-- Create the diskann index and table
CREATE TABLE listings_diskann AS TABLE listings;
CREATE INDEX listing_cosine_diskann ON listings_diskann USING diskann (description_vector vector_cosine_ops);