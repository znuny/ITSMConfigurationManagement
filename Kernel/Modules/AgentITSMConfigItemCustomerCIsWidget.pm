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
use utf8;

our @ObjectDependencies = (
    'Kernel::Output::HTML::Layout',
    'Kernel::System::ITSMConfigItemCustomerCIs',
    'Kernel::System::LinkObject',
    'Kernel::System::Web::Request',
);

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
        my $LinkList = $LinkObject->LinkList(
            Object  => 'Ticket',
            Key     => $Param{TicketID},
            Object2 => 'ITSMConfigItem',
            State   => 'Valid',
            UserID  => $Self->{UserID},
        );

        my $LinkType;

        LINKTYPE:
        for my $Type ( sort keys %{ $LinkList->{ITSMConfigItem} } ) {
            for my $Direction ( sort keys %{ $LinkList->{ITSMConfigItem}->{$Type} } ) {
                for my $ConfigItemID ( sort keys %{ $LinkList->{ITSMConfigItem}->{$Type}->{$Direction} } ) {
                    if ( $ConfigItemID == $Param{ConfigItemID} ) {
                        $LinkType = $Type;
                        last LINKTYPE;
                    }
                }
            }
        }

        if ( defined $LinkType ) {
            $LinkObject->LinkDelete(
                Object1 => 'Ticket',
                Key1    => $Param{TicketID},
                Object2 => 'ITSMConfigItem',
                Key2    => $Param{ConfigItemID},
                Type    => $LinkType,
                UserID  => $Self->{UserID},
            );
        }
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
    elsif ( $Self->{Subaction} eq 'LoadWidget' ) {
        my @ConfigItems = $ITSMConfigItemCustomerCIsObject->GetPossibleCustomerCIs(
            TicketID => $Param{TicketID},
        );

        for my $ConfigItem (@ConfigItems) {
            $LayoutObject->Block(
                Name => 'ConfigItems',
                Data => {
                    %{$ConfigItem},
                },
            );
        }

        if ( !scalar @ConfigItems ) {
            $LayoutObject->Block(
                Name => 'ConfigItemsNone',
            );
        }

        my $WidgetTicketHTML = $LayoutObject->Output(
            TemplateFile => 'AgentITSMConfigItemCustomerCIsWidget',
        );

        return $LayoutObject->Attachment(
            ContentType => 'text/html',
            Content     => $WidgetTicketHTML // ' ',
            Type        => 'inline',
            NoCache     => 1,
        );
    }

    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSON // '{}',
        Type        => 'inline',
        NoCache     => 1,
    );
}

1;
