function Get-GitHubTrend {
    Param
    (
       [Parameter(Mandatory=$false)]
       [string]$target = "powershell",

       [Parameter(Mandatory=$false)]
       [string]$baseUrl = "https://github.com",

       [Parameter(Mandatory=$false)]
       [string]$regex = '\"(.*)\"',

       [Parameter(Mandatory=$false)]
       [int]$length = 5,

       [Parameter(Mandatory=$false)]
       [switch]$week,

       [Parameter(Mandatory=$false)]
       [switch]$month
    )
    if ($week) {
        $url = "$baseUrl/trending/$($target)?since=weekly"
    } elseif ($month) {
        $url = "$baseUrl/trending/$($target)?since=monthly"
    } else {
        $url = "$baseUrl/trending/$target"
    }
    
    $geturl = Invoke-WebRequest -Uri $url
    $comment = $geturl.ParsedHtml.body.getElementsByTagName('div') | 
        Where {$_.getAttributeNode('class').Value -eq 'py-1'}
    $hrefs = $geturl.ParsedHtml.body.getElementsByTagName('div') | 
        Where {$_.getAttributeNode('class').Value -eq 'd-inline-block col-9 mb-1'}


    foreach ($html in $hrefs.innerHTML) {
        $result = (([regex]::Matches($html, $regex)).Groups[1].Value)
        $href += @("$baseUrl$result")
    }

    for ($i = 0; $i -lt $length; $i++) {
        if ($href[$i] -eq $null) { return }
        Write-Host $hrefs[$i].innerText  -BackgroundColor DarkGreen
        Write-Host $comment[$i].innerText
        Write-Host $href[$i] `n
    }
}
Get-GitHubTrend