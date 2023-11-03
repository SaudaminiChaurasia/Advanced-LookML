view: order_items {
  sql_table_name: `thelook.order_items` ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }
  dimension_group: created {
    type: time
    timeframes: [time, hour, date, week, month, year, hour_of_day, day_of_week, month_num, raw, week_of_year,month_name]
    sql: ${TABLE}.created_at ;;
  }

  parameter: date_granularity {
    type: unquoted
    allowed_value: {
      label: "Daily"
      value: "daily"
    }
    allowed_value: {
      label: "Weekly"
      value: "weekly"
    }
    allowed_value: {
      label: "Monthly"
      value: "monthly"
    }
  }

  dimension: date {
    sql:
    {% if date_granularity._parameter_value == 'daily' %}
      ${created_date}
    {% elsif date_granularity._parameter_value == 'weekly' %}
      ${created_week}
    {% elsif date_granularity._parameter_value == 'monthly' %}
      ${created_month}
    {% else %}
      NULL
    {% endif %};;
  }

  dimension_group: delivered {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.delivered_at ;;
  }
  dimension: inventory_item_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.inventory_item_id ;;
  }
  dimension: order_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.order_id ;;
  }
  dimension_group: returned {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.returned_at ;;
  }
  dimension: sale_price {
    type: number
    value_format_name: usd
    sql: ${TABLE}.sale_price ;;
  }
  dimension_group: shipped {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.shipped_at ;;
  }
  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }
  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.user_id ;;
  }
  dimension: gross_margin {
    label: "Gross Margin"
    type: number
    value_format_name: usd
    sql: ${sale_price} - ${inventory_items.cost};;
  }
  dimension: item_gross_margin_percentage {
    label: "Item Gross Margin Percentage"
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${gross_margin}/NULLIF(${sale_price},0) ;;
  }
  measure: count {
    type: count
    drill_fields: [detail*]
  }
  measure: total_sale {
    label: "Total Sale Price"
    type:  sum
    sql: ${sale_price};;
    value_format_name: usd
  }
  measure: average_sale {
    label: "Average Sale Price"
    type:  average
    sql: ${sale_price} ;;
    value_format_name: usd
  }
  measure: cumulative_sale {
    label: "Cumulative Total Sales"
    type:  running_total
    sql: ${sale_price} ;;
    value_format_name: usd
    drill_fields: [detail*]
  }
  measure: total_gross_revenue {
    label: "Total Gross Revenue"
    type:  sum
    filters: [status: "-Cancelled, -Returned"] #filtered measure
    sql: ${sale_price};;
    value_format_name: usd
    drill_fields: [detail*]
  }
  measure: total_gross_margin {
    label: "Total Gross Margin Amount"
    type:  sum
    sql: ${gross_margin} ;;
    value_format_name: usd
    drill_fields: [detail*]
  }
  measure: average_gross_margin {
    label: "Average Gross Margin"
    type:  average
    sql: ${gross_margin} ;;
    value_format_name: usd
    drill_fields: [detail*]
  }
  measure: gross_margin_percentage {
    label: "Gross Margin %"
    type:  number
    value_format_name: percent_2
    sql:  1.0 *${total_gross_margin}/NULLIF(${total_gross_revenue},0);;
    drill_fields: [detail*]
  }
  measure: items_returned {
    label: "Number of Items Returned"
    type:  count_distinct
    filters: [status: "returned"] #filtered measure
    sql: ${id};;
    drill_fields: [detail*]
  }
  measure: items_returned_rate {
    label: "Item Return Rate"
    type:  number
    sql: ${items_returned}/${count} ;;
    drill_fields: [detail*]
  }
  measure: customer_returning_items {
    label: "Number of Customers Returning Items"
    type:  count_distinct
    filters: [status: "returned"] #filtered measure
    sql: ${user_id} ;;
    drill_fields: [detail*]
  }
  measure: number_of_customers {
    label: "Total Number of Customers"
    type:  count_distinct
    sql: ${user_id} ;;
    drill_fields: [detail*]
  }
  measure: percentage_of_users_with_returns{
    label: "% of Users with Returns"
    type:  number
    sql: ${customer_returning_items}/${number_of_customers} ;;
    drill_fields: [detail*]
  }
  measure: average_spend_per_customer{
    label: "Average Spend Per Customer"
    type:  number
    sql: ${total_sale}/${number_of_customers};;
    value_format_name: usd
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
  id,
  users.last_name,
  users.id,
  users.first_name,
  inventory_items.id,
  inventory_items.product_name,
  orders.order_id
  ]
  }

}
