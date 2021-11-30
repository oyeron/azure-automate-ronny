[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $UrlKortstokk 
)

$ErrorActionPreference = 'Stop'

# Leser kortstokk fra url
try {
    $kortstokk = Invoke-WebRequest -Uri $UrlKortstokk
}
catch {
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

# Alterativ måte til Switch
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

# Skriver ut kortstokk og poengsum
Write-Output "Kortstokk: $(kortStokkTilStreng -kortstokk $kortstokk)"
Write-Host "Poengsum: $($poengKortstokk)"

$meg = $kortstokk[0..1]                         # Deler ut de to første kortene i kortstokken til meg selv
$kortstokk = $kortstokk[2..$kortstokk.Count]    # Fjerner de to første kortene fra kortstokken
$Magnus = $kortstokk[0..1]
$kortstokk = $kortstokk[2..$kortstokk.Count] 

# Skriver ut kortene til meg og Magnus 
Write-Output "meg: $(kortstokkTilStreng -kortstokk $meg)"
Write-Output "Magnus: $(kortstokkTilStreng -kortstokk $Magnus)"

# Skriver deretter ut resterende kort i kortstokken
Write-Output "Kortstokk: $(kortstokkTilStreng -kortstokk $kortstokk)" 


function skrivUtResultat {
    param (
        [string]
        $vinner,        
        [object[]]
        $kortStokkMagnus,
        [object[]]
        $kortStokkMeg        
    )
    Write-Output "Vinner: $vinner"
    Write-Output "magnus | $(sumPoengKortstokk -kortstokk $kortStokkMagnus) | $(kortstokkTilStreng -kortstokk $kortStokkMagnus)"    
    Write-Output "meg    | $(sumPoengKortstokk -kortstokk $kortStokkMeg)    | $(kortstokkTilStreng -kortstokk $kortStokkMeg)"
}

# bruker 'blackjack' som et begrep - er 21
$blackjack = 21

if ((sumPoengKortstokk -kortstokk $meg) -eq $blackjack) {
    skrivUtResultat -vinner "meg" -kortStokkMagnus $Magnus -kortStokkMeg $meg
    exit
}
elseif ((sumPoengKortstokk -kortstokk $Magnus) -eq $blackjack) {
    skrivUtResultat -vinner "magnus" -kortStokkMagnus $Magnus -kortStokkMeg $meg
    exit
}


while ((sumPoengKortstokk -kortstokk $meg) -lt 17) {
    $meg += $kortstokk[0]
    $kortstokk = $kortstokk[1..$kortstokk.Count]
}

if ((sumPoengKortstokk -kortstokk $meg) -gt $blackjack) {
    skrivUtResultat -vinner "magnus" -kortStokkMagnus $magnus -kortStokkMeg $meg
    exit
}


while ((sumPoengKortstokk -kortstokk $Magnus) -le (sumPoengKortstokk -kortstokk $meg)) {
    $Magnus += $kortstokk[0]
    $kortstokk = $kortstokk[1..$kortstokk.Count]
}

# Magnus taper spillet dersom poengsummen er høyere enn 21
if ((sumPoengKortstokk -kortstokk $Magnus) -gt $blackjack) {
    skrivUtResultat -vinner "meg" -kortStokkMagnus $magnus -kortStokkMeg $meg
    exit
}

# Skriver ut hvem som vinner spillet
skrivUtResultat -vinner "magnus" -kortStokkMagnus $magnus -kortStokkMeg $meg