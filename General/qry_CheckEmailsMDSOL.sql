use msdb
go

select *
from sysmail_allitems
--where mailitem_id=91345
where recipients like '%cs_shyftsupport@mdsol.com%'
order by sent_date desc