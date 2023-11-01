view: customer_metrics {
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
        Select
          users_id,
          count(order_id) as order_count,
          sum(sale_price) as total_sales,
          min(created_date) as first_order,
          max(created_date) as last_order
  FROM
  (SELECT
      users.id  AS users_id,
      order_items.order_id  AS order_id,
      order_items.sale_price AS sale_price,
      order_items.created_at AS created_date
  FROM `looker-private-demo.thelook.order_items`
       AS order_items
  LEFT JOIN `looker-private-demo.thelook.users`
       AS users ON users.id = order_items.user_id
  GROUP BY
      1,
      2,
      3,
      4
  ORDER BY
      1)
  group by users_id;;
}

  dimension: users_id {
    type: number
    primary_key: yes
    sql: ${TABLE}.users_id ;;
  }

  dimension: order_count_per_customer {
    type: number
    sql: ${TABLE}.order_count ;;
  }

  dimension: sales_per_customer {
    type: number
    sql: ${TABLE}.total_sales ;;
    value_format_name: usd
  }

  dimension: customer_lifetime_orders {
    type: tier
    tiers: [1,2,3,6,10]
    style: integer
    sql: ${order_count_per_customer};;
  }

  dimension: customer_lifetime_revenue {
    type: tier
    tiers: [5,20,50,100,500,1000]
    style: integer
    sql: ${sales_per_customer};;
    value_format_name: usd
  }

  dimension: first_order_date {
    type: date
    sql: ${TABLE}.first_order ;;
  }

  dimension: latest_order_date {
    type: date
    sql: ${TABLE}.last_order ;;
  }

  dimension: is_active {
    type: yesno
    sql: DATE_DIFF(CURRENT_DATE(), ${latest_order_date}, DAY) < 90;;
  }

  dimension: days_since_latest_order {
    type: number
    sql: DATE_DIFF(CURRENT_DATE(), ${latest_order_date}, DAY) ;;
  }
  dimension: is_repeat_customer {
    type: yesno
    sql: ${order_count_per_customer}>1 ;;
  }

  measure: is_repeat_customer_measure {
    hidden: yes
    type: sum
    sql: if(${is_repeat_customer},1,0) ;;
  }
  measure: if_has_at_least_one {
    hidden: yes
    type: sum
    sql: if(${order_count_per_customer}>=1,1,0) ;;
  }

  measure: repeat_purchase_rate {
    type: number
    value_format_name: percent_2
    sql: ${is_repeat_customer_measure}/ ${if_has_at_least_one} ;;
  }

  measure: average_days_since_latest_order {
    type: average
    sql: ${days_since_latest_order} ;;
  }

  measure: total_lifetime_orders {
    type: sum
    sql: ${order_count_per_customer} ;;
  }

  measure: average_lifetime_orders {
    type: average
    sql: ${order_count_per_customer} ;;
  }


}
