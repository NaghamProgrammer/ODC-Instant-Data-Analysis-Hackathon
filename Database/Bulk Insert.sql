create database Airbnb

CREATE TABLE AirbnbData (
    ID_Index INT,                  
    RealSum FLOAT,
    RoomType NVARCHAR(50),
    RoomShared BIT,               
    RoomPrivate BIT,
    PersonCapacity FLOAT,
    HostIsSuperhost BIT,
    Multi BIT,
    Biz BIT,
    CleanlinessRating FLOAT,
    GuestSatisfaction FLOAT,
    Bedrooms INT,
    Dist FLOAT,
    MetroDist FLOAT,
    AttrIndex FLOAT,
    AttrIndexNorm FLOAT,
    RestIndex FLOAT,
    RestIndexNorm FLOAT,
    Lng FLOAT,
    Lat FLOAT,
    DayType NVARCHAR(20),
    City NVARCHAR(50),
    Country NVARCHAR(50),
    CostOfLivingIndex FLOAT,
    GroceriesIndex FLOAT,
    RestaurantPriceIndex FLOAT,
    HappinessScore FLOAT,
    Economy FLOAT
);

CREATE TABLE Airbnb_Staging (
    ID_Index INT,
    realSum FLOAT,
    room_type NVARCHAR(50),
    room_shared NVARCHAR(10), 
    room_private NVARCHAR(10), 
    person_capacity FLOAT,
    host_is_superhost NVARCHAR(10), 
    multi NVARCHAR(10), 
    biz NVARCHAR(10), 
    cleanliness_rating FLOAT,
    guest_satisfaction_overall FLOAT,
    bedrooms INT,
    dist FLOAT,
    metro_dist FLOAT,
    attr_index FLOAT,
    attr_index_norm FLOAT,
    rest_index FLOAT,
    rest_index_norm FLOAT,
    lng FLOAT,
    lat FLOAT,
    day_type NVARCHAR(20),
    city NVARCHAR(50),
    country NVARCHAR(50),
    CostOfLivingIndex FLOAT,
    GroceriesIndex FLOAT,
    RestaurantPriceIndex FLOAT,
    happiness_score FLOAT,
    economy FLOAT
);

BULK INSERT Airbnb_Staging
FROM 'C:\Users\Asus\Downloads\final_df2.csv' 
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001'
);

INSERT INTO AirbnbData
SELECT 
    ID_Index, realSum, room_type,
    CASE WHEN room_shared = 'True' THEN 1 ELSE 0 END,
    CASE WHEN room_private = 'True' THEN 1 ELSE 0 END,
    person_capacity,
    CASE WHEN host_is_superhost = 'True' THEN 1 ELSE 0 END,
    CASE WHEN multi = '1' OR multi = 'True' THEN 1 ELSE 0 END,
    CASE WHEN biz = '1' OR biz = 'True' THEN 1 ELSE 0 END,
    cleanliness_rating, guest_satisfaction_overall, bedrooms,
    dist, metro_dist, attr_index, attr_index_norm,
    rest_index, rest_index_norm, lng, lat,
    day_type, city, country, CostOfLivingIndex,
    GroceriesIndex, RestaurantPriceIndex, happiness_score, economy
FROM Airbnb_Staging;

select * from AirbnbData