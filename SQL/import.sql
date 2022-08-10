use owid;


/*

  Temporäre Tabelle für den Import der Daten erstellen

*/

drop table if exists monkeypox;

create table monkeypox (
    location varchar(255) not NULL,
    `date` date not NULL,
    new_cases bigint(20) default NULL,
    new_cases_smoothed double default NULL,
    total_cases bigint(20) default NULL,
    new_cases_per_million double default NULL,
    total_cases_per_million double default NULL,
    new_cases_smoothed_per_million double default NULL,
    new_deaths bigint(20) default NULL,
    new_deaths_smoothed double default NULL,
    total_deaths double default NULL,
    new_deaths_per_million double default NULL,
    total_deaths_per_million double default NULL,
    new_deaths_smoothed_per_million double default NULL,
    primary key ( location, `date` )
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
;

LOAD DATA LOCAL INFILE '/tmp/owid_mpx.csv' 
    INTO TABLE monkeypox
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    IGNORE 1 ROWS
;

select max(`date`) from monkeypox where `location` = 'Germany';
