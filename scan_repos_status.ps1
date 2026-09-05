<#
.SYNOPSIS
    Tự động quét chi tiết tình trạng toàn bộ các repository trong E:\App AI,
    nhận diện chính xác từng file đang sửa dở, chi tiết commit và lịch sử thay đổi.
#>
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$ParentDir = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path (Join-Path $ParentDir "Mini-app-QLDA"))) {
    $ParentDir = $PSScriptRoot
}

$nowStr = (Get-Date -Format "dd/MM/yyyy HH:mm:ss")
Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host " >> QUET CHI TIET THAY DOI REPOSITORY - E:\App AI" -ForegroundColor Yellow
Write-Host " Thoi gian: $nowStr" -ForegroundColor Gray
Write-Host "========================================================`n" -ForegroundColor Cyan

$metadata = @{
    "Mini-app-QLDA" = @{
        Priority = "P0"
        Category = "active p0p1 git"
        Desc = "Quan ly du an dau tu cong, giai ngan von & vuong mac qua Zalo Mini App va Web."
        Progress = 70
        Tech = @("FastAPI", "TypeScript", "ZaUI", "PostgreSQL", "Docker")
        Blocker = "Dang dung temporary tunnel; cho Zalo App ID de submit review Mini App."
        Action = "Commit tai lieu cutover-plan & runbook do dang; chuan bi gateway."
        QuickCmd = "poetry run uvicorn app.main:app --reload"
    }
    "SmartDoc-UIpath" = @{
        Priority = "P0"
        Category = "active p0p1 git"
        Desc = "Sinh van ban hanh chinh & quyet dinh tu dong thay the UiPath, Word Task Pane 2016."
        Progress = 80
        Tech = @("FastAPI", "python-docx", "SQLite", "Office.js")
        Blocker = "Can xac thuc nguoi dung va manifest ben vung truoc khi chay LAN."
        Action = "Git pull commit moi tu origin/main; nap mau TB phan cong nhiem vu vao DB."
        QuickCmd = "poetry run uvicorn app.main:app --port 8000 --reload"
    }
    "Zalo-work-hub" = @{
        Priority = "P1"
        Category = "active p0p1"
        Desc = "Bot dieu hanh cong viec, boc tach tin nhan tieng Viet & nhac hen 4 moc qua Zalo."
        Progress = 65
        Tech = @("FastAPI", "SQLite WAL", "Streamlit", "OpenZCA", "Ubuntu")
        Blocker = "Can may chu Ubuntu co OpenZCA CLI va cau hinh danh muc assignee_routes."
        Action = "Deploy 3 systemd services len Ubuntu server va cau hinh mapping Zalo."
        QuickCmd = "poetry run streamlit run app/dashboard/dashboard_app.py"
    }
    "AI-STock" = @{
        Priority = "P1"
        Category = "active p0p1"
        Desc = "Nen tang phan tich dinh luong chung khoan VN (CANSLIM, Minervini) & bot Telegram 24/7."
        Progress = 85
        Tech = @("Python", "Streamlit", "vnstock v4", "SQLite", "GitHub Actions")
        Blocker = "Can giam sat do on dinh cron GitHub Actions 15:05 hang ngay."
        Action = "Giam sat runner atomic va mo rong bo loc nhom nganh co phieu."
        QuickCmd = "streamlit run app.py"
    }
    "personal-agentkit" = @{
        Priority = "P2"
        Category = "active"
        Desc = "He thong quan ly & dong bo Skills, Agents, Hooks, Rules cho Antigravity, Cursor, Codex."
        Progress = 85
        Tech = @("PowerShell", "Markdown", "JSON Schema", "106 Skills")
        Blocker = "Chua co remote repository tren GitHub (moi commit cuc bo)."
        Action = "Tao private GitHub repo de push ma nguon va viet them skill xay dung."
        QuickCmd = ".\sync.ps1"
    }
    "law-wiki-bidding-v2" = @{
        Priority = "P2"
        Category = "active"
        Desc = "Co so tri thuc Luat Dau thau 2023, ND 214/2025, TT 79, TT 80/2025 (LLM Wiki Graph)."
        Progress = 75
        Tech = @("Markdown", "Obsidian", "Python Ingest", "Knowledge Graph")
        Blocker = "Chua co giao dien tra cuu truc tiep; chua tong hop so sanh quy trinh."
        Action = "Soan thao bai tong hop so sanh quy trinh va tich hop chatbot RAG."
        QuickCmd = "obsidian://open?vault=law-wiki-bidding-v2"
    }
    "GPMB-SmartAuto" = @{
        Priority = "P3"
        Category = "stubs"
        Desc = "Ke hoach tu dong hoa ho so boi thuong, ho tro tai dinh cu & giai phong mat bang."
        Progress = 5
        Tech = @("Blueprint", "Chua co code")
        Blocker = "Chua co dac ta nghiep vu va kien truc."
        Action = "Soan thao tai lieu dac ta luong kiem dem va phuong an boi thuong."
        QuickCmd = ""
    }
    "Skills" = @{
        Priority = "P3"
        Category = "stubs"
        Desc = "Kho tai lieu tho chua 144 files mo ta 106 engineering skills (BATCH 1-5)."
        Progress = 50
        Tech = @("Raw JSON", "Batch Dumps")
        Blocker = "Du lieu tho chua chuan hoa theo cau truc SKILL.md."
        Action = "Trich xuat cac ky nang huu ich sang personal-agentkit/skills."
        QuickCmd = ""
    }
    "Phan mem kiem tra ho so XD" = @{
        Priority = "Ý tưởng"
        Category = "stubs"
        Desc = "Y tuong phan mem kiem tra loi ho so thiet ke ban ve thi cong va du toan XD."
        Progress = 0
        Tech = @("Thu muc trong")
        Blocker = "Chua khoi tao code base."
        Action = "Len danh muc cac quy chuan va loi ho so pho bien can kiem tra."
        QuickCmd = ""
    }
    "Smart" = @{
        Priority = "Dọn dẹp"
        Category = "stubs"
        Desc = "Phien ban cu hoac repository rong cua SmartDoc."
        Progress = 5
        Tech = @("Gitattributes")
        Blocker = "Du an khong con su dung."
        Action = "Xoa hoac di chuyen vao thu muc _archive."
        QuickCmd = ""
    }
    "AI-Space" = @{
        Priority = "Dọn dẹp"
        Category = "stubs"
        Desc = "Thu muc trong phuc vu thu nghiem tu do."
        Progress = 0
        Tech = @("Thu muc trong")
        Blocker = "Trong."
        Action = "Xoa hoac don dep de workspace gon gang."
        QuickCmd = ""
    }
}

$directories = Get-ChildItem -Path $ParentDir -Directory | Where-Object { 
    $_.Name -notmatch "^\." -and 
    $_.Name -ne "projects-dashboard" -and 
    $_.Name -ne "__pycache__" -and 
    $_.Name -ne "node_modules" -and 
    $_.Name -ne "venv" 
}
$repoDataList = @()

$results = foreach ($dir in $directories) {
    $path = $dir.FullName
    $name = $dir.Name
    $hasGit = Test-Path (Join-Path $path ".git")

    $branch = "N/A"
    $uncommittedCount = 0
    $uncommittedFiles = @()
    $uncommittedStat = ""
    $lastCommitHash = ""
    $lastCommitMsg = "N/A"
    $lastCommitDate = "N/A"
    $lastCommitStat = ""
    $lastCommitFiles = @()
    $recentCommits = @()
    $remoteStatus = "No Git"
    $healthBadge = "Empty/No Git"

    if ($hasGit) {
        $branch = (git -C $path branch --show-current 2>$null)
        if (-not $branch) { $branch = "HEAD detached" }

        # Uncommitted status & files
        $statusLines = (git -C $path status --short 2>$null)
        if ($statusLines) {
            $uncommittedCount = ($statusLines | Measure-Object).Count
            foreach ($line in ($statusLines | Select-Object -First 8)) {
                $uncommittedFiles += $line.Trim()
            }
        }
        $uncommittedStat = (git -C $path diff --shortstat 2>$null)
        if ($uncommittedStat) { $uncommittedStat = $uncommittedStat.Trim() }

        # Last commit details
        $lastCommitHash = (git -C $path log -1 --format="%h" 2>$null)
        $lastCommitMsg = (git -C $path log -1 --format="%s" 2>$null)
        $lastCommitDate = (git -C $path log -1 --format="%cd (%cr)" --date=short 2>$null)
        $lastCommitStat = (git -C $path show --shortstat --format="" HEAD 2>$null)
        if ($lastCommitStat) { $lastCommitStat = $lastCommitStat.Trim() }
        
        $changedRaw = (git -C $path diff-tree --no-commit-id --name-status -r HEAD 2>$null | Select-Object -First 6)
        if ($changedRaw) {
            foreach ($cr in $changedRaw) { $lastCommitFiles += $cr }
        }

        # Recent 3 commits
        $recentLines = (git -C $path log -n 3 --format="%h|%cr|%s" 2>$null)
        if ($recentLines) {
            foreach ($l in $recentLines) {
                $parts = $l -split '\|', 3
                if ($parts.Count -ge 3) {
                    $recentCommits += [PSCustomObject]@{
                        Hash = $parts[0]
                        Time = $parts[1]
                        Msg  = $parts[2]
                    }
                }
            }
        }

        # Remote sync status
        $remotes = (git -C $path remote 2>$null)
        if ($remotes) {
            $statusSb = (git -C $path status -sb 2>$null | Select-Object -First 1)
            if ($statusSb -match "behind (\d+)") {
                $remoteStatus = "Behind ($($Matches[1]))"
                $healthBadge = "[!] Behind Remote"
            } elseif ($statusSb -match "ahead (\d+)") {
                $remoteStatus = "Ahead ($($Matches[1]))"
                $healthBadge = "[!] Need Push"
            } else {
                $remoteStatus = "Up-to-date"
                $healthBadge = if ($uncommittedCount -gt 0) { "[!] Uncommitted ($uncommittedCount)" } else { "[OK] Clean" }
            }
        } else {
            $remoteStatus = "Local only"
            $healthBadge = if ($uncommittedCount -gt 0) { "[!] Local + Uncommitted" } else { "[OK] Local Clean" }
        }
    } else {
        $fileCount = (Get-ChildItem -Path $path -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count
        if ($fileCount -eq 0) {
            $healthBadge = "[-] Trong"
        } else {
            $healthBadge = "[*] Tai lieu tho ($fileCount files)"
        }
    }

    $meta = $metadata[$name]
    $priority = if ($meta) { $meta.Priority } else { "P3" }
    $category = if ($meta) { $meta.Category } else { "stubs" }
    $desc = if ($meta) { $meta.Desc } else { "Dự án mới" }
    $progress = if ($meta) { $meta.Progress } else { 0 }
    $tech = if ($meta) { $meta.Tech } else { @("Unknown") }
    $blocker = if ($meta) { $meta.Blocker } else { "Chưa có" }
    $action = if ($meta) { $meta.Action } else { "Cập nhật tài liệu" }
    $quickCmd = if ($meta) { $meta.QuickCmd } else { "" }

    if ($uncommittedCount -gt 0 -or $remoteStatus -match "Behind" -or $remoteStatus -match "Ahead") {
        if ($category -notmatch "git") { $category = "$category git" }
    }

    $repoObj = [PSCustomObject]@{
        Name             = $name
        Branch           = $branch
        Uncommitted      = $uncommittedCount
        UncommittedFiles = $uncommittedFiles
        UncommittedStat  = $uncommittedStat
        LastCommitHash   = $lastCommitHash
        LastCommitMsg    = $lastCommitMsg
        LastCommitDate   = $lastCommitDate
        LastCommitStat   = $lastCommitStat
        LastCommitFiles  = $lastCommitFiles
        RecentCommits    = $recentCommits
        RemoteSync       = $remoteStatus
        Health           = $healthBadge
        Priority         = $priority
        Category         = $category
        Desc             = $desc
        Progress         = $progress
        Tech             = $tech
        Blocker          = $blocker
        Action           = $action
        QuickCmd         = $quickCmd
    }

    $repoDataList += $repoObj

    [PSCustomObject]@{
        Repository    = $name
        Branch        = $branch
        "Uncommitted" = $uncommittedCount
        "Remote Sync" = $remoteStatus
        "Health"      = $healthBadge
        "Last Commit" = "$lastCommitDate | $lastCommitMsg"
    }
}

$results | Format-Table -AutoSize

# Export to projects_data.js
$jsonData = $repoDataList | ConvertTo-Json -Depth 5
$jsContent = "// Auto-generated by scan_repos_status.ps1`nwindow.LAST_SCAN = '$nowStr';`nwindow.MACHINE_NAME = '$env:COMPUTERNAME';`nwindow.PROJECTS_DATA = $jsonData;`n"

$destPaths = @(
    (Join-Path $ParentDir "projects_data.js"),
    (Join-Path $ParentDir "projects-dashboard\projects_data.js"),
    (Join-Path $PSScriptRoot "projects_data.js")
)

foreach ($dest in $destPaths) {
    if (Test-Path (Split-Path -Parent $dest)) {
        [System.IO.File]::WriteAllText($dest, $jsContent, [System.Text.Encoding]::UTF8)
    }
}

Write-Host "`n[+] Da cap nhat chi tiet thay doi file vao projects_data.js!" -ForegroundColor Green
Write-Host "[+] Web Dashboard tu dong hien thi chi tiet tung file sau moi lan commit/sua!" -ForegroundColor Green