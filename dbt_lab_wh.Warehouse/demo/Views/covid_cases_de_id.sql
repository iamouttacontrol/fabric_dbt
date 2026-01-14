-- Auto Generated (Do not modify) EEA7FF228BE381A0F623BCF12B6D1A190ADACC9176054BD43C96E4074E113839
create view "demo"."covid_cases_de_id" as 

with base as (
  select country, [date], total_cases
  from "dbt_lab_wh"."demo"."covid_cases"
  where lower(country) in ('germany','indonesia')
),
ranked as (
  select
    country, [date], total_cases,
    row_number() over (
      partition by country
      order by case when total_cases is null then 1 else 0 end, [date] desc
    ) as rn
  from base
)
select
  country,
  total_cases as total_cases_latest,
  [date]     as last_date_with_value
from ranked
where rn = 1;;