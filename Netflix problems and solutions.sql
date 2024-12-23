select * from netflix;

-- 1. Count the number of Movies vs TV Shows
select type,count(type) as count from netflix group by type;

-- 2. Find the most common rating for movies and TV shows

with countrating as (
select type,rating,count(*) as count1 from netflix group by type,rating order by 3 desc),
rankedrating as (select type,rating,count1,Rank() over(partition by type order by count1 desc) as rank from countrating)
select type,rating from rankedrating where rank=1;

-- 3. List all movies released in a specific year (e.g., 2020)

select type,release_year from netflix where type='Movie' and release_year=2020;

-- 4. Find the top 5 countries with the most content on Netflix

select unnest(string_to_array(country,',')) as new_country,count(*) as count from netflix 
group by new_country order by count desc limit 5;

-- 5. Identify the longest movie
select type,duration from netflix where type='Movie' and duration=(select max(duration) from netflix);


with tab as
(
select duration,type,split_part(duration,' ',1) as due from netflix)
select type,duration from tab where type='Movie' and due=(select max(due) from tab);

-- 6. Find content added in the last 5 years

select to_date(date_added,'Month DD, YYYY')as da from netflix where to_date(date_added,'Month DD, YYYY')>=current_date - interval '5 years';

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'
with dir as(
select type,unnest(string_to_array(director,',')) as director1 from netflix)

select type,director1 from dir where director1='Rajiv Chilaka';

-- 8. List all TV shows with more than 5 seasons

with season as(
select type,duration,split_part(duration,' ',1)::INT as sea from netflix
)
select type,duration from season where type='TV Show' and sea>5;

-- 9. Count the number of content items in each genre

with genre as
(
select unnest(string_to_array(listed_in,',')) as gen from netflix
)
select gen,count(*) from genre group by gen;

-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !
select extract(year from To_date(date_added,'Month DD, YYYY')) as date,count(*) ,
Round(count(*)::numeric/(select count(*) from netflix where country='India')*100,2) as avg from netflix 
where country='India' group by date order by 1 ;

-- 11. List all movies that are documentaries

SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries'

-- 12. Find all content without a director

SELECT * FROM netflix
WHERE director IS NULL

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
with sk as
(
select casts,release_year from netflix where casts like '%Salman Khan%' and release_year>extract(year from current_date)-10)
select count(*) as skmovies from sk;


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

select unnest(string_to_array(casts,',')) as actors,count(*) from netflix where country like '%India%' group by actors order by 2 desc limit 10;

/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/
with content as
(
select description,case when description ilike '%kill%' or description ilike '%violence' then 'Bad Content' else 'Good Content' end as category
from netflix)
select category,count(*) from content group by category;






