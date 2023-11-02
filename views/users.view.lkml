view: users {
  sql_table_name: `thelook.users` ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }
  dimension: age {
    type: number
    sql: ${TABLE}.age ;;
  }
  dimension: age_tier {
    label: "Age Tier"
    type: tier
    tiers: [0, 16, 26, 36, 51, 66]
    style: integer
    sql: ${age} ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
  }
  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}.country ;;
  }
  dimension_group: created {
    type: time
    timeframes: [time, hour, date, week, month, year, hour_of_day, day_of_week, day_of_month, month_num, raw, week_of_year,month_name]
    sql: ${TABLE}.created_at ;;
  }
  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }
  dimension: first_name {
    type: string
    sql: ${TABLE}.first_name ;;
  }
  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
  }
  dimension: last_name {
    type: string
    sql: ${TABLE}.last_name ;;
  }
  dimension: latitude {
    type: number
    sql: ${TABLE}.latitude ;;
  }
  dimension: longitude {
    type: number
    sql: ${TABLE}.longitude ;;
  }
  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
  }
  dimension: traffic_source {
    type: string
    sql: ${TABLE}.traffic_source ;;
  }
  dimension: zip {
    type: zipcode
    sql: ${TABLE}.zip ;;
  }
  dimension: customer_filter {
    case: {
      when: {
        sql: DATE_DIFF(CURRENT_DATE(), ${created_date}, DAY) < 90 ;;
        label: "New Customer"
      }
      else: "Long-term Customer"
    }
  }
  dimension: user_location {
    type: location
    sql_latitude: ${latitude} ;;
    sql_longitude: ${longitude} ;;
  }

  dimension: days_since_signup {
    type: number
    sql: DATE_DIFF(CURRENT_DATE(), ${created_date}, DAY) ;;
  }

  dimension: months_since_signup {
    type: number
    sql: DATE_DIFF(CURRENT_DATE(), ${created_date}, MONTH) ;;
  }

  dimension: customer_cohort {
    label: "Customer Cohort - Months"
    type: tier
    tiers: [5, 10, 15, 20, 25, 30, 35, 40, 45, 50]
    style: integer
    sql: ${months_since_signup} ;;
  }

  measure: average_days_since_signup{
    type: average
    sql: ${days_since_signup} ;;
  }

  measure: average_months_since_signup{
    type: average
    sql: ${months_since_signup} ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
  id,
  last_name,
  first_name,
  order_items_final.count,
  order_items.count,
  events.count,
  order_items_test.count,
  order_items_test2.count,
  orders.count
  ]
  }

}
