-- Creating tables 
-- Create tables for PH-EmployeeDB
CREATE TABLE departments (
     dept_no VARCHAR(4) NOT NULL,
     dept_name VARCHAR(40) NOT NULL,
     PRIMARY KEY (dept_no),
     UNIQUE (dept_name)
);
CREATE TABLE employees (
	 emp_no INT NOT NULL,
     birth_date DATE NOT NULL,
     first_name VARCHAR NOT NULL,
     last_name VARCHAR NOT NULL,
     gender VARCHAR NOT NULL,
     hire_date DATE NOT NULL,
     PRIMARY KEY (emp_no)
);
CREATE TABLE dept_manager (
	dept_no VARCHAR(4) NOT NULL,
	emp_no INT NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
	PRIMARY KEY (emp_no, dept_no)
);
CREATE TABLE salaries (
  emp_no INT NOT NULL,
  salary INT NOT NULL,
  from_date DATE NOT NULL,
  to_date DATE NOT NULL,
  FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
  PRIMARY KEY (emp_no)
);
CREATE TABLE dept_emp (
	emp_no INT NOT NULL,
	dept_no VARCHAR(4) NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
	FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
	PRIMARY KEY (emp_no, dept_no)
);
CREATE TABLE titles (
	emp_no INT NOT NULL,
	title VARCHAR(40) NOT NULL,
	from_date DATE NOT NULL,
	to_date DATE NOT NULL
);

SELECT * FROM titles;

SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1952-01-01' AND '1955-12-31';

SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1952-01-01' AND '1952-12-31';

-- Retirement eligibility
SELECT first_name, last_name
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Count of Retirement eligibility - Number of employees retiring
SELECT COUNT(first_name)
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Create a new table - retirement_info
SELECT first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Check our newly created table
SELECT * FROM retirement_info;

-- Recreate the retirement_info Table with the emp_no Column
-- First we need to drop the existing table so we can create a new one to include the emp_no
DROP TABLE retirement_info;

-- Create new table for retiring employees
SELECT emp_no, first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');
-- Check the table
SELECT * FROM retirement_info;


--
-- JOINS
-- Use Inner Join for Departments and dept-manager Tables
-- Joining departments and dept_manager tables
SELECT departments.dept_name,
     dept_manager.emp_no,
     dept_manager.from_date,
     dept_manager.to_date
FROM departments
-- The FROM statement points to the first table to be joined, Departments (Table 1).
INNER JOIN dept_manager
-- INNER JOIN points to the second table to be joined, dept_manager (Table 2).
ON departments.dept_no = dept_manager.dept_no;
-- this line indicates where Postgres should look for matches.

-- Use Left Join to capture retirement_info table
-- Joining retirement_info and dept_emp tables
SELECT retirement_info.emp_no,
	retirement_info.first_name,
	retirement_info.last_name,
	dept_emp.to_date
FROM retirement_info
LEFT JOIN dept_emp
ON retirement_info.emp_no = dept_emp.emp_no;


--
-- ALIASES
-- An alias in SQL allows developers to give nicknames to tables. This helps improve code readability by shortening longer names into one-, two-, or three-letter temporary names. This is commonly used in joins because multiple tables and columns are often listed
-- Use aliases on the previous join query
SELECT ri.emp_no,
	ri.first_name,
	ri.last_name,
	de.to_date
FROM retirement_info as ri
LEFT JOIN dept_emp as de
ON ri.emp_no = de.emp_no;
	
-- Use aliases on the inner join table combining departments and dept_manager tables
-- Joining departments and dept_manager tables with aliases
SELECT d.dept_name,
     dm.emp_no,
     dm.from_date,
     dm.to_date
FROM departments AS d
INNER JOIN dept_manager AS dm
ON d.dept_no = dm.dept_no;

-- Create a new table containing only the current employees who are eligible for retirement
-- Use Left Join for retirement_info and dept_emp tables
SELECT ri.emp_no,
	ri.first_name,
	ri.last_name,
	de.to_date
-- Create new table to hold the info - name it as current_emp
INTO current_emp
FROM retirement_info as ri
LEFT JOIN dept_emp as de
ON ri.emp_no = de.emp_no
-- Conditional to only filter to dates are 9999-01-01
WHERE de.to_date = ('9999-01-01');
-- Check table
SELECT * FROM current_emp;


--
-- Count, Group By, and Order By
-- Employee count by department number - for all current employees
SELECT COUNT(ce.emp_no), de.dept_no 
FROM current_emp AS ce
LEFT JOIN dept_emp AS de
ON ce.emp_no = de.emp_no
GROUP BY de.dept_no;
-- The result is out of order - we can correct this with ORDER BY

-- ORDER BY
SELECT COUNT(ce.emp_no), de.dept_no 
FROM current_emp AS ce
LEFT JOIN dept_emp AS de
ON ce.emp_no = de.emp_no
GROUP BY de.dept_no
ORDER BY de.dept_no;

-- Create it as a new table and export to csv
SELECT COUNT(ce.emp_no), de.dept_no 
INTO dept_emp_count
FROM current_emp AS ce
LEFT JOIN dept_emp AS de
ON ce.emp_no = de.emp_no
GROUP BY de.dept_no
ORDER BY de.dept_no;


-- Create additional lists
-- 1. Employee Information: A list of employees containing their unique employee number, their last name, first name, gender,to_date, and salary
-- 2. Management: A list of managers for each department, including the department number, name, and the manager's employee number, last name, first name, and the starting and ending employment dates
-- 3. Department Retirees: An updated current_emp list that includes everything it currently has, but also the employee's departments

-- 1. Employee Info - Tables Employees and salaries - emp_no as primary key
-- check the salaries table
SELECT * FROM salaries;
-- organize salares by to_date decending
SELECT * FROM salaries
ORDER BY to_date DESC;

-- dates in the salaries are not related to the most recent date of employment but of all salaries given from the 'begining of time'
-- the dates we want are current salaries of current employees, and the dates from the dept_emp table
-- Join more than two tables
SELECT e.emp_no, 
	e.first_name, 
	e.last_name,
	e.gender,
	de.to_date
-- create a new table
INTO emp_info
FROM employees as e
INNER JOIN salaries as s
ON (e.emp_no = s.emp_no)
INNER JOIN dept_emp as de
ON (e.emp_no = de.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (e.hire_date BETWEEN '1985-01-01' AND '1988-12-31')
AND (de.to_date = '9999-01-01');

-- 2. Management
-- looking at retiring managers 
-- we want department no and name, employee number, first name, last name, and their starting and ending employment dates
-- tables needed - departments, managers, employees
-- we can use current_emp instead of employees to get just the current employees. then departments and dept_manager for the other two

-- List of managers per department
SELECT dm.dept_no,
	d.dept_name,
	dm.emp_no,	
	ce.first_name,
	ce.last_name,
	dm.from_date,
	dm.to_date
INTO manager_info
FROM dept_manager as dm
	INNER JOIN departments as d
		ON (dm.dept_no = d.dept_no)
	INNER JOIN current_emp as ce
		ON (dm.emp_no = ce.emp_no);
	
-- 3. Department Retirees
-- add departments to the current_emp table
-- use inner joins on the current_emp, departments, and dept_emp to include the list of columns we'll need
SELECT ce.emp_no,
	ce.first_name,
	ce.last_name,
	d.dept_name
INTO dept_info
FROM current_emp as ce
	INNER JOIN dept_emp as de
		ON (ce.emp_no = de.emp_no)
	INNER JOIN departments as d
		ON (de.dept_no = d.dept_no);

-- Issues:
-- 1. What's going on with the salaries?
-- 2. Why are there only five active managers for nine departments?
-- 3. Why are some employees appearing twice?

-- new list to contain everything in the retirement_info table, only tailored for the Sales team.
-- include = Employee numbers, Employee first name, Employee last name, Employee department name
SELECT ri.emp_no,
	ri.first_name,
	ri.last_name,
	d.dept_name
INTO retirement_sales
FROM retirement_info as ri
	LEFT JOIN dept_emp as de
		ON(ri.emp_no = de.emp_no)
	LEFT JOIN departments as d
		ON(de.dept_no = d.dept_no)
WHERE (dept_name = 'Sales');

SELECT * FROM retirement_sales

-- new list of retiring employees in both the Sales and Development departments
SELECT ri.emp_no,
	ri.first_name,
	ri.last_name,
	d.dept_name
INTO retirement_sales_development
FROM retirement_info as ri
	LEFT JOIN dept_emp as de
		ON(ri.emp_no = de.emp_no)
	LEFT JOIN departments as d
		ON(de.dept_no = d.dept_no)
WHERE dept_name IN ('Sales','Development');

SELECT * FROM retirement_sales_development
