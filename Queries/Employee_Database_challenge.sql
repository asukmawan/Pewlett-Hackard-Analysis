-- The Retiring Employees by Title
SELECT e.emp_no,
	e.first_name,
	e.last_name,
	t.title,
	t.from_date,
	t.to_date
INTO retirement_titles
FROM employees as e
	INNER JOIN titles as t
		ON (e.emp_no = t.emp_no)
		WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
		ORDER BY e.emp_no;
SELECT * FROM retirement_titles	

-- Use Distinct with Orderby to remove duplicate rows - The DISTINCT ON statement will retrieve the first occurrence of the employee number for each set of rows defined by the ON () clause 
-- because the first row of each duplicate holds the most recent title of each employee(which we will use ORDER BY), we can isolate their most recent title and exclude any past positions they may have held
SELECT DISTINCT ON (emp_no) emp_no,
first_name,
last_name,
title
INTO unique_titles
FROM retirement_titles
ORDER BY emp_no, to_date DESC;


-- Retrieve the number of employees by their most recent job title who are about to retire

SELECT COUNT (emp_no),
title
INTO retiring_titles
FROM unique_titles
GROUP BY title
ORDER BY COUNT(emp_no) DESC;
