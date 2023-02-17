# --
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentITSMConfigItemCustomerCIsWidget;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Output::HTML::Layout',
    'Kernel::System::ITSMConfigItemCustomerCIs',
    'Kernel::System::LinkObject',
    'Kernel::System::Web::Request',
);

use Kernel::System::VariableCheck qw(:all);

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $ParamObject                     = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject                    = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $LinkObject                      = $Kernel::OM->Get('Kernel::System::LinkObject');
    my $ITSMConfigItemCustomerCIsObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItemCustomerCIs');

    for my $Param (qw(TicketID ConfigItemID CustomerUserID CustomerID)) {
        $Param{$Param} = $ParamObject->GetParam( Param => $Param ) // '';
    }

    my $JSON;

    if ( $Self->{Subaction} eq 'LinkAdd' ) {
        $LinkObject->LinkAdd(
            SourceObject => 'Ticket',
            SourceKey    => $Param{TicketID},
            TargetObject => 'ITSMConfigItem',
            TargetKey    => $Param{ConfigItemID},
            Type         => 'RelevantTo',
            State        => 'Valid',
            UserID       => $Self->{UserID},
        );
    }
    elsif ( $Self->{Subaction} eq 'LinkDelete' ) {
        $LinkObject->LinkDelete(
            Object1 => 'Ticket',
            Key1    => $Param{TicketID},
            Object2 => 'ITSMConfigItem',
            Key2    => $Param{ConfigItemID},
            Type    => 'RelevantTo',
            UserID  => $Self->{UserID},
        );
    }
    elsif ( $Self->{Subaction} eq 'CustomerUpdate' && $Param{CustomerUserID} ) {

        my @ConfigItems = $ITSMConfigItemCustomerCIsObject->GetPossibleCustomerCIs(
            CustomerUserID => $Param{CustomerUserID},
            CustomerID     => $Param{CustomerID},
        );

        if (@ConfigItems) {

            for my $ConfigItem (@ConfigItems) {
                $LayoutObject->Block(
                    Name => 'ConfigItems',
                    Data => {
                        %{$ConfigItem},
                    },
                );
            }

            my $CustomerCIWidgetHTML = $LayoutObject->Output(
                TemplateFile => 'AgentITSMConfigItemCustomerCIsWidget',
                Data         => {},
            );

            $JSON = $LayoutObject->JSONEncode(
                NoQuotes => 1,
                Data     => {
                    ConfigItems => $CustomerCIWidgetHTML,
                },
            );
        }
    }

    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSON // '{}',
        Type        => 'inline',
        NoCache     => 1,
    );
}

1;
