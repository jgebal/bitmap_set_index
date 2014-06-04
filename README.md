#Hierarchical bitmap implementation for Oracle

Hierarchical bitmap implementation in Oracle for set based operations

The project aims to implement a hierarchical bitmap on Oracle database using pure SQL and PL/SQL approach.

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
