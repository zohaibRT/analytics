{{ config(materialized='view') }}

with order_items as (

    select * from {{ ref('fct_order_items') }}

),

products as (

    select * from {{ ref('dim_products') }}

),

product_metrics as (

    select
        order_items.product_id,
        count(*) as total_order_items,
        sum(order_items.quantity) as total_quantity_sold,
        sum(order_items.item_gross_amount) as gross_item_revenue,
        sum(case when order_items.is_commercial_order then order_items.item_gross_amount else 0 end)
            as commercial_item_revenue,
        count(distinct order_items.order_id) as order_count

    from order_items
    group by order_items.product_id

),

final as (

    select
        product_metrics.product_id,
        products.sku,
        products.product_name,
        products.category_id,
        products.category_name,
        product_metrics.total_order_items,
        product_metrics.total_quantity_sold,
        product_metrics.gross_item_revenue,
        product_metrics.commercial_item_revenue,
        product_metrics.order_count

    from product_metrics
    inner join products
        on product_metrics.product_id = products.product_id

)

select * from final
