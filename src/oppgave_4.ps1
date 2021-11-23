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

# kortstokkTilStreng -kortstokk $kortstokk
Write-Output "Kortstokk: $(kortStokkTilStreng -kortstokk $kortstokk)"