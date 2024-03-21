# --
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AgentITSMConfigItemAttachment;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Output::HTML::Layout',
    'Kernel::System::ITSMConfigItem::Attachment',
    'Kernel::System::Log',
    'Kernel::System::Web::Request',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $LogObject          = $Kernel::OM->Get('Kernel::System::Log');
    my $ParamObject        = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $CIAttachmentObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItem::CIAttachment');

    # check needed stuff
    NEEDED:
    for my $Needed (qw(AttachmentID)) {
        $Param{$Needed} = $ParamObject->GetParam( Param => $Needed );

        next NEEDED if defined $Param{$Needed};

        $LogObject->Log(
            Priority => 'error',
            Message  => "Parameter '$Needed' is needed!",
        );
        return;
    }

    my %Attachment = $CIAttachmentObject->CIAttachmentGet(
        AttachmentID => $Param{AttachmentID},
    );

    if ( !%Attachment ) {
        return $LayoutObject->Redirect(
            OP => $Self->{LastScreenView},
        );
    }
    else {
        return $LayoutObject->Attachment(
            %Attachment
        );
    }
}

1;
