-- CREDIT RISK & LOAN DEFAULT ANALYSIS
-- Dataset: Lending Club
-- Records: 100,000
-- Tools: PostgreSQL / pgAdmin
-- Default Flag:
-- 1 = Charged Off or Default
-- 0 = Fully Paid
-- Note: All bands below match the bands used in the Python notebook,
-- so the numbers can be compared directly.

-- 1. DATA VALIDATION
-- Check total number of records
SELECT
COUNT(*) AS total_loans
FROM credit_risk_loan_default;

-- Checking loan status distribution
SELECT
loan_status,
COUNT(*) AS loan_count
FROM credit_risk_loan_default
GROUP BY loan_status
ORDER BY loan_count DESC;

-- Validate default flag mapping
SELECT
loan_status, default_flag,
COUNT(*) AS loan_count
FROM credit_risk_loan_default
GROUP BY loan_status, default_flag
ORDER BY loan_status, default_flag;

-- 1A. DATA QUALITY CHECKS
-- How many values are missing in key columns?
-- COUNT(column) skips NULLs, so COUNT(*) - COUNT(column) = number of missing values.
SELECT
COUNT(*) - COUNT(emp_length) AS missing_emp_length,
COUNT(*) - COUNT(dti) AS missing_dti,
COUNT(*) - COUNT(revol_util) AS missing_revol_util,
COUNT(*) - COUNT(annual_inc) AS missing_annual_inc
FROM credit_risk_loan_default;

-- Are there any unusual values?
-- DTI above 100% or zero income are likely data errors or special cases.
SELECT
SUM(CASE WHEN dti > 100 THEN 1 ELSE 0 END) AS dti_above_100,
MAX(dti) AS maximum_dti,
SUM(CASE WHEN annual_inc = 0 THEN 1 ELSE 0 END) AS zero_income_loans
FROM credit_risk_loan_default;

-- 2. OVERALL RISK PORTFOLIO
-- What is the overall size, exposure and observed default risk
-- of the loan portfolio?
SELECT
COUNT(*) AS total_loans,
SUM(default_flag) AS total_defaults,
COUNT(*) - SUM(default_flag) AS non_defaults,
ROUND(AVG(CAST(default_flag AS numeric)) * 100, 2) AS default_rate,
ROUND(SUM(loan_amnt), 2) AS total_loan_amount,
ROUND(AVG(loan_amnt), 2) AS average_loan_amount,
ROUND(MIN(loan_amnt), 2) AS minimum_loan_amount,
ROUND(MAX(loan_amnt), 2) AS maximum_loan_amount
FROM credit_risk_loan_default;

-- 3. DEFAULT RISK BY CREDIT GRADE
-- Which credit grades have the highest observed default rates?
-- (Grade is the lender's own rating, so it is studied here but not used in the scorecard.)
SELECT
grade,
COUNT(*) AS total_loans,
SUM(default_flag) AS total_defaults,
ROUND(AVG(CAST(default_flag AS numeric)) * 100, 2) AS default_rate
FROM credit_risk_loan_default
GROUP BY grade
ORDER BY default_rate DESC;

-- 4. DEFAULT RISK BY LOAN PURPOSE
-- Are certain loan purposes associated with higher observed default rates?
SELECT
purpose,
COUNT(*) AS total_loans,
SUM(default_flag) AS total_defaults,
ROUND(AVG(CAST(default_flag AS numeric)) * 100, 2) AS default_rate
FROM credit_risk_loan_default
GROUP BY purpose
ORDER BY default_rate DESC;

-- 5. DEFAULT RISK BY INCOME BAND
-- How does observed default risk vary across borrower income groups?
-- Same five bands as the Python notebook.
SELECT
CASE
WHEN annual_inc < 40000 THEN '1. < $40k'
WHEN annual_inc < 60000 THEN '2. $40k-$60k'
WHEN annual_inc < 80000 THEN '3. $60k-$80k'
WHEN annual_inc < 100000 THEN '4. $80k-$100k'
ELSE '5. $100k+'
END AS income_band,
COUNT(*) AS total_loans,
SUM(default_flag) AS total_defaults,
ROUND(AVG(CAST(default_flag AS numeric)) * 100, 2) AS default_rate
FROM credit_risk_loan_default
GROUP BY income_band
ORDER BY income_band;

-- 6. DEFAULT RISK BY EMPLOYMENT LENGTH
-- Is employment length associated with differences in observed
-- default rates?
-- COALESCE replaces a blank (NULL) value with 'Missing', like the notebook.
SELECT
COALESCE(emp_length, 'Missing') AS employment_length,
COUNT(*) AS total_loans,
SUM(default_flag) AS total_defaults,
ROUND(AVG(CAST(default_flag AS numeric)) * 100, 2) AS default_rate
FROM credit_risk_loan_default
GROUP BY employment_length
ORDER BY default_rate DESC;

-- 7. INTEREST RATE BY LOAN OUTCOME
-- Do interest rates differ across loan outcomes?
SELECT
loan_status,
COUNT(*) AS loan_count,
ROUND(AVG(int_rate), 2) AS average_interest_rate,
ROUND(MIN(int_rate), 2) AS minimum_interest_rate,
ROUND(MAX(int_rate), 2) AS maximum_interest_rate
FROM credit_risk_loan_default
GROUP BY loan_status
ORDER BY average_interest_rate DESC;

-- 8. DTI BY LOAN OUTCOME
-- Do borrowers with different loan outcomes have different
-- debt-to-income ratios?
-- DTI represents borrower indebtedness relative to income.
-- A few DTI values are extreme (up to 999), which pull the average up,
-- so we also show the average after leaving out DTI above 100.
SELECT
loan_status,
COUNT(*) AS loan_count,
ROUND(AVG(dti), 2) AS average_dti,
ROUND(AVG(CASE WHEN dti <= 100 THEN dti END), 2) AS average_dti_excl_extremes,
ROUND(MAX(dti), 2) AS maximum_dti
FROM credit_risk_loan_default
GROUP BY loan_status
ORDER BY average_dti DESC;

-- 9. DEFAULT RISK BY DTI BAND
-- Does observed default risk rise as borrowers carry more debt?
-- Same five bands as the Python notebook.
SELECT
CASE
WHEN dti IS NULL THEN '6. Missing'
WHEN dti < 10 THEN '1. <10'
WHEN dti < 20 THEN '2. 10-20'
WHEN dti < 30 THEN '3. 20-30'
WHEN dti < 40 THEN '4. 30-40'
ELSE '5. 40+'
END AS dti_band,
COUNT(*) AS total_loans,
SUM(default_flag) AS total_defaults,
ROUND(AVG(CAST(default_flag AS numeric)) * 100, 2) AS default_rate
FROM credit_risk_loan_default
GROUP BY dti_band
ORDER BY dti_band;

-- 10. DEFAULT RISK BY LOAN TERM
-- Is loan term associated with different observed default rates?
SELECT
term,
COUNT(*) AS total_loans,
SUM(default_flag) AS total_defaults,
ROUND(AVG(CAST(default_flag AS numeric)) * 100, 2) AS default_rate
FROM credit_risk_loan_default
GROUP BY term
ORDER BY default_rate DESC;

-- 11. DEFAULT RISK BY HOME OWNERSHIP
-- How does observed default risk vary across home-ownership categories?
SELECT
home_ownership,
COUNT(*) AS total_loans,
SUM(default_flag) AS total_defaults,
ROUND(AVG(CAST(default_flag AS numeric)) * 100, 2) AS default_rate
FROM credit_risk_loan_default
GROUP BY home_ownership
ORDER BY default_rate DESC;

-- 12. DEFAULT RISK BY VERIFICATION STATUS
-- Does borrower income verification status correspond to different
-- observed default rates?
SELECT
verification_status,
COUNT(*) AS total_loans,
SUM(default_flag) AS total_defaults,
ROUND(AVG(CAST(default_flag AS numeric)) * 100, 2) AS default_rate
FROM credit_risk_loan_default
GROUP BY verification_status
ORDER BY default_rate DESC;

-- 13. DEFAULT RISK BY REVOLVING CREDIT UTILISATION
-- Do borrowers using more of their credit-card limit default more often?
-- Same bands as the scorecard in the Python notebook.
SELECT
CASE
WHEN revol_util IS NULL THEN '6. Missing'
WHEN revol_util < 20 THEN '1. <20%'
WHEN revol_util < 40 THEN '2. 20-40%'
WHEN revol_util < 60 THEN '3. 40-60%'
WHEN revol_util < 80 THEN '4. 60-80%'
ELSE '5. 80%+'
END AS revol_util_band,
COUNT(*) AS total_loans,
SUM(default_flag) AS total_defaults,
ROUND(AVG(CAST(default_flag AS numeric)) * 100, 2) AS default_rate
FROM credit_risk_loan_default
GROUP BY revol_util_band
ORDER BY revol_util_band;

-- 14. DEFAULT RISK BY RECENT CREDIT ENQUIRIES
-- Do borrowers who applied for credit many times in the last
-- 6 months default more often?
SELECT
CASE
WHEN inq_last_6mths = 0 THEN '0'
WHEN inq_last_6mths = 1 THEN '1'
WHEN inq_last_6mths = 2 THEN '2'
ELSE '3+'
END AS enquiries_last_6_months,
COUNT(*) AS total_loans,
SUM(default_flag) AS total_defaults,
ROUND(AVG(CAST(default_flag AS numeric)) * 100, 2) AS default_rate
FROM credit_risk_loan_default
GROUP BY enquiries_last_6_months
ORDER BY enquiries_last_6_months;

-- 15. DEFAULT RISK BY INTEREST-RATE BAND
-- How does observed default risk vary across interest-rate bands?
-- Same five bands as the Python notebook.
SELECT
CASE
WHEN int_rate < 10 THEN '1. <10%'
WHEN int_rate < 15 THEN '2. 10%-15%'
WHEN int_rate < 20 THEN '3. 15%-20%'
WHEN int_rate < 25 THEN '4. 20%-25%'
ELSE '5. 25%+'
END AS interest_rate_band,
COUNT(*) AS total_loans,
SUM(default_flag) AS total_defaults,
ROUND(AVG(CAST(default_flag AS numeric)) * 100, 2) AS default_rate
FROM credit_risk_loan_default
GROUP BY interest_rate_band
ORDER BY interest_rate_band;

-- 16. DEFAULT RISK BY ISSUE YEAR
-- Do loans issued in different years show different default rates?
-- issue_d looks like 'Aug-16', so its last two characters give the year.
-- (Supports the out-of-time check and the finished-loans limitation in the notebook.)
SELECT
'20' || RIGHT(issue_d, 2) AS issue_year,
COUNT(*) AS total_loans,
SUM(default_flag) AS total_defaults,
ROUND(AVG(CAST(default_flag AS numeric)) * 100, 2) AS default_rate
FROM credit_risk_loan_default
GROUP BY issue_year
ORDER BY issue_year;

-- 17. DEFAULTED LOAN EXPOSURE
-- How much loan exposure is associated with defaulted loans?
SELECT
COUNT(*) AS defaulted_loans,
ROUND(SUM(loan_amnt), 2) AS total_defaulted_exposure,
ROUND(AVG(loan_amnt), 2) AS average_defaulted_loan
FROM credit_risk_loan_default
WHERE default_flag = 1;

-- 18. TOP 10 HIGH-RISK BORROWER SEGMENTS
-- Which combinations of grade and income band default the most?
-- Only segments with at least 100 loans are shown, so small groups
-- don't appear risky just by chance.
SELECT
grade,
CASE
WHEN annual_inc < 40000 THEN '1. < $40k'
WHEN annual_inc < 60000 THEN '2. $40k-$60k'
WHEN annual_inc < 80000 THEN '3. $60k-$80k'
WHEN annual_inc < 100000 THEN '4. $80k-$100k'
ELSE '5. $100k+'
END AS income_band,
COUNT(*) AS total_loans,
SUM(default_flag) AS total_defaults,
ROUND(AVG(CAST(default_flag AS numeric)) * 100, 2) AS default_rate
FROM credit_risk_loan_default
GROUP BY grade, income_band
HAVING COUNT(*) >= 100
ORDER BY default_rate DESC
LIMIT 10;
