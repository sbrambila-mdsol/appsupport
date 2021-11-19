select datepart(dw,'4/15/18')--SUNDAY 1
select datepart(dw,'4/16/18')--MONDAY 2
select datepart(dw,'4/17/18')--TUESDAY 3
select datepart(dw,'4/18/18')--WEDNESDAY 4
select datepart(dw,'4/19/18')--THURSDAY 5
select datepart(dw,'4/20/18')--FRIDAY 6
select datepart(dw,'4/21/18')--SATURDAY 7

DECLARE @MyDate DATETIME = GETDATE()
SELECT Holiday = CASE 
    WHEN [Month] = 1  AND [DayOfMonth] = 1 THEN 'New Year' 
    WHEN [Month] = 5  AND [DayOfMonth] >= 25 AND [DayName] = 'Monday' THEN 'Memorial Day' 
    WHEN [Month] = 7  AND [DayOfMonth] = 4 THEN 'Independence Day' 
    WHEN [Month] = 9  AND [DayOfMonth] <= 7 AND [DayName] = 'Monday' THEN 'Labor Day' 
    WHEN [Month] = 11 AND [DayOfMonth] BETWEEN 22 AND 28 AND [DayName] = 'Thursday' THEN 'Thanksgiving Day' 
    WHEN [Month] = 12 AND [DayOfMonth] = 25 THEN 'Christmas Day' 
	WHEN DATEPART(dw,@MyDate) IN (1,7) THEN 'Week End'
    ELSE 'Okay' END
FROM (
    SELECT 
        [Month] = MONTH(@MyDate),
        [DayOfMonth] = DAY(@MyDate),
        [DayName]   = DATENAME(weekday,@MyDate)
) c