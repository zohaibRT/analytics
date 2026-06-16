{{ config(materialized='view') }}

with source as (

    select * from {{ source('ecommerce', 'marketing_channels') }}

),

renamed as (

    select
        channel_id,
        channel_name

    from source

)

select * from renamed
