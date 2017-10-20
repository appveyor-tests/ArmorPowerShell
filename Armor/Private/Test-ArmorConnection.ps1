Function Test-ArmorConnection
{
	<#
		.SYNOPSIS
		Armor API session test.

		.DESCRIPTION
		Test to see if a session has been established with the Armor API.
		If no token is found, this will throw an error and halt the script.
		Otherwise, the token is loaded into the script's $Header variable.

		.NOTES
		Troy Lindsay
		Twitter: @troylindsay42
		GitHub: tlindsay42

		.INPUTS
		None
			You cannot pipe objects to Test-ArmorConnection.

		.OUTPUTS
		None
			Test-ArmorConnection has no output.

		.LINK
		https://github.com/tlindsay42/ArmorPowerShell

		.LINK
		https://docs.armor.com/display/KBSS/Armor+API+Guide

		.LINK
		https://developer.armor.com/

		.EXAMPLE
		Test-ArmorConnection

		Description
		-----------

		Validates that there is one Armor API connection token stored in '$global:ArmorConnection.Token'.
	#>

	[CmdletBinding()]
	Param()

	Begin
	{
		# The Begin section is used to perform one-time loads of data necessary to carry out the function's purpose
		# If a command needs to be run with each iteration or pipeline input, place it in the Process section

		$function = $MyInvocation.MyCommand.Name

		Write-Verbose -Message ( 'Beginning {0}.' -f $function )
	} # End of Begin

	Process
	{
		Write-Verbose -Message 'Validate that the Armor token exists.'

		If ( $global:ArmorConnection.Token.Count -eq 0 )
		{
			Write-Warning -Message 'Please connect an Armor API session before running this command.'
		}
		ElseIf ( $global:ArmorConnection.Token.Count -gt 1 )
		{
			Write-Warning -Message 'Please connect to only one Armor API session before running this command.'
		}

		If ( $global:ArmorConnection.Token.Count -ne 1 )
		{
			Throw 'A single connection with Connect-Armor is required.'
		}

		Write-Verbose -Message ( 
			'Found an Armor API authentication token with {0} minutes remaining until expiration.' -f
				( $global:ArmorConnection.SessionExpirationTime - ( Get-Date ) ).Minutes
		)
		
		If ( ( $global:ArmorConnection.SessionExpirationTime - ( Get-Date ) ).Minutes -lt 15 )
		{
			Write-Verbose -Message 'Renewing session token.'

			Update-ArmorApiToken -Token $global:ArmorConnection.Token |
				Out-Null
		}

		$script:Headers = $global:ArmorConnection.Headers

		Return
	} # End of Process

	End
	{
		Write-Verbose -Message ( 'Ending {0}.' -f $function )
	} # End of End
} # End of Function
