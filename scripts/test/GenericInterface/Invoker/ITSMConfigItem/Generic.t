# --
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

use strict;
use warnings;
use utf8;

use vars (qw($Self));

use Kernel::System::ObjectManager;

use Kernel::System::VariableCheck qw(:all);

use Kernel::GenericInterface::Invoker::ITSMConfigItem::Generic;

$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        RestoreDatabase => 1,
    },
);

my $HelperObject         = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
my $ZnunyHelperObject    = $Kernel::OM->Get('Kernel::System::ZnunyHelper');
my $ConfigObject         = $Kernel::OM->Get('Kernel::Config');
my $ValidObject          = $Kernel::OM->Get('Kernel::System::Valid');
my $ConfigItemObject     = $Kernel::OM->Get('Kernel::System::ITSMConfigItem');
my $GeneralCatalogObject = $Kernel::OM->Get('Kernel::System::GeneralCatalog');

my $GenericInvokerObject = Kernel::GenericInterface::Invoker::ITSMConfigItem::Generic->new(
    DebuggerObject => 1,    # this is a mock-up, the debugger object will not be used within this test.
);

my $UserID = 1;

#
# Prepare a config item
#
my $ValidID = $ValidObject->ValidLookup(
    Valid => 'valid',
);

my $Classes = $GeneralCatalogObject->ItemList(
    Class => 'ITSM::ConfigItem::Class',
    Valid => $ValidID,
);
my %Classes = reverse %{ $Classes // {} };

$Self->True(
    scalar $Classes{Computer},
    'Class "Computer" must be present.',
);

my $YesNo = $GeneralCatalogObject->ItemList(
    Class => 'ITSM::ConfigItem::YesNo',
    Valid => $ValidID,
);
my %YesNo = reverse %{ $YesNo // {} };

my $ConfigItemID = $ConfigItemObject->ConfigItemAdd(
    ClassID => $Classes{Computer},
    UserID  => $UserID,
);

$Self->True(
    scalar $ConfigItemID,
    'Config item must have been created successfully.',
) || return;

my $ComputerNameFirstVersion  = 'UnitTestComputer' . $HelperObject->GetRandomID();
my $ComputerNameSecondVersion = 'UnitTestComputer' . $HelperObject->GetRandomID();
my $Class                     = 'Computer';
my $ClassID                   = $Classes{Computer};

my $DeplStateProduction = $GeneralCatalogObject->ItemGet(
    Class => 'ITSM::ConfigItem::DeploymentState',
    Name  => 'Production',
);

my $DeplStateRepair = $GeneralCatalogObject->ItemGet(
    Class => 'ITSM::ConfigItem::DeploymentState',
    Name  => 'Repair',
);

my $InciStateOperational = $GeneralCatalogObject->ItemGet(
    Class => 'ITSM::Core::IncidentState',
    Name  => 'Operational',
);

my $InciStateIncident = $GeneralCatalogObject->ItemGet(
    Class => 'ITSM::Core::IncidentState',
    Name  => 'Incident',
);

my $Definition = $ConfigItemObject->DefinitionGet(
    ClassID => $ClassID,
);

my $FirstVersionID = $ZnunyHelperObject->_ITSMConfigItemVersionAdd(
    ConfigItemID  => $ConfigItemID,
    Name          => $ComputerNameFirstVersion,
    ClassName     => $Class,
    DeplStateName => 'Production',
    InciStateName => 'Operational',
    XMLData       => {
        CPU => [
            {
                Content => 'AMD Ryzen',
            },
        ],
        WarrantyExpirationDate => '2021-07-16',
        InstallDate            => '2021-07-16',
        NIC                    => [
            {
                Content    => 'NIC',
                IPoverDHCP => [
                    {
                        Content => $YesNo{Yes},
                    },
                ],
                IPAddress => [
                    {
                        Content => '127.0.0.1'
                    },
                ],
            },
        ],
    },
);

#
# Invalid config item ID
#
my $RequestData = $GenericInvokerObject->PrepareRequest(
    Data => {
        ConfigItemID => 999999999999,
        Event        => undef,
    },
);

my %ExpectedRequestData = (
    Success      => 0,
    ErrorMessage => 'Data of config item with ID 999999999999 could not be retrieved.',
);

$Self->IsDeeply(
    $RequestData,
    \%ExpectedRequestData,
    'PrepareRequest(): Request data must match expected one for invalid config item ID.',
);

#
# Valid config item ID without event
#
$RequestData = $GenericInvokerObject->PrepareRequest(
    Data => {
        ConfigItemID => $ConfigItemID,
        Event        => undef,
    },
);

my %ExpectedRequestDataFirstVersion = (
    XMLData => {
        NIC => [
            {
                IPAddress => [
                    {
                        Content => '127.0.0.1',
                    }
                ],
                IPoverDHCP => [
                    {
                        ReadableValue => 'Yes',
                        Content       => $YesNo{Yes},
                    }
                ],
                Content => 'NIC',
            },
        ],
        WarrantyExpirationDate => [
            {
                Content => '2021-07-16',
            },
        ],
        CPU => [
            {
                Content => 'AMD Ryzen',
            },
        ],
        InstallDate => [
            {
                Content => '2021-07-16',
            },
        ],
    },
    ConfigItemID => $ConfigItemID,
    DefinitionID => $Definition->{DefinitionID},
    InciStateID  => $InciStateOperational->{ItemID},
    Name         => $ComputerNameFirstVersion,
    DeplStateID  => $DeplStateProduction->{ItemID},
    DeplState    => 'Production',
    ClassID      => $ClassID,
    InciState    => 'Operational',
    Class        => $Class,
);

%ExpectedRequestData = (
    Success => 1,
    Data    => {
        ConfigItem => {
            %ExpectedRequestDataFirstVersion,
        },
        Event => undef,
    },
);

$Self->IsDeeply(
    $RequestData,
    \%ExpectedRequestData,
    'PrepareRequest(): Request data must match expected one for valid config item ID (first version) without event.',
);

my $SecondVersionID = $ZnunyHelperObject->_ITSMConfigItemVersionAdd(
    ConfigItemID  => $ConfigItemID,
    Name          => $ComputerNameSecondVersion,
    ClassName     => $Class,
    DeplStateName => 'Repair',
    InciStateName => 'Incident',
    XMLData       => {
        CPU => [
            {
                Content => 'Intel Core',
            },
        ],
        WarrantyExpirationDate => '2023-07-15',
        InstallDate            => '2021-07-16',
        NIC                    => [
            {
                Content    => 'NIC1',
                IPoverDHCP => [
                    {
                        Content => $YesNo{Yes},
                    },
                ],
                IPAddress => [
                    {
                        Content => '127.0.0.1'
                    },
                ],
            },
            {
                Content    => 'NIC2',
                IPoverDHCP => [
                    {
                        Content => $YesNo{No},
                    },
                ],
                IPAddress => [
                    {
                        Content => '127.1.0.1'
                    },
                ],
            },
        ],
    },
);

$RequestData = $GenericInvokerObject->PrepareRequest(
    Data => {
        ConfigItemID => $ConfigItemID,
        Event        => undef,
    },
);

my %ExpectedRequestDataSecondVersion = (
    XMLData => {
        NIC => [
            {
                IPAddress => [
                    {
                        Content => '127.0.0.1',
                    }
                ],
                IPoverDHCP => [
                    {
                        ReadableValue => 'Yes',
                        Content       => $YesNo{Yes},
                    }
                ],
                Content => 'NIC1',
            },
            {
                IPAddress => [
                    {
                        Content => '127.1.0.1',
                    }
                ],
                IPoverDHCP => [
                    {
                        ReadableValue => 'No',
                        Content       => $YesNo{No},
                    }
                ],
                Content => 'NIC2',
            },
        ],
        WarrantyExpirationDate => [
            {
                Content => '2023-07-15',
            },
        ],
        CPU => [
            {
                Content => 'Intel Core',
            },
        ],
        InstallDate => [
            {
                Content => '2021-07-16',
            },
        ],
    },
    ConfigItemID => $ConfigItemID,
    DefinitionID => $Definition->{DefinitionID},
    InciStateID  => $InciStateIncident->{ItemID},
    Name         => $ComputerNameSecondVersion,
    DeplStateID  => $DeplStateRepair->{ItemID},
    DeplState    => 'Repair',
    ClassID      => $ClassID,
    InciState    => 'Incident',
    Class        => $Class,
);

%ExpectedRequestData = (
    Success => 1,
    Data    => {
        ConfigItem => {
            %ExpectedRequestDataSecondVersion,
        },
        Event => undef,
    },
);

$Self->IsDeeply(
    $RequestData,
    \%ExpectedRequestData,
    'PrepareRequest(): Request data must match expected one for valid config item ID (second version) without event.',
);

#
# Valid config item ID with event ConfigItemCreate
# This should not return the data of the previous config item version.
#
$RequestData = $GenericInvokerObject->PrepareRequest(
    Data => {
        ConfigItemID => $ConfigItemID,
        Event        => 'ConfigItemCreate',
    },
);

%ExpectedRequestData = (
    Success => 1,
    Data    => {
        ConfigItem => {
            %ExpectedRequestDataSecondVersion,
        },
        Event => 'ConfigItemCreate',
    },
);

$Self->IsDeeply(
    $RequestData,
    \%ExpectedRequestData,
    'PrepareRequest(): Request data must match expected one for valid config item ID (second version) with event ConfigItemCreate.',
);

#
# Valid config item ID with event ConfigItemDelete
# This should not return the data of the previous config item version.
#
$RequestData = $GenericInvokerObject->PrepareRequest(
    Data => {
        ConfigItemID => $ConfigItemID,
        Event        => 'ConfigItemDelete',
    },
);

%ExpectedRequestData = (
    Success => 1,
    Data    => {
        ConfigItem => {
            %ExpectedRequestDataSecondVersion,
        },
        Event => 'ConfigItemDelete',
    },
);

$Self->IsDeeply(
    $RequestData,
    \%ExpectedRequestData,
    'PrepareRequest(): Request data must match expected one for valid config item ID (second version) with event ConfigItemDelete.',
);

#
# Valid config item ID with event DeploymentStateUpdate
# This should return the data of the previous config item version and as separate information
# the changed deployment status.
#
$RequestData = $GenericInvokerObject->PrepareRequest(
    Data => {
        ConfigItemID => $ConfigItemID,
        Event        => 'DeploymentStateUpdate',
    },
);

%ExpectedRequestData = (
    Success => 1,
    Data    => {
        ConfigItem => {
            %ExpectedRequestDataSecondVersion,
            PreviousConfigItemVersion => {
                %ExpectedRequestDataFirstVersion,
            },
            DeploymentStateUpdate => {
                Old => {
                    ID      => $ExpectedRequestDataFirstVersion{DeplStateID},
                    Content => $ExpectedRequestDataFirstVersion{DeplState},
                },
                New => {
                    ID      => $ExpectedRequestDataSecondVersion{DeplStateID},
                    Content => $ExpectedRequestDataSecondVersion{DeplState},
                },
            },
        },
        Event => 'DeploymentStateUpdate',
    },
);

$Self->IsDeeply(
    $RequestData,
    \%ExpectedRequestData,
    'PrepareRequest(): Request data must match expected one for valid config item ID (second version) with event DeploymentStateUpdate.',
);

#
# Valid config item ID with event IncidentStateUpdate
# This should return the data of the previous config item version and as separate information
# the changed incident status.
#
$RequestData = $GenericInvokerObject->PrepareRequest(
    Data => {
        ConfigItemID => $ConfigItemID,
        Event        => 'IncidentStateUpdate',
    },
);

%ExpectedRequestData = (
    Success => 1,
    Data    => {
        ConfigItem => {
            %ExpectedRequestDataSecondVersion,
            PreviousConfigItemVersion => {
                %ExpectedRequestDataFirstVersion,
            },
            IncidentStateUpdate => {
                Old => {
                    ID      => $ExpectedRequestDataFirstVersion{InciStateID},
                    Content => $ExpectedRequestDataFirstVersion{InciState},
                },
                New => {
                    ID      => $ExpectedRequestDataSecondVersion{InciStateID},
                    Content => $ExpectedRequestDataSecondVersion{InciState},
                },
            },
        },
        Event => 'IncidentStateUpdate',
    },
);

$Self->IsDeeply(
    $RequestData,
    \%ExpectedRequestData,
    'PrepareRequest(): Request data must match expected one for valid config item ID (second version) with event IncidentStateUpdate.',
);

#
# Valid config item ID with event NameUpdate
# This should return the data of the previous config item version and as separate information
# the changed name.
#
$RequestData = $GenericInvokerObject->PrepareRequest(
    Data => {
        ConfigItemID => $ConfigItemID,
        Event        => 'NameUpdate',
    },
);

%ExpectedRequestData = (
    Success => 1,
    Data    => {
        ConfigItem => {
            %ExpectedRequestDataSecondVersion,
            PreviousConfigItemVersion => {
                %ExpectedRequestDataFirstVersion,
            },
            NameUpdate => {
                Old => {
                    Content => $ExpectedRequestDataFirstVersion{Name},
                },
                New => {
                    Content => $ExpectedRequestDataSecondVersion{Name},
                },
            },
        },
        Event => 'NameUpdate',
    },
);

$Self->IsDeeply(
    $RequestData,
    \%ExpectedRequestData,
    'PrepareRequest(): Request data must match expected one for valid config item ID (second version) with event NameUpdate.',
);

#
# Valid config item ID with event ValueUpdate
# This should return the data of the previous config item version and as separate information
# the changed values of field CPU.
#
$RequestData = $GenericInvokerObject->PrepareRequest(
    Data => {
        ConfigItemID => $ConfigItemID,
        Event        => 'ValueUpdate',
    },
);

%ExpectedRequestData = (
    Success => 1,
    Data    => {
        ConfigItem => {
            %ExpectedRequestDataSecondVersion,
            PreviousConfigItemVersion => {
                %ExpectedRequestDataFirstVersion,
            },
            ValueUpdate => {
                'CPU::1' => {
                    New => {
                        Content => 'Intel Core',
                    },
                    Old => {
                        Content => 'AMD Ryzen',
                    },
                },
                'NIC::1' => {
                    New => {
                        Content => 'NIC1',
                    },
                    Old => {
                        Content => 'NIC',
                    },
                },
                'NIC::2' => {
                    New => {
                        Content => 'NIC2',
                    },
                    Old => {
                        Content => '',
                    },
                },
                'NIC::2::IPAddress::1' => {
                    New => {
                        Content => '127.1.0.1',
                    },
                    Old => {
                        Content => '',
                    },
                },
                'NIC::2::IPoverDHCP::1' => {
                    New => {
                        Content       => $YesNo{No},
                        ReadableValue => 'No',
                    },
                    Old => {
                        Content => '',
                    },
                },
                'WarrantyExpirationDate::1' => {
                    New => {
                        Content => '2023-07-15',
                    },
                    Old => {
                        Content => '2021-07-16',
                    },
                },
            },
        },
        Event => 'ValueUpdate',
    },
);

$Self->IsDeeply(
    $RequestData,
    \%ExpectedRequestData,
    'PrepareRequest(): Request data must match expected one for valid config item ID (second version) with event ValueUpdate.',
);

1;
