# --
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
## nofilter(TidyAll::Plugin::Znuny::Perl::LayoutObject)

package Kernel::System::ITSMConfigItem::CIAttachment;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Output::HTML::Layout',
    'Kernel::System::Log',
    'Kernel::System::VirtualFS',
);

use Kernel::System::VariableCheck qw(:all);

=head1 NAME

Kernel::System::ITSMConfigItem::CIAttachment - CIAttachment lib

=head1 SYNOPSIS

All CIAttachment functions

=head1 PUBLIC INTERFACE

=head2 new()

    Don't use the constructor directly, use the ObjectManager instead:

    my $CIAttachmentObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItem::CIAttachment');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    $Self->{CacheType} = 'CIAttachment';
    $Self->{CacheTTL}  = 60 * 60 * 24 * 20;

    return $Self;
}

=head2 CIAttachmentAdd()

adds an config item attachment to a config item

    my $Success = $CIAttachmentObject->CIAttachmentAdd(
        AttachmentID    => 1,
        ConfigItemField => 'Picture',
        ConfigItemID    => 123
        VersionID       => 123,
        Filename        => 'filename',
        Content         => 'content',
        ContentType     => 'text/plain',
    );

Returns:

    my $Success = 1;

=cut

sub CIAttachmentAdd {
    my ( $Self, %Param ) = @_;

    my $VirtualFSObject = $Kernel::OM->Get('Kernel::System::VirtualFS');
    my $LogObject       = $Kernel::OM->Get('Kernel::System::Log');

    # check needed stuff
    NEEDED:
    for my $Needed (qw(AttachmentID ConfigItemField ConfigItemID VersionID Filename Content ContentType)) {

        next NEEDED if defined $Param{$Needed};

        $LogObject->Log(
            Priority => 'error',
            Message  => "Parameter '$Needed' is needed!",
        );
        return;
    }

    $Param{Mode} ||= 'binary';

    my $Success = $VirtualFSObject->Write(
        Filename    => "CIAttachment/$Param{AttachmentID}",
        Mode        => $Param{Mode},
        Content     => \$Param{Content},
        Preferences => {
            CIAttachmentAttachmentID    => $Param{AttachmentID},
            CIAttachmentFilename        => $Param{Filename},
            CIAttachmentContentID       => $Param{ContentID},
            CIAttachmentContentType     => $Param{ContentType},
            CIAttachmentConfigItemField => $Param{ConfigItemField},
            CIAttachmentConfigItemID    => $Param{ConfigItemID},
            CIAttachmentVersionID       => $Param{VersionID},
        },
    );
    return if !$Success;

    return $Param{Filename};
}

=head2 CIAttachmentGet()

This function returns a CIAttachment.

    my %Attachment = $CIAttachmentObject->CIAttachmentGet(
        AttachmentID => '123',
    );

Returns:

    my %Attachment = (
        Content     => 'content',
        ContentType => 'text/plain',
        Filename    => 'blub.txt',
        FilesizeRaw => '13',
        Filesize    => '13 B',
        Type        => 'attachment',
    )

=cut

sub CIAttachmentGet {
    my ( $Self, %Param ) = @_;

    my $VirtualFSObject = $Kernel::OM->Get('Kernel::System::VirtualFS');
    my $LogObject       = $Kernel::OM->Get('Kernel::System::Log');
    my $LayoutObject    = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # check needed stuff
    NEEDED:
    for my $Needed (qw(AttachmentID)) {

        next NEEDED if defined $Param{$Needed};

        $LogObject->Log(
            Priority => 'error',
            Message  => "Parameter '$Needed' is needed!",
        );
        return;
    }

    $Param{Mode} ||= 'binary';

    my %AttachmentData = $VirtualFSObject->Read(
        Filename        => "CIAttachment/$Param{AttachmentID}",
        Mode            => $Param{Mode},
        DisableWarnings => 1,
    );
    if ( $AttachmentData{Preferences}->{FilesizeRaw} ) {
        $AttachmentData{Preferences}->{Filesize}
            = $LayoutObject->HumanReadableDataSize( Size => $AttachmentData{Preferences}->{FilesizeRaw} );
    }

    return if !%AttachmentData;
    return if !$AttachmentData{Content};

    my %Attachment = (
        Content     => ${ $AttachmentData{Content} },
        Filename    => $AttachmentData{Preferences}->{CIAttachmentFilename},
        ContentType => $AttachmentData{Preferences}->{CIAttachmentContentType},
        Filesize    => $AttachmentData{Preferences}->{Filesize},
        FilesizeRaw => $AttachmentData{Preferences}->{FilesizeRaw},
        Type        => 'attachment',
    );

    return %Attachment;
}

=head2 CIAttachmentList()

Returns an array with all config item attachments of the given config item.

    my @CIAttachmentIDs = $CIAttachmentObject->CIAttachmentList(
        ConfigItemField => 'Picture',  # optional
        ConfigItemID    => 123,        # optional
        VersionID       => 123,        # optional
    );

returns

    @CIAttachmentIDs = (
        'fewz544t4334f34sfrg',
        'dfsdfs94f0w4f48f43f',
    );

=cut

sub CIAttachmentList {
    my ( $Self, %Param ) = @_;

    my $LogObject       = $Kernel::OM->Get('Kernel::System::Log');
    my $VirtualFSObject = $Kernel::OM->Get('Kernel::System::VirtualFS');

    my %Preferences;
    if ( $Param{ConfigItemField} ) {
        $Preferences{CIAttachmentConfigItemField} = $Param{ConfigItemField};
    }
    if ( $Param{ConfigItemID} ) {
        $Preferences{CIAttachmentConfigItemID} = $Param{ConfigItemID};
    }
    if ( $Param{VersionID} ) {
        $Preferences{CIAttachmentVersionID} = $Param{VersionID};
    }

    if ( !%Preferences ) {
        $LogObject->Log(
            Priority => 'error',
            Message  => "You need to set ConfigItemField, ConfigItemID or VersionID!",
        );
        return;
    }

    # find all attachments of this config item
    my @Attachments = $VirtualFSObject->Find(
        Filename    => $Param{Filename} || '',
        Preferences => {
            %Preferences,
        },
    );

    for my $Attachment (@Attachments) {
        $Attachment =~ s{CIAttachment \/}{}xmsi;
    }

    return @Attachments;
}

=head2 CIAttachmentDelete()

Delete the given file from the virtual filesystem.

    my $Success = $CIAttachmentObject->CIAttachmentDelete(
        AttachmentID => 123,
    );

=cut

sub CIAttachmentDelete {
    my ( $Self, %Param ) = @_;

    my $LogObject       = $Kernel::OM->Get('Kernel::System::Log');
    my $VirtualFSObject = $Kernel::OM->Get('Kernel::System::VirtualFS');

    # check needed stuff
    for my $Needed (qw(AttachmentID)) {
        if ( !$Param{$Needed} ) {
            $LogObject->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );

            return;
        }
    }

    # delete file
    my $Success = $VirtualFSObject->Delete(
        Filename => "CIAttachment/$Param{AttachmentID}",
    );

    return $Success;
}

1;
