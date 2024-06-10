
-- Cleaning data
-- 1- delete duplicates
	-- Creat a new table with count cloumn to count how many this raw duplicats
insert into clean
select * , row_number() over( partition by company , location , industry , total_laid_off , percentage_laid_off , `date` , stage , country , funds_raised_millions ) as count
from layoffs ;
		-- any count > 1 is duplicates and need to delete
Delete from clean 
	where count > 1 ;
-- now we don't need count column anymore
	alter table clean
		drop column count ;
 -- 2- standardization of the data
  -- removing some unwanted spaces
	update clean 
	set company = trim(company);
 -- in the industry column there's proplem with compan (crypto) but with diffrent types but it's the same so we need merge them to be same industry
	update clean
	set industry = 'Crypto' 
		where industry like 'Crypto%';
  -- in the country column there is issure with 'united states' it's typed twice in the distinct select because it typed in diffrent form so i'll merge it also and let them 'USA'
  update clean
  set country = 'USA'
	where country like 'United States%';
  -- now the date has to be corrected to be in date form instead of text  
  update clean
  set `date`= str_to_date(`date`, '%m/%d/%Y');
  -- but it's still in text form we just transform it to data instead of string
  alter table clean
  modify column `date` date;
  
-- 3- deleting the not important blanks and nulls
-- so i'll delete the nulls if this exist in total laid off and percetage laid off and funds raised in millions 
delete from clean
where total_laid_off is null and percentage_laid_off is null and funds_raised_millions is null;

-- some industrys are nulls and blanks but the same company it typed it's idustry in another row so i'll merege the industry with the same company name
-- i changed all value of industry that black to nulls to be easier to select later
update clean 
set industry = null 
where industry = " " ;
-- changing the values that = nulls to be equal to the industry of the same company name but it's not null
update clean  c1
join clean  c2  
	on c1.company = c2.company
set c1.industry = c2.industry
where c1.industry is NULL and c2.industry is not NULL ;