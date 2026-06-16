{{ config(materialized='view') }}

with marketing_channels as (

    select * from {{ ref('stg_ecommerce__marketing_channels') }}

),

unattributed_channel as (

    select
        -1 as channel_id,
        'Unattributed' as channel_name

),

final as (

    select
        channel_id,
        channel_name

    from marketing_channels

    union all

    select
        channel_id,
        channel_name

    from unattributed_channel

)

select * from final
