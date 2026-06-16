{{ config(materialized='view') }}

with source as (

    select * from {{ source('ecommerce', 'orders') }}

),

renamed as (

    select
        order_id,
        customer_id,
        cast(order_date as timestamp) as order_date,
        lower(order_status) as order_status,
        channel_id,
        gross_amount,
        discount_amount,
        tax_amount,
        shipping_amount

    from source

)

select * from renamed
