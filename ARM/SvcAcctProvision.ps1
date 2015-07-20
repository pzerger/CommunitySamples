

[xml]$config =      '<?xml version="1.0" encoding="utf-8"?>
<Azure Location="West US" VNetName="ContosoNET">
    <ServiceAccounts>
	    <ServiceAccount UserName="CORP\SQLSvc1" Password="Contoso!000" Type="SQL" />
	    <ServiceAccount UserName="CORP\SQLSvc2" Password="Contoso!000" Type="SQL" />
	    <ServiceAccount UserName="CORP\SQLSvc3" Password="Contoso!000" Type="SQL" />
	    <ServiceAccount UserName="CORP\Installer" Password="Contoso!000" Type="DBA" />
    </ServiceAccounts>
</Azure>'


write-eventlog -logname Application -source Loadperf -eventID 3001 -entrytype Information -message "MyApp added a user-requested feature to the display." -category 1 -rawdata 10,20

#Provision domain service accounts 

    Write-Host "Configuring domain accounts"
    $serialXML = New-Object System.Xml.XmlDocument  
    $serialXML.AppendChild($serialXML.ImportNode($config.Azure.ServiceAccounts, $true)) | Out-Null

 
            Write-Host "Configure AD objects on $env:COMPUTERNAME..."

            Import-Module ActiveDirectory

            foreach($account in $config.Azure.ServiceAccounts.ServiceAccount)
            {
                if ($account.UserName.Contains('\') -and ([string]::IsNullOrEmpty($account.Create) -or (-not $account.Create.Equals('No'))))
                {
                    $uname = $account.UserName.Split('\')[1]
                    $password = ConvertTo-SecureString $account.Password -AsPlainText -Force
                    Write-Host " Add AD account" $account.UserName
                    New-ADUser `
                        -Name $uname `
                        -AccountPassword $password `
                        -PasswordNeverExpires $true `
                        -ChangePasswordAtLogon $false `
                        -Enabled $true

                    if($account.Type -eq "DBA")
                    {
                        Write-Host " Configure $($account.UserName) with needed WSFC permissions" 
                        Cd ad:
                        $sid = new-object System.Security.Principal.SecurityIdentifier (Get-ADUser $uname).SID
                        $guid = new-object Guid bf967a86-0de6-11d0-a285-00aa003049e2
                        $ace1 = new-object System.DirectoryServices.ActiveDirectoryAccessRule $sid,"CreateChild","Allow",$guid,"All"
                        $dn = (Get-ADDomain | select -ExpandProperty DistinguishedName )
                        $corp = Get-ADObject -Identity $dn
                        $acl = Get-Acl $corp
                        $acl.AddAccessRule($ace1)
                        Set-Acl -Path $dn -AclObject $acl
                    }
                }
            }
         
