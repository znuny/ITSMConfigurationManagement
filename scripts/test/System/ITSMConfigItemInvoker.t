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

$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        RestoreDatabase => 1,
    },
);

my $HelperObject                = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
my $ConfigItemObject            = $Kernel::OM->Get('Kernel::System::ITSMConfigItem');
my $GeneralCatalogObject        = $Kernel::OM->Get('Kernel::System::GeneralCatalog');
my $ValidObject                 = $Kernel::OM->Get('Kernel::System::Valid');
my $ITSMConfigItemInvokerObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItemInvoker');
my $ZnunyHelperObject           = $Kernel::OM->Get('Kernel::System::ZnunyHelper');

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
my $ConfigItemData = $ITSMConfigItemInvokerObject->GetConfigItemData(
    ConfigItemID => 999999999999,
    Event        => undef,
);

$Self->False(
    scalar $ConfigItemData,
    'GetConfigItemData(): Config item data must match expected one for invalid config item ID.',
);

#
# Valid config item ID without event
#
$ConfigItemData = $ITSMConfigItemInvokerObject->GetConfigItemData(
    ConfigItemID => $ConfigItemID,
    Event        => undef,
);

my %ExpectedConfigItemDataFirstVersion = (
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

$Self->IsDeeply(
    $ConfigItemData,
    \%ExpectedConfigItemDataFirstVersion,
    'GetConfigItemData(): Config item data must match expected one for valid config item ID (first version) without event.',
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

$ConfigItemData = $ITSMConfigItemInvokerObject->GetConfigItemData(
    ConfigItemID => $ConfigItemID,
    Event        => undef,
);

my %ExpectedConfigItemDataSecondVersion = (
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

$Self->IsDeeply(
    $ConfigItemData,
    \%ExpectedConfigItemDataSecondVersion,
    'GetConfigItemData(): Config item data must match expected one for valid config item ID (second version) without event.',
);

#
# Valid config item ID with event ConfigItemCreate
# This should not return the data of the previous config item version.
#
$ConfigItemData = $ITSMConfigItemInvokerObject->GetConfigItemData(
    ConfigItemID => $ConfigItemID,
    Event        => 'ConfigItemCreate',
);

$Self->IsDeeply(
    $ConfigItemData,
    \%ExpectedConfigItemDataSecondVersion,
    'GetConfigItemData(): Config item data must match expected one for valid config item ID (second version) with event ConfigItemCreate.',
);

#
# Valid config item ID with event ConfigItemDelete
# This should not return the data of the previous config item version.
#
$ConfigItemData = $ITSMConfigItemInvokerObject->GetConfigItemData(
    ConfigItemID => $ConfigItemID,
    Event        => 'ConfigItemDelete',
);

$Self->IsDeeply(
    $ConfigItemData,
    \%ExpectedConfigItemDataSecondVersion,
    'GetConfigItemData(): Config item data must match expected one for valid config item ID (second version) with event ConfigItemDelete.',
);

#
# Valid config item ID with event DeploymentStateUpdate
# This should return the data of the previous config item version and as separate information
# the changed deployment status.
#
$ConfigItemData = $ITSMConfigItemInvokerObject->GetConfigItemData(
    ConfigItemID => $ConfigItemID,
    Event        => 'DeploymentStateUpdate',
);

my %ExpectedConfigItemData = (
    %ExpectedConfigItemDataSecondVersion,
    PreviousConfigItemVersion => {
        %ExpectedConfigItemDataFirstVersion,
    },
    DeploymentStateUpdate => {
        Old => {
            ID      => $ExpectedConfigItemDataFirstVersion{DeplStateID},
            Content => $ExpectedConfigItemDataFirstVersion{DeplState},
        },
        New => {
            ID      => $ExpectedConfigItemDataSecondVersion{DeplStateID},
            Content => $ExpectedConfigItemDataSecondVersion{DeplState},
        },
    },
);

$Self->IsDeeply(
    $ConfigItemData,
    \%ExpectedConfigItemData,
    'GetConfigItemData(): Config item data must match expected one for valid config item ID (second version) with event DeploymentStateUpdate.',
);

#
# Valid config item ID with event IncidentStateUpdate
# This should return the data of the previous config item version and as separate information
# the changed incident status.
#
$ConfigItemData = $ITSMConfigItemInvokerObject->GetConfigItemData(
    ConfigItemID => $ConfigItemID,
    Event        => 'IncidentStateUpdate',
);

%ExpectedConfigItemData = (
    %ExpectedConfigItemDataSecondVersion,
    PreviousConfigItemVersion => {
        %ExpectedConfigItemDataFirstVersion,
    },
    IncidentStateUpdate => {
        Old => {
            ID      => $ExpectedConfigItemDataFirstVersion{InciStateID},
            Content => $ExpectedConfigItemDataFirstVersion{InciState},
        },
        New => {
            ID      => $ExpectedConfigItemDataSecondVersion{InciStateID},
            Content => $ExpectedConfigItemDataSecondVersion{InciState},
        },
    },
);

$Self->IsDeeply(
    $ConfigItemData,
    \%ExpectedConfigItemData,
    'GetConfigItemData(): Config item data must match expected one for valid config item ID (second version) with event IncidentStateUpdate.',
);

#
# Valid config item ID with event NameUpdate
# This should return the data of the previous config item version and as separate information
# the changed name.
#
$ConfigItemData = $ITSMConfigItemInvokerObject->GetConfigItemData(
    ConfigItemID => $ConfigItemID,
    Event        => 'NameUpdate',
);

%ExpectedConfigItemData = (
    %ExpectedConfigItemDataSecondVersion,
    PreviousConfigItemVersion => {
        %ExpectedConfigItemDataFirstVersion,
    },
    NameUpdate => {
        Old => {
            Content => $ExpectedConfigItemDataFirstVersion{Name},
        },
        New => {
            Content => $ExpectedConfigItemDataSecondVersion{Name},
        },
    },
);

$Self->IsDeeply(
    $ConfigItemData,
    \%ExpectedConfigItemData,
    'GetConfigItemData(): Config item data must match expected one for valid config item ID (second version) with event NameUpdate.',
);

#
# Valid config item ID with event ValueUpdate
# This should return the data of the previous config item version and as separate information
# the changed values of field CPU.
#
$ConfigItemData = $ITSMConfigItemInvokerObject->GetConfigItemData(
    ConfigItemID => $ConfigItemID,
    Event        => 'ValueUpdate',
);

%ExpectedConfigItemData = (
    %ExpectedConfigItemDataSecondVersion,
    PreviousConfigItemVersion => {
        %ExpectedConfigItemDataFirstVersion,
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
);

$Self->IsDeeply(
    $ConfigItemData,
    \%ExpectedConfigItemData,
    'GetConfigItemData(): Config item data must match expected one for valid config item ID (second version) with event ValueUpdate.',
);

1;
