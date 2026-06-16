{{ config(materialized='view') }}

with source as (

    select * from {{ source('ecommerce', 'order_items') }}

),

renamed as (

    select
        order_item_id,
        order_id,
        product_id,
        quantity,
        unit_price,
        line_amount

    from source

)

select * from renamed
