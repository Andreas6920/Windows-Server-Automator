
    # PART 1 - Optimization
        Write-host "PART 1 - Optimize Windows" -f Green
        
        Write-host "`t`t- Installing basic features in the background" -f Yellow
            Start-Job -Name "Install Features" -ScriptBlock {Install-WindowsFeature "BitLocker","Direct-Play","Wireless-Networking","qWave"} | Out-Null
            Start-Sleep -s 1;

        Write-host "`t`t- Disable IE Security." -f Yellow
            $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
            $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
            Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0
            Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0
            Stop-Process -Name Explorer
            Start-Sleep -s 1;

        Write-host "`t`t- Disable Server Manager to pop-up when booting." -f Yellow
            If (!(Test-Path "HKLM:\Software\Microsoft\ServerManager")) {New-Item -Path "HKLM:\Software\Microsoft\ServerManager" -Force | Out-Null}
            Set-ItemProperty -Path "HKLM:\Software\Microsoft\ServerManager" -Name "DoNotOpenServerManagerAtLogon" -Type DWord -Value 1
            Start-Sleep -s 1;

        Write-host "`t`t- Disable 'Ctrl+Alt+Del to login' requirement" -f Yellow
            If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System")) {New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Force | Out-Null}
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableCAD" -Type DWord -Value 1
            Start-Sleep -s 1;

        Write-host "`t`t- Disable shutdown reason requirement" -f Yellow
            If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Reliability")) {New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Reliability" -Force | Out-Null}
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Reliability" -Name "ShutdownReasonOn" -Type DWord -Value 0
            Start-Sleep -s 1;
        
        Write-host "`t`t- Disable Microsoft Logging Tasks in scheduled tasks." -f Yellow
            Start-Job -Name "Disabe scheduled tasks" -ScriptBlock {
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\Application Experience\" -TaskName "Microsoft Compatibility Appraiser" | Out-Null
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\Application Experience\" -TaskName "ProgramDataUpdater" | Out-Null
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\Application Experience\" -TaskName "StartupAppTask" | Out-Null
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\ApplicationData\" -TaskName "DsSvcCleanup" | Out-Null
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\Autochk\" -Taskname "Proxy" | Out-Null
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\Clip\" -TaskName "License Validation" | Out-Null
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\CloudExperienceHost\" -TaskName "CreateObjectTask" | Out-Null
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\Customer Experience Improvement Program\" -TaskName "Consolidator" | Out-Null
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\Customer Experience Improvement Program\" -TaskName "UsbCeip" | Out-Null
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\Diagnosis\" -TaskName "Scheduled" | Out-Null
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\DiskDiagnostic\" -TaskName "Microsoft-Windows-DiskDiagnosticDataCollector" | Out-Null
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\DiskFootprint\" -TaskName "Diagnostics" | Out-Null
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\License Manager\" -TaskName "TempSignedLicenseExchange" | Out-Null
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\Maintenance\" -TaskName "WinSAT" | Out-Null
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\NetTrace\" -TaskName "GatherNetworkInfo" | Out-Null
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\PI\" -TaskName "Sqm-Tasks" | Out-Null
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\Power Efficiency Diagnostics\" -TaskName "AnalyzeSystem" | Out-Null
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\PushToInstall\" -TaskName "LoginCheck" | Out-Null
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\PushToInstall\" -TaskName "Registration" | Out-Null
                    Disable-ScheduledTask -TaskPath "\Microsoft\Windows\Windows Error Reporting\" -TaskName "QueueReporting" | Out-Null
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
                    N {Write-Host "`t`tNO - This PC will not be renamed." -f red -nonewline; $reboot = $false} 
                    }   
                } While ($answer -notin "y", "n")    

    # PART 3 - IP configuration
        Write-host "PART 3 - IP CONFIGURATION" -f Green; Sleep -s 2
        Do {
        Write-Host "`tYour Network Adapters:" -f yellow
        # Get network adapters
        $nic = Get-NetIPAddress -AddressFamily IPv4;"";
        foreach ($n in $nic){ $int = $n.InterfaceAlias;write-host "`t`t$int ( IP:"$n.IPAddress")" -f Yellow}; Start-Sleep -s 2;"";

        Write-Host "`tWould you like to change your IP? (y/n)" -nonewline -f Yellow;
        $answer = Read-Host " " 
        Switch ($answer) { 

        Y {
        
            Do {Write-Host "`t`t`tPlease enter the NAME of the primary network interface card" -nonewline;
                $ethernetadaptername = Read-Host " " } 

            While ($ethernetadaptername -notin ((Get-NetIPAddress -AddressFamily IPv4).InterfaceAlias)) 

            # Get network settings
                $currentip = netsh interface ip show addresses $ethernetadaptername | select-string "IP Address"
                $currentsubnet = "/"+(Get-NetIPAddress -InterfaceAlias $ethernetadaptername -AddressFamily IPv4).PrefixLength
                $currentgateway = (netsh interface ip show addresses $ethernetadaptername | select-string "Default gateway")[0]
                $currentDNS = (Get-DnsClientServerAddress -InterfaceAlias Ethernet0).ServerAddresses
                "";
                Write-Host "`t`t`tCurrent IP Settings:" -f yellow
                Write-Host "`t`t`tInterface Name:`t`t`t`t`t`t  $ethernetadaptername" -f Yellow
                Write-Host "`t`t$currentip" -f Yello
                Write-Host "`t`t`tSubnet:`t`t`t`t`t`t`t`t "$currentsubnet -f Yellow
                Write-Host "`t`t$currentgateway" -f Yellow;""; 
            

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

        N  {    Write-Host "`t`tNo, this step will be skipped." -f red; Start-Sleep -s 2;   }

} }While ($answer -notin "y", "n")


<#
if ($reboot -eq $true){    

    #Prepairing reboot
        Download next script
        start-Start-Sleep -s 3 #Waiting for new DNS to respond
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        $jobpath = 'C:\ProgramData\dc-setup.ps1'
        Invoke-WebRequest -uri "###" -OutFile $jobpath -UseBasicParsing
        Setting to start after reboot
        $name = 'dc-setup'
        #$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ep bypass -file $jobpath"
        $principal = New-ScheduledTaskPrincipal -UserId $env:username -LogonType ServiceAccount -RunLevel Highest
        $trigger = New-ScheduledTaskTrigger -AtLogOn
        Register-ScheduledTask -TaskName $Name  -Principal $principal -Action $action -Trigger $trigger -Force | Out-Null 
        Write-Host "`t`tComputer is renamed, rebooting in 5 seconds.." -f yellow; Start-Sleep -s 5;
        Restart-Computer -Force }
        New-ScheduledTaskTrigger -AtLogOn
        Register-ScheduledTask -TaskName $Name  -Principal $principal -Action $action -Trigger $trigger -Force | Out-Null 
        Write-Host "`t`tComputer is renamed, rebooting in 5 seconds.." -f yellow; Start-Sleep -s 5;
        Restart-Computer -Force 

}
#>