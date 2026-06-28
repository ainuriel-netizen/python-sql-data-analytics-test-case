create database test_final;

use test_final;

-- 1. Чему равен MAU продукта?
select count(distinct user_id) as MAU
from audience
where month(date) = 11;

-- 2. Используя вкладку "Данные об аудитории", посчитайте, чему будет равен DAU 

select round(count(distinct user_id) / count(distinct date), 0) as DAU
from audience
where month(date) = 11;

-- 3. Используя вкладку "Данные об аудитории", посчитайте, чему будет равен retention первого дня у пользователей, пришедших в продукт 1 ноября 

with FirstNovUsers as (select distinct user_id
from audience
where date = '2023-11-01'),
RetainedFirstNovUsers as (select distinct user_id
from audience
where date = '2023-11-02' and user_id in (select * from FirstNovUsers))

select round((count(user_id) / (select count(user_id) from FirstNovUsers)) * 100, 1) as retained_nov_1_users
from RetainedFirstNovUsers;

/* 5. Во вкладке "Данные об аудитории" есть информация о том, сколько объявлений посмотрел каждый пользователь (view_adverts).
Посчитайте пользовательскую конверсию в просмотр объявления за ноябрь? (в пользователях) */
with ViewedAds as (select user_id
from audience
where view_adverts > 0)

select round((count(distinct user_id) / (select count(distinct user_id) from audience)) * 100, 1) as user_conversion_rate
from ViewedAds;

-- 6. Используя информацию из вкладки "Данные об аудитории", посчитайте среднее количество просмотренных объявлений на пользователя в ноябре
select round(sum(view_adverts) / count(distinct user_id), 1) as avg_views_per_user
from audience;

/* 7. Мы провели опрос среди 2000 пользователей. Из них 500 «критики», 1200 «сторонники» и 300 «нейтралы». Посчитайте, чему будет равен NPS 
* NPS (Net Promoter Score) — это метрика, которая измеряет лояльность пользователей к компании или продукту и делит их на три группы:
Сторонники (Promoters) , Нейтралы (Passives),  Критики (Detractors). NPS высчитывается как (% сторонников - % критиков).*/
select round((1200 / 2000) * 100 - (500 / 2000) * 100, 0) as nps_share;

/* 9. По датасету с листерами посчитайте средний доход на пользователя.
Из-за варианта ответа "Средняя не применима" я дополнительно проверила данные с помощью Python:
теоретически средняя величина была бы не применима, будь в данных аномальные выбросы, однако здесь значения, хоть и неравномерны, но значительных аномалий не видно.*/
with ListersRevenue as (select user_id, sum(revenue) as revenue
from listers
group by user_id)

select avg(revenue)
from ListersRevenue;

-- 10. По датасету с листерами посчитайте медиану возраста пользователя 
with UniqueUsers as (
    select user_id, MAX(age) as age
    from listers
    group by user_id
),
NumberedUsers as (
    select age, 
           row_number() over (order by age) as row_num,
           count(*) over () as total_count
    from UniqueUsers
)
select avg(age) as median_age
from NumberedUsers
where row_num in (floor((total_count + 1) / 2), ceil((total_count + 1) / 2));