#Q2 Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year. (SQL)
SELECT CustomerId, Surname, EstimatedSalary FROM customerinfo
WHERE QUARTER(Bank_DOJ) = 4
ORDER BY EstimatedSalary DESC
LIMIT 5;

#Q3 Calculate the average number of products used by customers who have a credit card. (SQL)
SELECT AVG(NumOfProducts) as product_avg
FROM bank_churn
WHERE HasCrCard = 1;

#Q5 Compare the average credit score of customers who have exited and those who remain. (SQL)
SELECT
AVG(CASE WHEN Exited = 1 THEN CreditScore ELSE Null END) as Avg_Exited_Score,
AVG(CASE WHEN Exited = 0 THEN CreditScore ELSE Null END) as Avg_Remain_Score
FROM bank_churn;

#Q6 Which gender has a higher average estimated salary, and how does it relate to the number of active accounts? (SQL)
SELECT g.GenderCategory,
ROUND(AVG(c.EstimatedSalary),2) AS Avg_Salary,
COUNT(DISTINCT b.CustomerId ) AS Num_Active_Accounts
FROM bank_churn b 
JOIN customerinfo c ON b.CustomerId=c.CustomerId
JOIN gender g ON c.GenderID=g.GenderID
WHERE IsActiveMember = 1
GROUP BY g.GenderCategory
ORDER BY Avg_Salary DESC;

#Q7 Segment the customers based on their credit score and identify the segment with the highest exit rate. (SQL)
WITH Customer_Segments AS (
    SELECT
        b.CustomerId,
        CASE
            WHEN b.CreditScore < 580 THEN 'Deep Subprime'
            WHEN b.CreditScore  >= 580 AND b.CreditScore < 620 THEN 'Subprime'
            WHEN b.CreditScore  >= 620 AND b.CreditScore < 660 THEN 'Near Prime'
            WHEN b.CreditScore  >= 660 AND b.CreditScore < 720 THEN 'Prime'
            ELSE 'Superprime'
        END AS Credit_Segment
    FROM bank_churn b
)
SELECT
    Credit_Segment,
    ROUND(AVG(Exited)*100,2) AS Exit_Rate
FROM Customer_Segments cs
JOIN bank_churn b ON cs.customerId = b.CustomerId
GROUP BY Credit_Segment
ORDER BY Credit_Segment ASC
LIMIT 1;

#Q8 Find out which geographic region has the highest number of active customers with a tenure greater than 5 years. (SQL)
SELECT c.GeographyID, 
COUNT(c.CustomerId) AS Active_Customers
FROM customerinfo c
JOIN bank_churn b ON c.CustomerId = b.CustomerId
WHERE b.IsActiveMember = 1 AND b.Tenure > 5
GROUP BY c.GeographyID
ORDER BY Active_Customers DESC;

#Q11 Examine the trend of customers joining over time and identify any seasonal patterns (yearly or monthly). Prepare the data through SQL and then visualize it.
select year(Bank_DOJ) as year, 
count(c.CustomerId) as count_customer_churn
from bank_churn b 
inner join customerinfo c ON b.CustomerId= c.CustomerId
where Exited= 1
group by year(Bank_DOJ);

#Q15 Using SQL, write a query to find out the gender-wise average income of males and females in each geography id. Also, rank the gender according to the average value. (SQL)
WITH Gender_Income AS (
    SELECT
        c.GeographyID,
        CASE WHEN c.GenderID = 1 THEN 'Male' ELSE 'Female' END AS Gender,
        ROUND(AVG(c.EstimatedSalary),2) AS Avg_Income
    FROM customerinfo c
    GROUP BY c.GeographyID, Gender
)
SELECT
GeographyID,
Gender,
Avg_Income,
RANK() OVER(PARTITION BY GeographyID ORDER BY Avg_Income DESC) AS Gender_Rank
FROM Gender_Income
ORDER BY GeographyID, Gender_Rank;

#Q16 Using SQL, write a query to find out the average tenure of the people who have exited in each age bracket (18-30, 30-50, 50+).
SELECT 
    CASE 
        WHEN c.Age BETWEEN 18 AND 30 THEN '18-30'
        WHEN c.Age BETWEEN 31 AND 50 THEN '31-50' 
        ELSE '51+' 
    END AS Age_Group,
    ROUND(AVG(Tenure),2) AS Avg_Tenure
FROM customerinfo c
JOIN bank_churn b ON c.CustomerId = b.CustomerId
WHERE Exited = 1
GROUP BY Age_Group
ORDER BY Age_Group;

#Q22 As we can see that the “CustomerInfo” table has the CustomerID and Surname, now if we have to join it with a table where the primary key is also a combination of CustomerID and Surname, come up with a column where the format is “CustomerID_Surname”.
select 
c.CustomerId,
c.Surname,
concat(c.CustomerId,'_',c.Surname) as CustomerId_Surname
from customerinfo c
join bank_churn b on c.CustomerId = b.CustomerId;

#Q23 Without using “Join”, can we get the “ExitCategory” from ExitCustomers table to Bank_Churn table? If yes do this using SQL.
SELECT *,
CASE WHEN Exited = 0 THEN 'Retain' ELSE 'Exit' END AS Exit_Catagory
FROM bank_churn;

#Q25 Write the query to get the customer IDs, their last name, and whether they are active or not for the customers whose surname ends with “on
SELECT c.CustomerID, c.Surname AS last_name,
CASE WHEN b.IsActiveMember = 1 THEN 'Active' ELSE 'Inactive' END AS Active_status
FROM customerinfo c 
JOIN bank_churn b ON c.CustomerId=b.CustomerId
WHERE c.Surname LIKE '%on'
ORDER BY c.Surname;

#Subjective Questions

#Q9. Utilize SQL queries to segment customers based on demographics and account details.
SELECT g.GeographyLocation,
CASE WHEN EstimatedSalary < 50000 THEN 'Low'
WHEN EstimatedSalary < 100000 THEN 'Medium'
ELSE 'High'
END AS Income_Segment,
CASE WHEN GenderID = 1 THEN 'Male'
ELSE 'Female'
END AS gender, age,
COUNT(c.CustomerId) as Number_of_customers
FROM customerinfo c
JOIN geography g on c.GeographyID= g.GeographyID
GROUP BY Income_Segment,g.GeographyLocation,gender,age
ORDER BY g.GeographyLocation,age;




#Q14 In the “Bank_Churn” table how can you modify the name of the “HasCrCard” column to “Has_creditcard”?
ALTER TABLE bank_churn
RENAME COLUMN HasCrCard TO Has_creditcard;
SELECT * FROM bank_churn;



