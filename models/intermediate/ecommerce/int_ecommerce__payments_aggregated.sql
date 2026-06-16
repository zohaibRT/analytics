{{ config(materialized='view') }}

with payments as (

    select * from {{ ref('stg_ecommerce__payments') }}

),

aggregated as (

    select
        order_id,
        sum(amount) as total_payment_amount,
        sum(case when payment_status = 'paid' then amount else 0 end) as successful_payment_amount,
        sum(case when payment_status = 'refunded' then amount else 0 end) as refunded_payment_amount,
        count(*) as payment_count,
        min(payment_date) as first_payment_date,
        max(payment_date) as last_payment_date,
        string_agg(distinct payment_method, ', ' order by payment_method) as payment_methods_used,
        bool_or(payment_status = 'paid') as has_paid_payment,
        bool_or(payment_status = 'refunded') as has_refunded_payment

    from payments
    group by order_id

)

select * from aggregated
