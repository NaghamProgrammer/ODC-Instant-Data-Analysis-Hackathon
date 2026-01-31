
-- does the price change between super hosts and Non-super hosts?
SELECT 
    h.host_is_superhost,
    AVG(l.realSum) AS avg_price,
    COUNT(*) AS listings_count
FROM Listing l
JOIN Host h ON l.host_id = h.host_id
GROUP BY h.host_is_superhost;


-- does the price change between professional hosts and unprofessional hosts?
SELECT 
    h.multi,
    AVG(l.realSum) AS avg_price,
    COUNT(*) AS listings
FROM Listing l
JOIN Host h ON l.host_id = h.host_id
GROUP BY h.multi;


--does the person capacity affect the price?
SELECT
    person_capacity,
    AVG(realSum / NULLIF(person_capacity, 0)) AS avg_price_per_person
FROM Listing
GROUP BY person_capacity
ORDER BY person_capacity;


--does the nearest to the city center affect the price?
SELECT
    CASE 
        WHEN dist < 1 THEN '< 1 km'
        WHEN dist BETWEEN 1 AND 3 THEN '1–3 km'
        WHEN dist BETWEEN 3 AND 5 THEN '3–5 km'
        ELSE '> 5 km'
    END AS distance_band,
    AVG(realSum) AS avg_price
FROM Listing
GROUP BY 
    CASE 
        WHEN dist < 1 THEN '< 1 km'
        WHEN dist BETWEEN 1 AND 3 THEN '1–3 km'
        WHEN dist BETWEEN 3 AND 5 THEN '3–5 km'
        ELSE '> 5 km'
    END
ORDER BY avg_price DESC;


-- does the cleanliness affect the guest satisfication ?
SELECT
    cleanliness_rating,
    AVG(guest_satisfaction_overall) AS avg_satisfaction
FROM Listing
GROUP BY cleanliness_rating
ORDER BY cleanliness_rating;


--does the high price gurnatee the high guest satisfication ?
SELECT
    CASE 
        WHEN realSum < 200 THEN 'Low Price'
        WHEN realSum BETWEEN 200 AND 400 THEN 'Mid Price'
        ELSE 'High Price'
    END AS price_segment,
    AVG(guest_satisfaction_overall) AS avg_satisfaction
FROM Listing
GROUP BY 
    CASE 
        WHEN realSum < 200 THEN 'Low Price'
        WHEN realSum BETWEEN 200 AND 400 THEN 'Mid Price'
        ELSE 'High Price'
    END;

--does the day type effects the price? demonstrate by the Avg price and # of reservations
SELECT
    day_type,
    AVG(realSum) AS avg_price,
    COUNT(*) AS listings
FROM Listing
GROUP BY day_type;


-- does the happiness score meet the guest satisfaction?
SELECT
    co.country_name,
    co.happiness_score,
    AVG(l.guest_satisfaction_overall) AS avg_guest_satisfaction
FROM Listing l
JOIN City c ON l.city_id = c.city_id
JOIN Country co ON c.country_id = co.country_id
GROUP BY co.country_name, co.happiness_score
ORDER BY co.happiness_score DESC;

--------------------------------------------------------------------------------------

--window by rank
select l.city_id, c.city_name, co.country_name, realSum, day_type,
	row_number() over (partition by l.city_id order by realSum desc) as rank_
	from Listing l join City c on l.city_id = c.city_id
	join Country co on c.country_id = co.country_id

-- view for each country what is the avg price and satisfication
CREATE VIEW vw_Country_Price_Satisfaction AS
SELECT
    co.country_name,
    AVG(l.realSum) AS avg_price,
    AVG(l.guest_satisfaction_overall) AS avg_satisfaction,
    COUNT(*) AS total_listings
FROM Listing l
JOIN City c ON l.city_id = c.city_id
JOIN Country co ON c.country_id = co.country_id
GROUP BY co.country_name;


SELECT *
FROM vw_Country_Price_Satisfaction
ORDER BY avg_price DESC;


-- view to show the top 10 country in price in weekday or weekend
CREATE VIEW vw_Top_Countries_Weekday_Weekend AS
SELECT
    co.country_name,
    l.day_type,
    AVG(l.realSum) AS avg_price,
    COUNT(*) AS total_listings
FROM Listing l
JOIN City c ON l.city_id = c.city_id
JOIN Country co ON c.country_id = co.country_id
GROUP BY co.country_name, l.day_type;

SELECT *
FROM vw_Top_Countries_Weekday_Weekend
WHERE day_type = 'Weekend'
ORDER BY avg_price DESC;

SELECT *
FROM vw_Top_Countries_Weekday_Weekend
WHERE day_type = 'Weekday'
ORDER BY avg_price DESC;

--Cte for each city what is the price and guest satisfaction and # of reservations
WITH CityStats AS (
    SELECT
        c.city_name,
        AVG(l.realSum) AS avg_price,
        AVG(l.guest_satisfaction_overall) AS avg_satisfaction,
        COUNT(*) AS listings_count
    FROM Listing l
    JOIN City c ON l.city_id = c.city_id
    GROUP BY c.city_name
)
SELECT
    city_name,
    avg_price,
    avg_satisfaction,
    listings_count
FROM CityStats
WHERE avg_satisfaction >= 85
ORDER BY avg_price DESC;

--Cte for the best 2 countries in guest satisfaction
WITH CountrySatisfaction AS (
    SELECT
        co.country_name,
        AVG(l.guest_satisfaction_overall) AS avg_satisfaction
    FROM Listing l
    JOIN City c ON l.city_id = c.city_id
    JOIN Country co ON c.country_id = co.country_id
    GROUP BY co.country_name
)
SELECT TOP 2
    country_name,
    avg_satisfaction
FROM CountrySatisfaction
ORDER BY avg_satisfaction DESC;


-- does the distance from metro affect the price?
WITH AvgMetro AS (
    SELECT AVG(metro_dist) AS avg_metro_dist
    FROM Listing
),
MetroGroups AS (
    SELECT
        CASE 
            WHEN l.metro_dist < a.avg_metro_dist 
                THEN 'Near Metro'
            ELSE 'Far from Metro'
        END AS metro_group,
        l.realSum
    FROM Listing l
    CROSS JOIN AvgMetro a
)
SELECT
    metro_group,
    AVG(realSum) AS avg_price
FROM MetroGroups
GROUP BY metro_group;

