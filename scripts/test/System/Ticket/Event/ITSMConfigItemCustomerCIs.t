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

use Kernel::System::VariableCheck qw(:all);

$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        RestoreDatabase => 1,
    },
);

my $ConfigObject                    = $Kernel::OM->Get('Kernel::Config');
my $HelperObject                    = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
my $TicketObject                    = $Kernel::OM->Get('Kernel::System::Ticket');
my $UnitTestITSMConfigItemObject    = $Kernel::OM->Get('Kernel::System::UnitTest::ITSMConfigItem');
my $UnitTestParamObject             = $Kernel::OM->Get('Kernel::System::UnitTest::Param');
my $ITSMConfigItemCustomerCIsObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItemCustomerCIs');

my %ConfigItemKey = %{
    $ConfigObject->Get('AgentCustomerUserInformationCenter::Backend')->{'0060-CUIC-ITSMConfigItemCustomerUser'}
        ->{ConfigItemKey} || {}
};

my $RandomID       = $HelperObject->GetRandomID();
my $ConfigItemName = "UnitTestPC $RandomID";

my $TestUserLogin3 = $HelperObject->TestCustomerUserCreate();
my $VersionRef     = $UnitTestITSMConfigItemObject->ConfigItemCreate(
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
            'Linked'       => '0',
            'ConfigItemID' => $VersionRef->{ConfigItemID},
            'Number'       => $VersionRef->{Number},
            'Name'         => $ConfigItemName,
            'Class'        => 'Computer',
            'Icon'         => '',
        }
    ],
    "GetPossibleCustomerCIs",
);

$UnitTestParamObject->ParamSet(
    Name  => 'ITSMConfigItemCustomerCIList',
    Value => $VersionRef->{ConfigItemID},
);

my $TicketID = $HelperObject->TicketCreate(
    CustomerUser => $TestUserLogin3,
);

$TicketObject->EventHandlerTransaction();

@ConfigItems = $ITSMConfigItemCustomerCIsObject->GetPossibleCustomerCIs(
    CustomerUserID => $TestUserLogin3,
    TicketID       => $TicketID,
);

$Self->IsDeeply(
    \@ConfigItems,
    [
        {
            'Linked'       => '1',
            'ConfigItemID' => $VersionRef->{ConfigItemID},
            'Number'       => $VersionRef->{Number},
            'Name'         => $ConfigItemName,
            'Class'        => 'Computer',
            'Icon'         => '',
        }
    ],
    "GetPossibleCustomerCIs with Ticket link",
);

1;
