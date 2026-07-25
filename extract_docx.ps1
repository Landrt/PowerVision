$docxPath = "d:\GDG Hackthon build with IA\cahier-des-charges-boitier-socadel.docx"
$tempDir = "d:\GDG Hackthon build with IA\extracted_docx"
if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
$zipCopy = "d:\GDG Hackthon build with IA\temp_docx.zip"
Copy-Item $docxPath $zipCopy
Expand-Archive -Path $zipCopy -DestinationPath $tempDir -Force
Remove-Item $zipCopy

$xmlPath = Join-Path $tempDir "word\document.xml"
$xmlContent = Get-Content -Path $xmlPath -Raw -Encoding UTF8
[xml]$xmlDoc = $xmlContent
$nsmgr = New-Object System.Xml.XmlNamespaceManager($xmlDoc.NameTable)
$nsmgr.AddNamespace("w", "http://schemas.openxmlformats.org/wordprocessingml/2006/main")
$nodes = $xmlDoc.SelectNodes("//w:t", $nsmgr)
$result = ""
foreach ($node in $nodes) {
    $result += $node.InnerText
}
$result | Out-File -FilePath "d:\GDG Hackthon build with IA\cahier_extracted.txt" -Encoding UTF8
Write-Output "Extraction done"
