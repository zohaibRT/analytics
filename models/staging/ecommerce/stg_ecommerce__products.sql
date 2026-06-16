{{ config(materialized='view') }}

with source as (

    select * from {{ source('ecommerce', 'products') }}

),

renamed as (

    select
        product_id,
        sku,
        product_name,
        category_id,
        unit_price,
        active_flag

    from source

)

select * from renamed
