Function Submit-Request
{
	<#
		.SYNOPSIS
		Helper function used to send data to an endpoint and then format the response for further use.

		.DESCRIPTION
		{ required: more detailed description of the function's purpose }

		.NOTES
		Troy Lindsay
		Twitter: @troylindsay42
		GitHub: tlindsay42

		.PARAMETER URI
		The endpoint's URI.

		.PARAMETER Headers
		The headers containing authentication details.

		.PARAMETER Method
		The action (method) to perform on the endpoint.

		.PARAMETER Body
		Any optional request body data being submitted to the endpoint.

		.INPUTS
		None
			You cannot pipe objects to Submit-Request.

		.OUTPUTS
		Microsoft.PowerShell.Commands.HtmlWebResponseObject

		.LINK
		https://github.com/tlindsay42/ArmorPowerShell

		.LINK
		https://docs.armor.com/display/KBSS/Armor+API+Guide

		.LINK
		https://developer.armor.com/

		.EXAMPLE
		{required: show one or more examples using the function}
	#>

	[CmdletBinding( SupportsShouldProcess = $true )]
	Param
	(
		[Parameter( Position = 0 )]
		[ValidateNotNullorEmpty()]
		[String] $Uri = $null,
		[Parameter( Position = 1 )]
		[ValidateNotNull()]
		[Hashtable] $Headers = @{},
		[Parameter( Position = 2 )]
		[ValidateNotNullorEmpty()]
		[String] $Method = $null,
		[Parameter( Position = 3 )]
		[ValidateNotNullorEmpty()]
		[String] $Body = $null
	)
	
	Process
	{
		$result = $null

		If ( $PSCmdlet.ShouldProcess( $id, $resources.Description ) )
		{
			Try
			{
				Write-Verbose -Message 'Submitting the request.'

				# Because some calls require more than the default payload limit of 2MB, ExpandPayload dynamically adjusts the payload limit
				$result = ExpandPayload -Response ( Invoke-WebRequest -Uri $Uri -Headers $Headers -Method $Method -Body $Body )
			}
			Catch
			{
				$warningMessage = 'The endpoint supplied to the Armor API is invalid. Likely this is due to an incompatible version of the API or references pointing to a non-existent endpoint. The URI passed was: {0}' -f $Uri

				Switch -Wildcard ( $_ )
				{
					'Route not defined.'
					{
						Write-Warning -Message $warningMessage -Verbose

						Throw $_.Exception
					}
					
					'Invalid ManagedId*'
					{
						Write-Warning -Message $warningMessage -Verbose

						Throw $_.Exception 
					}

					Default { Throw $_ }
				}
			}
		}

		Return $result
	}
}
