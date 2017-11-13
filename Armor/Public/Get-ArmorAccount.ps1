Function Get-ArmorAccount
{
	<#
		.SYNOPSIS
		Retrieves a list of Armor account memberships for the currently authenticated user.

		.DESCRIPTION
		{ required: more detailed description of the function's purpose }

		.NOTES
		Troy Lindsay
		Twitter: @troylindsay42
		GitHub: tlindsay42

		.PARAMETER ApiVersion
		The API version.  The default value is $Global:ArmorSession.ApiVersion.

		.INPUTS
		None
			You cannot pipe objects to Get-ArmorAccount.

		.OUTPUTS
		System.Collections.Hashtable

		.LINK
		https://github.com/tlindsay42/ArmorPowerShell

		.LINK
		https://docs.armor.com/display/KBSS/Armor+API+Guide

		.LINK
		https://developer.armor.com/

		.EXAMPLE
		{required: show one or more examples using the function}
	#>

	[CmdletBinding()]
	Param
	(
		[ValidateSet( 'v1.0' )]
		[String] $ApiVersion = $Global:ArmorSession.ApiVersion
	)

	Begin
	{
		$function = $MyInvocation.MyCommand.Name

		Write-Verbose -Message ( 'Beginning {0}.' -f $function )

		Test-ArmorSession
	} # End of Begin

	Process
	{
		Write-Verbose -Message ( 'Gather API Data for {0}.' -f $function )
		$resources = Get-ArmorApiData -Endpoint $function -ApiVersion $ApiVersion

		$uri = New-ArmorApiUriString -Endpoints $resources.Uri -IDs $ID

		$uri = New-ArmorApiUriQueryString -QueryKeys $resources.Query.Keys -Parameters ( Get-Command -Name $function ).Parameters.Values -Uri $uri

		$results = Submit-ArmorApiRequest -Uri $uri -Method $resources.Method

		$results = Select-ArmorApiResult -Results $results -Filter $resources.Filter

		$Global:ArmorConnection.Accounts = @()
		
		ForEach ( $account In $results.Accounts )
		{
			$temp = New-Object -TypeName PSCustomObject |
				Select-Object -Property 'Name', 'ID', 'Status', 'Parent', 'Currency', 'Products'

			$temp.Name = $account.Name.Trim()
			$temp.ID = $account.Id
			$temp.Status = $account.Status.Trim()
			$temp.Parent = $account.Parent
			$temp.Currency = $account.Currency.Trim()
			$temp.Products = $account.Products

			$Global:ArmorConnection.Accounts += $temp
		}

		Return $Global:ArmorConnection.Accounts
	} # End of Process

	End
	{
		Write-Verbose -Message ( 'Ending {0}.' -f $function )
	} # End of End
} # End of Function
