--CREDIT RISK & LOAN DEFAULT ANALYSIS
--Dataset: Lending Club
-- Records: 100,000
-- Tools: PostgreSQL / pgAdmin
-- Default Flag:
-- 1 = Charged Off or Default
-- 0 = Fully Paid

-- 1. DATA VALIDATION
-- Check total number of records
SELECT 
COUNT(*) AS total_loans
FROM credit_risk_loan_default;

--checking loan status distribution
SELECT
loan_status,
COUNT(*) AS loan_count
FROM credit_risk_loan_default
GROUP BY loan_status
ORDER BY loan_count DESC;

--validate default flag mapping
SELECT
loan_status,default_flag,
COUNT(*) AS loan_count
FROM credit_risk_loan_default
GROUP BY loan_status,default_flag
ORDER BY loan_status,default_flag;

--2. OVERALL RISK PORTFOLIO
--What is the overall size,exposure and observed default risk
--of the loan portfolio?
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

--3. DEFAULT RISK BY CREDIT GRADE
--Which credit grades have the highest observed default rates?
SELECT
grade,
COUNT(*) AS total_loans,
SUM(default_flag) AS total_defaults,
ROUND(AVG(CAST(default_flag AS numeric)) * 100, 2) AS default_rate
FROM credit_risk_loan_default
GROUP BY grade
ORDER BY default_rate DESC;

--4. DEFAULT RISK BY LOAN PURPOSE
--Are certain loan purposes associated with higher observed default rates?
SELECT
purpose,
COUNT(*) AS total_loans,
SUM(default_flag) AS total_defaults,
ROUND(AVG(CAST(default_flag AS numeric)) * 100, 2) AS default_rate
FROM credit_risk_loan_default
GROUP BY purpose
ORDER BY default_rate DESC;

-- 5. DEFAULT RISK BY INCOME BAND
--How does observed default risk vary across borrower income groups?
SELECT
"Income Band",
COUNT(*) AS total_loans,
SUM(default_flag) AS total_defaults,
ROUND(AVG(CAST(default_flag AS numeric)) * 100, 2) AS default_rate
FROM credit_risk_loan_default
GROUP BY "Income Band"
ORDER BY default_rate DESC;

-- 6. DEFAULT RISK BY EMPLOYMENT LENGTH
--Is employment length associated with differences in observed
--default rates?
SELECT
emp_length,
COUNT(*) AS total_loans,
SUM(default_flag) AS total_defaults,
ROUND(AVG(CAST(default_flag AS numeric)) * 100, 2) AS default_rate
FROM credit_risk_loan_default
GROUP BY emp_length
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
--Do borrowers with different loan outcomes have different
--debt-to-income ratios?
--DTI represents borrower indebtedness relative to income.
SELECT
loan_status,
COUNT(*) AS loan_count,
ROUND(AVG(dti), 2) AS average_dti,
ROUND(MAX(dti), 2) AS maximum_dti
FROM credit_risk_loan_default
GROUP BY loan_status
ORDER BY average_dti DESC;

-- 9. DEFAULT RISK BY LOAN TERM
--Is loan term associated with different observed default rates?
SELECT
term,
COUNT(*) AS total_loans,
SUM(default_flag) AS total_defaults,
ROUND(AVG(CAST(default_flag AS numeric)) * 100, 2) AS default_rate
FROM credit_risk_loan_default
GROUP BY term
ORDER BY default_rate DESC;

-- 10. DEFAULT RISK BY HOME OWNERSHIP
--How does observed default risk vary across home-ownership categories?
SELECT
home_ownership,
COUNT(*) AS total_loans,
SUM(default_flag) AS total_defaults,
ROUND(AVG(CAST(default_flag AS numeric)) * 100, 2) AS default_rate
FROM credit_risk_loan_default
GROUP BY home_ownership
ORDER BY default_rate DESC;

-- 11. DEFAULT RISK BY VERIFICATION STATUS
--Does borrower income verification status correspond to different 
--observed default rates?
SELECT
verification_status,
COUNT(*) AS total_loans,
SUM(default_flag) AS total_defaults,
ROUND(AVG(CAST(default_flag AS numeric)) * 100, 2) AS default_rate
FROM credit_risk_loan_default
GROUP BY verification_status
ORDER BY default_rate DESC;

-- 12. DEFAULTED LOAN EXPOSURE
--How much loan exposure is associated with defaulted loans?
SELECT
COUNT(*) AS defaulted_loans,
ROUND(SUM(loan_amnt), 2) AS total_defaulted_exposure,
ROUND(AVG(loan_amnt), 2) AS average_defaulted_loan
FROM credit_risk_loan_default
WHERE default_flag = 1;

-- 13. TOP 10 HIGH-RISK BORROWER SEGMENTS
SELECT
grade,
"Income Band",
COUNT(*) AS total_loans,
SUM(default_flag) AS total_defaults,
ROUND(AVG(CAST(default_flag AS numeric)) * 100, 2) AS default_rate
FROM credit_risk_loan_default
GROUP BY grade,"Income Band"
HAVING COUNT(*) >= 100
ORDER BY default_rate DESC
LIMIT 10;

-- 14. DEFAULT RISK BY INTEREST-RATE BAND
--How does observed default risk vary across interest-rate bands?
SELECT
CASE
WHEN int_rate < 10 THEN '<10%'
WHEN int_rate < 15 THEN '10%-15%'
WHEN int_rate < 20 THEN '15%-20%'
ELSE '20%+'
END AS interest_rate_band,

COUNT(*) AS total_loans,
SUM(default_flag) AS total_defaults,
ROUND(AVG(CAST(default_flag AS numeric)) * 100,2) AS default_rate

FROM credit_risk_loan_default

GROUP BY
CASE
WHEN int_rate < 10 THEN '<10%'
WHEN int_rate < 15 THEN '10%-15%'
WHEN int_rate < 20 THEN '15%-20%'
ELSE '20%+'
END

ORDER BY default_rate DESC;




