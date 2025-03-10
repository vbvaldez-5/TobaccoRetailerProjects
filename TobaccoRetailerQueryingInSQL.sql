--PRELIMINARY ITEM: The following files can be utilized
--for the tables in this database: tobacco_retailer_info.csv,
--license_tracking.csv, and compliance_visits.csv

--Let's assume we got a request to identify the store types who
--have a sale to minor violation

--First, we perform a join

SELECT * FROM compliance_visits c
RIGHT JOIN retailer_info t
ON c.retailer_id=t.retailer_id

--Now we want to see the count of store types 

SELECT COUNT(sale_to_minor_violation), store_type 
FROM compliance_visits c
RIGHT JOIN retailer_info t
ON c.retailer_id=t.retailer_id
WHERE sale_to_minor_violation = 'Yes'
GROUP BY store_type

--Based off the previous output, we can see
--that the store type with the most
--sale to minor violations is the Convenience store
--type with 42

--Now, let's assume we want to know the store type
--with flavored product violations

SELECT COUNT(flavored_tobacco_violation), store_type 
FROM compliance_visits c
RIGHT JOIN retailer_info t
ON c.retailer_id=t.retailer_id
WHERE flavored_tobacco_violation = 'Yes'
GROUP BY store_type

--This time, we see that gas stations have more
--flavored product violations 35

--Yes and No responses are great, but what if we want
--to know if the retailers are overall compliant after
--the inspection visit?

--Let's add a column to the compliance visit table
--to give us a new column that tells us if the
--retailer is overall compliant or noncompliant

ALTER TABLE compliance_visits
ADD compliance_status TEXT

--Now that we have a new column, let's update
--the records for the new column by assigning
--the new overall compliance status based off
--the conditions in the violations columns

UPDATE compliance_visits
SET compliance_status =
CASE
	WHEN flavored_tobacco_violation = 'No' AND
	min_price_violation = 'No' AND
	min_size_violation = 'No' AND
	self_service_violation = 'No' AND
	sale_to_minor_violation = 'No' THEN 'Compliant'
	ELSE 'Noncompliant'
	END
	
--Now that we have that, let's see if the updated 
--table has the new column with the new records

SELECT compliance_status FROM compliance_visits

--Let's get a count of how many retailers are
--compliant or noncompliant

SELECT compliance_status, COUNT(compliance_status) FROM compliance_visits
GROUP BY compliance_status

--Now let's perform another join to see the expiration dates
--for the compliant retailers.

SELECT *
FROM compliance_visits c
RIGHT JOIN license_tracking k
ON c.retailer_id=k.retailer_id
WHERE compliance_status = 'Noncompliant'
AND license_expiration_date IS NOT null