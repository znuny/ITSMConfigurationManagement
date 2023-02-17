# --
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
## nofilter(TidyAll::Plugin::Znuny::Perl::ParamObject)

package Kernel::System::Ticket::Event::ITSMConfigItemCustomerCIs;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::System::LinkObject',
    'Kernel::System::Log',
    'Kernel::System::Web::Request',
);

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $LogObject   = $Kernel::OM->Get('Kernel::System::Log');
    my $LinkObject  = $Kernel::OM->Get('Kernel::System::LinkObject');
    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

    NEEDED:
    for my $Needed (qw( Data Event Config UserID )) {
        next NEEDED if $Param{$Needed};

        $LogObject->Log(
            Priority => 'error',
            Message  => "Need $Needed!"
        );
        return;
    }

    NEEDED:
    for my $Needed (qw( TicketID )) {
        next NEEDED if $Param{Data}->{$Needed};

        $LogObject->Log(
            Priority => 'error',
            Message  => "Need $Needed in Data!"
        );
        return;
    }

    my $CIList = $ParamObject->GetParam( Param => 'ITSMConfigItemCustomerCIList' ) || '';
    return 1 if !$CIList;

    my @ConfigItemIDs = split ',', $CIList;

    for my $ConfigItemID (@ConfigItemIDs) {
        $LinkObject->LinkAdd(
            SourceObject => 'Ticket',
            SourceKey    => $Param{Data}->{TicketID},
            TargetObject => 'ITSMConfigItem',
            TargetKey    => $ConfigItemID,
            Type         => 'RelevantTo',
            State        => 'Valid',
            UserID       => $Param{UserID},
        );
    }

    return 1;
}

1;
