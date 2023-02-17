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

my $ConfigObject                    = $Kernel::OM->Get('Kernel::Config');
my $HelperObject                    = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
my $LinkObject                      = $Kernel::OM->Get('Kernel::System::LinkObject');
my $UnitTestITSMConfigItemObject    = $Kernel::OM->Get('Kernel::System::UnitTest::ITSMConfigItem');
my $ITSMConfigItemCustomerCIsObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItemCustomerCIs');

my %ConfigItemKey = %{
    $ConfigObject->Get('AgentCustomerUserInformationCenter::Backend')->{'0060-CUIC-ITSMConfigItemCustomerUser'}
        ->{ConfigItemKey} || {}
};

my $TestUserLogin = $HelperObject->TestCustomerUserCreate();

my @ExpectedConfigItemIDs;
my $VersionRef;
my $RandomID;
my $ConfigItemName;

for my $Index ( 0 .. 3 ) {
    $RandomID       = $HelperObject->GetRandomID();
    $ConfigItemName = "UnitTestPC $RandomID";
    $VersionRef     = $UnitTestITSMConfigItemObject->ConfigItemCreate(
        Name          => $ConfigItemName,
        ClassName     => 'Computer',
        DeplStateName => 'Production',
        InciStateName => 'Operational',
        XMLData       => {
            OtherEquipment           => '...',
            Note                     => '...',
            SerialNumber             => '...',
            WarrantyExpirationDate   => '2016-01-01',
            InstallDate              => '2016-01-01',
            $ConfigItemKey{Computer} => $TestUserLogin,
        },
    );

    $Self->True(
        $VersionRef->{ConfigItemID},
        "ConfigItemCreate was successfull - $VersionRef->{ConfigItemID}",
    );

    push @ExpectedConfigItemIDs, $VersionRef->{ConfigItemID};

}

my @CustomerUserCIs = $ITSMConfigItemCustomerCIsObject->GetCustomerUserCIs(
    CustomerUserID => $TestUserLogin,
);

$Self->IsDeeply(
    \@CustomerUserCIs,
    \@ExpectedConfigItemIDs,
    "GetCustomerCIs was successfull for CustomerUser - $TestUserLogin",
);

# with other user
my @ExpectedConfigItemIDs2;

$RandomID = $HelperObject->GetRandomID();

my $TestUserLogin2 = $HelperObject->TestCustomerUserCreate();

$VersionRef = $UnitTestITSMConfigItemObject->ConfigItemCreate(
    Name          => $ConfigItemName,
    ClassName     => 'Computer',
    DeplStateName => 'Production',
    InciStateName => 'Operational',
    XMLData       => {
        OtherEquipment           => '...',
        Note                     => '...',
        SerialNumber             => '...',
        WarrantyExpirationDate   => '2016-01-01',
        InstallDate              => '2016-01-01',
        $ConfigItemKey{Computer} => $TestUserLogin2,
    },
);

$Self->True(
    $VersionRef->{ConfigItemID},
    "ConfigItemCreate was successfull - $VersionRef->{ConfigItemID}",
);

push @ExpectedConfigItemIDs2, $VersionRef->{ConfigItemID};

$RandomID = $HelperObject->GetRandomID();

$VersionRef = $UnitTestITSMConfigItemObject->ConfigItemCreate(
    Name          => $ConfigItemName,
    ClassName     => 'Computer',
    DeplStateName => 'Production',
    InciStateName => 'Operational',
    XMLData       => {
        OtherEquipment           => '...',
        Note                     => '...',
        SerialNumber             => '...',
        WarrantyExpirationDate   => '2016-01-01',
        InstallDate              => '2016-01-01',
        $ConfigItemKey{Computer} => "DummyUser",
    },
);

@CustomerUserCIs = $ITSMConfigItemCustomerCIsObject->GetCustomerUserCIs(
    CustomerUserID => $TestUserLogin2,
);

$Self->IsDeeply(
    \@CustomerUserCIs,
    \@ExpectedConfigItemIDs2,
    "GetCustomerCIs was successfull for CustomerUser - $TestUserLogin2",
);

# GetPossibleCustomerCIs

$RandomID       = $HelperObject->GetRandomID();
$ConfigItemName = "UnitTestPC $RandomID";

my $TestUserLogin3 = $HelperObject->TestCustomerUserCreate();
$VersionRef = $UnitTestITSMConfigItemObject->ConfigItemCreate(
    Name          => $ConfigItemName,
    ClassName     => 'Computer',
    DeplStateName => 'Production',
    InciStateName => 'Operational',
    XMLData       => {
        OtherEquipment           => '...',
        Note                     => '...',
        SerialNumber             => '...',
        WarrantyExpirationDate   => '2016-01-01',
        InstallDate              => '2016-01-01',
        $ConfigItemKey{Computer} => $TestUserLogin3,
    },
);

my @ConfigItems = $ITSMConfigItemCustomerCIsObject->GetPossibleCustomerCIs(
    CustomerUserID => $TestUserLogin3,
);

$Self->IsDeeply(
    \@ConfigItems,
    [
        {
            'Class'        => 'Computer',
            'Icon'         => '',
            'Linked'       => '0',
            'ConfigItemID' => $VersionRef->{ConfigItemID},
            'Number'       => $VersionRef->{Number},
            'Name'         => $ConfigItemName,
        }
    ],
    "GetPossibleCustomerCIs",
);

my $TicketID = $HelperObject->TicketCreate(
    CustomerUser => $TestUserLogin3,
);

$LinkObject->LinkAdd(
    SourceObject => 'Ticket',
    SourceKey    => $TicketID,
    TargetObject => 'ITSMConfigItem',
    TargetKey    => $VersionRef->{ConfigItemID},
    Type         => 'RelevantTo',
    State        => 'Valid',
    UserID       => 1,
);

@ConfigItems = $ITSMConfigItemCustomerCIsObject->GetPossibleCustomerCIs(
    CustomerUserID => $TestUserLogin3,
    TicketID       => $TicketID,
);

$Self->IsDeeply(
    \@ConfigItems,
    [
        {
            'Class'        => 'Computer',
            'Icon'         => '',
            'Linked'       => '1',
            'ConfigItemID' => $VersionRef->{ConfigItemID},
            'Number'       => $VersionRef->{Number},
            'Name'         => $ConfigItemName,
        }
    ],
    "GetPossibleCustomerCIs with Ticket link",
);

1;
