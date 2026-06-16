{{ config(materialized='view') }}

with orders_enriched as (

    select * from {{ ref('int_ecommerce__orders_enriched') }}

),

final as (

    select
        order_id,
        customer_id,
        coalesce(channel_id, -1) as channel_id,
        order_date,
        order_status,
        gross_amount,
        discount_amount,
        tax_amount,
        shipping_amount,
        order_subtotal_amount,
        calculated_order_total_amount,
        total_payment_amount,
        successful_payment_amount,
        total_refund_amount,
        net_order_amount,
        payment_count,
        refund_count,
        is_cancelled_order,
        is_refunded_order,
        is_completed_order,
        is_commercial_order

    from orders_enriched

)

select * from final
