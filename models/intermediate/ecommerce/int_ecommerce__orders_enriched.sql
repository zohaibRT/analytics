{{ config(materialized='view') }}

with orders as (

    select * from {{ ref('stg_ecommerce__orders') }}

),

customers as (

    select * from {{ ref('stg_ecommerce__customers') }}

),

marketing_channels as (

    select * from {{ ref('stg_ecommerce__marketing_channels') }}

),

payments_aggregated as (

    select * from {{ ref('int_ecommerce__payments_aggregated') }}

),

refunds_aggregated as (

    select * from {{ ref('int_ecommerce__refunds_aggregated') }}

),

enriched as (

    select
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        orders.order_status,
        orders.channel_id,
        orders.gross_amount,
        orders.discount_amount,
        orders.tax_amount,
        orders.shipping_amount,

        customers.customer_full_name,
        customers.email as customer_email,
        customers.country as customer_country,
        customers.city as customer_city,
        customers.customer_segment,

        marketing_channels.channel_name,

        coalesce(payments_aggregated.total_payment_amount, 0) as total_payment_amount,
        coalesce(payments_aggregated.successful_payment_amount, 0) as successful_payment_amount,
        coalesce(payments_aggregated.refunded_payment_amount, 0) as refunded_payment_amount,
        coalesce(payments_aggregated.payment_count, 0) as payment_count,
        payments_aggregated.first_payment_date,
        payments_aggregated.last_payment_date,
        payments_aggregated.payment_methods_used,
        coalesce(payments_aggregated.has_paid_payment, false) as has_paid_payment,
        coalesce(payments_aggregated.has_refunded_payment, false) as has_refunded_payment,

        coalesce(refunds_aggregated.total_refund_amount, 0) as total_refund_amount,
        coalesce(refunds_aggregated.refund_count, 0) as refund_count,
        refunds_aggregated.first_refund_date,
        refunds_aggregated.last_refund_date,

        orders.gross_amount - orders.discount_amount as order_subtotal_amount,
        orders.gross_amount - orders.discount_amount + orders.tax_amount + orders.shipping_amount
            as calculated_order_total_amount,
        orders.gross_amount - orders.discount_amount + orders.tax_amount + orders.shipping_amount
            - coalesce(refunds_aggregated.total_refund_amount, 0) as net_order_amount,

        orders.order_status = 'cancelled' as is_cancelled_order,
        orders.order_status = 'refunded' as is_refunded_order,
        orders.order_status = 'completed' as is_completed_order,
        orders.order_status in ('completed', 'refunded') as is_commercial_order

    from orders
    inner join customers
        on orders.customer_id = customers.customer_id
    left join marketing_channels
        on orders.channel_id = marketing_channels.channel_id
    left join payments_aggregated
        on orders.order_id = payments_aggregated.order_id
    left join refunds_aggregated
        on orders.order_id = refunds_aggregated.order_id

)

select * from enriched
