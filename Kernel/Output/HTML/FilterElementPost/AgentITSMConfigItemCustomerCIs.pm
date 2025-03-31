# --
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::FilterElementPost::AgentITSMConfigItemCustomerCIs;

use strict;
use warnings;
use utf8;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::Group',
    'Kernel::System::Web::Request',
);

use Kernel::System::VariableCheck qw(:all);

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $GroupObject  = $Kernel::OM->Get('Kernel::System::Group');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');

    my $Config = $ConfigObject->Get('AgentITSMConfigItemCustomerCIsWidget');

    my $Permission;

    # show only if the user is in one of the allowed groups
    if ( IsArrayRefWithData( $Config->{Group} ) ) {
        GROUP:
        for my $CurrentGroup ( @{ $Config->{Group} } ) {
            my $HasPermission = $GroupObject->PermissionCheck(
                UserID    => $LayoutObject->{UserID},
                GroupName => $CurrentGroup,
                Type      => 'move_into',
            );
            next GROUP if !$HasPermission;

            $Permission = 1;

            last GROUP;
        }
    }
    return if !$Permission;

    $Param{TicketID} = $ParamObject->GetParam( Param => 'TicketID' ) || '';

    $LayoutObject->Block(
        Name => 'Widget',
        Data => {
            CSSStyle => $LayoutObject->{Action} ne 'AgentTicketZoom' ? 'display:none;' : '',
        }
    );

    my $WidgetHTML = $LayoutObject->Output(
        TemplateFile => 'AgentITSMConfigItemCustomerCIsWidget',
    );

    my $Data = {
        Widget   => $WidgetHTML,
        TicketID => $Param{TicketID},
    };

    my $InitParameter = $LayoutObject->JSONEncode(
        NoQuotes => 1,
        Data     => $Data,
    );

    my $JSBlock = <<"JS_BLOCK";
    ITSM.Agent.ConfigItem.CustomerCIsWidget.Init($InitParameter);
JS_BLOCK

    $LayoutObject->AddJSOnDocumentCompleteIfNotExists(
        Key  => 'ITSM.Agent.ConfigItem.CustomerCIsWidget',
        Code => $JSBlock,
    );

    return 1;
}

1;
