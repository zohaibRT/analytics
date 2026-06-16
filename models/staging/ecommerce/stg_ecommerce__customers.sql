{{ config(materialized='view') }}

with source as (

    select * from {{ source('ecommerce', 'customers') }}

),

renamed as (

    select
        customer_id,
        first_name,
        last_name,
        trim(concat_ws(' ', first_name, last_name)) as customer_full_name,
        lower(email) as email,
        country,
        city,
        cast(signup_date as date) as signup_date,
        lower(customer_segment) as customer_segment

    from source

)

select * from renamed
