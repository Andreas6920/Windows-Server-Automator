# PART 1 - Initial configurations

    ## PART 1.1 - COMPUTERNAME
    Write-host "PART 1.1 - PC NAME" -f Green
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

## PART 1.2 - IP CONFIGURATION
Write-host "PART 1.2 - IP CONFIGURATION" -f Green; Sleep -s 2
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
        Write-Host "`t`t`tIP SETTING COMPLETE!" -f yellow; Start-Sleep -S 1
        }
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