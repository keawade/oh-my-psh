$CurrentDir = Get-Location
$InstallDirectory = "$Env:USERPROFILE\.oh-my-psh"
$RepoURI = "https://github.com/keawade/oh-my-psh"

Function Install {
    Write-Host "[oh-my-psh] Installing module into $InstallDirectory."

    if (-Not (Test-Path $PROFILE)) {
        Write-Host "[oh-my-psh] Creating PowerShell profile: $PROFILE"
        New-Item $PROFILE -Force -Type File -ErrorAction Stop
    }

    if (-Not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Warning "[oh-my-psh] Git command not found. Please add git to PATH."
        Return
    }

    if (-Not (Test-Path $InstallDirectory)) {
        New-Item $InstallDirectory -ItemType Directory | Out-Null
    }

    Set-Location $InstallDirectory

    git.exe clone $RepoURI $InstallDirectory
    git.exe fetch --tags $RepoURI | Out-Null
    $tags = git.exe describe --tags | Out-Null
    $latest = git.exe rev-list --tags --max-count=1 | Out-Null
    git.exe checkout $latest | Out-Null
    git.exe pull $InstallDirectory | Out-Null
    Set-Location $CurrentDir

    Write-Host "[oh-my-psh] Installation complete."
}

Function Test-Previous {
    Write-Host "[oh-my-psh] Checking for existing installation..."
    $ProfileLine = ". '$InstallDirectory\profile.example.ps1'"
    if (Select-String -Path $PROFILE -Pattern $ProfileLine -Quiet -SimpleMatch) {
        Write-Host "[oh-my-psh] Previous installation found. Exiting."
        exit
    }
}

# Originally adapted from (http://www.west-wind.com/Weblog/posts/197245.aspx) and shamelessly lifted from posh-git (https://github.com/dahlbyk/posh-git)
Function Get-FileEncoding($Path) {
    $bytes = [byte[]](Get-Content $Path -Encoding byte -ReadCount 4 -TotalCount 4)

    if(!$bytes) { return 'utf8' }

    switch -regex ('{0:x2}{1:x2}{2:x2}{3:x2}' -f $bytes[0],$bytes[1],$bytes[2],$bytes[3]) {
        '^efbbbf'   { return 'utf8' }
        '^2b2f76'   { return 'utf7' }
        '^fffe'     { return 'unicode' }
        '^feff'     { return 'bigendianunicode' }
        '^0000feff' { return 'utf32' }
        default     { return 'ascii' }
    }
}

Function Enable-Profile {
    Write-Host "[oh-my-psh] Adding oh-my-psh to profile..."
@"

# Load oh-my-psh profile
$ProfileLine

"@ | Out-File $PROFILE -Append -Encoding (Get-FileEncoding $PROFILE)

}

Test-Previous
Install

# .$PROFILE