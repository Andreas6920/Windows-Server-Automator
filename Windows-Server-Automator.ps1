﻿# Prepare

$path_install = "C:\Program Files\WindowsPowerShell\Modules\Windows-Server-Automator"
    New-Item -ItemType Directory $path_install -ErrorAction SilentlyContinue | Out-Null
$modules = "WinSerAuto-HostConfigurator","WinSerAuto-RoleConfigurator","WinSerAuto-ADConfigurator","WinSerAuto-ShareConfigurator"
    $modules | % {iwr -useb "https://raw.githubusercontent.com/Andreas6920/Windows-Server-Automator/main/res/modules/$_.psm1" -OutFile $path_install\$_.psm1}
    iwr -useb "https://raw.githubusercontent.com/Andreas6920/Windows-Server-Automator/main/Windows-Server-Automator.ps1" -OutFile $path_install\Windows-Server-Automator.ps1
$reg_install = "HKLM:\Software\WinSerAuto"
    If (!(Test-Path $reg_install)) {New-Item -Path $reg_install -Force | Out-Null; $modules | % {Set-ItemProperty -Path $reg_install -Name $_ -Type DWord -Value 0}}

Get-ScheduledTask -TaskName "Windows-Server-Automator" -ErrorAction SilentlyContinue | Stop-ScheduledTask | out-null
Get-ScheduledTask -TaskName "Windows-Server-Automator" -ErrorAction SilentlyContinue | Disable-ScheduledTask | out-null

# Menu
$logo = 
"

██╗    ██╗██╗███╗   ██╗██████╗  ██████╗ ██╗    ██╗███████╗    ███████╗███████╗██████╗ ██╗   ██╗███████╗██████╗ 
██║    ██║██║████╗  ██║██╔══██╗██╔═══██╗██║    ██║██╔════╝    ██╔════╝██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗
██║ █╗ ██║██║██╔██╗ ██║██║  ██║██║   ██║██║ █╗ ██║███████╗    ███████╗█████╗  ██████╔╝██║   ██║█████╗  ██████╔╝
██║███╗██║██║██║╚██╗██║██║  ██║██║   ██║██║███╗██║╚════██║    ╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██╔══╝  ██╔══██╗
╚███╔███╔╝██║██║ ╚████║██████╔╝╚██████╔╝╚███╔███╔╝███████║    ███████║███████╗██║  ██║ ╚████╔╝ ███████╗██║  ██║
 ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝╚═════╝  ╚═════╝  ╚══╝╚══╝ ╚══════╝    ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝
                                                                                                               
                 █████╗ ██╗   ██╗████████╗ ██████╗ ███╗   ███╗ █████╗ ████████╗ ██████╗ ██████╗                
                ██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗████╗ ████║██╔══██╗╚══██╔══╝██╔═══██╗██╔══██╗               
                ███████║██║   ██║   ██║   ██║   ██║██╔████╔██║███████║   ██║   ██║   ██║██████╔╝               
                ██╔══██║██║   ██║   ██║   ██║   ██║██║╚██╔╝██║██╔══██║   ██║   ██║   ██║██╔══██╗               
                ██║  ██║╚██████╔╝   ██║   ╚██████╔╝██║ ╚═╝ ██║██║  ██║   ██║   ╚██████╔╝██║  ██║               
                ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝               
                                                                     
Version 0.3
Creator: Andreas6920 | https://github.com/Andreas6920/


"                                                                   

# Change menu color if module already executed
if ((Get-ItemProperty -Path $reg_install -Name "WinSerAuto-HostConfigurator")."WinSerAuto-HostConfigurator" -ne 0){$menu1 = "DarkGray"} else {$menu1 = "Green"}
if ((Get-ItemProperty -Path $reg_install -Name "WinSerAuto-RoleConfigurator")."WinSerAuto-RoleConfigurator" -ne 0){$menu2 = "DarkGray"} else {$menu2 = "Green"}
if ((Get-ItemProperty -Path $reg_install -Name "WinSerAuto-ADConfigurator")."WinSerAuto-ADConfigurator" -ne 0){$menu3 = "DarkGray"} else {$menu3 = "Green"}
if ((Get-ItemProperty -Path $reg_install -Name "WinSerAuto-ShareConfigurator")."WinSerAuto-ShareConfigurator" -ne 0){$menu4 = "DarkGray"} else {$menu4 = "Green"}

# Option list
Clear-Host
"";Write-host $logo -f Green;"";
Write-host "`t`t1) Host Configurator`t`t( Server Optimizer / Hostname / IP )" -f $menu1
Write-host "`t`t2) Baserole Configurator`t( Server Role / Domain Name )" -f $menu2
Write-host "`t`t3) AD Configurator`t`t( OU creation / User Creation / CSV import )" -f $menu3
Write-host "`t`t4) Share Configurator`t`t( Security Group Creator / NTFS / SMB )" -f $menu4
Write-host "`t`t0) Exit" -f Green
Write-host "" -f Green
"";"";

# User input
do {
    Write-Host "Choose your option:`t" -f Green -nonewline; ; ;
    $selection = Read-Host
    Switch ($selection) {

        1 {    CLS;Import-Module "$path_install\WinSerAuto-HostConfigurator"    }
        2 {    CLS;Import-Module "$path_install\WinSerAuto-RoleConfigurator"    }
        3 {    CLS;Import-Module "$path_install\WinSerAuto-ADConfigurator"      }
        4 {    CLS;Import-Module "$path_install\WinSerAuto-ShareConfigurator"   }
        0 {                                                                     }
   
    }}
while ($selection -ne 0 )