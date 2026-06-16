{{ config(materialized='view') }}

with orders as (

    select * from {{ ref('fct_orders') }}

),

channels as (

    select * from {{ ref('dim_marketing_channels') }}

),

channel_metrics as (

    select
        orders.channel_id,
        count(*) as total_orders,
        count(*) filter (where orders.is_commercial_order) as commercial_orders,
        count(*) filter (where orders.is_completed_order) as completed_orders,
        count(*) filter (where orders.is_refunded_order) as refunded_orders,
        count(*) filter (where orders.is_cancelled_order) as cancelled_orders,
        sum(orders.calculated_order_total_amount) as gross_revenue,
        sum(orders.net_order_amount) as net_revenue,
        sum(orders.total_refund_amount) as refund_amount

    from orders
    group by orders.channel_id

),

final as (

    select
        channel_metrics.channel_id,
        channels.channel_name,
        channel_metrics.total_orders,
        channel_metrics.commercial_orders,
        channel_metrics.completed_orders,
        channel_metrics.refunded_orders,
        channel_metrics.cancelled_orders,
        channel_metrics.gross_revenue,
        channel_metrics.net_revenue,
        channel_metrics.refund_amount,
        channel_metrics.gross_revenue / nullif(channel_metrics.commercial_orders, 0) as average_order_value

    from channel_metrics
    inner join channels
        on channel_metrics.channel_id = channels.channel_id

)

select * from final
