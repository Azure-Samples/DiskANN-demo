/************************************************************
Title: SCRIPT 3 - AI DEMO -VECTOR SIMILARITY SEARC
Desc: SETUP SEATTLE AIRBNB DATA SET
Date: 8/26/2024
************************************************************/
-- SHOW server_version;

-- Listings table
SELECT listing_id, name, city, summary, description, bedrooms, bathrooms
FROM listings LIMIT 5;

-- Show a vector
SELECT name, description_vector FROM listings
LIMIT 1;

-- And search with vector column
SELECT listing_id, name, description
FROM listings
ORDER BY description_vector <=> azure_openai.create_embeddings('text-embedding-3-small', 'homes near pacific science center that allows pets and parking')::vector
LIMIT 5;

-- Fulltext + Semantic search
SELECT listing_id, name, description
FROM listings
-- fulltext search
WHERE textsearch @@ phraseto_tsquery('Capitol Hill')
ORDER BY description_vector <=> azure_openai.create_embeddings('text-embedding-3-small', 'homes near pacific science center that allows pets and parking')::vector
LIMIT 5;

-- Fulltext + Semantic search with Index
SET LOCAL enable_seqscan TO OFF; -- force index usage
SELECT listing_id, name, description
FROM listings_diskann
-- fulltext search
WHERE textsearch @@ phraseto_tsquery('Capitol Hill')
ORDER BY description_vector <=> azure_openai.create_embeddings('text-embedding-3-small', 'homes near pacific science center that allows pets and parking')::vector
LIMIT 5;

-- Find a property with a private room near Discovery Park, analyze the sentiment of the reviews for these properties

WITH listings_cte AS (
    SELECT l.listing_id, name, listing_location, summary FROM listings l
    INNER JOIN calendar c ON l.listing_id = c.listing_id
    WHERE ST_DWithin(
        listing_location,
        ST_GeomFromText('POINT(-122.410347 47.655598)', 4326),
        0.025
    )
    AND c.date = '2016-01-13'
    AND c.available = 't'
    AND c.price <= 75.00
    AND l.listing_id IN (SELECT listing_id FROM reviews)
    ORDER BY description_vector <=> azure_openai.create_embeddings('text-embedding-3-small', 'Properties with a private room near Discovery Park')::vector
    LIMIT 3
),
sentiment_cte AS (
    SELECT r.listing_id, comments, azure_cognitive.analyze_sentiment(comments, 'en') AS sentiment
    FROM reviews r
    INNER JOIN listings_cte l ON r.listing_id = l.listing_id
)
SELECT
    l.listing_id,
    name,
    listing_location,
    summary,
    avg((sentiment).positive_score) as avg_positive_score,
    avg((sentiment).neutral_score) as avg_neutral_score,
    avg((sentiment).negative_score) as avg_negative_score
FROM sentiment_cte s
INNER JOIN listings_cte l on s.listing_id = l.listing_id
GROUP BY l.listing_id, name, listing_location, summary;