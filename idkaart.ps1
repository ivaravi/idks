#########[version]$VersionNow = 0.0.1
[version]$VersionNow = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -match "Eesti ID-kaardi" } | % {$_.Version}
#Praeguseks versiooni muutujaks panin $VersionNow. 
#Otsin "Eesti ID-kaardi" fraasi installitud tarkvara listist, ning kuvan selle versiooni. 
#Saan teada praeguse versiooni.
#[version] ette kirjutades määran ära andmetüübi kuidas mulle seda kuvatakse.
[xml]$xml = (Invoke-WebRequest –Uri ‘https://installer.id.ee/media/windows/win64_stable.xml’).Content
#Invoke-WebRequest abiga saan internetilehe sisu, ning URI parameetriga otsin infot täpsemalt.
#[xml] ette kirjutades määran ära andmetüübi kuidas mulle seda kuvatakse ehk xml dokumendis.
#Kasutan Default "Laadi alla" nupu downloadi mis on 64 bitine stabiilne versioon.
#Võtan sellest .xml, et oleks kergem töödelda.
#Content abil laaditakse see võrgust alla mälusse ja tehtakse xml objektist contect object.
[version]$VersionUp = $xml.products.product.ProductVersion
#Kõige uuemaks versiooni muutujaks panin $VersionUp.
#Saan teada kõige uuema ja stabiilsema versiooni tarkvarast.
$InstallRequired = [version]$VersionUp -gt [version]$VersionNow
#Kui netis oleva versiooni number on suurem kui olemasoleva versiooni number siis tõmmatakse uus versioon.
If( $InstallRequired ) {
#Kui temp kausta ei ole kuhu tarkvara setup tõmmatakse, siis tehakse temp kaust.
#Kui temp kaust on olemas siis ei tehta kausta.
If (-Not (Test-Path C:\Temp)) {New-Item -ItemType directory -Path C:\Temp}
Start-BitsTransfer -Source ("https://installer.id.ee/media/windows/" + $xml.products.product.FileName) -Destination C:\Temp\
#Start-BitsTransfer'i commandiga alustatakse  uue versiooni allalaadimist.
#Võetakse kõige uuema ja stabiilsema versiooni nimi ja lisatakse see URLile kus setupid paiknevad ja laetakse alla.
Start-Process ("C:\Temp\" + $xml.products.product.FileName) -ArgumentList "/qn" -Wait
}
#Pannakse temp folderist setup tööle ja installitakse uus versioon peale..
Remove-Item ("C:\Temp\" + $xml.products.product.FileName)