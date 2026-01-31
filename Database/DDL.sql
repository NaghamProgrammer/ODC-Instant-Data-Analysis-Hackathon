-- =========================
-- COUNTRY
-- =========================
CREATE TABLE Country (
    country_id INT IDENTITY(1,1) PRIMARY KEY,
    country_name NVARCHAR(100) NOT NULL UNIQUE,
    cost_of_living_index FLOAT,
    groceries_index FLOAT,
    restaurant_price_index FLOAT,
    happiness_score FLOAT,
    economy FLOAT
);

-- =========================
-- CITY
-- =========================
CREATE TABLE City (
    city_id INT IDENTITY(1,1) PRIMARY KEY,
    city_name NVARCHAR(100) NOT NULL,
    country_id INT NOT NULL,
    CONSTRAINT FK_City_Country
        FOREIGN KEY (country_id) REFERENCES Country(country_id)
);

-- =========================
-- HOST
-- =========================
CREATE TABLE Host (
    host_id INT IDENTITY(1,1) PRIMARY KEY,
    host_is_superhost BIT,
    multi BIT
);

-- =========================
-- LISTING
-- =========================
CREATE TABLE Listing (
    listing_id INT IDENTITY(1,1) PRIMARY KEY,
    realSum FLOAT,
    room_type NVARCHAR(50),
    room_shared BIT,
    room_private BIT,
    person_capacity INT,
    biz BIT,
    cleanliness_rating FLOAT,
    guest_satisfaction_overall FLOAT,
    bedrooms INT,
    dist FLOAT,
    metro_dist FLOAT,
    attr_index FLOAT,
    attr_index_norm FLOAT,
    rest_index FLOAT,
    rest_index_norm FLOAT,
    lat FLOAT,
    lng FLOAT,
    day_type NVARCHAR(20),
    city_id INT NOT NULL,
    host_id INT NOT NULL,
    CONSTRAINT FK_Listing_City
        FOREIGN KEY (city_id) REFERENCES City(city_id),
    CONSTRAINT FK_Listing_Host
        FOREIGN KEY (host_id) REFERENCES Host(host_id)
);



INSERT INTO Country (
    country_name,
    cost_of_living_index,
    groceries_index,
    restaurant_price_index,
    happiness_score,
    economy
)
SELECT DISTINCT
    [Country],
    [CostOfLivingIndex],
    [GroceriesIndex],
    [RestaurantPriceIndex],
    [HappinessScore],
    [Economy]
FROM [dbo].[AirbnbData];


INSERT INTO Host (host_is_superhost, multi)
SELECT DISTINCT
    [HostIsSuperhost],
    [Multi]
FROM [dbo].[AirbnbData];

INSERT INTO City (city_name, country_id)
SELECT DISTINCT
    a.City,
    c.country_id
FROM [dbo].[AirbnbData] a
JOIN Country c
    ON c.country_name = a.Country;


INSERT INTO Listing (
    realSum,
    room_type,
    room_shared,
    room_private,
    person_capacity,
    biz,
    cleanliness_rating,
    guest_satisfaction_overall,
    bedrooms,
    dist,
    metro_dist,
    attr_index,
    attr_index_norm,
    rest_index,
    rest_index_norm,
    lat,
    lng,
    day_type,
    city_id,
    host_id
)
SELECT
    r.[RealSum],
    r.[RoomType],
    r.[RoomShared],
    r.[RoomPrivate],
    CAST(r.[PersonCapacity] AS INT),
    r.[Biz],
    r.[CleanlinessRating],
    r.[GuestSatisfaction],
    r.[Bedrooms],
    r.[Dist],
    r.[MetroDist],
    r.[AttrIndex],
    r.[AttrIndexNorm],
    r.[RestIndex],
    r.[RestIndexNorm],
    r.[Lat],
    r.[Lng],
    r.[DayType],
    ci.city_id,
    h.host_id
FROM [dbo].[AirbnbData] r
JOIN City ci
    ON ci.city_name = r.[City]
JOIN Country co
    ON co.country_name = r.[Country]
JOIN Host h
    ON h.host_is_superhost = r.[HostIsSuperhost]
   AND h.multi = r.Multi;


select * ,
	row_number() over (partition by city_id order by realSum desc) as track_rank
	from Listing