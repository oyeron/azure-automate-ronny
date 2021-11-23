[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $UrlKortstokk 
)

$ErrorActionPreference = 'Stop'

# Leser kortstokk fra url
try{
    $kortstokk = Invoke-WebRequest -Uri $UrlKortstokk
}
catch{
    Write-Host "Ugyldig url"
    Exit 1
}


# konverterer fra json-streng til intern datatype
$kortstokk = ConvertFrom-Json -InputObject $kortstokk.Content       


function kortstokkTilStreng {
    [OutputType([string])]
    param (
        [object[]]
        $kortstokk
    )
    $streng = ""
    foreach ($kort in $kortstokk) {
        $streng = $streng + "$($kort.suit[0])" + "$($kort.value)" + " "
    }
    return $streng
}

$poengKortstokk = 0

foreach ($kort in $kortstokk) {
    if ($kort.value -ceq 'J') {
        $poengKortstokk = $poengKortstokk + 10
    }
    elseif ($kort.value -ceq 'Q') {
        $poengKortstokk = $poengKortstokk + 10
    }
    elseif ($kort.value -ceq 'K') {
        $poengKortstokk = $poengKortstokk + 10
    }
    elseif ($kort.value -ceq 'A') {
        $poengKortstokk = $poengKortstokk + 11
    }
    else {
        $poengKortstokk = $poengKortstokk + $kort.value
    }
}

function sumPoengKortstokk {
    [OutputType([int])]
    param (
        [object[]]
        $kortstokk
    )

    $poengKortstokk = 0

    foreach ($kort in $kortstokk) {
        # Undersøk hva en Switch er
        $poengKortstokk += switch ($kort.value) {
            { $_ -cin @('J', 'Q', 'K') } { 10 }
            'A' { 11 }
            default { $kort.value }
        }
    }
    return $poengKortstokk
}

# kortstokkTilStreng -kortstokk $kortstokk
Write-Output "Kortstokk: $(kortStokkTilStreng -kortstokk $kortstokk)"
Write-Host "Poengsum: $($poengKortstokk)"