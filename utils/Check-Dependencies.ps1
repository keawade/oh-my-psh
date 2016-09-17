Param(
    # Check modules or commands
    [Parameter(Mandatory=$True, Position=1)]
    [ValidateSet("command","module")]
    [String]
    $action,
    # Array of items to check for
    [Parameter(Mandatory=$True, Position=2)]
    [ValidateNotNullOrEmpty]
    [String[]]
    $dependencies
)
$failed = @()


# Check for modules
if ($action -eq "module") {
    foreach ($dependency in $dependencies) {
        if (-Not (Get-Module $dependency -ListAvailable)) {
            $failed += $dependency
        }
    }
}


# Check for commands
if ($action -eq "command") {
    foreach ($dependency in $dependencies) {
        if (-Not (Get-Command $dependency -ErrorAction SilentlyContinue)) {
            $failed += $dependency
        }
    }
}

return $failed
