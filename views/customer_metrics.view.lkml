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

  dimension: customer_lifetime_orders {
    type: tier
    tiers: [1,2,3,6,10]
    style: integer
    sql: ${order_count_per_customer};;
  }

  dimension: sales_per_customer {
    type: number
    sql: ${TABLE}.total_sales ;;
    value_format_name: usd
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

  dimension: last_order_date {
    type: date
    sql: ${TABLE}.last_order ;;
  }

  dimension: is_active {
    type: yesno
    sql: DATE_DIFF(CURRENT_DATE(), ${last_order_date}, DAY) < 90;;
  }

  dimension: days_since_latest_order {
    type: number
    sql: DATE_DIFF(CURRENT_DATE(), ${last_order_date}, DAY) ;;
  }

  dimension: repeat_customer {
    type: yesno
    sql: ${order_count_per_customer}>1 ;;
  }

  measure: total_lifetime_orders {
    type: sum
    sql: ${order_count_per_customer} ;;
  }

  measure: average_lifetime_orders {
    type: average
    sql: ${order_count_per_customer} ;;
  }

  measure: total_lifetime_revenue {
    type: sum
    sql: ${sales_per_customer} ;;
    value_format_name: usd
  }

  measure: average_lifetime_revenue {
    type: average
    sql: ${sales_per_customer} ;;
    value_format_name: usd
  }

  measure: average_days_since_latest_order {
    type: average
    sql: ${days_since_latest_order} ;;
  }

  measure: repeat_customer_value {
    hidden: yes
    type: sum
    sql: if(${repeat_customer},1,0) ;; #customers who have made 2+ orders
  }

  measure: total_paying_customers {
    hidden: yes
    type: sum
    sql: if(${order_count_per_customer}>=1,1,0) ;; #customer with at least 1 order lifetime
  }

  measure: repeat_purchase_rate {
    type: number
    value_format_name: percent_2
    sql: ${repeat_customer_value}/ ${total_paying_customers} ;;
  }

  parameter: metric_selector {
    type: unquoted
    allowed_value: {
      label: "Average Lifetime Orders"
      value: "average_lifetime_orders"
    }
    allowed_value: {
      label: "Total Lifetime Orders"
      value: "total_lifetime_orders"
    }
    allowed_value: {
      label: "Total Lifetime Revenue"
      value: "total_lifetime_revenue"
    }
  }

  measure: dynamic_metric_selector {
    sql:
    {% if ${metric_selector}._parameter_value == 'average_lifetime_orders' %}
    ${average_lifetime_orders}
    {% elsif ${metric_selector}._parameter_value == 'total_lifetime_orders' %}
    ${total_lifetime_orders}
    {% elsif ${metric_selector}._parameter_value == 'total_lifetime_revenue' %}
    ${total_lifetime_revenue}
    {% else %}
    NULL
    {% endif %};;
    value_format_name: "usd"
  }



}
