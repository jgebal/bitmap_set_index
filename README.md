#Set-based hierarchical bitmap index

Set-based Hierarchical bitmap index implementation in Oracle for set based operations.

The purpose of the project is to provide a set-based operator and index that gives simple syntax and huge performance gains on set-based comparison queries.
Sample queries that use set-based comparison are:
- List all employees that like exactly the same things as Mike.
- List all employees that like some part of things as Mike.
- Order the employees by similarity of likes
- List all employees that like totally different fruits than Mike.
If you need to compare data-sets containing comparable data, the project might become handy.
A classic SQL-approach query to list all employees ordered by likes similarity would be like the one below:
```sql
WITH likes_counted AS
  (
  SELECT count(*) OVER (PARTITION BY employee_id) likes_count,
        el.*
   FROM employees_likes el
  )
SELECT elc1.employee_id, elc2.employee_id, count(1)*100/elc1.likes_count similarity
  FROM likes_counted elc1
  JOIN likes_counted elc2
    ON elc1.like_id = elc2.like_id
   AND elc1.employee_id > elc2.employee_id
  GROUP BY elc1.employee_id, elc2.employee_id, elc1.likes_count
 ORDER BY similarity DESC;
```

The project uses hierarchical bitmap index approach for set-based operations, as described here: http://www.cs.put.poznan.pl/mmorzy/papers/adbis03.pdf

The plan is to implement the index as a generic, Oracle-managed object, that will be using Oracle Extensible Indexing, as described here:
http://docs.oracle.com/cd/B28359_01/appdev.111/b28425/ext_idx_frmwork.htm
and here:
http://docs.oracle.com/cd/B19306_01/server.102/b14200/ap_examples001.htm
and with API described here:
http://docs.oracle.com/cd/B28359_01/appdev.111/b28425/ext_idx_ref.htm

The project is build and tested using Oracle 11g XE and ruby-plsql, ruby-plsql-spec framework for unit testing.
https://github.com/rsim/ruby-plsql
https://github.com/rsim/ruby-plsql-spec

----

##Implementation Plans

###Bitmap maintenance layer:
- Create bitmap from a list of bits
- Add bit to bitmap
- Add bit list to bitmap
- Remove bit from bitmap
- Remove bit list from bitmap
- Store bitmap
- Retrieve bitmap

###Bitmap operators layer:
- INTERSECT(bitmap,bitmap) returns bitmap
- UNION(bitmap,bitmap) returns bitmap
- MINUS(bitmap,bitmap) returns bitmap
- COUNT_BITS(bitmap) returns INTEGER
- CONTAINS_ALL(bitmap, bitmap) return BOOLEAN/INTEGER (0,1)
- IS_EQUAL(bitmap, bitmap) return BOOLEAN/INTEGER (0,1)

###Translation layer:

- Create bitmap for a data-set
    As an API want to be able to define a bitmap on a table containing customer_transactions.

    The bitmap should be created per each customer and should be build out of the list of products bought by customer.
    We could have a helper object holding:

    - table name (customer_-transactions)
    - parent table name (customer)
    - key column list (customer_id)
    - ref cursor with new values to be populated in bitmap (product_id, product_line)

    We could have a function/procedure to build the bitmap based on the object passed

- Update bitmap from data-set
    - add new keys
    - remove deleted keys
- Drop single bitmap for key column


Helpful links:
---
[Example of Domain Index implementation in Oracle](http://docs.oracle.com/cd/E18283_01/server.112/e17118/ap_examples001.htm)

[The theory for the hierarchical index](http://www.cs.put.poznan.pl/mmorzy/papers/adbis03.pdf)
