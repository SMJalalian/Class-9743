function Get-pwsysteminfo {
    param (
        $Pcname
    )
    $osinfo      = Get-CimInstance -ComputerName $Pcname Win32_OperatingSystem 
    $computersys = Get-CimInstance -ComputerName $Pcname Win32_ComputerSystem
    $totalmemory = Get-CimInstance Win32_PhysicalMemory -ComputerName $Pcname | Measure-Object -Property capacity -Sum | Foreach {"{0:N2}" -f ([math]::round(($_.Sum / 1GB),2))}
    $hardinfo    = Get-CimInstance Win32_DiskDrive -ComputerName $Pcname | Measure-Object -Property size -Sum | Foreach {"{0:N2}" -f ([math]::round(($_.Sum / 1GB),2))}
    

#$osinfo.Caption
#$osinfo.OSType
#$osinfo.Version
#$osinfo.OSArchitecture
#$totalmemory
#$hardinfo
#$computersys.UserName

$obj = new-object psobject
Add-Member -InputObject $obj -MemberType NoteProperty -Name "oscaption" -Value $osinfo.Caption
Add-Member -InputObject $obj -MemberType NoteProperty -Name "osversion" -Value $osinfo.Version
Add-Member -InputObject $obj -MemberType NoteProperty -Name "osArchitecture" -Value $osinfo.OSArchitecture
Add-Member -InputObject $obj -MemberType NoteProperty -Name "totalmemory" -Value $totalmemory
Add-Member -InputObject $obj -MemberType NoteProperty -Name "hardinfo" -Value $hardinfo
Add-Member -InputObject $obj -MemberType NoteProperty -Name "pcusername" -Value $computersys.UserName
return $obj
}

$X = Get-pwsysteminfo -Pcname Server-02

