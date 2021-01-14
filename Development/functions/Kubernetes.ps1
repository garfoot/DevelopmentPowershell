<#
.synopsis
Gets the names of pods based on a selector.
.parameter Selector
The Kubernetes selector to use to query for pods.
#>
function Get-PodName([string] $Selector) {
    kubectl get pod --selector=$Selector -o yaml | ConvertFrom-Yaml | Select-Object -ExpandProperty items | ForEach-Object { $_.metadata.name }
}
