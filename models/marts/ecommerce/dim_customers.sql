{{ config(materialized='view') }}

with customers as (

    select * from {{ ref('stg_ecommerce__customers') }}

),

customer_metrics as (

    select * from {{ ref('int_ecommerce__customer_order_metrics') }}

),

final as (

    select
        customers.customer_id,
        customers.customer_full_name,
        customers.email,
        customers.country,
        customers.city,
        customers.signup_date,
        customers.customer_segment,

        customer_metrics.first_order_date,
        customer_metrics.last_order_date,
        customer_metrics.total_orders,
        customer_metrics.commercial_orders,
        customer_metrics.lifetime_gross_amount,
        customer_metrics.lifetime_net_amount,
        customer_metrics.lifetime_refund_amount,
        customer_metrics.is_repeat_customer

    from customers
    left join customer_metrics
        on customers.customer_id = customer_metrics.customer_id

)

select * from final
