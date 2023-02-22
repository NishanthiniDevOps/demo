--
-- Table structure for table employee
--

CREATE TABLE employee1 (
    id        char(5),
    employee_name       varchar(100),
    employee_salary         integer,
  employee_age        integer,
    CONSTRAINT code_titlee PRIMARY KEY(id)
);
--
-- Dumping data for table employee
--

INSERT INTO employee1 (id, employee_name, employee_salary, employee_age) VALUES
(1, 'Tiger Nixon', 320800, 61),
(2, 'Garrett Winters', 170750, 63),
(3, 'Ashton Cox', 86000, 66),
(4, 'Cedric Kelly', 433060, 22),
(5, 'Airi Satou', 162700, 33);
