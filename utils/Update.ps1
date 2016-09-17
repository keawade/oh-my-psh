[reflection.assembly]::LoadWithPartialName("System.Version")
$Version = "0.0.1"
$GithubAPI = "https://api.github.com"
$RepoPath = "repos/keawade/oh-my-psh"

Function Update {
    # Get latest release metadata from GitHub
    $LatestRelease = (Invoke-WebRequest "$GithubAPI/$RepoPath/releases" | ConvertFrom-Json)[0] # TODO: "$GithubAPI/$RepoPath/releases/latest"

    # Prepare version comparison objects
    $LatestVersion = New-Object System.Version($LatestRelease.tag_name)
    $InstalledVersion = New-Object System.Version($Version)


    Write-Host "[oh-my-psh] Checking for updates..."
    # Check if installed version is older than the version of the latest release
    if ($InstalledVersion.CompareTo($LatestVersion) -lt 0) {
        Write-Host "[oh-my-psh] Notice: Module update available"
    } else {
        Write-Host "[oh-my-psh] Success: Module current"
    }
}
