#Requires -RunAsAdministrator
# ============================================================
#  OpenClaw Windows Installer (WSL2)
#  Author: Liam
# ============================================================

$ErrorActionPreference = "Stop"
$DISTRO = "openclaw"
$WSL_CONFIG = "$env:USERPROFILE\.wslconfig"
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$SETUP_SCRIPT = Join-Path $SCRIPT_DIR "setup-openclaw.sh"

function Write-Banner {
    Write-Host ""
    Write-Host "  =============================================" -ForegroundColor Cyan
    Write-Host "   OpenClaw Windows Installer"                   -ForegroundColor Cyan
    Write-Host "  =============================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step($num, $msg) {
    Write-Host "  [$num] " -ForegroundColor Green -NoNewline
    Write-Host $msg
}

function Write-Info($msg) {
    Write-Host "      $msg" -ForegroundColor DarkGray
}

function Write-Warn($msg) {
    Write-Host "  [!] $msg" -ForegroundColor Yellow
}

function Write-Err($msg) {
    Write-Host "  [X] $msg" -ForegroundColor Red
}

function Test-WindowsVersion {
    $build = [System.Environment]::OSVersion.Version.Build
    if ($build -lt 19041) {
        Write-Err "Windows build $build is too old. Need 19041+ (Win10 2004 or Win11)."
        return $false
    }
    Write-Info "Windows build $build - OK"
    return $true
}

function Test-WSLInstalled {
    try {
        $result = wsl --status 2>&1
        return $LASTEXITCODE -eq 0
    } catch {
        return $false
    }
}

function Test-DistroInstalled {
    $lxssPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss"
    if (-Not (Test-Path $lxssPath)) { return $false }
    $found = Get-ChildItem $lxssPath | Where-Object {
        (Get-ItemProperty $_.PSPath).DistributionName -eq $DISTRO
    }
    return ($null -ne $found)
}

function Install-WSL2 {
    Write-Step "1" "Checking WSL2..."

    if (Test-WSLInstalled) {
        Write-Info "WSL2 is ready."
    } else {
        Write-Info "Installing WSL2..."
        wsl --install --no-distribution 2>&1 | Out-Null

        if ($LASTEXITCODE -ne 0) {
            dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart 2>&1 | Out-Null
            dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart 2>&1 | Out-Null
            wsl --set-default-version 2 2>&1 | Out-Null

            Write-Warn "WSL2 enabled. Reboot may be required."
            $reboot = Read-Host "      Reboot now? (y/n)"
            if ($reboot -eq "y") { Restart-Computer -Force }
            exit 0
        }
        Write-Info "WSL2 installed."
    }
}

function Install-Distro {
    Write-Step "3" "Setting up OpenClaw environment..."

    if (Test-DistroInstalled) {
        Write-Warn "偵測到已安裝的 '$DISTRO' 環境。"
        Write-Host ""
        Write-Host "  請選擇：" -ForegroundColor Cyan
        Write-Host "    1) 重新安裝（刪除後重裝）" -ForegroundColor White
        Write-Host "    2) 僅解除安裝（刪除後結束）" -ForegroundColor White
        Write-Host "    3) 不動，繼續" -ForegroundColor White
        Write-Host ""
        $choice = Read-Host "      輸入 1、2 或 3"
        switch ($choice) {
            "1" {
                Write-Info "正在移除 '$DISTRO'..."
                wsl --unregister $DISTRO 2>&1 | Out-Null
                Write-Info "已移除。開始重新安裝..."
            }
            "2" {
                Write-Info "正在移除 '$DISTRO'..."
                wsl --unregister $DISTRO 2>&1 | Out-Null
                Write-Host ""
                Write-Host "  已解除安裝。" -ForegroundColor Green
                Read-Host "  按 Enter 關閉"
                exit 0
            }
            default {
                Write-Info "保留現有環境。"
                return
            }
        }
    }

    if (-Not (Test-DistroInstalled)) {
        Write-Info "Creating environment '$DISTRO'..."

        # Set console to UTF-8 so WSL's Chinese output displays correctly
        $prevCP = [Console]::OutputEncoding
        [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
        chcp 65001 > $null 2>&1

        # Suppress WSL stderr warnings (red text) — they are not fatal
        $prevEAP = $ErrorActionPreference
        $ErrorActionPreference = "SilentlyContinue"

        # Run wsl install in background with spinner
        $installJob = Start-Job -ScriptBlock {
            param($d)
            wsl --install -d Ubuntu-24.04 --name $d --no-launch *> $null
            if ($LASTEXITCODE -ne 0) {
                wsl --install -d Ubuntu-24.04 --no-launch *> $null
            }
        } -ArgumentList $DISTRO

        $spinner = @('|', '/', '-', '\')
        $i = 0
        Write-Host ""
        while ($installJob.State -eq 'Running') {
            Write-Host -NoNewline "`r      $($spinner[$i % 4]) Installing Ubuntu 24.04... (this may take a few minutes)"
            Start-Sleep -Milliseconds 300
            $i++
        }
        Write-Host "`r      Done.                                                    "

        Receive-Job $installJob -ErrorAction SilentlyContinue | Out-Null
        Remove-Job $installJob

        $ErrorActionPreference = $prevEAP
        [Console]::OutputEncoding = $prevCP

        Write-Info "Setting up user..."

        $username = "openclaw"
        $password = "openclaw"
        wsl -d $DISTRO -- bash -c "useradd -m -s /bin/bash -G sudo $username; echo '${username}:${password}' | chpasswd; echo '${username} ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/${username}" 2>&1 | Out-Null

        $lxssPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss"
        $distroKey = Get-ChildItem $lxssPath | Where-Object {
            (Get-ItemProperty $_.PSPath).DistributionName -eq $DISTRO
        }
        if ($distroKey) {
            $prevEAP2 = $ErrorActionPreference
            $ErrorActionPreference = "Continue"
            $uid = wsl -d $DISTRO -- id -u $username 2>&1
            $ErrorActionPreference = $prevEAP2
            if ($uid -match "^\d+$") {
                Set-ItemProperty -Path $distroKey.PSPath -Name "DefaultUid" -Value ([int]$uid)
                Write-Info "User: $username / Password: $password"
            }
        }

        if (-Not (Test-DistroInstalled)) {
            Write-Err "Setup failed. Try rebooting."
            exit 1
        }
        Write-Info "Environment ready."
    }
}

function Set-WSLConfig {
    Write-Step "2" "Configuring memory limits..."

    $totalRAM = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
    $wslRAM = [math]::Min(8, [math]::Max(4, [math]::Floor($totalRAM / 2)))

    $config = @"
[wsl2]
memory=${wslRAM}GB
swap=2GB
localhostForwarding=true

[boot]
systemd=true
"@

    if (Test-Path $WSL_CONFIG) {
        $bytes = [System.IO.File]::ReadAllBytes($WSL_CONFIG)
        $hasBOM = ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
        if ($hasBOM) {
            Write-Warn "Fixing .wslconfig encoding..."
            [System.IO.File]::WriteAllText($WSL_CONFIG, $config, (New-Object System.Text.UTF8Encoding $false))
            Write-Info "Fixed."
            return
        }
        $existing = Get-Content $WSL_CONFIG -Raw
        if ($existing -match "memory=") {
            Write-Info "Memory limits already set."
            return
        }
    }

    [System.IO.File]::WriteAllText($WSL_CONFIG, $config, (New-Object System.Text.UTF8Encoding $false))
    Write-Info "Memory limit: ${wslRAM}GB (system: ${totalRAM}GB)"
}

function Set-WSLAutoStart {
    Write-Step "4" "Setting up auto-start..."

    $taskName = "OpenClaw-WSL-Gateway"
    $existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue

    if ($existingTask) {
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    }

    $action = New-ScheduledTaskAction `
        -Execute "wsl.exe" `
        -Argument "-d $DISTRO -- bash -lc 'openclaw gateway start 2>&1 >> ~/.openclaw/gateway.log &'"

    $trigger = New-ScheduledTaskTrigger -AtLogon
    $principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Limited
    $settings = New-ScheduledTaskSettingsSet `
        -AllowStartIfOnBatteries `
        -DontStopIfGoingOnBatteries `
        -StartWhenAvailable `
        -RestartCount 3 `
        -RestartInterval (New-TimeSpan -Minutes 1)

    Register-ScheduledTask `
        -TaskName $taskName `
        -Action $action `
        -Trigger $trigger `
        -Principal $principal `
        -Settings $settings `
        -Description "OpenClaw gateway auto-start" | Out-Null

    Write-Info "OpenClaw will auto-start on login."
}

function Start-OpenClawSetup {
    Write-Step "5" "Installing OpenClaw..."
    Write-Host ""

    if (-Not (Test-Path $SETUP_SCRIPT)) {
        Write-Err "setup-openclaw.sh not found!"
        Write-Err "Make sure all files are in the same folder."
        exit 1
    }

    $prevEAP = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    $wslScriptPath = wsl -d $DISTRO wslpath -u ($SETUP_SCRIPT -replace '\\', '\\') 2>&1
    $ErrorActionPreference = $prevEAP

    wsl -d $DISTRO -u openclaw -- bash -c "cp '$wslScriptPath' /tmp/setup-openclaw.sh; chmod +x /tmp/setup-openclaw.sh; /tmp/setup-openclaw.sh"

    if ($LASTEXITCODE -ne 0) {
        Write-Err "Setup encountered an error."
        Write-Err "Retry: wsl -d $DISTRO bash /tmp/setup-openclaw.sh"
        exit 1
    }
}

function Show-Summary {
    Write-Host ""
    Write-Host "  =============================================" -ForegroundColor Green
    Write-Host "   Done!"                                        -ForegroundColor Green
    Write-Host "  =============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Commands (run in PowerShell):" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "    Start:   wsl -d $DISTRO openclaw gateway start"   -ForegroundColor White
    Write-Host "    Stop:    wsl -d $DISTRO openclaw gateway stop"    -ForegroundColor White
    Write-Host "    Status:  wsl -d $DISTRO openclaw gateway status"  -ForegroundColor White
    Write-Host "    Check:   wsl -d $DISTRO openclaw doctor"          -ForegroundColor White
    Write-Host "    Web UI:  http://localhost:18789"                   -ForegroundColor White
    Write-Host ""
}

# ========================
#  Main
# ========================
Write-Banner

if (-Not (Test-WindowsVersion)) { exit 1 }

Install-WSL2
Set-WSLConfig
Install-Distro
Set-WSLAutoStart
Start-OpenClawSetup
Show-Summary

Read-Host "Press Enter to close"
