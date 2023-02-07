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
my $CustomerUserObject          = $Kernel::OM->Get('Kernel::System::CustomerUser');
my $CustomerCompanyObject       = $Kernel::OM->Get('Kernel::System::CustomerCompany');
my $ConfigObject                = $Kernel::OM->Get('Kernel::Config');

my $UserID = 1;

$ConfigObject->Set(
    Key   => 'CheckEmailAddresses',
    Value => 0,
);

$ConfigObject->Set(
    Key   => 'CheckMXRecord',
    Value => 0,
);

my $ValidID = $ValidObject->ValidLookup(
    Valid => 'valid',
);

#
# Prepare customer company and user
#
my $CustomerID = $CustomerCompanyObject->CustomerCompanyAdd(
    CustomerID             => 'UnitTestCustomerCompany' . $HelperObject->GetRandomID(),
    CustomerCompanyName    => 'UnitTestCustomerCompany name',
    CustomerCompanyStreet  => 'UnitTestCustomerCompany street',
    CustomerCompanyZIP     => 'UnitTestCustomerCompany postal code',
    CustomerCompanyCity    => 'UnitTestCustomerCompany city',
    CustomerCompanyCountry => 'Germany',
    CustomerCompanyURL     => 'http://www.example.org',
    CustomerCompanyComment => 'UnitTestCustomerCompany comment',
    ValidID                => $ValidID,
    UserID                 => $UserID,
);

my %CustomerCompany = $CustomerCompanyObject->CustomerCompanyGet(
    CustomerID => $CustomerID,
);

delete $CustomerCompany{Config};
delete $CustomerCompany{CompanyConfig};

my $CustomerUserLogin = $CustomerUserObject->CustomerUserAdd(
    Source         => 'CustomerUser',
    UserFirstname  => 'UnitTestCustomerUser first name',
    UserLastname   => 'UnitTestCustomerCompany last name',
    UserCustomerID => $CustomerID,
    UserLogin      => 'UnitTestCustomerCompany' . $HelperObject->GetRandomID(),
    UserPassword   => '12345678',
    UserEmail      => 'email@example.com',
    ValidID        => $ValidID,
    UserID         => $UserID,
);

my %CustomerUser = $CustomerUserObject->CustomerUserDataGet(
    User => $CustomerUserLogin,
);

delete $CustomerUser{Config};
delete $CustomerUser{CompanyConfig};

#
# Prepare a config item
#
my $Classes = $GeneralCatalogObject->ItemList(
    Class => 'ITSM::ConfigItem::Class',
    Valid => $ValidID,
);
my %Classes = reverse %{ $Classes // {} };

$Self->True(
    scalar $Classes{Location},
    'Class "Location" must be present.',
);

my $ConfigItemID = $ConfigItemObject->ConfigItemAdd(
    ClassID => $Classes{Location},
    UserID  => $UserID,
);

$Self->True(
    scalar $ConfigItemID,
    'Config item must have been created successfully.',
) || return;

my $LocationType = $GeneralCatalogObject->ItemGet(
    Class => 'ITSM::ConfigItem::Location::Type',
    Name  => 'Office',
);

my $DeplStateProduction = $GeneralCatalogObject->ItemGet(
    Class => 'ITSM::ConfigItem::DeploymentState',
    Name  => 'Production',
);

my $InciStateOperational = $GeneralCatalogObject->ItemGet(
    Class => 'ITSM::Core::IncidentState',
    Name  => 'Operational',
);

my $Definition = $ConfigItemObject->DefinitionGet(
    ClassID => $Classes{Location},
);

my $LocationName = 'UnitTestLocation' . $HelperObject->GetRandomID();

my $VersionID = $ZnunyHelperObject->_ITSMConfigItemVersionAdd(
    ConfigItemID  => $ConfigItemID,
    Name          => $LocationName,
    ClassName     => 'Location',
    DeplStateName => 'Production',
    InciStateName => 'Operational',
    XMLData       => {
        Type       => $LocationType->{ItemID},
        CustomerID => $CustomerID,
        Owner      => $CustomerUserLogin,
    },
);

my $ConfigItemData = $ITSMConfigItemInvokerObject->GetConfigItemData(
    ConfigItemID => $ConfigItemID,
    Event        => undef,
);

my %ExpectedConfigItemData = (
    XMLData => {
        Type => [
            {
                Content       => $LocationType->{ItemID},
                ReadableValue => 'Office',
            },
        ],
        CustomerID => [
            {
                Content       => $CustomerID,
                ReadableValue => \%CustomerCompany,
            },
        ],
        Owner => [
            {
                Content       => $CustomerUserLogin,
                ReadableValue => \%CustomerUser,
            },
        ],
    },
    ConfigItemID => $ConfigItemID,
    DefinitionID => $Definition->{DefinitionID},
    InciStateID  => $InciStateOperational->{ItemID},
    Name         => $LocationName,
    DeplStateID  => $DeplStateProduction->{ItemID},
    DeplState    => 'Production',
    ClassID      => $Classes{Location},
    InciState    => 'Operational',
    Class        => 'Location',
);

$Self->IsDeeply(
    $ConfigItemData,
    \%ExpectedConfigItemData,
    'GetConfigItemData(): Config item data must match expected one.',
);

1;
