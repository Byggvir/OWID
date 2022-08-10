use owid;


/*

  Temporäre Tabelle für den Import der Daten erstellen

*/

drop table if exists covid19;

create table covid19 (
    iso_code char(3) default NULL,
    continent varchar(255) default NULL,
    location varchar(255) default NULL,
    `date` date default NULL,
    total_cases bigint(20) default 0,
    new_cases bigint(20) default 0,
    new_cases_smoothed double default 0,
    total_deaths bigint(20) default 0,
    new_deaths bigint(20) default 0,
    new_deaths_smoothed double default 0,
    total_cases_per_million double default 0,
    new_cases_per_million double default 0,
    new_cases_smoothed_per_million double default 0,
    total_deaths_per_million double default 0,
    new_deaths_per_million double default 0,
    new_deaths_smoothed_per_million double default 0,
    reproduction_rate double default 0,
    icu_patients bigint(20) default 0,
    icu_patients_per_million double default 0,
    hosp_patients bigint(20) default 0,
    hosp_patients_per_million double default 0,
    weekly_icu_admissions bigint(20) default 0,
    weekly_icu_admissions_per_million double default 0,
    weekly_hosp_admissions bigint(20) default 0,
    weekly_hosp_admissions_per_million double default 0,
    total_tests bigint(20) default 0,
    new_tests bigint(20) default 0,
    total_tests_per_thousand double default 0,
    new_tests_per_thousand double default 0,
    new_tests_smoothed double default 0,
    new_tests_smoothed_per_thousand double default 0,
    positive_rate double default 0,
    tests_per_case double default 0,
    tests_units double default 0,
    total_vaccinations bigint(20) default 0,
    people_vaccinated bigint(20) default 0,
    people_fully_vaccinated bigint(20) default 0,
    total_boosters bigint(20) default 0,
    new_vaccinations bigint(20) default 0,
    new_vaccinations_smoothed double default 0,
    total_vaccinations_per_hundred double default 0,
    people_vaccinated_per_hundred double default 0,
    people_fully_vaccinated_per_hundred double default 0,
    total_boosters_per_hundred double default 0,
    new_vaccinations_smoothed_per_million double default 0,
    new_people_vaccinated_smoothed double default 0,
    new_people_vaccinated_smoothed_per_hundred double default 0,
    stringency_index double default 0,
    population bigint(20) default 0,
    population_density double default 0,
    median_age double default 0,
    aged_65_older double default 0,
    aged_70_older double default 0,
    gdp_per_capita double default 0,
    extreme_poverty double default 0,
    cardiovasc_death_rate double default 0,
    diabetes_prevalence double default 0,
    female_smokers double default 0,
    male_smokers double default 0,
    handwashing_facilities double default 0,
    hospital_beds_per_thousand double default 0,
    life_expectancy double default 0,
    human_development_index double default 0,
    excess_mortality_cumulative_absolute bigint(20) default 0,
    excess_mortality_cumulative bigint(20) default 0,
    excess_mortality bigint(20) default 0,
    excess_mortality_cumulative_per_million double default 0,
    primary key ( iso_code, `date` )
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
;

LOAD DATA LOCAL INFILE '/tmp/owid_covid.csv' 
    INTO TABLE covid19
    FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
    IGNORE 1 ROWS
;

select max(`date`) from covid19 where `location` = 'Germany';
