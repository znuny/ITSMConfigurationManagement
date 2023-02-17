# --
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::ITSMConfigItemCustomerCIs;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::GeneralCatalog',
    'Kernel::System::ITSMConfigItem',
    'Kernel::System::LinkObject',
    'Kernel::System::Log',
    'Kernel::System::Ticket',
);

use Kernel::System::VariableCheck qw(:all);

=head1 NAME

Kernel::System::ITSMConfigItemCustomerCIs - ITSMConfigItemCustomerCIs lib

=head1 SYNOPSIS

All ITSMConfigItemCustomerCIs functions

=head1 PUBLIC INTERFACE

=head2 new()

    Don't use the constructor directly, use the ObjectManager instead:

    my $ITSMConfigItemCustomerCIsObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItemCustomerCIs');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

=head2 GetCustomerUserCIs()

Searches for all customer user specific config items

    my @ConfigItemIDs = $ITSMConfigItemCustomerCIsObject->GetCustomerUserCIs(
        CustomerUserID => $CustomerUserLogin,                       # the CustomerUserID is the UserLogin
    );

Returns:

    my @ConfigItemIDs = [1,2,3,4];

=cut

sub GetCustomerUserCIs {
    my ( $Self, %Param ) = @_;

    my $ConfigItemObject     = $Kernel::OM->Get('Kernel::System::ITSMConfigItem');
    my $ConfigObject         = $Kernel::OM->Get('Kernel::Config');
    my $GeneralCatalogObject = $Kernel::OM->Get('Kernel::System::GeneralCatalog');
    my $LogObject            = $Kernel::OM->Get('Kernel::System::Log');

    NEEDED:
    for my $Needed (qw(CustomerUserID)) {
        next NEEDED if defined $Param{$Needed};

        $LogObject->Log(
            Priority => 'error',
            Message  => "Parameter '$Needed' is needed in GetCustomerUserCIs!",
        );
        return;
    }

    my %ConfigItemKey = %{
        $ConfigObject->Get('AgentCustomerUserInformationCenter::Backend')->{'0060-CUIC-ITSMConfigItemCustomerUser'}
            ->{ConfigItemKey}
            || {}
    };

    my $Classes = $GeneralCatalogObject->ItemList(
        Class => 'ITSM::ConfigItem::Class',
    );
    my %Classes = reverse %{$Classes};

    my @ConfigItemIDs;
    ENTRY:
    for my $Class ( sort keys %ConfigItemKey ) {

        # only valid classes
        next ENTRY if !$Classes{$Class};

        my $Attribute = $ConfigItemKey{$Class};

        my $ItemDataRef = $GeneralCatalogObject->ItemGet(
            Class => 'ITSM::ConfigItem::Class',
            Name  => $Class,
        );
        next ENTRY if !IsHashRefWithData($ItemDataRef);

        my $What = '[%]{' . "'Version'" . '}[%]{' . "'" . $Attribute . "'" . '}[%]{' . "'Content'" . '}';

        my $ConfigItemIDs = $ConfigItemObject->ConfigItemSearchExtended(
            ClassIDs => [ $ItemDataRef->{ItemID} ],
            What     => [
                {
                    $What => $Param{CustomerUserID},
                },
            ],
            Limit => 100_000,
        );
        next ENTRY if !IsArrayRefWithData($ConfigItemIDs);

        push @ConfigItemIDs, @{$ConfigItemIDs};
    }

    return @ConfigItemIDs;
}

=head2 GetCustomerCIs()

Searches for all customer specific config items

    my @ConfigItemIDs = $ITSMConfigItemCustomerCIsObject->GetCustomerCIs(
        CustomerID => $CustomerID,
    );

Returns:

    my @ConfigItemIDs = [1,2,3,4];

=cut

sub GetCustomerCIs {
    my ( $Self, %Param ) = @_;

    my $ConfigItemObject     = $Kernel::OM->Get('Kernel::System::ITSMConfigItem');
    my $ConfigObject         = $Kernel::OM->Get('Kernel::Config');
    my $GeneralCatalogObject = $Kernel::OM->Get('Kernel::System::GeneralCatalog');
    my $LogObject            = $Kernel::OM->Get('Kernel::System::Log');

    NEEDED:
    for my $Needed (qw(CustomerID)) {
        next NEEDED if defined $Param{$Needed};

        $LogObject->Log(
            Priority => 'error',
            Message  => "Parameter '$Needed' is needed in GetCustomerCIs!",
        );
        return;
    }

    my %ConfigItemKey = %{
        $ConfigObject->Get('AgentCustomerInformationCenter::Backend')->{'0060-CIC-ITSMConfigItemCustomerCompany'}
            ->{ConfigItemKey}
            || {}
    };

    my $Classes = $GeneralCatalogObject->ItemList(
        Class => 'ITSM::ConfigItem::Class',
    );
    my %Classes = reverse %{$Classes};

    my @ConfigItemIDs;
    ENTRY:
    for my $Class ( sort keys %ConfigItemKey ) {

        # only valid classes
        next ENTRY if !$Classes{$Class};

        my $Attribute = $ConfigItemKey{$Class};

        my $ItemDataRef = $GeneralCatalogObject->ItemGet(
            Class => 'ITSM::ConfigItem::Class',
            Name  => $Class,
        );
        next ENTRY if !IsHashRefWithData($ItemDataRef);

        my $What = '[%]{' . "'Version'" . '}[%]{' . "'" . $Attribute . "'" . '}[%]{' . "'Content'" . '}';

        my $ConfigItemIDs = $ConfigItemObject->ConfigItemSearchExtended(
            ClassIDs => [ $ItemDataRef->{ItemID} ],
            What     => [
                {
                    $What => $Param{CustomerID},
                },
            ],
            Limit => 100_000,
        );

        next ENTRY if !IsArrayRefWithData($ConfigItemIDs);

        push @ConfigItemIDs, @{$ConfigItemIDs};
    }

    return @ConfigItemIDs;
}

=head2 GetPossibleCustomerCIs()

Returns possible customer CIs.

    my @ConfigItems = $ITSMConfigItemCustomerCIsObject->GetPossibleCustomerCIs(
        CustomerUserID => 123,
        TicketID       => 123,      # optional
    );

Returns:

    my @ConfigItems = (
        {
            'Linked'       => '1',
            'ConfigItemID' => 123456,
            'Name'         => 'Computer xyz',
        }
    );

=cut

sub GetPossibleCustomerCIs {
    my ( $Self, %Param ) = @_;

    my $ConfigItemObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItem');
    my $ConfigObject     = $Kernel::OM->Get('Kernel::Config');
    my $LinkObject       = $Kernel::OM->Get('Kernel::System::LinkObject');
    my $TicketObject     = $Kernel::OM->Get('Kernel::System::Ticket');

    my $Config = $ConfigObject->Get('ITSMConfigItem::Frontend::AgentITSMConfigItemCustomerCIs');

    my %LinkKeyList;

    if ( $Param{TicketID} ) {
        my %Ticket = $TicketObject->TicketGet(
            TicketID => $Param{TicketID},
            UserID   => 1,
        );

        $Param{CustomerUserID} = $Ticket{CustomerUserID};
        $Param{CustomerID}     = $Ticket{CustomerID};

        %LinkKeyList = $LinkObject->LinkKeyList(
            Object1 => 'Ticket',
            Key1    => $Param{TicketID},
            Object2 => 'ITSMConfigItem',
            State   => 'Valid',
            UserID  => 1,
        );
    }

    my @ConfigItems;
    return @ConfigItems if !( $Param{CustomerUserID} || $Param{CustomerID} );

    my @CustomerUserConfigItemIDs;
    if ( $Config->{CustomerUser} ) {
        @CustomerUserConfigItemIDs = $Self->GetCustomerUserCIs(
            CustomerUserID => $Param{CustomerUserID},
            Limit          => $Config->{SearchLimit},
        );
    }
    my @CustomerConfigItemIDs;
    if ( $Config->{CustomerCompany} ) {
        @CustomerConfigItemIDs = $Self->GetCustomerCIs(
            CustomerID => $Param{CustomerID},
            Limit      => $Config->{SearchLimit},
        );
    }

    my @ConfigItemIDs   = ( @CustomerUserConfigItemIDs, @CustomerConfigItemIDs );
    my %UniqConfigItems = map { $_ => $_ } @ConfigItemIDs;
    @ConfigItemIDs = sort keys %UniqConfigItems;

    my %Mapping = %{ $Config->{Mapping} || {} };

    for my $ConfigItemID (@ConfigItemIDs) {
        my $Version = $ConfigItemObject->VersionGet(
            ConfigItemID => $ConfigItemID,
        );

        push @ConfigItems, {
            ConfigItemID => $ConfigItemID,
            Name         => $Version->{Name},
            Number       => $Version->{Number},
            Class        => $Version->{Class},
            Icon         => $Mapping{ $Version->{Class} } || '',
            Linked       => $LinkKeyList{$ConfigItemID} || 0,
        };
    }

    return @ConfigItems;
}
1;
