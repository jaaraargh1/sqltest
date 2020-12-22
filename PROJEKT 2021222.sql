DROP VIEW IF EXISTS loaned_books;
DROP VIEW IF EXISTS who_handles_most_artifacts;
DROP VIEW IF EXISTS site_wih_most_artifacts;
DROP VIEW IF EXISTS number_of_different_kinds_of_litterature;
DROP TABLE IF EXISTS slide_loans; --LEVEL 3
DROP TABLE IF EXISTS slides, list_of_authors, handeled_by, litterature_loans; --LEVEL 2
DROP TABLE IF EXISTS litterature, artifacts,dig_projects; --LEVEL 1
DROP TABLE IF EXISTS staff_members,dig_sites, authors, kinds; --LEVEL 0


--LEVEL 0
CREATE TABLE staff_members(
		PRIMARY KEY(employee_id),
		employee_id			INT					IDENTITY(1,1),
		first_name			VARCHAR(32)			NOT NULL,
		surname				VARCHAR(32)			NOT NULL,
		phone_number		VARCHAR(15),
		[role]				VARCHAR(32)
		CONSTRAINT [role] CHECK([role] IN ('Researcher', 'Librarian', 'Slide librarian', 'Supervisor')),
		hired				DATE				NOT NULL,
		resigned			DATE
);

--LEVEL 0
CREATE TABLE dig_sites(
		PRIMARY KEY(dig_number),
		dig_number			INT					IDENTITY(1,1),
		[name]				VARCHAR(32)			NOT NULL,		
		[description]		VARCHAR(100)		NOT NULL,
		x_cord				DECIMAL(10,2)		NOT NULL,
		y_cord				DECIMAL(10,2)		NOT NULL,
		[location]			VARCHAR(32)			NOT NULL
);

--LEVEL 0
CREATE TABLE authors(
		PRIMARY KEY(author_id),
		author_id			INT					IDENTITY(1,1),
		first_name			VARCHAR(32)			NOT NULL,
		surname				VARCHAR(32)			NOT NULL
);

--LEVEL 0
CREATE TABLE kinds(
		PRIMARY KEY(id),
		id					INT					IDENTITY(1,1),
		type_of_litt		VARCHAR(32),		
		CONSTRAINT type_of_litt CHECK(type_of_litt IN ('Book', 'Journal', 'Paper'))	
);

--LEVEL 1
CREATE TABLE litterature(
		PRIMARY KEY(litterature_id),
		litterature_id		INT					IDENTITY(1,1),
		kind_id				INT,				--LEVEL 0
		[location]			VARCHAR(32)			NOT NULL,
		title				VARCHAR(32)			NOT NULL,
		isbn				VARCHAR(13),	
		FOREIGN KEY			(kind_id)	
		REFERENCES			kinds(id)
);

--LEVEL 1
CREATE TABLE artifacts(
		PRIMARY KEY(artifact_number),
		artifact_number		INT					IDENTITY(1,1),
		dig_number			INT,				--LEVEL 0	
		depth				INT					NOT NULL,	
		shelf_number		INT,
		[finding_date]		DATE				NOT NULL,
		found_at_x			DECIMAL(10,2)		NOT NULL,
		found_at_y			DECIMAL(10,2)		NOT NULL,
		[description]		VARCHAR(100),
		FOREIGN KEY			(dig_number)	
		REFERENCES			dig_sites(dig_number)
);

--LEVEL 1
CREATE TABLE dig_projects(
		PRIMARY KEY(dig_number, employee_id),
		dig_number			INT,				--LEVEL 0
		employee_id			INT,				--LEVEL 0
		FOREIGN KEY			(employee_id)	
		REFERENCES			staff_members(employee_id),
		FOREIGN KEY			(dig_number)	
		REFERENCES			dig_sites(dig_number)
		
);

--LEVEL 2
CREATE TABLE slides(
		PRIMARY KEY(slide_number),
		slide_number		INT					IDENTITY(1,1),
		artifact_number		INT,				--LEVEL 1
		dig_number			INT,				--LEVEL 0	
		[index]				VARCHAR(32)			NOT NULL,	--tema
		[description]		VARCHAR(100)		NOT NULL,
		FOREIGN KEY			(artifact_number)	
		REFERENCES			artifacts(artifact_number),
		FOREIGN KEY			(dig_number)	
		REFERENCES			dig_sites(dig_number)
);

--LEVEL 2
CREATE TABLE list_of_authors(
		PRIMARY KEY(litterature_id, author_id),
		litterature_id		INT,				--LEVEL 1
		author_id			INT,				--LEVEL 0
		FOREIGN KEY			(litterature_id)	
		REFERENCES			litterature(litterature_id),
		FOREIGN KEY			(author_id)	
		REFERENCES			authors(author_id)
);

--LEVEL 2
CREATE TABLE handeled_by(
		PRIMARY KEY(artifact_number, employee_id),
		employee_id			INT,				--LEVEL 0
		artifact_number		INT,				--LEVEL 1
		FOREIGN KEY			(employee_id)	
		REFERENCES			staff_members(employee_id),
		FOREIGN KEY			(artifact_number)	
		REFERENCES			artifacts(artifact_number)
	
);

--LEVEL 2
CREATE TABLE litterature_loans(
		PRIMARY KEY(litterature_id, employee_id),
		employee_id			INT,				--LEVEL 0
		litterature_id		INT,				--LEVEL 1
		lending_date		DATE				NOT NULL,
		return_date			DATE,
		FOREIGN KEY			(employee_id)	
		REFERENCES			staff_members(employee_id),
		FOREIGN KEY			(litterature_id)	
		REFERENCES			litterature(litterature_id)
);

-- LEVEL 3
CREATE TABLE slide_loans(
		PRIMARY KEY(slide_number, employee_id),
		employee_id			INT,				--LEVEL 0
		slide_number		INT,				--LEVEL 2
		lending_date		DATE				NOT NULL,
		return_date			DATE,
		FOREIGN KEY			(employee_id)	
		REFERENCES			staff_members(employee_id),
		FOREIGN KEY			(slide_number)	
		REFERENCES			litterature(litterature_id)
);
GO
CREATE VIEW loaned_books AS
SELECT L.litterature_id,L.title,
CASE 
WHEN
L.litterature_id = LL.litterature_id AND kind_id != 3 then 'Has been loaned'
END AS 'Loaned_book'
FROM litterature as L
LEFT JOIN litterature_loans as LL
ON L.litterature_id = LL.litterature_id;
GO

GO
CREATE VIEW number_of_different_kinds_of_litterature AS
SELECT K.id, L.kind_id, K.type_of_litt
FROM kinds AS K
INNER JOIN litterature AS L
ON K.id = L.kind_id

GO

GO
CREATE VIEW site_wih_most_artifacts AS
SELECT D.dig_number,A.finding_date  FROM artifacts AS A 
INNER JOIN dig_sites AS D
ON A.dig_number = D.dig_number



GO

INSERT INTO staff_members
		VALUES	('Agnes', 'Kjellin', '0704602484', 'Supervisor','2020-10-10', NULL),
				('Ted', 'Bäckman', '0705873694', 'Researcher', '2017-03-16', NULL),
				('Natlin', 'Abdul-Karim', '0735668219', 'Librarian', '2015-08-13', NULL),
				('Julia', 'Holmgren Karlsson', '0704338521', 'Slide Librarian', '2018-05-30', NULL),
				('Albin', 'Ambrosius', '0736998526', 'Researcher', '2017-05-30', NULL),
				('Fredrich', 'Nietzsche', NULL, 'Librarian', '1990-05-14', '2015-08-16'),
				('Lukas', 'Lagerfors', '0724763385', 'Supervisor', '2008-05-09', '2020-10-10'),
				('Shakira', 'Ripoll', '0726995423', 'Researcher', '2003-05-30', NULL);

INSERT INTO dig_sites
		VALUES	('Xanadu utgrävning', 'Sommarhuvudstad för Mongolväldet och Yuandynastin.', '600.60', '400.00','Mongoliet'),
				('El Dorado utgrävning', 'Eldorado är en mytologisk utopi som är placerad någonstans i Sydamerika.', '1200.31', '1000.00','Sydamerika'),
				('Konungarnas dal utgrävning', 'En dalgång i södra Egypten.', '500.60', '550.12','Egypten'),	
				('Xian utgrävning', 'Är huvudstad i Shaanxi-provinsen i Kina och namnet betyder "västra freden.', '300.21', '250.45','Kina'),	
				('Megalopolis utgrävning', 'En 5000 års gammal stad i Israel.', '700.55', '660.00','Israel'),	
				('Zhaw Marg utgrävning', 'Liten by i Iran', '400.00', '400.00','Iran');	

INSERT INTO authors
		VALUES	('Marcus','Aurelius'),
				('Niccollo','Machiavelli'),
				('August','Strindberg'),
				('Astrid','Lindgren');

INSERT INTO kinds
		VALUES	('Book'),
				('Paper'),
				('Journal');


INSERT INTO litterature
		VALUES	('1', 'Hylla 12','Fursten','9789127026902'),
				('1', 'Hylla 1','Arkeologibok 1','9789127026901'),
				('1', 'Hylla 5','Arkeologibok 2','9789127026903'),
				('1', 'Hylla 8','Arkeologibok 3','9789127026904'),
				('1', 'Hylla 2','Arkeologibok 4','9789127026905'),
				('1', 'Hylla 14','Arkeologibok 5','9789127026906'),
				('1', 'Hylla 11','Arkeologibok 6','9789127026907'),
				('1', 'Hylla 12','Fursten','9789127026902'),
				('2', 'Hylla 5', 'Agnes tankar om Xanadu', NULL),
				('3', 'Hylla 10', 'En Guide till tetris', NULL),
				('3', 'Hylla 10', 'En Guide för arkeologer', NULL),
				('3', 'Hylla 10', 'Svensk Arkeologihistoria', NULL),
				('3', 'Hylla 10', 'Teds Journal', NULL),
				('3', 'Hylla 10', 'Natlins Journal', NULL),
				('3', 'Hylla 10', 'Agnes Journal', NULL),
				('3', 'Hylla 10', 'Julias Journal', NULL);

INSERT INTO artifacts
		VALUES	('1', '12','5','1997-05-28', '320.5', '520.4','Vacker artifakt från Xanadu'),
				('2', '60','3','2016-05-02', '130.5', '220.4','Artefakt 1'),
				('4', '3','5','2003-05-28', '350.5', '220.4','Artefakt 2'),
				('5', '2','5','2003-05-28', '306.5', '220.4','Artefakt 3'),
				('2', '40','5','2016-05-28', '330.5', '220.4','Artefakt 4'),
				('1', '28','6','1997-05-28', '350.5', '220.4','Artefakt 5'),
				('3', '12','7','2003-05-28', '360.5', '220.4','Artefakt 6'),
				('3', '15','7','1987-05-28', '430.5', '120.4','Artefakt 7'),
				('4', '2','8','2003-05-28', '530.5', '260.4','Artefakt 8'),
				('1', '5','4','1987-05-28', '360.5', '250.4','Artefakt 9'),
				('2', '8','4','1997-05-28', '340.5', '240.4','Artefakt 10'),
				('5', '18','4','2016-05-28', '320.5', '230.4','Artefakt 1'),
				('2', '13','3','1997-05-28', '301.5', '240.4','Artefakt 2'),
				('3', '19','3','2003-05-28', '320.5', '207.4','Artefakt 3'),
				('1', '50','7','2016-05-28', '10.5', '250.4','Artefakt 4'),
				('1', '36','7','1987-05-28', '50.5', '250.4','Artefakt 5'),
				('5', '12','2','2020-05-28', '60.5', '250.4','Artefakt 6'),
				('4', '8','2','2003-05-28', '60.5', '270.4','Artefakt 7'),
				('4', '25','2','2016-05-28', '30.7', '280.4','Artefakt 8'),
				('1', '3','5','2003-05-28', '30.5', '920.4','Artefakt 9'),
				('3', '27','5','1987-05-28', '34.5', '720.4','Artefakt 10'),
				('2', '29','5','2020-05-28', '55.5', '620.4','Artefakt 1'),
				('1', '11','6','1997-05-28', '66.5', '520.4','Artefakt 2'),
				('1', '12','6','1997-05-28', '77.5', '420.4','Artefakt 3'),
				('3', '4','6','2003-05-28', '44.5', '230.4','Artefakt 4'),
				('3', '5','2','2016-05-28', '22.5', '120.4','Artefakt 5'),
				('5', '8','2','1987-05-28', '33.5', '620.4','Artefakt 6'),
				('5', '7','1','2020-05-28', '55.5', '720.4','Artefakt 7'),
				('5', '3','1','1997-05-28', '66.5', '820.4','Artefakt 8'),
				('1', '1','3','1987-05-28', '66.5', '290.4','Artefakt 9'),
				('4', '14','14','1987-05-28', '55.5', '250.4','Artefakt 10');
			
INSERT INTO dig_projects
		VALUES	('1', '1'),
				('1', '2'),
				('1', '3'),
				('1', '4'),
				('1', '5'),
				('2', '1'),
				('2', '6'),
				('2', '4'),
				('3', '1');

INSERT INTO slides
		VALUES	('4', '1','tema 1','description'),
				('4', '2','tema 2','description'),
				('1', '3','tema 4','description 140'),
				('3', '4','tema 5','description 6'),
				('3', '5','tema 2','description 7'),
				('5', '4','tema 3','description 8'),
				('6', '4','tema 5','description 190'),
				('2', '4','tema 4','description 1'),
				('4', '6','tema 2','description 2'),
				('4', '6','tema 1','description 4'),
				('4', '1','tema 1','description 5'),
				('4', '2','tema 3','description 10'),
				('4', '2','tema 2','description 12'),
				('4', '1','tema 3','description 3'),
				('4', '4','tema 1','description 10');

INSERT INTO list_of_authors
		VALUES	('1','4'),
				('12','1'),
				('12','2'),
				('6','3'),
				('2','2'),
				('2','1');

INSERT INTO handeled_by
		VALUES	('3','1'),
				('2','2'),
				('5','3'),
				('4','4'),
				('2','3');
				-- employeeid, bokid
				--book= 1,paper = 2,journal = 3
				-- 10 - 16 = journals
INSERT INTO litterature_loans
		VALUES	('1','2', '2020-05-01', NULL),
				('2','4', '2019-12-12', '2020-02-14'),
				('3','5', '2018-03-05', '2018-06-15'),
				('4','3', '2020-03-12', NULL),
				('5','1', '2020-05-25', NULL),
				('1','10', '2020-04-05', NULL),
				('5','11', '2020-03-01', NULL),
				('4','12', '1987-02-15', NULL),
				('3','13', '2020-01-15', NULL),
				('2','14', '2020-06-15', NULL);
				

INSERT INTO slide_loans
		VALUES	('1','2','2020-05-10','2020-05-22'),
				('2','3','2020-06-14','2020-05-22'),
				('3','4','2020-07-13','2020-05-22'),
				('1','5','2020-08-12',NULL),
				('1','1','2020-09-11',NULL);

-- VILKA BÖCKER HAR INTE LÅNATS UT < WHERE CONDITION UPPFYLLT 1 GÅNG, ord> --  
-- DEN ENDA FRÅGAN SOM FÅR VARA SIMPEL DVS ALLA ANDRA MÅSTE INNEHÅLLA join, agg & villkor 
SELECT title,LOCATION FROM litterature 
WHERE kind_id != '3' AND litterature_id not in (SELECT litterature_id FROM litterature_loans)
ORDER BY title;
	
-- sites med mest artefakter hittade =) mellan olika datum.



-- vilka böcker har lånats ut??
SELECT title, [Loaned_book]
FROM loaned_books
WHERE loaned_book IS NOT NULL
ORDER BY title;

SELECT TOP 3 dig_number, COUNT(*) AS 'antalet artefakter hittade' FROM site_wih_most_artifacts AS S 

WHERE S.finding_date
BETWEEN '1980-01-01' AND '2000-12-31'
GROUP BY dig_number ORDER BY 2 DESC; 


SELECT N.type_of_litt, COUNT(*) AS 'antalet' FROM number_of_different_kinds_of_litterature AS N
GROUP BY kind_id, type_of_litt ORDER BY 2 DESC; 












      
         
        
  