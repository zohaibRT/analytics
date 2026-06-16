{{ config(materialized='view') }}

with refunds as (

    select * from {{ ref('stg_ecommerce__refunds') }}

),

aggregated as (

    select
        order_id,
        sum(refund_amount) as total_refund_amount,
        count(*) as refund_count,
        min(refund_date) as first_refund_date,
        max(refund_date) as last_refund_date

    from refunds
    group by order_id

)

select * from aggregated
