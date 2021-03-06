--------------------------------------------------------
--  DDL for Table EMPLOYEES
--------------------------------------------------------

CREATE TABLE EMPLOYEES
(	EMPLOYEE_ID NUMBER(6,0),
   FIRST_NAME VARCHAR2(20),
   LAST_NAME VARCHAR2(25),
   EMAIL VARCHAR2(25),
   PHONE_NUMBER VARCHAR2(20),
   HIRE_DATE DATE
) ;
--------------------------------------------------------
--  DDL for Index EMP_EMAIL_UK
--------------------------------------------------------

CREATE UNIQUE INDEX EMP_EMAIL_UK ON EMPLOYEES (EMAIL)
;
--------------------------------------------------------
--  DDL for Index EMP_EMP_ID_PK
--------------------------------------------------------

CREATE UNIQUE INDEX EMP_EMP_ID_PK ON EMPLOYEES (EMPLOYEE_ID)
;
--------------------------------------------------------
--  DDL for Index EMP_NAME_IX
--------------------------------------------------------

CREATE INDEX EMP_NAME_IX ON EMPLOYEES (LAST_NAME, FIRST_NAME)
;
--------------------------------------------------------
--  Constraints for Table EMPLOYEES
--------------------------------------------------------

ALTER TABLE EMPLOYEES ADD CONSTRAINT EMP_EMP_ID_PK PRIMARY KEY (EMPLOYEE_ID) ENABLE;
ALTER TABLE EMPLOYEES ADD CONSTRAINT EMP_EMAIL_UK UNIQUE (EMAIL) ENABLE;
ALTER TABLE EMPLOYEES MODIFY (HIRE_DATE CONSTRAINT EMP_HIRE_DATE_NN NOT NULL ENABLE);
ALTER TABLE EMPLOYEES MODIFY (EMAIL CONSTRAINT EMP_EMAIL_NN NOT NULL ENABLE);
ALTER TABLE EMPLOYEES MODIFY (LAST_NAME CONSTRAINT EMP_LAST_NAME_NN NOT NULL ENABLE);


SET DEFINE OFF;
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (100,'Steven','King','SKING','515.123.4567',to_date('17-JUN-03','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (101,'Neena','Kochhar','NKOCHHAR','515.123.4568',to_date('21-SEP-05','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (102,'Lex','De Haan','LDEHAAN','515.123.4569',to_date('13-JAN-01','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (103,'Alexander','Hunold','AHUNOLD','590.423.4567',to_date('03-JAN-06','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (104,'Bruce','Ernst','BERNST','590.423.4568',to_date('21-MAY-07','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (105,'David','Austin','DAUSTIN','590.423.4569',to_date('25-JUN-05','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (106,'Valli','Pataballa','VPATABAL','590.423.4560',to_date('05-FEB-06','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (107,'Diana','Lorentz','DLORENTZ','590.423.5567',to_date('07-FEB-07','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (108,'Nancy','Greenberg','NGREENBE','515.124.4569',to_date('17-AUG-02','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (109,'Daniel','Faviet','DFAVIET','515.124.4169',to_date('16-AUG-02','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (110,'John','Chen','JCHEN','515.124.4269',to_date('28-SEP-05','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (111,'Ismael','Sciarra','ISCIARRA','515.124.4369',to_date('30-SEP-05','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (112,'Jose Manuel','Urman','JMURMAN','515.124.4469',to_date('07-MAR-06','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (113,'Luis','Popp','LPOPP','515.124.4567',to_date('07-DEC-07','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (114,'Den','Raphaely','DRAPHEAL','515.127.4561',to_date('07-DEC-02','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (115,'Alexander','Khoo','AKHOO','515.127.4562',to_date('18-MAY-03','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (116,'Shelli','Baida','SBAIDA','515.127.4563',to_date('24-DEC-05','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (117,'Sigal','Tobias','STOBIAS','515.127.4564',to_date('24-JUL-05','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (118,'Guy','Himuro','GHIMURO','515.127.4565',to_date('15-NOV-06','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (119,'Karen','Colmenares','KCOLMENA','515.127.4566',to_date('10-AUG-07','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (120,'Matthew','Weiss','MWEISS','650.123.1234',to_date('18-JUL-04','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (121,'Adam','Fripp','AFRIPP','650.123.2234',to_date('10-APR-05','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (122,'Payam','Kaufling','PKAUFLIN','650.123.3234',to_date('01-MAY-03','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (123,'Shanta','Vollman','SVOLLMAN','650.123.4234',to_date('10-OCT-05','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (124,'Kevin','Mourgos','KMOURGOS','650.123.5234',to_date('16-NOV-07','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (125,'Julia','Nayer','JNAYER','650.124.1214',to_date('16-JUL-05','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (126,'Irene','Mikkilineni','IMIKKILI','650.124.1224',to_date('28-SEP-06','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (127,'James','Landry','JLANDRY','650.124.1334',to_date('14-JAN-07','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (128,'Steven','Markle','SMARKLE','650.124.1434',to_date('08-MAR-08','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (129,'Laura','Bissot','LBISSOT','650.124.5234',to_date('20-AUG-05','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (130,'Mozhe','Atkinson','MATKINSO','650.124.6234',to_date('30-OCT-05','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (131,'James','Marlow','JAMRLOW','650.124.7234',to_date('16-FEB-05','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (132,'TJ','Olson','TJOLSON','650.124.8234',to_date('10-APR-07','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (133,'Jason','Mallin','JMALLIN','650.127.1934',to_date('14-JUN-04','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (134,'Michael','Rogers','MROGERS','650.127.1834',to_date('26-AUG-06','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (135,'Ki','Gee','KGEE','650.127.1734',to_date('12-DEC-07','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (136,'Hazel','Philtanker','HPHILTAN','650.127.1634',to_date('06-FEB-08','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (137,'Renske','Ladwig','RLADWIG','650.121.1234',to_date('14-JUL-03','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (138,'Stephen','Stiles','SSTILES','650.121.2034',to_date('26-OCT-05','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (139,'John','Seo','JSEO','650.121.2019',to_date('12-FEB-06','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (140,'Joshua','Patel','JPATEL','650.121.1834',to_date('06-APR-06','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (141,'Trenna','Rajs','TRAJS','650.121.8009',to_date('17-OCT-03','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (142,'Curtis','Davies','CDAVIES','650.121.2994',to_date('29-JAN-05','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (143,'Randall','Matos','RMATOS','650.121.2874',to_date('15-MAR-06','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (144,'Peter','Vargas','PVARGAS','650.121.2004',to_date('09-JUL-06','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (145,'John','Russell','JRUSSEL','011.44.1344.429268',to_date('01-OCT-04','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (146,'Karen','Partners','KPARTNER','011.44.1344.467268',to_date('05-JAN-05','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (147,'Alberto','Errazuriz','AERRAZUR','011.44.1344.429278',to_date('10-MAR-05','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (148,'Gerald','Cambrault','GCAMBRAU','011.44.1344.619268',to_date('15-OCT-07','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (149,'Eleni','Zlotkey','EZLOTKEY','011.44.1344.429018',to_date('29-JAN-08','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (150,'Peter','Tucker','PTUCKER','011.44.1344.129268',to_date('30-JAN-05','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (151,'David','Bernstein','DBERNSTE','011.44.1344.345268',to_date('24-MAR-05','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (152,'Peter','Hall','PHALL','011.44.1344.478968',to_date('20-AUG-05','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (153,'Christopher','Olsen','COLSEN','011.44.1344.498718',to_date('30-MAR-06','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (154,'Nanette','Cambrault','NCAMBRAU','011.44.1344.987668',to_date('09-DEC-06','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (155,'Oliver','Tuvault','OTUVAULT','011.44.1344.486508',to_date('23-NOV-07','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (156,'Janette','King','JKING','011.44.1345.429268',to_date('30-JAN-04','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (157,'Patrick','Sully','PSULLY','011.44.1345.929268',to_date('04-MAR-04','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (158,'Allan','McEwen','AMCEWEN','011.44.1345.829268',to_date('01-AUG-04','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (159,'Lindsey','Smith','LSMITH','011.44.1345.729268',to_date('10-MAR-05','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (160,'Louise','Doran','LDORAN','011.44.1345.629268',to_date('15-DEC-05','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (161,'Sarath','Sewall','SSEWALL','011.44.1345.529268',to_date('03-NOV-06','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (162,'Clara','Vishney','CVISHNEY','011.44.1346.129268',to_date('11-NOV-05','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (163,'Danielle','Greene','DGREENE','011.44.1346.229268',to_date('19-MAR-07','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (164,'Mattea','Marvins','MMARVINS','011.44.1346.329268',to_date('24-JAN-08','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (165,'David','Lee','DLEE','011.44.1346.529268',to_date('23-FEB-08','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (166,'Sundar','Ande','SANDE','011.44.1346.629268',to_date('24-MAR-08','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (167,'Amit','Banda','ABANDA','011.44.1346.729268',to_date('21-APR-08','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (168,'Lisa','Ozer','LOZER','011.44.1343.929268',to_date('11-MAR-05','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (169,'Harrison','Bloom','HBLOOM','011.44.1343.829268',to_date('23-MAR-06','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (170,'Tayler','Fox','TFOX','011.44.1343.729268',to_date('24-JAN-06','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (171,'William','Smith','WSMITH','011.44.1343.629268',to_date('23-FEB-07','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (172,'Elizabeth','Bates','EBATES','011.44.1343.529268',to_date('24-MAR-07','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (173,'Sundita','Kumar','SKUMAR','011.44.1343.329268',to_date('21-APR-08','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (174,'Ellen','Abel','EABEL','011.44.1644.429267',to_date('11-MAY-04','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (175,'Alyssa','Hutton','AHUTTON','011.44.1644.429266',to_date('19-MAR-05','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (176,'Jonathon','Taylor','JTAYLOR','011.44.1644.429265',to_date('24-MAR-06','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (177,'Jack','Livingston','JLIVINGS','011.44.1644.429264',to_date('23-APR-06','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (178,'Kimberely','Grant','KGRANT','011.44.1644.429263',to_date('24-MAY-07','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (179,'Charles','Johnson','CJOHNSON','011.44.1644.429262',to_date('04-JAN-08','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (180,'Winston','Taylor','WTAYLOR','650.507.9876',to_date('24-JAN-06','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (181,'Jean','Fleaur','JFLEAUR','650.507.9877',to_date('23-FEB-06','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (182,'Martha','Sullivan','MSULLIVA','650.507.9878',to_date('21-JUN-07','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (183,'Girard','Geoni','GGEONI','650.507.9879',to_date('03-FEB-08','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (184,'Nandita','Sarchand','NSARCHAN','650.509.1876',to_date('27-JAN-04','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (185,'Alexis','Bull','ABULL','650.509.2876',to_date('20-FEB-05','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (186,'Julia','Dellinger','JDELLING','650.509.3876',to_date('24-JUN-06','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (187,'Anthony','Cabrio','ACABRIO','650.509.4876',to_date('07-FEB-07','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (188,'Kelly','Chung','KCHUNG','650.505.1876',to_date('14-JUN-05','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (189,'Jennifer','Dilly','JDILLY','650.505.2876',to_date('13-AUG-05','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (190,'Timothy','Gates','TGATES','650.505.3876',to_date('11-JUL-06','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (191,'Randall','Perkins','RPERKINS','650.505.4876',to_date('19-DEC-07','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (192,'Sarah','Bell','SBELL','650.501.1876',to_date('04-FEB-04','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (193,'Britney','Everett','BEVERETT','650.501.2876',to_date('03-MAR-05','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (194,'Samuel','McCain','SMCCAIN','650.501.3876',to_date('01-JUL-06','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (195,'Vance','Jones','VJONES','650.501.4876',to_date('17-MAR-07','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (196,'Alana','Walsh','AWALSH','650.507.9811',to_date('24-APR-06','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (197,'Kevin','Feeney','KFEENEY','650.507.9822',to_date('23-MAY-06','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (198,'Donald','OConnell','DOCONNEL','650.507.9833',to_date('21-JUN-07','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (199,'Douglas','Grant','DGRANT','650.507.9844',to_date('13-JAN-08','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (200,'Jennifer','Whalen','JWHALEN','515.123.4444',to_date('17-SEP-03','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (201,'Michael','Hartstein','MHARTSTE','515.123.5555',to_date('17-FEB-04','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (202,'Pat','Fay','PFAY','603.123.6666',to_date('17-AUG-05','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (203,'Susan','Mavris','SMAVRIS','515.123.7777',to_date('07-JUN-02','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (204,'Hermann','Baer','HBAER','515.123.8888',to_date('07-JUN-02','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (205,'Shelley','Higgins','SHIGGINS','515.123.8080',to_date('07-JUN-02','DD-MON-RR'));
Insert into EMPLOYEES (EMPLOYEE_ID,FIRST_NAME,LAST_NAME,EMAIL,PHONE_NUMBER,HIRE_DATE) values (206,'William','Gietz','WGIETZ','515.123.8181',to_date('07-JUN-02','DD-MON-RR'));

commit;
SET DEFINE ON;