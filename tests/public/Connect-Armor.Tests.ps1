Remove-Module -Name "${env:CI_MODULE_NAME}*" -ErrorAction 'SilentlyContinue'
Import-Module -Name $env:CI_MODULE_MANIFEST_PATH -Force

$systemUnderTest = ( Split-Path -Leaf $MyInvocation.MyCommand.Path ) -replace '\.Tests\.', '.'
$filePath = Join-Path -Path $env:CI_MODULE_PUBLIC_PATH -ChildPath $systemUnderTest

. $filePath

$privateFunctionFiles = Get-ChildItem -Path $env:CI_MODULE_PRIVATE_PATH
foreach ( $privateFunctionFile in $privateFunctionFiles ) {
    . $privateFunctionFile.FullName
}

$function = $systemUnderTest.Split( '.' )[0]
$describe = $Global:PublicFunctionForm -f $function
Describe -Name $describe -Tag 'Function', 'Public', $function -Fixture {
    #region init
    $help = Get-Help -Name $function -Full

    $splat = @{
        'TypeName'     = 'System.Management.Automation.PSCredential'
        'ArgumentList' = 'test', ( 'Fake Password' | ConvertTo-SecureString -AsPlainText -Force )
        'ErrorAction'  = 'Stop'
    }
    $creds = New-Object @splat

    $validCode = 'VGhpcyBpcyBzb21lIHRleHQgdG8gY29udmVydCB2aWEgQ3J5cHQu='
    #endregion

    $splat = @{
        'ExpectedFunctionName' = $function
        'FoundFunctionName'    = $help.Name
        }
    TestAdvancedFunctionName @splat

    TestAdvancedFunctionHelpMain -Help $help

    TestAdvancedFunctionHelpInputs -Help $help

    $splat = @{
        'ExpectedOutputTypeNames' = 'ArmorSession'
        'Help'                    = $help
        }
    TestAdvancedFunctionHelpOutputs @splat

    $splat = @{
        'ExpectedParameterNames' = 'Credential', 'AccountID', 'Server', 'Port', 'ApiVersion'
        'Help'                   = $help
            }
    TestAdvancedFunctionHelpParameters @splat

    $splat = @{
        'ExpectedNotes' = $Global:FunctionHelpNotes
        'Help'          = $help
            }
    TestAdvancedFunctionHelpNotes @splat

        # Get the user's identity information
        Mock -CommandName Invoke-WebRequest -Verifiable -ModuleName $env:CI_MODULE_NAME -MockWith {
            @{
                'StatusCode' = 200
                'Content'    = $Global:JsonResponseBody.Identity1
            }
        }

        $testName = $Global:ReturnTypeForm
        It -Name $testName -Test {
            Connect-Armor -Credential $creds |
                Should -BeOfType ( [ArmorSession] )
        } # End of It
        Assert-VerifiableMock
        Assert-MockCalled -CommandName Invoke-WebRequest -Times 1 -ParameterFilter {
            $Uri -match ( Get-ArmorApiData -FunctionName 'Connect-Armor' -ApiVersion 'v1.0' ).Endpoints
        }
        Assert-MockCalled -CommandName Invoke-WebRequest -Times 1 -ParameterFilter {
            $Uri -match ( Get-ArmorApiData -FunctionName 'New-ArmorApiToken' -ApiVersion 'v1.0' ).Endpoints
        }
        Assert-MockCalled -CommandName Invoke-WebRequest -Times 1 -ModuleName $env:CI_MODULE_NAME

        # Get the temporary authorization code
        Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
            @{
                'StatusCode' = 200
                'Content'    = $Global:JsonResponseBody.Authorize1
            }
        } -ParameterFilter {
            $Uri -match ( Get-ArmorApiData -FunctionName 'Connect-Armor' -ApiVersion 'v1.0' ).Endpoints
        }
    } # End of Context

    Context -Name 'Access Denied' -Fixture {
        # Get the temporary authorization code
        Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
            @{
                'StatusCode'        = 403
                'StatusDescription' = 'Access Denied'
                'Content'    = @{
                    'errorCode'     = 'access_denied'
                    'badLogonCount' = 0
                }
            }
        } -ParameterFilter {
            $Uri -match ( Get-ArmorApiData -FunctionName 'Connect-Armor' -ApiVersion 'v1.0' ).Endpoints
        }

        $testName = 'should fail on invalid credentials'
        It -Name $testName -Test {
            { Connect-Armor -Credential $creds } |
                Should -Throw
        } # End of It

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Invoke-WebRequest -Times 1 -ParameterFilter {
            $Uri -match ( Get-ArmorApiData -FunctionName 'Connect-Armor' -ApiVersion 'v1.0' ).Endpoints
        }
    } # End of Context

    Context -Name 'Authorize' -Fixture {
        Mock -CommandName Submit-ArmorApiRequest -Verifiable -MockWith {
            @{
                'redirect_uri' = $null
                'code'         = ''
                'success'      = 'true'
            }
        }

        $testName = 'should fail on invalid authorization code'
        It -Name $testName -Test {
            param (
                [String] $Code,
                [String] $Success
            )
            { Connect-Armor -Credential $creds } |
                Should -Throw
        } # End of It

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Submit-ArmorApiRequest -Times 1

        Mock -CommandName Submit-ArmorApiRequest -Verifiable -MockWith {
            @{
                'redirect_uri' = $null
                'code'         = $validCode
                'success'      = 'false'
            }
        }

        $testName = 'should fail on invalid success value'
        It -Name $testName -Test {
            param (
                [String] $Code,
                [String] $Success
            )
            { Connect-Armor -Credential $creds } |
                Should -Throw
        } # End of It

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Submit-ArmorApiRequest -Times 1
    } # End of Context

    Context -Name 'API Token' -Fixture {
        Mock -CommandName Submit-ArmorApiRequest -Verifiable -MockWith {
            @{
                'redirect_uri' = $null
                'code'         = $validCode
                'success'      = 'true'
            }
        }
        Mock -CommandName New-ArmorApiToken -Verifiable -MockWith {}

        $testName = 'should fail on invalid token'
        It -Name $testName -Test {
            { Connect-Armor -Credential $creds } |
                Should -Throw
        } # End of It

        Assert-VerifiableMock
        Assert-MockCalled -CommandName Submit-ArmorApiRequest -Times 1
        Assert-MockCalled -CommandName New-ArmorApiToken -Times 1
    } # End of Context
} # End of Describe
