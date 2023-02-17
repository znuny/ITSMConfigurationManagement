# --
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
## nofilter(TidyAll::Plugin::Znuny::Perl::ParamObject)

package Kernel::System::ITSMConfigItem::Event::CIAttachment;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Output::HTML::ITSMConfigItem::LayoutCIAttachment',
    'Kernel::System::ITSMConfigItem::CIAttachment',
    'Kernel::System::Log',
    'Kernel::System::Web::Request',
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $LogObject = $Kernel::OM->Get('Kernel::System::Log');

    # check needed stuff
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
    for my $Needed (qw( ConfigItemID )) {

        next NEEDED if $Param{Data}->{$Needed};

        $LogObject->Log(
            Priority => 'error',
            Message  => "Need $Needed in Data!"
        );
        return;
    }

    $Self->VersionCreate(%Param);
    $Self->VersionDelete(%Param);

    return 1;
}

=head2 VersionCreate()

This function will save the attachments to the file system if the config item is created.

    my $Success = $EventObject->VersionCreate(%Param);

Returns:

    my $Success = 1;

=cut

sub VersionCreate {
    my ( $Self, %Param ) = @_;

    my $CIAttachmentObject       = $Kernel::OM->Get('Kernel::System::ITSMConfigItem::CIAttachment');
    my $LayoutCIAttachmentObject = $Kernel::OM->Get('Kernel::Output::HTML::ITSMConfigItem::LayoutCIAttachment');
    my $LogObject                = $Kernel::OM->Get('Kernel::System::Log');
    my $ParamObject              = $Kernel::OM->Get('Kernel::System::Web::Request');

    return if $Param{Event} ne 'VersionCreate';

    my @ParamNames = $ParamObject->GetParamNames();

    my $ConfigItemID = $Param{Data}->{ConfigItemID};
    my $VersionID    = $Param{Data}->{Comment};

    PARAM:
    for my $ParamName (@ParamNames) {

        # only check params of the CIAttachment backend
        next PARAM if $ParamName !~ m{::CIAttachment\z}xmsi;

        # remove suffix
        $ParamName =~ s{::CIAttachment\z}{}xmsi;

        # get field base key
        my $AttachmentKey = $LayoutCIAttachmentObject->AttachmentKeyGet(
            Key => $ParamName,
        );
        next PARAM if !defined $AttachmentKey;

        # get attachment index of the temp cache
        my $AttachmentIndex = $LayoutCIAttachmentObject->AttachmentIndexGet(
            Key => $ParamName,
        );
        next PARAM if !defined $AttachmentIndex;

        # get form id
        my $FormID = $LayoutCIAttachmentObject->FormIDGet(
            AttachmentKey => $AttachmentKey,
        );
        next PARAM if !defined $FormID;

        # get current value of the attachment
        my $AttachmentID = $ParamObject->GetParam( Param => $ParamName );
        next PARAM if !defined $AttachmentID;

        # get attachment based on the cached data
        my %Attachment = $LayoutCIAttachmentObject->AttachmentCacheGet(
            Index  => $AttachmentIndex,
            FormID => $FormID,
        );
        next PARAM if !%Attachment;

        # save data to file system
        my $ContentID = $CIAttachmentObject->CIAttachmentAdd(
            AttachmentID    => $AttachmentID,
            ConfigItemField => $AttachmentKey,
            ConfigItemID    => $ConfigItemID,
            VersionID       => $VersionID,
            Filename        => $Attachment{Filename},
            Content         => $Attachment{Content},
            ContentType     => $Attachment{ContentType},
        );

        if ( !$ContentID ) {
            $LogObject->Log(
                Priority => 'error',
                Message  => "Failed to write attachment for '$ParamName'",
            );
            return;
        }
    }

    return 1;
}

=head2 VersionDelete()

This function will save the attachments to the file system if the config item is created.

    my $Success = $EventObject->VersionDelete(%Param);

Returns:

    my $Success = 1;

=cut

sub VersionDelete {
    my ( $Self, %Param ) = @_;

    my $CIAttachmentObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItem::CIAttachment');

    return if $Param{Event} ne 'VersionDelete';

    my $ConfigItemID = $Param{Data}->{ConfigItemID};
    my $VersionID    = $Param{Data}->{Comment};

    my @Attachments = $CIAttachmentObject->CIAttachmentList(
        ConfigItemID => $ConfigItemID,
        VersionID    => $VersionID,
    );

    for my $AttachmentID (@Attachments) {
        $CIAttachmentObject->CIAttachmentDelete(
            AttachmentID => $AttachmentID,
        );
    }

    return 1;
}

1;
