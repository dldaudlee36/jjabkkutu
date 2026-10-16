$baseDir = "c:\Users\User\Documents\antigravity\calm-salk\kkutu"
$indexPath = Join-Path $baseDir "index.html"

Write-Host "Reading existing index.html to extract HTML body..."
$lines = [System.IO.File]::ReadAllLines($indexPath, [System.Text.Encoding]::UTF8)

# Find </style>
$styleCloseIdx = -1
for ($i = 0; $i -lt [Math]::Min(2000, $lines.Length); $i++) {
    if ($lines[$i].Trim() -eq "</style>") {
        $styleCloseIdx = $i
        break
    }
}

# Find <script>
$scriptTagIdx = -1
for ($i = $styleCloseIdx; $i -lt [Math]::Min(2500, $lines.Length); $i++) {
    if ($lines[$i].Trim() -eq "<script>") {
        $scriptTagIdx = $i
        break
    }
}

if ($styleCloseIdx -eq -1 -or $scriptTagIdx -eq -1) {
    throw "Could not find </style> or <script> markers!"
}

# Extract HTML body between </style> and <script>
$bodyHtml = [string]::Join("`r`n", $lines[($styleCloseIdx + 1)..($scriptTagIdx - 1)])

# Read fresh CSS
$css = [System.IO.File]::ReadAllText((Join-Path $baseDir "css\style.css"), [System.Text.Encoding]::UTF8)

# Read fresh JS parts
$peerjs = [System.IO.File]::ReadAllText((Join-Path $baseDir "js\peerjs.min.js"), [System.Text.Encoding]::UTF8)
if ($peerjs -match "^\s*Title:\s*Live Content") {
    throw "peerjs.min.js still contains markdown headers at start!"
}

$hangul = [System.IO.File]::ReadAllText((Join-Path $baseDir "js\hangul.js"), [System.Text.Encoding]::UTF8)
$wordsDb = [System.IO.File]::ReadAllText((Join-Path $baseDir "js\words_db.js"), [System.Text.Encoding]::UTF8)
$dictionary = [System.IO.File]::ReadAllText((Join-Path $baseDir "js\dictionary.js"), [System.Text.Encoding]::UTF8)
$app = [System.IO.File]::ReadAllText((Join-Path $baseDir "js\app.js"), [System.Text.Encoding]::UTF8)

$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("<!DOCTYPE html>")
[void]$sb.AppendLine('<html lang="ko" data-theme="simple-dark">')
[void]$sb.AppendLine("<head>")
[void]$sb.AppendLine('  <meta charset="UTF-8" />')
[void]$sb.AppendLine('  <meta name="viewport" content="width=device-width, initial-scale=1.0" />')
$titleText = [System.Text.Encoding]::UTF8.GetString([byte[]]@(0xEB,0x81,0x84,0xED,0x88,0xAC,0x20,0x4C,0x49,0x54,0x45,0x20,0xC2,0xB7,0x20,0xEC,0x8B,0xA4,0xEC,0x8B,0x9C,0xEA,0xB0,0x84,0x20,0xEB,0x81,0x9D,0xEB,0xA7,0x90,0xEC,0x9E,0x87,0xEA,0xB8,0xB0))
[void]$sb.AppendLine("  <title>$titleText</title>")
[void]$sb.AppendLine("  <style>")
[void]$sb.AppendLine($css)
[void]$sb.AppendLine("  </style>")
[void]$sb.AppendLine("</head>")
[void]$sb.AppendLine($bodyHtml)
[void]$sb.AppendLine("  <script>")
[void]$sb.AppendLine("/* --- PeerJS WebRTC Library --- */")
[void]$sb.AppendLine($peerjs)
[void]$sb.AppendLine("/* --- Hangul Decomposition Engine --- */")
[void]$sb.AppendLine($hangul)
[void]$sb.AppendLine("/* --- 332,231 Standard Korean Words DB --- */")
[void]$sb.AppendLine($wordsDb)
[void]$sb.AppendLine("/* --- Dictionary Engine --- */")
[void]$sb.AppendLine($dictionary)
[void]$sb.AppendLine("/* --- Main Game App --- */")
[void]$sb.AppendLine($app)
[void]$sb.AppendLine("  </script>")
[void]$sb.AppendLine("</body>")
[void]$sb.AppendLine("</html>")

$finalHtml = $sb.ToString()

[System.IO.File]::WriteAllText($indexPath, $finalHtml, [System.Text.Encoding]::UTF8)
$destFile = Get-ChildItem -Path $baseDir -Filter "*단일파일*.html" | Select-Object -First 1
if ($destFile) {
    Copy-Item -LiteralPath $indexPath -Destination $destFile.FullName -Force
} else {
    Copy-Item -LiteralPath $indexPath -Destination (Join-Path $baseDir ([System.Text.Encoding]::UTF8.GetString([byte[]]@(0xEB,0x81,0x84,0xED,0x88,0xAC,0x2D,0xEB,0x8B,0xA8,0xEC,0x9D,0xBC,0xED,0x8C,0x8C,0xEC,0x9D,0xBC,0x2E,0x68,0x74,0x6D,0x6C)))) -Force
}

Write-Host "Success! Bundled single-file index.html ($($finalHtml.Length) chars) with 6 new themes!"
