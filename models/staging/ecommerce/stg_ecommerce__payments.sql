{{ config(materialized='view') }}

with source as (

    select * from {{ source('ecommerce', 'payments') }}

),

renamed as (

    select
        payment_id,
        order_id,
        cast(payment_date as timestamp) as payment_date,
        lower(payment_method) as payment_method,
        lower(payment_status) as payment_status,
        amount

    from source

)

select * from renamed
