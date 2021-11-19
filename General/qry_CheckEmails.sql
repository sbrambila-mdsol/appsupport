use msdb
go

select *
from sysmail_allitems
--where mailitem_id=91345
order by sent_date desc