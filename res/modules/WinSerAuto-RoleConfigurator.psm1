Do {
        Write-Host "`t`tWould you like to deploy a active directory? (y/n)" -nonewline -f green;
        $answer = Read-Host " " 
        Switch ($answer) { 
            Y { 
            
 #Install AD windows feature
            $WarningPreference = "SilentlyContinue"
            Install-WindowsFeature AD-Domain-Services -IncludeManagementTools | out-null
      

# Domain name validator
            DO{
                "";
                $domainname = (Read-Host -Prompt "`t`t`t`tPlease enter a domain name")
                $valid = "no"
                if($domainname -match '[^a-zA-Z0-9.-]'){write-host "`t`t`t`t" -nonewline; write-host "ERROR:`tInvalid character is used" -BackgroundColor Red -f White}
                elseif($domainname -match '^\.'){write-host "`t`t`t`t" -nonewline; Write-host "ERROR:`tstarts with dot (.)" -BackgroundColor Red -f White}
                elseif($domainname -match '^\-'){write-host "`t`t`t`t" -nonewline; Write-host "ERROR:`tstarts with hyphen (-)" -BackgroundColor Red -f White}
                elseif($domainname -notmatch '\.'){write-host "`t`t`t`t" -nonewline; Write-host "ERROR:`tdoes not contain dot (.) as domain seperator" -BackgroundColor Red -f White}
                else{$valid = "yes"}
            }while($valid -eq "no")

# Password valicator
            DO{
                            
                $password = (Read-Host -Prompt "`t`t`t`tPlease enter a admin password")
                $valid = "no"
                if($password.Length -le 7){write-host "`t`t`t`t" -nonewline; write-host "ERROR:`tPassword too short" -BackgroundColor Red -f White}
                elseif($password -cmatch '^[a-z]*$'){write-host "`t`t`t`t" -nonewline; write-host "ERROR:`tPassword only contains lower-case letters" -BackgroundColor Red -f White}
                elseif(!($password -cmatch '[A-Z]')){write-host "`t`t`t`t" -nonewline; write-host "ERROR:`tPassword must contain Uppercase-case letter" -BackgroundColor Red -f White}
                else {$valid = "yes"}

            }while($valid -eq "no")

# Setup Active directory

                Import-Module ADDSDeployment
                Install-ADDSForest `
                -CreateDnsDelegation:$false `
                -DatabasePath "C:\Windows\NTDS" `
                -DomainMode "WinThreshold" `
                -DomainName $domainname `
                -DomainNetbiosName ($domainname.split(".")[0]).ToUpper() `
                -ForestMode "WinThreshold" `
                -Confirm:$false `
                -SafeModeAdministratorPassword (ConvertTo-SecureString -AsPlainText $password -Force) `
                -InstallDns:$true `
                -LogPath "C:\Windows\NTDS" `
                -NoRebootOnCompletion:$true `
                -SysvolPath "C:\Windows\SYSVOL" `
                -Force:$true
                
                $WarningPreference = "Continue"
                $reboot = $true
            }              
            N {Write-Host "`t`t`tNO - This step will be skipped." -f red; $reboot = $false} 

        }   
} While ($answer -notin "y","n")

# If reboot - add script to logon
    if ($reboot -eq $true){    
        #Scheduled task
        $taskName = "Windows-Server-Automator"
        $description = "Server deployment script"
        $taskAction = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-w Maximized -command iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Andreas6920/Windows-Server-Automator/main/Windows-Server-Automator.ps1'))"
        $taskTrigger = New-ScheduledTaskTrigger -Atlogon     
        Register-ScheduledTask -TaskName $taskName -Description $description -Action $taskAction -Trigger $taskTrigger
        #Reboot
        Write-Host "`t`tComputer is renamed, rebooting in 5 seconds.." -f yellow; Start-Sleep -s 5;
        Restart-Computer -Force }

# If not reboot - execute main script
    if ($reboot -eq $false){
        # Main menu
        Write-Host "`t`tModule Complete. Going back to main menu." -f yellow; Start-Sleep -S 2
        CLS; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Andreas6920/Windows-Server-Automator/main/Windows-Server-Automator.ps1'))  }



    