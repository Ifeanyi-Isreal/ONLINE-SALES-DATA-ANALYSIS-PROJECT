# ONLINE-SALES-DATA-ANALYSIS-PROJECT
This project involved analysing an online retail dataset to understand sales performance, customer behaviour, product performance and order outcomes. SQL and Excel were used to explore and validate the data, while Power BI and DAX were used to develop an interactive dashboard and communicate the key findings.
The analysis focused on answering practical business questions around revenue, customers, products, orders, cancellations and profitability.

# Business Objective
The objective was to transform the raw transaction data into meaningful business insights that could help the business understand its sales performance, identify areas of concern and make better decisions around customers, products and orders.

# Challenges Encountered and How They Were Resolved
## Customer Location Inconsistency
During the SQL analysis, we discovered that some customers appeared to have transactions associated with more than one location. Rather than immediately treating this as an error, we investigated the customer and transaction records to understand whether the issue was caused by duplicate customers, changes in customer location, or multiple transaction records.

This demonstrated the importance of examining the underlying records before cleaning or removing data, because the same customer appearing in different locations does not automatically mean that the data is incorrect.

## Identifying Completed and Cancelled Orders

The dataset did not simply provide a straightforward business explanation of completed and cancelled orders. Through SQL exploration of the order/invoice identifiers, we identified a pattern that allowed cancelled transactions to be distinguished from completed transactions.

This was then used to create an Order Status classification so that completed and cancelled orders could be analysed separately.

## Unexpected 50/50 Order Status Result

The initial order-status analysis showed approximately 50% completed and 50% cancelled orders, which appeared unusual.
Instead of accepting the result, we investigated the calculation and recognised that the transaction-level structure of the dataset meant that multiple rows could belong to the same order. We therefore reviewed the calculation and changed the analysis to use distinct orders rather than simply counting transaction rows.

After correcting and validating the calculation, the result became:

Completed Orders: 82.35%
Cancelled Orders: 17.65%

This was an important lesson in validating analytical results before using them for business decisions.

## Negative Profit

During the SQL analysis, we also identified transactions with negative profit.
Rather than treating negative values simply as data errors, we considered their business meaning. A negative-profit transaction means that the business generated a loss on that transaction after considering the relevant sales and cost relationship.

We then considered its relationship with cancelled orders. A cancelled order may not necessarily represent a realised sale, and therefore its associated revenue and profit should not automatically be interpreted as normal completed business performance.

This led to an important analytical distinction between:

_transactions recorded in the dataset and transactions that represent successfully completed business activity._

The negative-profit analysis therefore became an area for further investigation rather than simply removing the negative values.

# Key Findings
The analysis showed that the business generated approximately 17.32M in revenue, with approximately 36K orders and 6K customers.

Revenue increased significantly from approximately 0.69M in 2009 to 8.72M in 2010, before declining to approximately 7.92M in 2011. This indicates strong initial growth followed by a decline that requires further investigation.

November recorded the highest monthly revenue at approximately 2.3M, suggesting that seasonal purchasing patterns may have influenced sales performance.

The analysis also produced a 71.99% repeat customer rate, showing that returning customers represented a significant proportion of the customer base based on the project's defined measure.

After validating the order-status calculation, 82.35% of orders were completed while 17.65% were cancelled.

The analysis also identified negative-profit transactions, highlighting that high sales value does not necessarily mean that every transaction is profitable.

# Business Insights
The analysis indicates that the business experienced substantial growth between 2009 and 2010 but subsequently experienced a decline in revenue. Understanding the factors behind this decline should therefore be a priority.

The high repeat-customer rate suggests that customer retention is an important part of the business, and further analysis could determine what products or markets contribute most to repeat purchases.

The 17.65% cancellation rate is significant and should be investigated to determine whether cancellations are concentrated around particular products, customers, countries or periods.

The presence of negative-profit transactions also demonstrates the importance of analysing profitability alongside revenue. A product or order generating high revenue may still be financially undesirable if its associated costs result in a loss.

# Recommendations

The business should investigate the reasons for the revenue decline after 2010 by analysing product, customer, country and order trends.

The 17.65% cancellation rate should be investigated by product, country and time period to identify patterns that may help reduce cancellations.

Negative-profit transactions should be reviewed to determine whether they are associated with discounting, product costs, cancellations or other operational factors.

High-performing products should receive appropriate attention in inventory and marketing planning, while customer retention should continue to be monitored because repeat customers represent an important part of the business.

Finally, revenue should not be evaluated in isolation. Management should consider revenue, order completion, cancellations and profitability together when assessing business performance.

# Conclusion

This project demonstrated that effective data analysis goes beyond writing SQL queries or creating Power BI visuals. The analysis required us to question unexpected results, investigate the underlying data, validate calculations and interpret the numbers from a business perspective.

The project provided insights into revenue trends, customer behaviour, product performance, order completion, cancellations and profitability while also identifying areas requiring further investigation.
Moreover, 

## Analytical Approach:
_When an unexpected result appeared, we did not immediately assume that the data was wrong. We first examined the structure of the data, investigated the possible causes, evaluated the business meaning of the result, corrected the calculation where necessary, and then validated the outcome before using it for decision-making_.
