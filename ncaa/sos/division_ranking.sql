begin;

create temporary table r (
       school_id	 integer,
       div	 text,
       year	 integer,
       str	 numeric(4,3),
       park	 numeric(4,3),
       ofs	 numeric(4,3),
       dfs	 numeric(4,3),
       sos	 numeric(4,3)
);

insert into r
(school_id,div,year,str,park,ofs,dfs,sos)
(
select
t.school_id,
t.division as div,
sf.year,
(sf.strength*h.exp_factor/p.exp_factor)::numeric(4,3) as str,
park::numeric(4,3) as park,
(offensive*h.exp_factor)::numeric(4,3) as ofs,
(defensive*p.exp_factor)::numeric(4,3) as dfs,
schedule_strength::numeric(4,3) as sos
from ncaa._schedule_factors sf
left outer join ncaa.schools_divisions t
  on (t.school_id,t.year)=(sf.school_id,sf.year)
left outer join ncaa._factors h
  on (h.parameter,h.level::integer)=('h_div',length(t.division))
left outer join ncaa._factors p
  on (p.parameter,p.level::integer)=('p_div',length(t.division))
where sf.year in (2014)
and t.school_id is not null
order by str desc);

select
year,
exp(avg(log(str)))::numeric(4,3) as str,
exp(avg(log(park)))::numeric(4,3) as park,
exp(avg(log(ofs)))::numeric(4,3) as ofs,
exp(-avg(log(dfs)))::numeric(4,3) as dfs,
exp(avg(log(sos)))::numeric(4,3) as sos,
count(*) as n
from r
group by year
order by year asc;

select
year,
div,
exp(avg(log(str)))::numeric(4,3) as str,
exp(avg(log(park)))::numeric(4,3) as park,
exp(avg(log(ofs)))::numeric(4,3) as ofs,
exp(-avg(log(dfs)))::numeric(4,3) as dfs,
exp(avg(log(sos)))::numeric(4,3) as sos,
--avg(str)::numeric(4,3) as str,
--avg(park)::numeric(4,3) as park,
--avg(ofs)::numeric(4,3) as ofs,
--(1/avg(dfs))::numeric(4,3) as dfs,
--avg(sos)::numeric(4,3) as sos,
count(*) as n
from r
where div is not null
group by year,div
order by year asc,str desc;

select * from r
where div is null
and year=2014;

commit;