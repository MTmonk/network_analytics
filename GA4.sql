WITH pageviews AS (
  SELECT
    user_pseudo_id,
    event_bundle_sequence_id,
    event_timestamp,
    event_name,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = "page_location") AS page_location
  FROM `avisia-analytics.analytics_271196011.events_20250201`
  WHERE event_name = "page_view"
),
transitions AS (
  SELECT
    p1.user_pseudo_id,
    p1.page_location AS from_page,
    p2.page_location AS to_page,
    p1.event_timestamp AS from_time,
    p2.event_timestamp AS to_time
  FROM pageviews p1
  JOIN pageviews p2
  ON p1.user_pseudo_id = p2.user_pseudo_id
  AND p2.event_timestamp > p1.event_timestamp
  ORDER BY p1.user_pseudo_id, p1.event_timestamp
)
SELECT from_page, to_page, COUNT(*) AS transition_count
FROM transitions
GROUP BY from_page, to_page
ORDER BY transition_count DESC
