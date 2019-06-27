$allapacserver = "SNGPINFDCA03.apac.ad.tullib.com"
$allcorpserver = "LDNPINFDCG03.corp.ad.tullib.com"
$alleurserver = "LDNPINFDCE01.eur.ad.tullib.com"
$allnaserver = "NJCPINFDCN02.na.ad.tullib.com"
$allglobalserver = "GB00WDSSAPP03P.global.icap.com"
$allukserver = "UK0WDSSAPP04P.uk.icap.com"
$allusserver = "USICAPDCS03.us.icap.com"


$OUs = Get-ADOrganizationalUnit -Server $allukserver -Properties canonicalname -Filter *


$OUsdetail = $OUS | ForEach-Object{
        [pscustomobject]@{
            OUName = Split-Path $_.CanonicalName -Leaf
            CanonicalName = $_.CanonicalName
            UserCount = (Get-AdUser -Server $allukserver -Filter * -SearchBase $_.DistinguishedName -SearchScope OneLevel).Count
        } 
    }

$OUSdetail | Export-CSV C:\temp\UK_OUs.csv -NTI