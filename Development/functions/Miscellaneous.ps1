
<#
.Synopsis
Remove-BuildFiles removes all obj and bin folders except under node_modules from the current path.
#>
function Remove-BuildFiles() {
    Get-ChildItem -Directory -Recurse obj, bin | Where-Object { $_.FullName -notmatch "\\node_modules\\" } | Remove-Item -Recurse -Force
}
  
<#
  .synopsis
  Get-GitIgnore downloads .gitignore files from GitHub.
  .parameter Name
  The name of the .gitignore file to download.
  .description
  Downloads a .gitignore file from https://github.com/github/gitignore and places it in the
  current working folder.
  .example
  Get-GitIgnore -Name VisualStudio
  #>
function Get-GitIgnore([string] $Name) {
    $client = New-Object System.Net.WebClient
    $path = Resolve-Path .
    $path = Join-Path $path ".gitignore"
    $client.DownloadFile("https://raw.githubusercontent.com/github/gitignore/master/$($Name).gitignore", $path)
}
  
<#
  .synopsis
  Starts an instance of Portainer in Docker.
  .description
  Starts Portainer (https://www.portainer.io/). This assumes that Portainer is installed and configured.
  #>
function Start-Portainer() {
    Invoke-Expression "docker run -d -p 8000:8000 -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer"
}
  
<#
  .synopsis
  Remove-StaleBranches removes local branches that are no longer tracking an upstream remote.
  .parameter Force
  Forces removal of the branches without prompting.
  #>
function Remove-StaleBranches([switch]$Force) {
    $branches = Invoke-Expression "git branch -vv" | Select-String "^\s*(?'branch'[-a-zA-Z\/_0-9]+).*(?=: gone]).*$" -AllMatches `
    | ForEach-Object { $_.Matches[0].Groups["branch"].value }
  
    if (-not $Force -and $branches.count -gt 0) {
        Write-Host "Deleting the following branches" -ForegroundColor Yellow
        foreach ($branch in $branches) {
            Write-Host $branch
        }
  
        $prompt = Read-Host -Prompt "Delete (y/n)?"
    }
  
    if ($Force -or $prompt -eq "y") {
        foreach ($branch in $branches) {
            Invoke-Expression "git branch -D $($branch)"
        } 
    }
}
  