{{ config(materialized='view') }}

with customers as (

    select * from {{ ref('stg_ecommerce__customers') }}

),

orders_enriched as (

    select * from {{ ref('int_ecommerce__orders_enriched') }}

),

order_metrics as (

    select
        customer_id,
        min(order_date) as first_order_date,
        max(order_date) as last_order_date,
        count(*) as total_orders,
        count(*) filter (where is_commercial_order) as commercial_orders,
        count(*) filter (where is_completed_order) as completed_orders,
        count(*) filter (where is_refunded_order) as refunded_orders,
        count(*) filter (where is_cancelled_order) as cancelled_orders,
        sum(calculated_order_total_amount) as lifetime_gross_amount,
        sum(net_order_amount) as lifetime_net_amount,
        sum(total_refund_amount) as lifetime_refund_amount

    from orders_enriched
    group by customer_id

),

customer_order_metrics as (

    select
        customers.customer_id,
        customers.customer_full_name,
        customers.email,
        customers.country,
        customers.city,
        customers.signup_date,
        customers.customer_segment,

        order_metrics.first_order_date,
        order_metrics.last_order_date,
        coalesce(order_metrics.total_orders, 0) as total_orders,
        coalesce(order_metrics.commercial_orders, 0) as commercial_orders,
        coalesce(order_metrics.completed_orders, 0) as completed_orders,
        coalesce(order_metrics.refunded_orders, 0) as refunded_orders,
        coalesce(order_metrics.cancelled_orders, 0) as cancelled_orders,
        coalesce(order_metrics.lifetime_gross_amount, 0) as lifetime_gross_amount,
        coalesce(order_metrics.lifetime_net_amount, 0) as lifetime_net_amount,
        coalesce(order_metrics.lifetime_refund_amount, 0) as lifetime_refund_amount,
        coalesce(order_metrics.commercial_orders, 0) >= 2 as is_repeat_customer

    from customers
    left join order_metrics
        on customers.customer_id = order_metrics.customer_id

)

select * from customer_order_metrics
