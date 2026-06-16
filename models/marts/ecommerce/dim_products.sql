{{ config(materialized='view') }}

with products as (

    select * from {{ ref('stg_ecommerce__products') }}

),

categories as (

    select * from {{ ref('stg_ecommerce__categories') }}

),

final as (

    select
        products.product_id,
        products.sku,
        products.product_name,
        products.category_id,
        categories.category_name,
        products.unit_price,
        products.active_flag

    from products
    left join categories
        on products.category_id = categories.category_id

)

select * from final
