view: order_patterns {
  # # You can specify the table name if it's different from the view name:
  # sql_table_name: my_schema_name.tester ;;
  #
  # # Define your dimensions and measures here, like this:
  # dimension: user_id {
  #   description: "Unique ID for each user that has ordered"
  #   type: number
  #   sql: ${TABLE}.user_id ;;
  # }
  #
  # dimension: lifetime_orders {
  #   description: "The total number of orders for each user"
  #   type: number
  #   sql: ${TABLE}.lifetime_orders ;;
  # }
  #
  # dimension_group: most_recent_purchase {
  #   description: "The date when each user last ordered"
  #   type: time
  #   timeframes: [date, week, month, year]
  #   sql: ${TABLE}.most_recent_purchase_at ;;
  # }
  #
  # measure: total_lifetime_orders {
  #   description: "Use this for counting lifetime orders across many users"
  #   type: sum
  #   sql: ${lifetime_orders} ;;
  # }

  derived_table: {
    sql:
      SELECT
        order_id,
        user_id,
        created_at AS created_date,
        COUNT(order_id) OVER(PARTITION BY user_id) AS order_count,
        ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY created_at ASC) AS order_sequence,
        DATE_DIFF(created_at,
                  LAG(created_at) OVER (PARTITION BY user_id ORDER BY created_at ASC),
                  DAY) AS days_between_orders
      FROM `looker-private-demo.thelook.orders`
        AS orders;;
  }

  dimension: order_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.order_id ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension_group: created_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.created_at ;;
  }

  dimension: order_count {
    type: number
    sql: ${TABLE}.order_count ;;
  }

  dimension: order_sequence {
    type: number
    sql: ${TABLE}.order_sequence ;;
  }

  dimension: days_between_orders {
    type: number
    sql: ${TABLE}.days_between_orders ;;
  }

  dimension: is_first_purchase {
    type: yesno
    sql: ${order_sequence}=1 ;;
  }

  dimension: has_subsequent_order {
    type: yesno
    sql: ${order_sequence}>1 ;;
  }

  measure: average_days_between_orders {
    type:  average
    sql: ${TABLE}.days_between_orders ;;
  }

  measure: number_of_customers { #paying customers? hoe many customers are paying rather then total
    type:  count_distinct
    sql: ${user_id} ;;
  }

  measure: purchase_within_60days{
    type:  count_distinct
    filters: [days_between_orders: "<=60"]
    sql: ${user_id} ;;
  }

  measure: 60_Day_Repeat_Purchase_Rate{
    #label: "% of customers that have purchased within 60 days of a prior purchase"
    type:  number
    value_format_name: percent_2
    sql: ${purchase_within_60days}/NULLIF(${number_of_customers},0) ;;
  }


}
