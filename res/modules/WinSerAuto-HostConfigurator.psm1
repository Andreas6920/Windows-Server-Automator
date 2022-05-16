
    # PART 1 - Optimization
        Write-host "PART 1 - Optimize Windows" -f Green
            
        Write-host "`t- Installing basic features in the background" -f Yellow
            Start-Job -Name "Install Features" -ScriptBlock {Install-WindowsFeature "BitLocker","Direct-Play","Wireless-Networking","qWave"} | Out-Null
            Start-Sleep -s 1;

        Write-host "`t- Disable IE Security." -f Yellow
            $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
            $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
            Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0
            Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0
            Stop-Process -Name Explorer; Start-Process Explorer
            Start-Sleep -s 1;

        Write-host "`t- Disable Server Manager to pop-up when booting." -f Yellow
            If (!(Test-Path "HKLM:\Software\Microsoft\ServerManager")) {New-Item -Path "HKLM:\Software\Microsoft\ServerManager" -Force | Out-Null}
            Set-ItemProperty -Path "HKLM:\Software\Microsoft\ServerManager" -Name "DoNotOpenServerManagerAtLogon" -Type DWord -Value 1
            Start-Sleep -s 1;

        Write-host "`t- Disable 'Ctrl+Alt+Del to login' requirement" -f Yellow
            If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System")) {New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Force | Out-Null}
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableCAD" -Type DWord -Value 1
            Start-Sleep -s 1;

        Write-host "`t- Disable shutdown reason requirement" -f Yellow
            If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Reliability")) {New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Reliability" -Force | Out-Null}
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Reliability" -Name "ShutdownReasonOn" -Type DWord -Value 0
            Start-Sleep -s 1;
        
        Write-host "`t- Disable Microsoft Logging Tasks in scheduled tasks." -f Yellow
            Start-Job -Name "Disabe scheduled tasks" -ScriptBlock {
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\Application Experience\" -TaskName "Microsoft Compatibility Appraiser"
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\Application Experience\" -TaskName "ProgramDataUpdater"
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\Application Experience\" -TaskName "StartupAppTask"
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\ApplicationData\" -TaskName "DsSvcCleanup"
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\Autochk\" -Taskname "Proxy"
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\Clip\" -TaskName "License Validation"
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\CloudExperienceHost\" -TaskName "CreateObjectTask"
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\Customer Experience Improvement Program\" -TaskName "Consolidator"
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\Customer Experience Improvement Program\" -TaskName "UsbCeip"
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\Diagnosis\" -TaskName "Scheduled"
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\DiskDiagnostic\" -TaskName "Microsoft-Windows-DiskDiagnosticDataCollector"
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\DiskFootprint\" -TaskName "Diagnostics"
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\License Manager\" -TaskName "TempSignedLicenseExchange"
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\Maintenance\" -TaskName "WinSAT"
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\NetTrace\" -TaskName "GatherNetworkInfo"
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\PI\" -TaskName "Sqm-Tasks"
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\Power Efficiency Diagnostics\" -TaskName "AnalyzeSystem"
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\PushToInstall\" -TaskName "LoginCheck"
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\PushToInstall\" -TaskName "Registration"
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\Windows Error Reporting\" -TaskName "QueueReporting"
            } | Out-Null | Wait-Job
            Start-Sleep -s 1;

# PART 2 - Computername
    Write-host "PART 2- PC NAME" -f Green
        Do {
            Write-Host "`tCurrent PC Name:" -f yellow -nonewline; Write-Host " $env:computername" -f Yellow
            Write-Host "`tWould you like to rename this PC? (y/n)" -nonewline -f Yellow;
            $answer = Read-Host " " 
            Switch ($answer) { 
                Y {
                    $WarningPreference = "SilentlyContinue"
                    Write-Host "`t`tNew PC name" -nonewline;
                    $PCname = Read-Host " "
                    Rename-computer -newname $PCname
                    $WarningPreference = "Continue"
                    $reboot = $true
                    Write-Host "`t`tComputer description" -NoNewline
                    $Description = Read-Host " " 
                    $ThisPCDescription=Get-WmiObject -class Win32_OperatingSystem
                    $ThisPCDescription.Description=$Description
                    $ThisPCDescription.put() | out-null
                    Write-Host "`t`tComputer renamed. PC will reboot after IP configuration." -f yellow; Sleep -s 2
                    "";}
                N {Write-Host "`tNO - This PC will not be renamed." -f Yellow ; $reboot = $false} 
                }   
         } While ($answer -notin "y", "n")    

# PART 3 - IP configuration
    Write-host "PART 3 - IP CONFIGURATION" -f Green; Sleep -s 2
    # Get network settings
        $ethernetadaptername = (Test-NetConnection -ComputerName www.google.com).InterfaceAlias
        $currentip = (Get-NetIPAddress | ? AddressFamily -eq IPv4 |? InterfaceAlias -eq  $ethernetadaptername).IPAddress
        $currentsubnet = "/"+(Get-NetIPAddress -InterfaceAlias $ethernetadaptername -AddressFamily IPv4).PrefixLength
        $currentgateway = ((Get-NetIPConfiguration | ? InterfaceAlias -eq $ethernetadaptername).IPv4DefaultGateway).NextHop
        $currentDNS = (Get-DnsClientServerAddress -InterfaceAlias Ethernet0).ServerAddresses

        Write-Host "`tYour Network Settings:" -f yellow
        "";
        Write-Host "`t`tCurrent IP Settings:" -f yellow
        Write-Host "`t`tInterface Name:`t`t`t`t$ethernetadaptername" -f Yellow
        Write-Host "`t`tIP:`t`t`t`t`t$currentip" -f Yello
        Write-Host "`t`tSubnet:`t`t`t`t`t$currentsubnet" -f Yellow
        Write-Host "`t`tDefault Gateway:`t`t`t$currentgateway" -f Yellow;""; 


    Do {
    Write-Host "`tWould you like to change your IP? (y/n)" -nonewline -f Yellow;
    $answer = Read-Host " " 
    Switch ($answer) { 

        Y {
            # Enter New adapter settings
            Do {Write-Host "`t`t`tEnter new IP Address" -f yellow -NoNewline
            $newIP = Read-Host " " } While ($newIP -notmatch "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}")
            Do {Write-Host "`t`t`tEnter new SUBNET VALUE (example: 24, 16, 8)" -f yellow -NoNewline
            $newSubnet = Read-Host " "} While ($newSubnet -notin 8..30)
            Do {Write-Host "`t`t`tEnter new gateway IP:" -f yellow -NoNewline
            $newGW = Read-Host " "} While ($newGW -notmatch "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}")
            Do {Write-Host "`t`t`tEnter new DNS IP:" -f yellow -NoNewline
            $newDNS = Read-Host " "} While ($newDNS -notmatch "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}")

            # Configure new settings
            "";
            Write-Host "`t`t`tNEW CONFIGURATION IS BEING SET:" -f yellow;
            Write-Host "`t`t`t - Clearing current settings.." -f Yellow;
            Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\services\Tcpip\Parameters\Interfaces\$((Get-NetAdapter -InterfaceAlias $ethernetadaptername).InterfaceGuid) -Name EnableDHCP -Value 0 -ea SilentlyContinue
            Remove-NetIpAddress -InterfaceAlias $ethernetadaptername -AddressFamily IPv4 -Confirm:$false -ErrorAction SilentlyContinue
            Remove-NetRoute -InterfaceAlias $ethernetadaptername -AddressFamily IPv4 -Confirm:$false -ErrorAction SilentlyContinue
            Start-Sleep -s 2

            Write-Host "`t`t`t - Setting new IP..." -f Yellow; Start-Sleep -s 1
            Write-Host "`t`t`t - Setting new Subnet..." -f Yellow; Start-Sleep -s 1
            Write-Host "`t`t`t - Setting new Gateway..." -f Yellow; Start-Sleep -s 1
            New-NetIpAddress -InterfaceAlias $ethernetadaptername -IpAddress $newIP -PrefixLength $newSubnet -DefaultGateway $newGW -AddressFamily IPv4 | out-null
            Write-Host "`t`t`t - Setting new DNS..." -f Yellow; Start-Sleep -s 1
            Set-DnsClientServerAddress -InterfaceAlias $ethernetadaptername -ServerAddresses $newDNS | out-null
            Write-Host "`t`t`tIP SETTING COMPLETE!" -f yellow; Start-Sleep -S 1}

        N  {    Write-Host "`t`tNo, this step will be skipped." -f red; Start-Sleep -s 2;    }
                } 
    }While ($answer -notin "y", "n")


# Part 4 - Post script
    
    Set-ItemProperty -Path "HKLM:\Software\WinSerAuto\" -Name "WinSerAuto_HostConfigurator"  -Type DWord -Value 1 | Out-Null
    


    if ($reboot -eq $true){    

        #Prepairing reboot
        
        $action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ep bypass -file $script"
        $principal = New-ScheduledTaskPrincipal -UserId $env:username -LogonType ServiceAccount -RunLevel Highest
        $trigger = New-ScheduledTaskTrigger -AtLogOn 
        $script = "C:\Program Files\WindowsPowerShell\Modules\Windows-Server-Automator\Windows-Server-Automator.ps1"
            New-Item -ItemType Directory ($script | Split-path) -ErrorAction SilentlyContinue | Out-Null
            if(!(test-path $script)){
            [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
            Invoke-WebRequest -uri "https://raw.githubusercontent.com/Andreas6920/Windows-Server-Automator/main/Windows-Server-Automator.ps1" -OutFile $script -UseBasicParsing}
        Register-ScheduledTask -TaskName "Windows-Server-Automator" -Principal $principal -Action $action -Trigger $trigger -Force | Out-Null 

        Write-Host "`t`tComputer is renamed, rebooting in 5 seconds.." -f yellow; Start-Sleep -s 5;
        Restart-Computer -Force }
#>