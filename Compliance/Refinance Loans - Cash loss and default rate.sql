---First Data Set 
--Default
CREATE TEMP TABLE ALLREFINANCES AS
with defamount as (
select year
(REFINANCEDATE) year, gtstate, sum(ADJUSTEDREFINANCEAMOUNT) ADJUSTEDREFINANCEAMOUNT, sum(ADJUSTEDFINREFINANCEFEE) ADJUSTEDREFINANCEFEE,sum(c.amount) fstretamount,sum(c.amount)/ (sum(ADJUSTEDREFINANCEAMOUNT) + sum(ADJUSTEDFINREFINANCEFEE)) defaultdollar,
count(*) totalitems,sum(case when TRANSACTIONTYPE = 4 then 1 else 0 end) collitems, sum(case when TRANSACTIONTYPE = 4 then 1 else 0 end)/count(*) defaultpercent
from ACE_REPORTS_DB.SREDDY.REFINANCEPAYMENTPLANELIGIBILITYV18 a 
left outer join ace_ods..CLITEM b on a.GTGLN_NBR = b.LOAN
left outer join  ace_ods..CLIRET c on b.ITEM = c.ITEM and c."TYPE" = 'FST'
where TRANSACTIONTYPE in (3,4)
group by year
(REFINANCEDATE),gtstate),

--cash loss
cashloss as
(
select year
(REFINANCEDATE) year, gtstate, sum(ADJUSTEDREFINANCEAMOUNT) ADJUSTEDREFINANCEAMOUNT, sum(coalesce(CASHLOSS,0)) CASHLOSS,
sum(coalesce(CASHLOSS,0))/ sum(ADJUSTEDREFINANCEAMOUNT) cashlossdollar,count(*) totalitems, sum(case when cashloss > 0 then 1 else 0 end ) cashlossitems, sum(case when cashloss > 0 then 1 else 0 end )/count(*) cashlosspercent
from ACE_REPORTS_DB.SREDDY.REFINANCEPAYMENTPLANELIGIBILITYV18 a 
where TRANSACTIONTYPE in (3,4) --and cashloss > 0
group by year
(REFINANCEDATE),gtstate)

select coalesce(a.YEAR,c.YEAR) year,coalesce(a.GTSTATE,c.gtstate) gtstate, a.ADJUSTEDREFINANCEAMOUNT,ADJUSTEDREFINANCEFEE, FSTRETAMOUNT, DEFAULTdollar, a.TOTALITEMs totaldefaulitems, COLLITEMS, DEFAULTpercent, 
c.ADJUSTEDREFINANCEAMOUNT ADJUSTEDREFINANCEAMOUNTcashloss, CASHLOSS, CASHLOSSdollar, c.TOTALITEMS TOTALITEMStype3andtype4, CASHLOSSITEMS, CASHLOSSPERCENT
from defamount a 
full outer join cashloss c on a.YEAR  = c.YEAR and a.GTSTATE  = c.gtstate


--YEAR 
SELECT YEAR, SUM(FSTRETAMOUNT)/SUM(ADJUSTEDREFINANCEAMOUNT + ADJUSTEDREFINANCEFEE ) DEFAULTdollar,  FROM 
ALLREFINANCES
GROUP BY YEAR

--STATE
SELECT GTSTATE, SUM(FSTRETAMOUNT)/SUM(ADJUSTEDREFINANCEAMOUNT + ADJUSTEDREFINANCEFEE ) DEFAULTdollar FROM 
ALLREFINANCES
GROUP BY GTSTATE


