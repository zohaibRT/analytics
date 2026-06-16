{{ config(materialized='view') }}

with source as (

    select * from {{ source('ecommerce', 'refunds') }}

),

renamed as (

    select
        refund_id,
        order_id,
        cast(refund_date as timestamp) as refund_date,
        refund_amount,
        refund_reason

    from source

)

select * from renamed
