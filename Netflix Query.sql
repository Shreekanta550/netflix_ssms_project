--Netflix Project -- 15 business problems

select * from netflixs;

-- 1. Count the number of Movies vs Tv shows
use netflix
Select type,count(*) as Total_content 
from netflixs
group by type;

-- 2. Find the most common rating for movies and Tv shows
use netflix
WITH ranked_data AS
(
    SELECT
        type,	
        rating,
        COUNT(*) AS total_count,
        RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
    FROM netflixs
    GROUP BY type, rating
)
SELECT 
    type, 
    rating
FROM ranked_data
WHERE ranking = 1;


-- 3. List all the movies released in a specific year (e.g., 2020)

Use netflix
Select * from netflixs
where type = 'Movie' and release_year = 2020;

-- 4. Find the top 5 countries with the most content on netflix

SELECT value AS new_country, COUNT(show_id) AS total_content
FROM netflixs
CROSS APPLY STRING_SPLIT(country, ',')
GROUP BY value
ORDER BY total_content DESC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;

-- 5. Identify the longest movie?

select * from netflixs
where type = 'Movie' and duration = (select max(duration) from netflixs);

-- 6. Find content added in the last 5 years

SELECT * 
FROM netflixs
WHERE CAST(date_added AS DATE) >= DATEADD(YEAR, -5, GETDATE());

-- 7. Find all the Movies/Tv shows by director 'rajiv chilaka'

select * from netflixs
where director like '%Rajiv Chilaka%';

-- 8. List all Tv show with more than 5 seasons

SELECT * 
FROM netflixs
WHERE type = 'Tv show'
AND CAST(SUBSTRING(duration, 1, CHARINDEX(' ', duration) - 1) AS INT) > 5;

--9. Count the number of content items in each genre

SELECT value AS genre, 
       COUNT(show_id) AS total_content
FROM netflixs
CROSS APPLY STRING_SPLIT(listed_in, ',')
GROUP BY value;

-- 10. Find the each year and the average number of content release in India on netflix, 
--return top 5 year with highest avg content release:
use netflix
SELECT 
    YEAR(CONVERT(DATE, date_added, 101)) AS year, 
    COUNT(*) AS yearly_content,
    ROUND(CAST(COUNT(*) AS FLOAT) / (SELECT CAST(COUNT(*) AS FLOAT) 
                                     FROM netflixs 
                                     WHERE country = 'India') * 100, 2) AS avg_content_per_year
FROM netflixs
WHERE country = 'India'
GROUP BY YEAR(CONVERT(DATE, date_added, 101));

-- 11. List all movies that are documentaries

select * from netflixs
where listed_in like '%Documentaries%';

--12. Find all content without a director

select * from netflixs
where director is null;

--13. find how many movies actor 'salman khan' appeared in last 10 years!

SELECT * 
FROM netflixs
WHERE cast LIKE '%salman khan%' 
AND release_year > YEAR(GETDATE()) - 10;

--14. Find the top 10 actors who have appeared in the highest number of movies produced in india.

SELECT value AS actors, 
       COUNT(*) AS total_content
FROM netflixs
CROSS APPLY STRING_SPLIT(cast, ',')
WHERE country LIKE '%india%'
GROUP BY value
ORDER BY total_content DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. 
--label content containing these keywords as 'bad' and all other content as 'good'. count how many items fall into each
--category.
WITH new_table AS (
    SELECT *,
           CASE 
               WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'bad_content'
               ELSE 'good_content'
           END AS category
    FROM netflixs
)
SELECT category, COUNT(*) AS total_content
FROM new_table
GROUP BY category;






