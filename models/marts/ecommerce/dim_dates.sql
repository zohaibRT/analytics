{{ config(materialized='view') }}

with all_dates as (

    select order_date::date as date_day
    from {{ ref('int_ecommerce__orders_enriched') }}

    union all

    select payment_date::date as date_day
    from {{ ref('stg_ecommerce__payments') }}

    union all

    select refund_date::date as date_day
    from {{ ref('stg_ecommerce__refunds') }}

    union all

    select signup_date::date as date_day
    from {{ ref('stg_ecommerce__customers') }}

),

date_bounds as (

    select
        min(date_day) as min_date,
        max(date_day) as max_date

    from all_dates

),

date_spine as (

    select
        generate_series(
            (select min_date from date_bounds),
            (select max_date from date_bounds),
            interval '1 day'
        )::date as date_day

),

final as (

    select
        date_day,
        extract(year from date_day)::int as year,
        extract(quarter from date_day)::int as quarter,
        extract(month from date_day)::int as month,
        trim(to_char(date_day, 'Month')) as month_name,
        extract(week from date_day)::int as week,
        extract(day from date_day)::int as day_of_month,
        extract(dow from date_day)::int as day_of_week,
        extract(dow from date_day) in (0, 6) as is_weekend

    from date_spine

)

select * from final
