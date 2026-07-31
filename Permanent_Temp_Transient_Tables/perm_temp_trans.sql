create or replace table Data_TBL(status String);

create or replace temporary table Data_TBL_Temp(status String);

Alter warehouse Compute_wh suspend;
insert into Data_TBL
values('Permanenrt');

create or replace transient table Data_TBL_transient(status String);


show tables;


create or replace global temporary table Data_TBL(status String);


insert into Data_TBL
values('temporary');

select * from data_tbl;



create or replace temp table  Data_TBL_Temp clone Data_TBL_transient ;
