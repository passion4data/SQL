/*Project Problem Statement:
-------------------------------

You are hired by a chain of online retail stores “Reliant retail limited”. They provided you with “orders” database and seek answers to the following queries as the results from these queries will help the company in making data-driven decisions that will impact the overall growth of the online retail store.*/

/* 1. Write a query to display the product details (product_class_code, product_id, product_desc,
product_price) as per the following criteria and sort them descending order of category:
i) If the category is 2050, increase the price by 2000
ii) If the category is 2051, increase the price by 500
iii) If the category is 2052, increase the price by 600
Hint: Use CASE statement, no permanent change in table required.
(60 rows)[NORE:PRODUCT TABLE] */

use orders;

select prd.Product_Class_Code, prd.Product_ID, prd.Product_Desc,prd.Product_Price,
case prd.Product_Class_Code
when 2050 then prd.product_price + 2000 -- calculating increased/new price for 2050 category
when 2051 then prd.product_price + 500 -- calculating increased/new price for 2051 category
when 2052 then prd.product_price + 600 -- calculating increased/new price for 2052 category
else prd.product_price
end Increased_Price
from product prd
inner join product_class pc
on prd.product_class_code = pc.product_class_code
order by 1 desc;

/* 2. Write a query to display (product_class_desc, product_id,
product_desc, product_quantity_avail ) and Show inventory status of products as below
as per their available quantity:
a. For Electronics and Computer categories, if available quantity is <= 10, show
'Low stock', 11 <= qty <= 30, show 'In stock', >= 31, show 'Enough stock'
b. For Stationery and Clothes categories, if qty <= 20, show 'Low stock', 21 <= qty <=
80, show 'In stock', >=81, show 'Enough stock'
c. Rest of the categories, if qty <= 15 – 'Low Stock', 16 <= qty <= 50 – 'In Stock', >=
51 – 'Enough stock'
For all categories, if available quantity is 0, show 'Out of
stock'.
Hint: Use case statement. (60 ROWS)[NOTE : TABLES TO BE USED – product,
product_class] */

select PC.product_class_desc as 'Product Class Desc',
PR.product_id AS 'Product ID',
PR.product_desc AS 'Product Description',
PR.product_quantity_avail AS 'Quantity In-Stock',
case 
when product_class_desc in ('Electronics','Computer') then
case 
when product_quantity_avail = 0 then 'Out of stock' 
when product_quantity_avail <= 10 then 'Low Stock'
when (product_quantity_avail >= 11 and product_quantity_avail <=30) then 'In Stock'
when product_quantity_avail >= 31 then 'Enough Stock'
end
when product_class_desc in ('Stationery','Clothes') then
case
when product_quantity_avail = 0 then 'Out of stock' 
when product_quantity_avail <= 20 then 'Low Stock'
when (product_quantity_avail >= 21 and product_quantity_avail <=80) then 'In Stock'
when product_quantity_avail >= 81 then 'Enough Stock'
end
else
case
when product_quantity_avail = 0 THEN 'Out of stock'
when product_quantity_avail <= 15 then 'Low Stock'
when product_quantity_avail between 16 and 50 then 'In Stock'
when product_quantity_avail >= 51 then 'Enough stock'
end
end as Inventory_Status
from product PR
inner join product_class PC
on PR.product_class_code = PC.product_class_code;

/* 3. Write a query to Show the count of cities in all countries other than USA & MALAYSIA, with
more than 1 city, in the descending order of CITIES.
(2 rows)[NOTE :ADDRESS TABLE] */

select country, count(distinct(city)) as No_of_Cities -- choosing distinct as there are duplicate entries for cities
from address 
where country not in ('USA','Malaysia')  
group by country
having count(city) > 1
order by No_of_Cities DESC;


/* 4. Write a query to display the customer_id,customer full name ,city,pincode,and order
details (order id, product class desc, product desc, subtotal(product_quantity *
product_price)) for orders shipped to cities whose pin codes do not have any 0s in them.
Sort the output on customer name, order date and subtotal.(52 ROWS)
[NOTE : TABLE TO BE USED - online_customer, address, order_header,
order_items, product, product_class] */

select onc.Customer_ID, concat(onc.customer_fname, ' ', onc.customer_lname) as Customer_Fullname, adr.City, adr.Pincode,
orhd.Order_ID, pcl.Product_Class_Desc, pr.Product_Desc, (oit.product_quantity*pr.product_price) as Subtotal
from online_customer onc
inner join address adr 
on onc.address_id = adr.address_id
inner join order_header orhd
on onc.customer_id = orhd.customer_id
inner join order_items oit
on orhd.order_id = oit.order_id
inner join product pr
on oit.product_id = pr.product_id
inner join product_class pcl
on pr.product_class_code = pcl.product_class_code
where orhd.order_status = 'Shipped' AND adr.pincode not like "%0%"
order by Customer_Fullname,Subtotal asc;


/* 5. Write a Query to display product id,product description,totalquantity(sum(product quantity) for a
given item whose product id is 201 and which item has been bought along with it maximum no. of
times. Display only one record which has the maximum value for total quantity in this scenario.
(USE SUB-QUERY)(1 ROW)[NOTE : ORDER_ITEMS TABLE,PRODUCT TABLE] */

select oit.Product_ID,prd.Product_Desc, sum(oit.product_quantity) as Total_Quantity
from order_items oit
inner join product prd on prd.product_id = oit.product_id
where oit.order_id in
(select distinct order_id from
order_items oite where product_id = 201)
and oit.product_id != 201
group by oit.product_id
order by Total_Quantity desc
limit 1;


/* 6. Write a query to display the customer_id,customer name, email and order details
(order id, product desc,product qty, subtotal(product_quantity * product_price)) for all
customers even if they have not ordered any item.(225 ROWS)
[NOTE : TABLE TO BE USED - online_customer, order_header, order_items,
product] */

select onc.Customer_ID, concat(onc.customer_fname, ' ', onc.customer_lname) as Customer_Fullname,
onc.Customer_Email, orh.Order_ID, prd.Product_Desc, oit.Product_Quantity,
(oit.product_quantity * product_price) as Subtotal
from online_customer onc 
left join order_header orh 
on onc.customer_id = orh.customer_id
left join order_items oit 
on orh.order_id = oit.order_id
left join product prd 
on oit.product_id = prd.product_id
order by onc.customer_id, oit.Product_Quantity asc;


/* 7. Write a query to display carton id ,(len*width*height) as carton_vol and identify the
optimum carton (carton with the least volume whose volume is greater than the total volume of
all items(len * width * height * product_quantity)) for a given order whose order id is 10006
, Assume all items of an order are packed into one single carton (box) .(1 ROW)[NOTE :
CARTON TABLE] */

select Carton_ID ,(len*width*height) as Total_Volume
from carton 
where (len*width*height) >= (select sum(prd.len*prd.width*prd.height*oit.product_quantity) as temp
from orders.order_items oit
inner join orders.product prd on oit.product_id = prd.product_id
where oit.order_id =10006)
order by Total_Volume asc
limit 1;


/* 8. Write a query to display details (customer id,customer fullname,order id,product quantity)
of customers who bought more than ten (i.e. total order qty) products with credit card or net
banking as the mode of payment per shipped order. (6 ROWS)
[NOTE: TABLES TO BE USED - online_customer, order_header, order_items,] */

select onc.Customer_ID, concat(onc.customer_fname, ' ', onc.customer_lname) as Customer_Fullname,
orh.Order_ID, sum(oit.product_quantity) as Total_Order_Quantity
from online_customer onc
inner join order_header orh
on onc.customer_id = orh.customer_id
inner join order_items oit
on orh.order_id = oit.order_id
where payment_mode in ('Credit Card','Net banking')
and orh.order_status = 'Shipped'
group by 1,2,3
having Total_Order_Quantity > 10;



/* 9.Write a query to display the order_id,customer_id and customer fullname starting with “A” along
with (product quantity) as total quantity of products shipped for order ids > 10030
(5 Rows) [NOTE: TABLES to be used-online_customer,Order_header, order_items] */

select orh.Order_ID, onc.Customer_ID, 
concat(onc.customer_fname, ' ', onc.customer_lname) as Customer_Fullname,
sum(oit.product_quantity) as Total_Order_Quantity
from online_customer onc
inner join order_header orh
on onc.customer_id = orh.customer_id
inner join order_items oit
on orh.order_id = oit.order_id
where onc.customer_fname like "A%" and orh.order_status = 'Shipped' 
and orh.order_id > 10030
group by 1,2,3;


/* 10. Write a query to display product class description, totalquantity(sum(product_quantity), Total
value (product_quantity * product price) and show which class of products have been shipped
highest(Quantity) to countries outside India other than USA? Also show the total value of those
items.
(1 ROWS)[NOTE:PRODUCT TABLE,ADDRESS TABLE,ONLINE_CUSTOMER
TABLE,ORDER_HEADER TABLE,ORDER_ITEMS TABLE,PRODUCT_CLASS TABLE] */

select pcl.product_class_code as Product_Class_Code,
pcl.product_class_desc as Product_Class_Description,
sum(oit.product_quantity) as Total_Prod_Quantity,
sum(oit.product_quantity * prd.product_price) as Total_Value
from order_items oit
inner join order_header orh 
on orh.order_id = oit.order_id 
inner join online_customer onc 
on onc.customer_id = orh.customer_id
inner join product prd 
on prd.product_id = oit.product_id
inner join product_class pcl 
on pcl.product_class_code = prd.product_class_code
inner join address a 
on a.address_id = onc.address_id 
where orh.order_status ='Shipped' and a.country not in('India','USA')
group by 1,2
order by Total_Prod_Quantity desc 
limit 1;