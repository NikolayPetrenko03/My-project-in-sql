WITH revenue_per_time_slot AS (
SELECT 
	CASE 
		WHEN HOUR(order_time) BETWEEN 6 AND 11 THEN 'Morning (6 AM - 12 PM)'
		WHEN HOUR(order_time) BETWEEN 12 AND 17 THEN 'Afternoon (12 PM - 6 PM)'
		WHEN HOUR(order_time) BETWEEN 18 AND 23 THEN 'Evening (6 PM - 12 AM)'
		ELSE 'Night (12 AM - 6 AM)'
	END AS time_segment,
	DATE_FORMAT(order_date, '%Y-%m') AS month_year,
	SUM(final_price) AS total_revenue
    FROM orders
    WHERE order_date BETWEEN '2022-06-01' AND '2022-09-30'
    GROUP BY time_segment, month_year
),
revenue_with_change AS (
    SELECT 
        *,
        LAG(total_revenue) OVER (PARTITION BY time_segment ORDER BY month_year) AS prev_revenue,
        ROUND(((total_revenue - LAG(total_revenue) OVER (PARTITION BY time_segment ORDER BY month_year)) / 
        LAG(total_revenue) OVER (PARTITION BY time_segment ORDER BY month_year)) * 100, 2) AS percentage_change
    FROM revenue_per_time_slot
)
SELECT * FROM revenue_with_change;
