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

my $HelperObject                 = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
my $ConfigItemObject             = $Kernel::OM->Get('Kernel::System::ITSMConfigItem');
my $GeneralCatalogObject         = $Kernel::OM->Get('Kernel::System::GeneralCatalog');
my $DynamicFieldObject           = $Kernel::OM->Get('Kernel::System::DynamicField');
my $DynamicFieldBackendObject    = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');
my $ValidObject                  = $Kernel::OM->Get('Kernel::System::Valid');
my $TicketObject                 = $Kernel::OM->Get('Kernel::System::Ticket');
my $ZnunyHelperObject            = $Kernel::OM->Get('Kernel::System::ZnunyHelper');
my $DynamicFieldConfigItemObject = $Kernel::OM->Get('Kernel::System::DynamicField::ConfigItem');

my $ValidID = $ValidObject->ValidLookup(
    Valid => 'valid',
);

my $UserID = 1;

#
# Prepare config item
#
my $ClassListRef = $GeneralCatalogObject->ItemList(
    Class => 'ITSM::ConfigItem::Class',
    Valid => $ValidID,
);
my %ClassList = reverse %{ $ClassListRef || {} };

my $YesNoRef = $GeneralCatalogObject->ItemList(
    Class => 'ITSM::ConfigItem::YesNo',
    Valid => $ValidID,
);
my %YesNoList = reverse %{ $YesNoRef || {} };

my $ConfigItem1ID = $ConfigItemObject->ConfigItemAdd(
    ClassID => $ClassList{Computer},
    UserID  => $UserID,
);

$Self->True(
    scalar $ConfigItem1ID,
    'Config item must have been created successfully.',
);

my $ConfigItem1VersionID = $ZnunyHelperObject->_ITSMConfigItemVersionAdd(
    ConfigItemID  => $ConfigItem1ID,
    Name          => 'Unit test computer 1',
    ClassName     => 'Computer',
    DeplStateName => 'Production',
    InciStateName => 'Operational',
    XMLData       => {
        OtherEquipment         => 'Mouse',
        Note                   => 'Unit test computer 1 note.',
        WarrantyExpirationDate => '2040-01-01',
        InstallDate            => '2040-01-01',
        CPU                    => [
            {
                Content => 'CPU 1',
            },
            {
                Content => 'CPU 2',
            },
        ],
        NIC => [
            {
                Content    => 'NIC',
                IPoverDHCP => [
                    {
                        Content => $YesNoList{Yes},
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

$Self->True(
    scalar $ConfigItem1VersionID,
    'Config item version must have been created successfully.',
);

my $ConfigItem2ID = $ConfigItemObject->ConfigItemAdd(
    ClassID => $ClassList{Computer},
    UserID  => $UserID,
);

$Self->True(
    scalar $ConfigItem2ID,
    'Config item must have been created successfully.',
);

my $ConfigItem2VersionID = $ZnunyHelperObject->_ITSMConfigItemVersionAdd(
    ConfigItemID  => $ConfigItem2ID,
    Name          => 'Unit test computer 2',
    ClassName     => 'Computer',
    DeplStateName => 'Production',
    InciStateName => 'Operational',
    XMLData       => {
        OtherEquipment         => 'Mouse',
        Note                   => 'Unit test computer 2 note.',
        WarrantyExpirationDate => '2041-01-01',
        InstallDate            => '2041-01-01',
        CPU                    => [
            {
                Content => 'CPU 1',
            },
            {
                Content => 'CPU 4',
            },
        ],
        NIC => [
            {
                Content    => 'NIC',
                IPoverDHCP => [
                    {
                        Content => $YesNoList{No},
                    },
                ],
                IPAddress => [
                    {
                        Content => '127.0.0.2'
                    },
                ],
            },
        ],
    },
);

$Self->True(
    scalar $ConfigItem2VersionID,
    'Config item version must have been created successfully.',
);

#
# Prepare dynamic fields.
#
my @DynamicFields = (
    {
        Name          => 'DynamicFieldConfigItemUnitTestText1',
        Label         => 'DynamicFieldConfigItemUnitTestText1',
        InternalField => 0,
        ObjectType    => 'Ticket',
        FieldType     => 'Text',
        Config        => {
            DefaultValue => '',
        },
    },
    {
        Name          => 'DynamicFieldConfigItemUnitTestText2',
        Label         => 'DynamicFieldConfigItemUnitTestText2',
        InternalField => 0,
        ObjectType    => 'Ticket',
        FieldType     => 'Text',
        Config        => {
            DefaultValue => '',
        },
    },
    {
        Name          => 'DynamicFieldConfigItemUnitTestText3',
        Label         => 'DynamicFieldConfigItemUnitTestText3',
        InternalField => 0,
        ObjectType    => 'Ticket',
        FieldType     => 'Text',
        Config        => {
            DefaultValue => '',
        },
    },
    {
        Name          => 'DynamicFieldConfigItemUnitTestText4',
        Label         => 'DynamicFieldConfigItemUnitTestText4',
        InternalField => 0,
        ObjectType    => 'Ticket',
        FieldType     => 'Text',
        Config        => {
            DefaultValue => '',
        },
    },
    {
        Name          => 'DynamicFieldConfigItemUnitTestText5',
        Label         => 'DynamicFieldConfigItemUnitTestText5',
        InternalField => 0,
        ObjectType    => 'Ticket',
        FieldType     => 'Text',
        Config        => {
            DefaultValue => '',
        },
    },
    {
        Name          => 'DynamicFieldConfigItemUnitTestDateTime',
        Label         => 'DynamicFieldConfigItemUnitTestDateTime',
        InternalField => 0,
        ObjectType    => 'Ticket',
        FieldType     => 'DateTime',
        Config        => {
            DefaultValue => '',
        },
    },
    {
        Name          => 'DynamicFieldConfigItemUnitTestDate',
        Label         => 'DynamicFieldConfigItemUnitTestDate',
        InternalField => 0,
        ObjectType    => 'Ticket',
        FieldType     => 'Date',
        Config        => {
            DefaultValue => '',
        },
    },
    {
        Name          => 'DynamicFieldConfigItemUnitTestMultiselect1',
        Label         => 'DynamicFieldConfigItemUnitTestMultiselect1',
        InternalField => 0,
        ObjectType    => 'Ticket',
        FieldType     => 'Multiselect',
        Config        => {
            DefaultValue   => '',
            PossibleNone   => 1,
            PossibleValues => {
                'CPU 1' => 'CPU 1',
                'CPU 2' => 'CPU 2',
                'CPU 3' => 'CPU 3',
            },
        },
    },
    {
        Name          => 'DynamicFieldConfigItemUnitTestMultiselect2',
        Label         => 'DynamicFieldConfigItemUnitTestMultiselect2',
        InternalField => 0,
        ObjectType    => 'Ticket',
        FieldType     => 'Multiselect',
        Config        => {
            DefaultValue   => '',
            PossibleNone   => 1,
            PossibleValues => {
                'CPU 1' => 'CPU 1',
                'CPU 2' => 'CPU 2',
                'CPU 3' => 'CPU 3',
            },
        },
    },
    {
        Name          => 'DynamicFieldConfigItemUnitTestMultiselect3',
        Label         => 'DynamicFieldConfigItemUnitTestMultiselect3',
        InternalField => 0,
        ObjectType    => 'Ticket',
        FieldType     => 'Multiselect',
        Config        => {
            DefaultValue   => '',
            PossibleNone   => 1,
            PossibleValues => {
                'CPU 1' => 'CPU 1',
                'CPU 2' => 'CPU 2',
                'CPU 3' => 'CPU 3',
            },
        },
    },
    {
        Name          => 'DynamicFieldConfigItemUnitTestDropdown1',
        Label         => 'DynamicFieldConfigItemUnitTestDropdown1',
        InternalField => 0,
        ObjectType    => 'Ticket',
        FieldType     => 'Dropdown',
        Config        => {
            DefaultValue   => '',
            PossibleNone   => 1,
            PossibleValues => {
                'CPU 1' => 'CPU 1',
                'CPU 2' => 'CPU 2',
                'CPU 3' => 'CPU 3',
            },
        },
    },
    {
        Name          => 'DynamicFieldConfigItemUnitTestDropdown2',
        Label         => 'DynamicFieldConfigItemUnitTestDropdown2',
        InternalField => 0,
        ObjectType    => 'Ticket',
        FieldType     => 'Dropdown',
        Config        => {
            DefaultValue   => '',
            PossibleNone   => 1,
            PossibleValues => {
                'CPU 1' => 'CPU 1',
                'CPU 2' => 'CPU 2',
                'CPU 3' => 'CPU 3',
            },
        },
    },
    {
        Name          => 'DynamicFieldConfigItemUnitTestDropdown3',
        Label         => 'DynamicFieldConfigItemUnitTestDropdown3',
        InternalField => 0,
        ObjectType    => 'Ticket',
        FieldType     => 'Dropdown',
        Config        => {
            DefaultValue   => '',
            PossibleNone   => 1,
            PossibleValues => {
                'CPU 1' => 'CPU 1',
                'CPU 2' => 'CPU 2',
                'CPU 3' => 'CPU 3',
            },
        },
    },

    # ConfigItemDropdown (single select)
    {
        Name          => 'DynamicFieldConfigItemUnitTestConfigItem1',
        Label         => 'DynamicFieldConfigItemUnitTestConfigItem1',
        InternalField => 0,
        ObjectType    => 'Ticket',
        FieldType     => 'ConfigItemDropdown',
        Config        => {
            ConfigItemClass       => 'Computer',
            ConfigItemLinkType    => undef,
            ConfigItemLinkSource  => undef,
            ConfigItemLinkRemoval => 0,
            AdditionalDFStorage   => [
                {
                    DynamicField  => 'DynamicFieldConfigItemUnitTestText1',
                    ConfigItemKey => 'CPU',
                    Type          => 'Frontend',
                },
                {
                    DynamicField  => 'DynamicFieldConfigItemUnitTestText2',
                    ConfigItemKey => 'CPU::2',
                    Type          => 'FrontendBackend',
                },
                {
                    DynamicField  => 'DynamicFieldConfigItemUnitTestText3',
                    ConfigItemKey => 'Name',
                    Type          => 'FrontendBackend',
                },
                {
                    DynamicField  => 'DynamicFieldConfigItemUnitTestText4',
                    ConfigItemKey => 'NIC::1::IPAddress::1',
                    Type          => 'FrontendBackend',
                },
                {
                    DynamicField  => 'DynamicFieldConfigItemUnitTestText5',
                    ConfigItemKey => 'ClassID',
                    Type          => 'Backend',                               # Notice that this one is backend only
                },
                {
                    DynamicField  => 'DynamicFieldConfigItemUnitTestDate',
                    ConfigItemKey => 'WarrantyExpirationDate',
                    Type          => 'FrontendBackend',
                },
                {
                    DynamicField  => 'DynamicFieldConfigItemUnitTestDateTime',
                    ConfigItemKey => 'WarrantyExpirationDate',
                    Type          => 'FrontendBackend',
                },
                {
                    DynamicField  => 'DynamicFieldConfigItemUnitTestDropdown1',
                    ConfigItemKey => 'CPU::1',
                    Type          => 'Frontend',
                },
                {
                    DynamicField  => 'DynamicFieldConfigItemUnitTestDropdown2',
                    ConfigItemKey => 'CPU',
                    Type          => 'Backend',
                },
                {
                    DynamicField  => 'DynamicFieldConfigItemUnitTestMultiselect1',
                    ConfigItemKey => 'CPU::2',
                    Type          => 'FrontendBackend',
                },
                {
                    DynamicField  => 'DynamicFieldConfigItemUnitTestMultiselect2',
                    ConfigItemKey => 'CPU',
                    Type          => 'FrontendBackend',
                },
            ],
        },
    },

    # ConfigItemMultiselect
    {
        Name          => 'DynamicFieldConfigItemUnitTestConfigItem2',
        Label         => 'DynamicFieldConfigItemUnitTestConfigItem2',
        InternalField => 0,
        ObjectType    => 'Ticket',
        FieldType     => 'ConfigItemMultiselect',
        Config        => {
            ConfigItemClass       => 'Computer',
            ConfigItemLinkType    => undef,
            ConfigItemLinkSource  => undef,
            ConfigItemLinkRemoval => 0,
            AdditionalDFStorage   => [
                {
                    DynamicField  => 'DynamicFieldConfigItemUnitTestText1',
                    ConfigItemKey => 'CPU',
                    Type          => 'Backend',
                },
                {
                    DynamicField  => 'DynamicFieldConfigItemUnitTestText2',
                    ConfigItemKey => 'CPU::2',
                    Type          => 'FrontendBackend',
                },
                {
                    DynamicField  => 'DynamicFieldConfigItemUnitTestText3',
                    ConfigItemKey => 'Name',
                    Type          => 'FrontendBackend',
                },
                {
                    DynamicField  => 'DynamicFieldConfigItemUnitTestText4',
                    ConfigItemKey => 'NIC::1::IPAddress::1',
                    Type          => 'FrontendBackend',
                },
                {
                    DynamicField  => 'DynamicFieldConfigItemUnitTestText5',
                    ConfigItemKey => 'ClassID',
                    Type          => 'Frontend',                              # Notice that this one is frontend only
                },
                {
                    DynamicField  => 'DynamicFieldConfigItemUnitTestDate',
                    ConfigItemKey => 'WarrantyExpirationDate',
                    Type          => 'Backend',
                },
                {
                    DynamicField  => 'DynamicFieldConfigItemUnitTestDateTime',
                    ConfigItemKey => 'WarrantyExpirationDate',
                    Type          => 'Backend',
                },
                {
                    DynamicField  => 'DynamicFieldConfigItemUnitTestDropdown1',
                    ConfigItemKey => 'CPU::1',
                    Type          => 'Backend',
                },
                {
                    DynamicField  => 'DynamicFieldConfigItemUnitTestDropdown2',
                    ConfigItemKey => 'CPU',
                    Type          => 'Backend',
                },
                {
                    DynamicField  => 'DynamicFieldConfigItemUnitTestMultiselect1',
                    ConfigItemKey => 'CPU::2',
                    Type          => 'Backend',
                },
                {
                    DynamicField  => 'DynamicFieldConfigItemUnitTestMultiselect2',
                    ConfigItemKey => 'CPU',
                    Type          => 'Backend',
                },
            ],
        },
    },
);

my $DynamicFieldsCreated = $ZnunyHelperObject->_DynamicFieldsCreate(@DynamicFields);

$Self->True(
    scalar $DynamicFieldsCreated,
    'Dynamic fields must have been created successfully.',
);

#
# ConfigItemDropdown (DynamicFieldConfigItemUnitTestConfigItem1)
#

my $TicketID = $HelperObject->TicketCreate();

my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
    Name => 'DynamicFieldConfigItemUnitTestConfigItem1',
);

# Triggers event Kernel::System::Ticket::Event::DynamicFieldConfigItemAdditionalDFStorage
$DynamicFieldBackendObject->ValueSet(
    DynamicFieldConfig => $DynamicFieldConfig,
    ObjectID           => $TicketID,
    Value              => $ConfigItem1ID,
    UserID             => $UserID,
);

# Only additional dynamic fields set to type "backend" are expected to be set by the event.
my %ExpectedDynamicFieldData = (
    DynamicFieldConfigItemUnitTestText1        => undef,                    # configured for frontend, not backend
    DynamicFieldConfigItemUnitTestText2        => 'CPU 2',
    DynamicFieldConfigItemUnitTestText3        => 'Unit test computer 1',
    DynamicFieldConfigItemUnitTestText4        => '127.0.0.1',
    DynamicFieldConfigItemUnitTestText5        => $ClassList{Computer},
    DynamicFieldConfigItemUnitTestDate         => '2040-01-01',
    DynamicFieldConfigItemUnitTestDateTime     => '2040-01-01 00:00:00',
    DynamicFieldConfigItemUnitTestDropdown1    => undef,                    # configured for frontend, not backend
    DynamicFieldConfigItemUnitTestDropdown2    => 'CPU 1',
    DynamicFieldConfigItemUnitTestMultiselect1 => [
        'CPU 2',
    ],
    DynamicFieldConfigItemUnitTestMultiselect2 => [
        'CPU 1',
        'CPU 2',
    ],
);

my %Ticket = $TicketObject->TicketGet(
    TicketID      => $TicketID,
    DynamicFields => 1,
    UserID        => $UserID,
);

for my $DynamicFieldName ( sort keys %ExpectedDynamicFieldData ) {
    my $ExpectedValue = $ExpectedDynamicFieldData{$DynamicFieldName};

    if ( $DynamicFieldName eq 'DynamicFieldConfigItemUnitTestDate' ) {
        $ExpectedValue .= ' 00:00:00';
    }

    $Self->IsDeeply(
        $Ticket{ 'DynamicField_' . $DynamicFieldName },
        $ExpectedValue,
        "ConfigItemDropdown - Content of dynamic field $DynamicFieldName must match expected one.",
    );
}

#
# ConfigItemMultiselect (DynamicFieldConfigItemUnitTestConfigItem2)
#

$TicketID = $HelperObject->TicketCreate();

$DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
    Name => 'DynamicFieldConfigItemUnitTestConfigItem2',
);

# Triggers event Kernel::System::Ticket::Event::DynamicFieldConfigItemAdditionalDFStorage
$DynamicFieldBackendObject->ValueSet(
    DynamicFieldConfig => $DynamicFieldConfig,
    ObjectID           => $TicketID,
    Value              => [ $ConfigItem1ID, $ConfigItem2ID, ],
    UserID             => $UserID,
);

# # Only additional dynamic fields set to type "backend" are expected to be set by the event.
%ExpectedDynamicFieldData = (
    DynamicFieldConfigItemUnitTestText1 => 'CPU 1, CPU 2, CPU 1, CPU 4',
    DynamicFieldConfigItemUnitTestText2 => 'CPU 2, CPU 4',
    DynamicFieldConfigItemUnitTestText3 => 'Unit test computer 1, Unit test computer 2',
    DynamicFieldConfigItemUnitTestText4 => '127.0.0.1, 127.0.0.2',
    DynamicFieldConfigItemUnitTestText5        => undef,                   # configured for frontend, not backend
    DynamicFieldConfigItemUnitTestDate         => '2040-01-01',
    DynamicFieldConfigItemUnitTestDateTime     => '2040-01-01 00:00:00',
    DynamicFieldConfigItemUnitTestDropdown1    => 'CPU 1',
    DynamicFieldConfigItemUnitTestDropdown2    => 'CPU 1',
    DynamicFieldConfigItemUnitTestMultiselect1 => [
        'CPU 2',
        'CPU 4',
    ],
    DynamicFieldConfigItemUnitTestMultiselect2 => [
        'CPU 1',
        'CPU 2',
        'CPU 1',
        'CPU 4',
    ],
);

%Ticket = $TicketObject->TicketGet(
    TicketID      => $TicketID,
    DynamicFields => 1,
    UserID        => $UserID,
);

for my $DynamicFieldName ( sort keys %ExpectedDynamicFieldData ) {
    my $ExpectedValue = $ExpectedDynamicFieldData{$DynamicFieldName};

    if ( $DynamicFieldName eq 'DynamicFieldConfigItemUnitTestDate' ) {
        $ExpectedValue .= ' 00:00:00';
    }

    $Self->IsDeeply(
        $Ticket{ 'DynamicField_' . $DynamicFieldName },
        $ExpectedValue,
        "ConfigItemMultiselect - Content of dynamic field $DynamicFieldName must match expected one.",
    );
}

1;
