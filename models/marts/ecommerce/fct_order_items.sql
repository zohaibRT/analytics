{{ config(materialized='view') }}

with order_items_enriched as (

    select * from {{ ref('int_ecommerce__order_items_enriched') }}

),

final as (

    select
        order_item_id,
        order_id,
        customer_id,
        product_id,
        category_id,
        coalesce(channel_id, -1) as channel_id,
        order_date,
        order_status,
        quantity,
        unit_price,
        line_amount,
        item_gross_amount,
        is_commercial_order

    from order_items_enriched

)

select * from final
