Import-Module -Name $CI_MODULE_MANIFEST_PATH -Force

$systemUnderTest = ( Split-Path -Leaf $MyInvocation.MyCommand.Path ) -replace '\.Tests\.', '.'

$function = $systemUnderTest.Split( '.' )[0]
$describe = $Global:FORM_FUNCTION_PUBLIC -f $function
Describe -Name $describe -Tag 'Function', 'Public', $function -Fixture {
    #region init
    $help = Get-Help -Name $function -Full
    #endregion

    $splat = @{
        ExpectedFunctionName = $function
        FoundFunctionName    = $help.Name
    }
    Test-AdvancedFunctionName @splat

    Test-AdvancedFunctionHelpMain -Help $help

    Test-AdvancedFunctionHelpInput -Help $help

    $splat = @{
        ExpectedOutputTypeNames = 'ArmorSession'
        Help                    = $help
    }
    Test-AdvancedFunctionHelpOutput @splat

    $splat = @{
        ExpectedParameterNames = 'Credential', 'AccountID', 'Server', 'Port', 'ApiVersion'
        Help                   = $help
    }
    Test-AdvancedFunctionHelpParameter @splat

    $splat = @{
        ExpectedNotes = $Global:FORM_FUNCTION_HELP_NOTES
        Help          = $help
    }
    Test-AdvancedFunctionHelpNote @splat

    Context -Name 'Access Denied' -Fixture {
        InModuleScope -ModuleName $Global:CI_MODULE_NAME -ScriptBlock {
            #region init
            $splat = @{
                TypeName     = 'System.Management.Automation.PSCredential'
                ArgumentList = 'test', ( 'Fake Password' | ConvertTo-SecureString -AsPlainText -Force )
                ErrorAction  = 'Stop'
            }
            $creds = New-Object @splat
            #endregion

            # Get the temporary authorization code
            Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
                @{
                    StatusCode        = 403
                    StatusDescription = 'Access Denied'
                    Content           = @{
                        errorCode     = 'access_denied'
                        badLogonCount = 0
                    }
                }
            } -ParameterFilter {
                $Uri -match ( Get-ArmorApiData -FunctionName 'Connect-Armor' -ApiVersion 'v1.0' ).Endpoints
            }

            $testName = 'should fail on invalid credentials'
            It -Name $testName -Test {
                { Connect-Armor -Credential $creds } |
                    Should -Throw
            }

            Assert-VerifiableMock
            Assert-MockCalled -CommandName Invoke-WebRequest -Times 1 -ParameterFilter {
                $Uri -match ( Get-ArmorApiData -FunctionName 'Connect-Armor' -ApiVersion 'v1.0' ).Endpoints
            }
        }
    }

    Context -Name 'Authorize' -Fixture {
        InModuleScope -ModuleName $Global:CI_MODULE_NAME -ScriptBlock {
            #region init
            $splat = @{
                TypeName     = 'System.Management.Automation.PSCredential'
                ArgumentList = 'test', ( 'Fake Password' | ConvertTo-SecureString -AsPlainText -Force )
                ErrorAction  = 'Stop'
            }
            $creds = New-Object @splat

            $validCode = 'VGhpcyBpcyBzb21lIHRleHQgdG8gY29udmVydCB2aWEgQ3J5cHQu='
            #endregion

            Mock -CommandName Submit-ArmorApiRequest -Verifiable -MockWith {
                @{
                    redirect_uri = $null
                    code         = ''
                    success      = 'true'
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
            }

            Assert-VerifiableMock
            Assert-MockCalled -CommandName Submit-ArmorApiRequest -Times 1

            Mock -CommandName Submit-ArmorApiRequest -Verifiable -MockWith {
                @{
                    redirect_uri = $null
                    code         = $validCode
                    success      = 'false'
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
            }

            Assert-VerifiableMock
            Assert-MockCalled -CommandName Submit-ArmorApiRequest -Times 2
        }
    }

    Context -Name 'API Token' -Fixture {
        InModuleScope -ModuleName $Global:CI_MODULE_NAME -ScriptBlock {
            #region init
            $splat = @{
                TypeName     = 'System.Management.Automation.PSCredential'
                ArgumentList = 'test', ( 'Fake Password' | ConvertTo-SecureString -AsPlainText -Force )
                ErrorAction  = 'Stop'
            }
            $creds = New-Object @splat

            $validCode = 'VGhpcyBpcyBzb21lIHRleHQgdG8gY29udmVydCB2aWEgQ3J5cHQu='
            #endregion

            Mock -CommandName Submit-ArmorApiRequest -Verifiable -MockWith {
                @{
                    redirect_uri = $null
                    code         = $validCode
                    success      = 'true'
                }
            }
            Mock -CommandName New-ArmorApiToken -Verifiable -MockWith {}

            $testName = 'should fail on invalid token'
            It -Name $testName -Test {
                { Connect-Armor -Credential $creds } |
                    Should -Throw
            }

            Assert-VerifiableMock
            Assert-MockCalled -CommandName Submit-ArmorApiRequest -Times 1
            Assert-MockCalled -CommandName New-ArmorApiToken -Times 1
        }
    }

    Context -Name 'Valid Logins' -Fixture {
        InModuleScope -ModuleName $Global:CI_MODULE_NAME -ScriptBlock {
            #region init
            $splat = @{
                TypeName     = 'System.Management.Automation.PSCredential'
                ArgumentList = 'test', ( 'Fake Password' | ConvertTo-SecureString -AsPlainText -Force )
                ErrorAction  = 'Stop'
            }
            $creds = New-Object @splat

            $validCode = 'VGhpcyBpcyBzb21lIHRleHQgdG8gY29udmVydCB2aWEgQ3J5cHQu='
            #endregion

            Mock -CommandName Submit-ArmorApiRequest -Verifiable -MockWith {
                @{
                    redirect_uri = $null
                    code         = $validCode
                    success      = 'true'
                }
            }
            Mock -CommandName New-ArmorApiToken -Verifiable -MockWith {}

            $testName = 'should fail on invalid token'
            It -Name $testName -Test {
                { Connect-Armor -Credential $creds } |
                    Should -Throw
            }

            Assert-VerifiableMock
            Assert-MockCalled -CommandName Submit-ArmorApiRequest -Times 1
            Assert-MockCalled -CommandName New-ArmorApiToken -Times 1
        }
    }

    Context -Name $Global:RETURN_TYPE_CONTEXT -Fixture {
        InModuleScope -ModuleName $Global:CI_MODULE_NAME -ScriptBlock {
            #region init
            $splat = @{
                TypeName     = 'System.Management.Automation.PSCredential'
                ArgumentList = 'test', ( 'Fake Password' | ConvertTo-SecureString -AsPlainText -Force )
                ErrorAction  = 'Stop'
            }
            $creds = New-Object @splat
            $connectArmorEndpoint = ( Get-ArmorApiData -FunctionName 'Connect-Armor' -ApiVersion 'v1.0' ).Endpoints
            $newArmorApiTokenEndpoint = ( Get-ArmorApiData -FunctionName 'New-ArmorApiToken' -ApiVersion 'v1.0' ).Endpoints
            $getArmorIdentityEndpoint = ( Get-ArmorApiData -FunctionName 'Get-ArmorIdentity' -ApiVersion 'v1.0' ).Endpoints
            #endregion

            # Get the temporary authorization code
            Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
                @{
                    StatusCode = 200
                    Content    = $Global:JSON_RESPONSE_BODY.Authorize1
                }
            } -ParameterFilter {
                $Uri -match $connectArmorEndpoint
            }

            # Convert the temporary authorization code to an API token
            Mock -CommandName Invoke-WebRequest -Verifiable -MockWith {
                @{
                    StatusCode = 200
                    Content    = $Global:JSON_RESPONSE_BODY.Token1
                }
            } -ParameterFilter {
                $Uri -match $newArmorApiTokenEndpoint
            }

            # Get the user's identity information
            Mock -CommandName Invoke-WebRequest -Verifiable -ModuleName $Global:CI_MODULE_NAME -MockWith {
                @{
                    StatusCode = 200
                    Content    = $Global:JSON_RESPONSE_BODY.Identity1
                }
            } -ParameterFilter {
                $Uri -match $getArmorIdentityEndpoint
            }

            $testCases = @(
                @{
                    FoundReturnType    = ( Connect-Armor -Credential $creds ).GetType().Name
                    ExpectedReturnType = 'ArmorSession'
                },
                @{
                    FoundReturnType    = ( Connect-Armor -Credential $creds -AccountID 2 ).GetType().Name
                    ExpectedReturnType = 'ArmorSession'
                },
                @{
                    FoundReturnType    = ( Connect-Armor -Credential $creds -Server 'api.armor.tld' -Port 4443 ).GetType().Name
                    ExpectedReturnType = 'ArmorSession'
                },
                @{
                    FoundReturnType    = ( Connect-Armor -Credential $creds -AccountID 3 -Server 'api.armor.test' -Port 8443 ).GetType().Name
                    ExpectedReturnType = 'ArmorSession'
                },
                @{
                    FoundReturnType    = ( Connect-Armor $creds 4 'api.armor.test' 8443 ).GetType().Name
                    ExpectedReturnType = 'ArmorSession'
                }
            )
            $testName = $Global:FORM_RETURN_TYPE
            It -Name $testName -TestCases $testCases -Test {
                param ( [String] $FoundReturnType, [String] $ExpectedReturnType)
                $FoundReturnType |
                    Should -Be $ExpectedReturnType
            }
            Assert-VerifiableMock
            Assert-MockCalled -CommandName Invoke-WebRequest -Times $testCases.Count -ParameterFilter {
                $Uri -match $connectArmorEndpoint
            }
            Assert-MockCalled -CommandName Invoke-WebRequest -Times $testCases.Count -ParameterFilter {
                $Uri -match $newArmorApiTokenEndpoint
            }
            Assert-MockCalled -CommandName Invoke-WebRequest -Times $testCases.Count -ModuleName $Global:CI_MODULE_NAME -ParameterFilter {
                $Uri -match $getArmorIdentityEndpoint
            }

            $testName = "has an 'OutputType' entry for <FoundReturnType>"
            It -Name $testName -TestCases $testCases -Test {
                param ( [String] $FoundReturnType, [String] $ExpectedReturnType )
                $FoundReturnType |
                    Should -BeIn ( Get-Help -Name 'Connect-Armor' -Full ).ReturnValues.ReturnValue.Type.Name
            }
        }
    }
}
