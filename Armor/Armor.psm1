# Get class definition files, as well as the private and public function definition files.
$lib = Get-ChildItem -Path "$PSScriptRoot/Lib/*.ps1" -ErrorAction 'Stop'
$private = Get-ChildItem -Path "$PSScriptRoot/Private/*.ps1" -ErrorAction 'Stop'
$public = Get-ChildItem -Path "$PSScriptRoot/Public/*.ps1" -ErrorAction 'Stop'

# Source the definition files
foreach ( $import in ( $lib + $private + $public ) ) {
    . $import.FullName
}

# Export the Public modules
Export-ModuleMember -Function $public.BaseName -ErrorAction 'Stop'
