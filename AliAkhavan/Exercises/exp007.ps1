[int] $s=0

for ([int]$i=1000; $i -le 2000)
  {  
       $i=$i+2
    if ($i -le 2000)
    {
     $s = $s + $i
       Write-Host "Numbers are=" $i
    }  
    else
    {
   
      Write-Host "Numbers are=" $s
    }
}
