
$domainAcct = 'CONTOSO\Installer'

Write-Host " Adding NT AUTHORITY\SYSTEM with required permissions"
Invoke-SqlCmd -Query "CREATE LOGIN [NT AUTHORITY\SYSTEM] FROM WINDOWS" -ServerInstance "."
Invoke-SqlCmd -Query "GRANT ALTER ANY AVAILABILITY GROUP TO [NT AUTHORITY\SYSTEM] AS SA" -ServerInstance "." 
Invoke-SqlCmd -Query "GRANT CONNECT SQL TO [NT AUTHORITY\SYSTEM] AS SA" -ServerInstance "."
Invoke-SqlCmd -Query "GRANT VIEW SERVER STATE TO [NT AUTHORITY\SYSTEM] AS SA" -ServerInstance "."

Write-Host " Adding CONTOSO\Installer with required permissions"
Invoke-SqlCmd -Query "CREATE LOGIN [$domainAcct] FROM WINDOWS" -ServerInstance "."
Invoke-SqlCmd -Query "GRANT ALTER ANY AVAILABILITY GROUP TO [$domainAcct] AS SA" -ServerInstance "." 
Invoke-SqlCmd -Query "GRANT CONNECT SQL TO [$domainAcct] AS SA" -ServerInstance "."
Invoke-SqlCmd -Query "GRANT VIEW SERVER STATE TO [$domainAcct] AS SA" -ServerInstance "."

Invoke-SqlCmd -Query "EXEC sp_addsrvrolemember [$domainAcct], 'sysadmin'" -ServerInstance "."