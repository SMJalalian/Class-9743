Install-Module -Name Posh-SSH -RequiredVersion 2.0.2
Install-Module -Name Posh-Cisco
function New-RandomPassword {
    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        # Length, Type uint32, Length of the random string to create.
        [Parameter(Mandatory=$true,
                   Position=0)]
        [ValidatePattern('[0-9]+')]
        [ValidateRange(1,100)]
        [uint32]
        $Length,

        # Lowercase, Type switch, Use lowercase characters.
        [Parameter(Mandatory=$false)]
        [switch]
        $Lowercase=$false,
        
        # Uppercase, Type switch, Use uppercase characters.
        [Parameter(Mandatory=$false)]
        [switch]
        $Uppercase=$false,

        # Numbers, Type switch, Use alphanumeric characters.
        [Parameter(Mandatory=$false)]
        [switch]
        $Numbers=$false,

        # Symbols, Type switch, Use symbol characters.
        [Parameter(Mandatory=$false)]
        [switch]$Symbols=$false
        )
    Begin
    {
        if (-not($Lowercase -or $Uppercase -or $Numbers -or $Symbols)) 
        {
            throw "You must specify one of: -Lowercase -Uppercase -Numbers -Symbols"
        }

        # Specifies bitmap values for character sets selected.
        $CHARSET_LOWER=1
        $CHARSET_UPPER=2
        $CHARSET_NUMBER=4
        $CHARSET_SYMBOL=8

        # Creates character arrays for the different character classes, based on ASCII character values.
        $charsLower=97..122 | %{ [Char] $_ }
        $charsUpper=65..90 | %{ [Char] $_ }
        $charsNumber=48..57 | %{ [Char] $_ }
        $charsSymbol=35,36,40,41,42,44,45,46,47,58,59,63,64,92,95 | %{ [Char] $_ }
    }
    Process
    {
        # Contains the array of characters to use.
        $charList=@()
        # Contains bitmap of the character sets selected.
        $charSets=0
        if ($Lowercase) 
        {
            $charList+=$charsLower
            $charSets=$charSets -bor $CHARSET_LOWER
        }
        if ($Uppercase) 
        {
            $charList+=$charsUpper
            $charSets=$charSets -bor $CHARSET_UPPER
        }
        if ($Numbers) 
        {
            $charList+=$charsNumber
            $charSets=$charSets -bor $CHARSET_NUMBER
        }
        if ($Symbols) 
        {
            $charList+=$charsSymbol
            $charSets=$charSets -bor $CHARSET_SYMBOL
        }

        <#
        .SYNOPSIS
            Test string for existnce specified character.
        .DESCRIPTION
            examins each character of a string to determine if it contains a specificed characters
        .EXAMPLE
            Test-StringContents i string
        #>
        function Test-StringContents([String] $test, [Char[]] $chars) 
        {
            foreach ($char in $test.ToCharArray()) 
            {
                if ($chars -ccontains $char) 
                {
                    return $true 
                }
            }
            return $false
        }

        do 
        {
            # No character classes matched yet.
            $flags=0
            $output=""
            # Create output string containing random characters.
            1..$Length | % { $output+=$charList[(get-random -maximum $charList.Length)] }

            # Check if character classes match.
            if ($Lowercase) 
            {
                if (Test-StringContents $output $charsLower) 
                {
                    $flags=$flags -bor $CHARSET_LOWER
                }
            }
            if ($Uppercase) 
            {
                if (Test-StringContents $output $charsUpper) 
                {
                    $flags=$flags -bor $CHARSET_UPPER
                }
            }
            if ($Numbers) 
            {
                if (Test-StringContents $output $charsNumber) 
                {
                    $flags=$flags -bor $CHARSET_NUMBER
                }
            }
            if ($Symbols) 
            {
                if (Test-StringContents $output $charsSymbol) 
                {
                    $flags=$flags -bor $CHARSET_SYMBOL
                }
            }
        }
        until ($flags -eq $charSets)
    }
    End
    {   
    	$output
    }
}

$AllRecords = Get-DnsServerResourceRecord -ComputerName DC -ZoneName PowerShell.Local | Where-Object -Property HostName -Like *KE*Router*
$Cred = Get-Credential
$Command1 = "aaa new-model"
$Command2 = "aaa authentication login default group radius local"
$Command3 = "aaa authorization exec default group radius local if-authenticated"
$Command4 = "radius-server host 192.168.30.210 auth-port 1645 acct-port 1646"
$Command5 = "radius-server key "

foreach ( $Record in $AllRecords ) {
    $Key = New-RandomPassword 10 -Lowercase -Uppercase 
    $Command = $Command5 + $Key   
    $Name = $Record.HostName.Split(".")
    Write-Host($Name[0] + " IP address information .... ") -ForegroundColor Yellow
    $IP = $Record.RecordData.IPv4Address.IPAddressToString    
    $SSH = New-SSHSession -ComputerName $IP -Credential $Cred -AcceptKey
    $Stream = New-SSHShellStream -Index 0 -Rows 50
    $Stream.WriteLine("conf t")
    Start-Sleep -Seconds 1
    $Stream.WriteLine($Command1)
    Start-Sleep -Seconds 1
    $Stream.WriteLine($Command2)
    Start-Sleep -Seconds 1
    $Stream.WriteLine($Command3)
    Start-Sleep -Seconds 1
    $Stream.WriteLine($Command4)
    Start-Sleep -Seconds 1
    $Stream.WriteLine($Command)
    Start-Sleep -Seconds 1
    Get-SSHSession | Remove-SSHSession 
    #Start-Sleep -Seconds 5    

    Invoke-Command -ComputerName DC -ArgumentList $Name[0], $IP, $Key -ScriptBlock{ New-NpsRadiusClient -Name $args[0] -Address $args[1] -AuthAttributeRequired $false -SharedSecret $args[2] -VendorName "RADIUS Standard"}
    #$Stream.Read()  
       
}

#New-NpsRadiusClient -Name KE-01 -Address 192.168.30.30 -AuthAttributeRequired $false -SharedSecret aaa -VendorName "RADIUS Standard"