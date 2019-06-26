# Review Service

## Review table

column | type | description
-------|------|------------
rater_id | integer |
rater_type | string |
rateable_id | integer |
rateable_type | string |
rating_type | integer | 0 for star, 1 for thumb.
rating | integer | When rating_type is "star", range from 1 to 5. When rating_type is "thumb", range from 0 to 2 (0 => none, 1 => thumb up, 2 => thumb down)
comment | string |
active | boolean |
metadata | jsonb | Metadata is useful for storing additional, structured information on an object. e.g. `{ "store_id": 1, "product_id": 1 }`

## Use cases

### User rates store, get average rating of store

```sql
INSERT INTO reviews (rater_type, rater_id, rateable_type, rateable_id, rating_type, rating)
VALUES
  ('User', 1, 'Store', 1, 'star', 1),
  ('User', 1, 'Store', 1, 'star', 5),
  ('User', 1, 'Store', 3, 'star', 2);

SELECT AVG(rating) as rating_average, COUNT(rating) as rating_count
FROM reviews
WHERE rateable_type = 'Store'
GROUP BY rateable_id;

   rating_average   | rating_count
--------------------+--------------
 3.0000000000000000 |            2
 2.0000000000000000 |            1
```

### User rates order item, get thumb up count of product by store.

Order item is a product sold in store. (1 product can be sold at different store).
Save store_id and product_id info in metadata so we can query it.

```sql
INSERT INTO reviews (rater_type, rater_id, rateable_type, rateable_id, rating_type, rating, metadata)
VALUES
  ('User', 1, 'OrderItem', 1, 'thumb', 1, '{ "store_id": 1, "product_id": 1 }'),
  ('User', 1, 'OrderItem', 2, 'thumb', 1, '{ "store_id": 1, "product_id": 1 }'),
  ('User', 1, 'OrderItem', 3, 'thumb', 1, '{ "store_id": 1, "product_id": 2 }'),
  ('User', 1, 'OrderItem', 4, 'thumb', 1, '{ "store_id": 2, "product_id": 1 }');

SELECT
  metadata -> 'store_id' as store_id,
  metadata -> 'product_id' as product_id,
  COUNT(*) as thumb_up_count
FROM reviews
WHERE
  rateable_type = 'OrderItem' AND
  rating = 1 AND -- thumb up = 1
  (metadata -> 'store_id') IS NOT NULL AND
  (metadata -> 'product_id') IS NOT NULL
GROUP BY metadata -> 'store_id', metadata -> 'product_id';

 store_id | product_id | thumb_up_count
----------+------------+----------------
 1        | 1          |              2
 1        | 2          |              1
 2        | 1          |              1
```

## Bonus: partial index in metadata

If we want to query order item by store, then we can create a partial index to let the query faster.

```sql
CREATE INDEX index_reviews_on_rateable_type_order_item
ON reviews (((metadata -> 'store_id')::int))
WHERE
  rateable_type = 'OrderItem' AND
  metadata -> 'store_id' IS NOT NULL

SELECT * FROM reviews
WHERE
  rateable_type = 'OrderItem' AND
  (metadata -> 'store_id') IS NOT NULL AND
  (metadata -> 'store_id')::int = 1;
```