# Prepare
$path_install = "C:\Program Files\WindowsPowerShell\Modules\Windows-Server-Automator"
    New-Item -ItemType Directory $path_install -ErrorAction SilentlyContinue | Out-Null

$modules = "WinSerAuto-HostConfigurator","WinSerAuto-RoleConfigurator","WinSerAuto-ADConfigurator","WinSerAuto-ShareConfigurator"
    $modules | % {iwr -useb "https://raw.githubusercontent.com/Andreas6920/Windows-Server-Automator/main/res/modules/$_.psm1" -OutFile $path_install\$_.psm1; Start-Sleep -s 1}

$reg_install = "HKLM:\Software\WinSerAuto"
    If (!(Test-Path $reg_install)) {New-Item -Path $reg_install -Force | Out-Null; $modules | % {Set-ItemProperty -Path $reg_install -Name $_ -Type DWord -Value 0 | Out-Null}}


# Menu
Clear-Host
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
                                                                     
Version 0.2
Creator: Andreas6920 | https://github.com/Andreas6920/


"                                                                   

# Change color if module already executed
if ((Get-ItemProperty -Path $reg_install -Name "WinSerAuto_HostConfigurator").WinSerAuto_HostConfigurator -eq 0){$menu1 = "Green"} else {$menu1 = "DarkGray"}
if ((Get-ItemProperty -Path $reg_install -Name "WinSerAuto_RoleConfigurator").WinSerAuto_RoleConfigurator -eq 0){$menu2 = "Green"} else {$menu2 = "DarkGray"}
if ((Get-ItemProperty -Path $reg_install -Name "WinSerAuto_ADConfigurator").WinSerAuto_ADConfigurator -eq 0){$menu3 = "Green"} else {$menu3 = "DarkGray"}
if ((Get-ItemProperty -Path $reg_install -Name "WinSerAuto_ShareConfigurator").WinSerAuto_ShareConfigurator -eq 0){$menu4 = "Green"} else {$menu4 = "DarkGray"}

# Option list
Clear-Host
"";
Write-host $logo -f Green
"";
Write-host "`t`t1) Host Configurator`t`t( Server Optimizer / Hostname / IP )" -f $menu1
Write-host "`t`t2) Baserole Configurator`t( Server Role / Domain Name )" -f $menu2
Write-host "`t`t3) AD Configurator`t`t`t( OU creation / User Creation / CSV import )" -f $menu3
Write-host "`t`t4) Share Configurator`t`t( Security Group Creator / NTFS / SMB )" -f $menu4
Write-host "`t`t0) Exit" -f Green
"";"";

# User input
do {
    Write-Host "Choose your option:`t" -f Green -nonewline; ; ;
    $selection = Read-Host
    Switch ($selection) {

        1 {    Import-Module "$path_install\WinSerAuto-HostConfigurator"    }
        2 {    Import-Module "$path_install\WinSerAuto-RoleConfigurator"    }
        3 {    Import-Module "$path_install\WinSerAuto-ADConfigurator"      }
        4 {    Import-Module "$path_install\WinSerAuto-ShareConfigurator"   }
        0 {                                                                 }
   
    }}
while ($selection -ne 0 )