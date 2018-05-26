foreach ( $className in 'ArmorPhoneNumber' ) {
    $classPath = Split-Path -Path $MyInvocation.MyCommand.Path -Parent |
        Join-Path -ChildPath "${className}.ps1"
    . $classPath
}

class ArmorUser {
    [ValidateRange( 1, 65535 )]
    [UInt16] $ID

    [ValidateSet( 'Enabled', 'Disabled' )]
    [String] $Status

    [AllowEmptyString()]
    [String] $Title

    [ValidateNotNullOrEmpty()]
    [String] $FirstName

    [ValidateNotNullOrEmpty()]
    [String] $LastName

    [ValidatePattern( '^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$' )]
    [Alias( 'UserName' )]
    [String] $Email

    [ValidateNotNull()]
    [Alias( 'Phone' )]
    [ArmorPhoneNumber] $PhonePrimary

    # Populated via [TimeZoneInfo]::GetSystemTimeZones().ID
    [ValidateSet(
        'Dateline Standard Time',
        'UTC-11',
        'Aleutian Standard Time',
        'Hawaiian Standard Time',
        'Marquesas Standard Time',
        'Alaskan Standard Time',
        'UTC-09',
        'Pacific Standard Time (Mexico)',
        'UTC-08',
        'Pacific Standard Time',
        'US Mountain Standard Time',
        'Mountain Standard Time (Mexico)',
        'Mountain Standard Time',
        'Central America Standard Time',
        'Central Standard Time',
        'Easter Island Standard Time',
        'Central Standard Time (Mexico)',
        'Canada Central Standard Time',
        'SA Pacific Standard Time',
        'Eastern Standard Time (Mexico)',
        'Eastern Standard Time',
        'Haiti Standard Time',
        'Cuba Standard Time',
        'US Eastern Standard Time',
        'Turks And Caicos Standard Time',
        'Paraguay Standard Time',
        'Atlantic Standard Time',
        'Venezuela Standard Time',
        'Central Brazilian Standard Time',
        'SA Western Standard Time',
        'Pacific SA Standard Time',
        'Newfoundland Standard Time',
        'Tocantins Standard Time',
        'E. South America Standard Time',
        'SA Eastern Standard Time',
        'Argentina Standard Time',
        'Greenland Standard Time',
        'Montevideo Standard Time',
        'Magallanes Standard Time',
        'Saint Pierre Standard Time',
        'Bahia Standard Time',
        'UTC-02',
        'Mid-Atlantic Standard Time',
        'Azores Standard Time',
        'Cape Verde Standard Time',
        'UTC',
        'Morocco Standard Time',
        'GMT Standard Time',
        'Greenwich Standard Time',
        'W. Europe Standard Time',
        'Central Europe Standard Time',
        'Romance Standard Time',
        'Sao Tome Standard Time',
        'Central European Standard Time',
        'W. Central Africa Standard Time',
        'Jordan Standard Time',
        'GTB Standard Time',
        'Middle East Standard Time',
        'Egypt Standard Time',
        'E. Europe Standard Time',
        'Syria Standard Time',
        'West Bank Standard Time',
        'South Africa Standard Time',
        'FLE Standard Time',
        'Israel Standard Time',
        'Kaliningrad Standard Time',
        'Sudan Standard Time',
        'Libya Standard Time',
        'Namibia Standard Time',
        'Arabic Standard Time',
        'Turkey Standard Time',
        'Arab Standard Time',
        'Belarus Standard Time',
        'Russian Standard Time',
        'E. Africa Standard Time',
        'Iran Standard Time',
        'Arabian Standard Time',
        'Astrakhan Standard Time',
        'Azerbaijan Standard Time',
        'Russia Time Zone 3',
        'Mauritius Standard Time',
        'Saratov Standard Time',
        'Georgian Standard Time',
        'Caucasus Standard Time',
        'Afghanistan Standard Time',
        'West Asia Standard Time',
        'Ekaterinburg Standard Time',
        'Pakistan Standard Time',
        'India Standard Time',
        'Sri Lanka Standard Time',
        'Nepal Standard Time',
        'Central Asia Standard Time',
        'Bangladesh Standard Time',
        'Omsk Standard Time',
        'Myanmar Standard Time',
        'SE Asia Standard Time',
        'Altai Standard Time',
        'W. Mongolia Standard Time',
        'North Asia Standard Time',
        'N. Central Asia Standard Time',
        'Tomsk Standard Time',
        'China Standard Time',
        'North Asia East Standard Time',
        'Singapore Standard Time',
        'W. Australia Standard Time',
        'Taipei Standard Time',
        'Ulaanbaatar Standard Time',
        'North Korea Standard Time',
        'Aus Central W. Standard Time',
        'Transbaikal Standard Time',
        'Tokyo Standard Time',
        'Korea Standard Time',
        'Yakutsk Standard Time',
        'Cen. Australia Standard Time',
        'AUS Central Standard Time',
        'E. Australia Standard Time',
        'AUS Eastern Standard Time',
        'West Pacific Standard Time',
        'Tasmania Standard Time',
        'Vladivostok Standard Time',
        'Lord Howe Standard Time',
        'Bougainville Standard Time',
        'Russia Time Zone 10',
        'Magadan Standard Time',
        'Norfolk Standard Time',
        'Sakhalin Standard Time',
        'Central Pacific Standard Time',
        'Russia Time Zone 11',
        'New Zealand Standard Time',
        'UTC+12',
        'Fiji Standard Time',
        'Kamchatka Standard Time',
        'Chatham Islands Standard Time',
        'UTC+13',
        'Tonga Standard Time',
        'Samoa Standard Time',
        'Line Islands Standard Time'
    )]
    [String] $TimeZone

    [ValidateNotNull()]
    [CultureInfo] $Culture

    [ValidateNotNull()]
    [Boolean] $IsMfaEnabled = $true

    [ValidateSet( 'PhoneApp', 'VoiceCall' )]
    [String] $MfaMode

    [ValidateSet( 'Standard' )]
    [String] $MfaPinMode

    [AllowEmptyCollection()]
    [UInt16[]] $Permissions = @()

    [ValidateNotNull()]
    [DateTime] $LastModified

    [ValidateNotNull()]
    [DateTime] $PasswordLastSet

    [ValidateNotNull()]
    [Boolean] $MustChangePassword

    [ValidateNotNull()]
    [DateTime] $LastLogin

    #Constructors
    ArmorUser () {}
}
