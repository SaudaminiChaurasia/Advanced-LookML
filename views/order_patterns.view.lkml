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
        order.user_id  AS users_id,
        order.order_id  AS order_id,
        order.created_at AS created_date,
        COUNT(order.order_id) OVER(PARTITION BY order.user_id) AS Order_Count,
        ROW_NUMBER() OVER(PARTITION BY order.user_id ORDER BY order.created_at ASC) AS Order_Sequence
      FROM `looker-private-demo.thelook.orders`
        AS orders;;
  }

}
