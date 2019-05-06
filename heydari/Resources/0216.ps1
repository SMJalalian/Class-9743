
Get-CimInstance -ClassName win32_computersystem | Format-Table -property username -AutoSize -Wrap
get-CimInstance -ClassName win32_operatingsystem | Format-Table -property   caption,osarchitecture,version -AutoSize -Wrap

$c=Get-CimInstance -ClassName win32_physicalmemory #| Format-Table -property capacity -AutoSize -Wrap
$s=0
foreach ($b in $c){
$s += $b.Capacity
}
$s = $s / (1024*1024*1024)
$s 



$d=Get-CimInstance -ClassName win32_logicaldisk #|Format-Table -property size -AutoSize -Wrap
$j=0
foreach ($e in $d){
$j += $e.size
}
$j = $j /(1024*1024*1024)
$j