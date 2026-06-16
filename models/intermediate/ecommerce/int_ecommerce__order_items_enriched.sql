{{ config(materialized='view') }}

with order_items as (

    select * from {{ ref('stg_ecommerce__order_items') }}

),

products as (

    select * from {{ ref('stg_ecommerce__products') }}

),

categories as (

    select * from {{ ref('stg_ecommerce__categories') }}

),

orders_enriched as (

    select * from {{ ref('int_ecommerce__orders_enriched') }}

),

enriched as (

    select
        order_items.order_item_id,
        order_items.order_id,
        order_items.product_id,
        order_items.quantity,
        order_items.unit_price,
        order_items.line_amount,
        order_items.quantity * order_items.unit_price as item_gross_amount,

        products.sku,
        products.product_name,
        products.active_flag as product_active_flag,

        categories.category_id,
        categories.category_name,

        orders_enriched.customer_id,
        orders_enriched.customer_full_name,
        orders_enriched.customer_email,
        orders_enriched.customer_segment,
        orders_enriched.channel_id,
        orders_enriched.channel_name,
        orders_enriched.order_date,
        orders_enriched.order_status,
        orders_enriched.is_commercial_order,
        orders_enriched.gross_amount as order_gross_amount,
        orders_enriched.calculated_order_total_amount as order_calculated_total_amount

    from order_items
    inner join products
        on order_items.product_id = products.product_id
    left join categories
        on products.category_id = categories.category_id
    inner join orders_enriched
        on order_items.order_id = orders_enriched.order_id

)

select * from enriched
