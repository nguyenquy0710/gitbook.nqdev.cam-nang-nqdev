# SQL Server Error : 14151, Severity: 18. Replication agent

### SQL Server Error : 14151 Details



### Relate errors below



### Cause of Error sql server 14151



### Solution for Resolving the Error SQL Server 14151

```sql

USE distribution;

SELECT * FROM distribution..MSdistribution_agents;
SELECT TOP(100) * FROM distribution..MSdistribution_history ORDER BY time DESC;
SELECT TOP(100) * FROM distribution..MSrepl_errors ORDER BY time DESC;
SELECT TOP(100) * FROM distribution..MSlogreader_history ORDER BY time DESC;
```
