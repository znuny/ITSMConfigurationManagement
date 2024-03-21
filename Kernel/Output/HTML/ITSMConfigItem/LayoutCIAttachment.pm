# --
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::ITSMConfigItem::LayoutCIAttachment;

use strict;
use warnings;

use Digest::MD5 qw(md5 md5_hex md5_base64);

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::ITSMConfigItem',
    'Kernel::System::ITSMConfigItem::CIAttachment',
    'Kernel::System::Log',
    'Kernel::System::Time',
    'Kernel::System::Web::Request',
    'Kernel::System::Web::UploadCache',
);

use parent 'Kernel::Output::HTML::ITSMConfigItem::LayoutBaseSelectable';

=head1 NAME

Kernel::Output::HTML::ITSMConfigItem::LayoutCIAttachment - layout backend module

=head1 SYNOPSIS

All layout functions of CIAttachment objects

=head2 OutputStringCreate()

create output string

    my $Value = $BackendObject->OutputStringCreate(
        Value => 11,       # (optional)
        Item => $ItemRef,
    );

=cut

sub OutputStringCreate {
    my ( $Self, %Param ) = @_;

    my $LogObject          = $Kernel::OM->Get('Kernel::System::Log');
    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject        = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $CIAttachmentObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItem::CIAttachment');

    my $Value = $Param{Value};
    return if !$Value;

    my %Attachment = $CIAttachmentObject->CIAttachmentGet(
        AttachmentID => $Param{Value},
    );

    my $String
        = '<a href="' . $LayoutObject->{Baselink} . 'Action=AgentITSMConfigItemAttachment;AttachmentID=' . $Value;

    # add session id if needed
    if ( !$LayoutObject->{SessionIDCookie} ) {
        $String .= ';' . $LayoutObject->{SessionName} . "=" . $LayoutObject->{SessionID};
    }

    $String .= '">' . $Attachment{Filename} . '</a> (' . $Attachment{Filesize} . ')';

    return $String;
}

=head2 FormDataGet()

get form data as hash reference

    my $FormDataRef = $BackendObject->FormDataGet(
        Key => 'Item::1::Node::3',
        Item => $ItemRef,
    );

=cut

sub FormDataGet {
    my ( $Self, %Param ) = @_;

    my $LogObject          = $Kernel::OM->Get('Kernel::System::Log');
    my $ParamObject        = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $CIAttachmentObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItem::CIAttachment');
    my $UploadCacheObject  = $Kernel::OM->Get('Kernel::System::Web::UploadCache');
    my $ConfigItemObject   = $Kernel::OM->Get('Kernel::System::ITSMConfigItem');
    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # check needed stuff
    NEEDED:
    for my $Needed (qw(Key Item)) {

        next NEEDED if defined $Param{$Needed};

        $LogObject->Log(
            Priority => 'error',
            Message  => "Parameter '$Needed' is needed in FormDataGet!",
        );
        return;
    }

    my $DisplayValue     = $ParamObject->GetParam( Param => $Param{Key} );
    my $AttachmentDelete = $ParamObject->GetParam( Param => $Param{Key} . "::Delete" );
    my $AttachmentIndex  = $Self->AttachmentIndexGet(%Param);
    my $AttachmentKey    = $Self->AttachmentKeyGet(%Param);

    for my $GetParam (qw(ConfigItemID ClassID SubmitSave)) {
        $Param{$GetParam} = $ParamObject->GetParam( Param => $GetParam );
    }

    my %FormData;
    $FormData{Value} = undef;

    my $FormID = $Self->FormIDGet(
        AttachmentKey => $AttachmentKey,
    );

    # get the upload file
    my %UploadFile = $ParamObject->GetUploadAll(
        Param  => $Param{Key} . "::Upload",
        Source => 'string',
    );

    if (%UploadFile) {

        # generate new id for the attachment which will be saved
        # in the xml of the config item version
        $DisplayValue = $Self->AttachmentIDGenerate();

        # add attachment to temp cache
        $UploadCacheObject->FormIDAddFile(
            %UploadFile,
            FormID => $FormID,
        );
    }
    elsif ($AttachmentDelete) {

        # remove attachment from temp cache if the user removes it from the form data
        $Self->AttachmentCacheDelete(
            AttachmentIndex => $AttachmentIndex,
            FormID          => $FormID,
        );

        $FormData{Value} = '';
    }

    if ($DisplayValue) {
        $FormData{Value} = $DisplayValue;
    }

    # set invalid param...
    return \%FormData if !$Param{Item}->{Input}->{Required};
    return \%FormData if $FormData{Value};

    $FormData{Invalid} = 1;
    $Param{Item}->{Form}->{ $Param{Key} }->{Invalid} = 1;

    return \%FormData;
}

=head2 InputCreate()

create a input string

    my $Value = $BackendObject->InputCreate(
        Key => 'Item::1::Node::3',
        Value => 11,       # (optional)
        Item => $ItemRef,
    );

=cut

sub InputCreate {
    my ( $Self, %Param ) = @_;

    my $LayoutObject       = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $LogObject          = $Kernel::OM->Get('Kernel::System::Log');
    my $CIAttachmentObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItem::CIAttachment');
    my $UploadCacheObject  = $Kernel::OM->Get('Kernel::System::Web::UploadCache');

    # check needed stuff
    ARGUMENT:
    for my $Argument (qw(Key Item)) {
        next ARGUMENT if $Param{$Argument};

        $LogObject->Log(
            Priority => 'error',
            Message  => "Need $Argument!"
        );
        return;
    }

    my $Value     = $Param{Value} || '';
    my $Key       = $Param{Key};
    my $KeyUpload = $Param{Key} . "::Upload";

    my $Filename;
    if ($Value) {

        # find the attachment index for the field key in the temp cache
        my $AttachmentIndex = $Self->AttachmentIndexGet(%Param);

        # get the attachment field base key
        my $AttachmentKey = $Self->AttachmentKeyGet(%Param);

        # get the form id for the field where the attachments are stored
        my $FormID = $Self->FormIDGet(
            AttachmentKey => $AttachmentKey,
        );

        if ( defined $AttachmentIndex && defined $AttachmentKey && defined $FormID ) {

            # find the cached temp attachment for the field
            my %Attachment = $Self->AttachmentCacheGet(
                Index  => $AttachmentIndex,
                FormID => $FormID,
            );

            if (%Attachment) {
                $Filename = $Attachment{Filename};
            }
            else {

                # get attachment from virtual fs
                my %CIAttachmentGet = $CIAttachmentObject->CIAttachmentGet(
                    AttachmentID => $Value,
                );

                if (%CIAttachmentGet) {
                    $Value = $Self->AttachmentIDGenerate();

                    # add attachment to temp cache
                    $UploadCacheObject->FormIDAddFile(
                        Filename    => $CIAttachmentGet{Filename},
                        ContentType => $CIAttachmentGet{ContentType},
                        Content     => $CIAttachmentGet{Content},
                        FormID      => $FormID,
                    );

                    return $Self->InputCreate(
                        %Param,
                        Value => $Value,
                    );
                }
            }
        }
    }

    my $Output = '<input type="hidden" name="'
        . $Key
        . '::CIAttachment" value="1"/><input type="hidden" name="'
        . $Key
        . '" value="'
        . $Value . '"/> ';
    if ($Filename) {
        $Output .= $Filename;
    }
    else {
        $Output .= '<input type="file" id="' . $KeyUpload . '" name="' . $KeyUpload . '" class="fixed" /> ';
    }

    $LayoutObject->AddJSOnDocumentComplete( Code => <<"ZNUUNY");

// use getElementById because id has colons
\$(document.getElementById("$KeyUpload")).on('change', function() {
    var \$Form = \$(document.getElementById("$KeyUpload")).closest('form');
    Core.Form.Validate.DisableValidation(\$Form);
    \$Form.submit();
});
ZNUUNY

    return $Output;
}

=head2 SearchFormDataGet()

get search form data

    my $Value = $BackendObject->SearchFormDataGet(
        Key => 'Item::1::Node::3',
        Item => $ItemRef,
    );

=cut

sub SearchFormDataGet {
    my ( $Self, %Param ) = @_;

    return;
}

=head2 SearchInputCreate()

create a search input string

    my $Value = $BackendObject->SearchInputCreate(
        Key => 'Item::1::Node::3',
        Item => $ItemRef,
    );

=cut

sub SearchInputCreate {
    my ( $Self, %Param ) = @_;

    return;
}

=head2 AttachmentIDGenerate()

This function returns an unique ID for the attachment.

    my $Success = $BackendObject->AttachmentIDGenerate();

Returns:

    my $Success = 1;

=cut

sub AttachmentIDGenerate {
    my ( $Self, %Param ) = @_;

    my $TimeObject = $Kernel::OM->Get('Kernel::System::Time');

    my $SystemTime = $TimeObject->SystemTime();

    my $Rand = rand(1_000_000_000);

    return md5_hex( $SystemTime . $Rand );
}

=head2 AttachmentIndexGet()

This function returns the attachment index for the field key.

    my $AttachmentIndex = $BackendObject->AttachmentIndexGet(
        Key => 'field::1',
    );

Returns:

    my $AttachmentIndex = 0;

=cut

sub AttachmentIndexGet {
    my ( $Self, %Param ) = @_;

    my $LogObject = $Kernel::OM->Get('Kernel::System::Log');

    # check needed stuff
    NEEDED:
    for my $Needed (qw(Key)) {

        next NEEDED if defined $Param{$Needed};

        $LogObject->Log(
            Priority => 'error',
            Message  => "Parameter '$Needed' is needed!",
        );
        return;
    }

    my @FieldSplit = split /\:\:/, $Param{Key};
    return int( $FieldSplit[-1] ) - 1;
}

=head2 AttachmentKeyGet()

This function returns the attachment index for the field key.

    my $AttachmentKey = $BackendObject->AttachmentKeyGet(
        Key => 'field::1',
    );

Returns:

    my $AttachmentKey = 'field';

=cut

sub AttachmentKeyGet {
    my ( $Self, %Param ) = @_;

    my $LogObject = $Kernel::OM->Get('Kernel::System::Log');

    # check needed stuff
    NEEDED:
    for my $Needed (qw(Key)) {

        next NEEDED if defined $Param{$Needed};

        $LogObject->Log(
            Priority => 'error',
            Message  => "Parameter '$Needed' is needed!",
        );
        return;
    }

    my @FieldSplit = split /\:\:/, $Param{Key};
    pop @FieldSplit;

    return join( '::', @FieldSplit );
}

=head2 FormIDGet()

This function returns the form id for the attachment field.

    my $FormID = $BackendObject->FormIDGet(
        AttachmentKey => 123,
    );

Returns:

    my $FormID = '111.12.3.123.1.23';

=cut

sub FormIDGet {
    my ( $Self, %Param ) = @_;

    my $ConfigObject         = $Kernel::OM->Get('Kernel::Config');
    my $ParamObject          = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LogObject            = $Kernel::OM->Get('Kernel::System::Log');
    my $WebUploadCacheObject = $Kernel::OM->Get('Kernel::System::Web::UploadCache');

    # check needed stuff
    NEEDED:
    for my $Needed (qw(AttachmentKey)) {

        next NEEDED if defined $Param{$Needed};

        $LogObject->Log(
            Priority => 'error',
            Message  => "Parameter '$Needed' is needed!",
        );
        return;
    }

    my $AttachmentKey = $Param{AttachmentKey};

    my $FormID = $ParamObject->GetParam( Param => 'FormID' );
    $FormID ||= $WebUploadCacheObject->{LastFormID};

    return if !$FormID;

    $FormID .= '.CIAttachment';
    $FormID .= '.' . $AttachmentKey;    # Node

    return $FormID;
}

=head2 AttachmentCacheGet()

This function returns the temporarily attachment data of the attachment field.

    my %Attachment = $BackendObject->AttachmentCacheGet(
        Index  => 0,
        FormID => '123',
    );

Returns:

    my %Attachment = (
        Filename    => 'asdf.txt',
        ContentType => 'text/plain',
        Content     => 'blub',
    );

=cut

sub AttachmentCacheGet {
    my ( $Self, %Param ) = @_;

    my $LogObject         = $Kernel::OM->Get('Kernel::System::Log');
    my $UploadCacheObject = $Kernel::OM->Get('Kernel::System::Web::UploadCache');

    # check needed stuff
    NEEDED:
    for my $Needed (qw(Index FormID)) {

        next NEEDED if defined $Param{$Needed};

        $LogObject->Log(
            Priority => 'error',
            Message  => "Parameter '$Needed' is needed!",
        );
        return;
    }

    my $FormID          = $Param{FormID};
    my $AttachmentIndex = $Param{Index};

    my @Data = $UploadCacheObject->FormIDGetAllFilesData(
        FormID => $FormID,
    );

    return if !@Data;

    my $Attachment = $Data[$AttachmentIndex];

    return if !IsHashRefWithData($Attachment);

    return %{$Attachment};
}

=head2 AttachmentCacheDelete()

This function deletes the temporarily attachment data of the attachment field.

    my $Success = $BackendObject->AttachmentCacheDelete(
        AttachmentIndex => 1,
        FormID          => '123',
    );

Returns:

    my $Success = 1;

=cut

sub AttachmentCacheDelete {
    my ( $Self, %Param ) = @_;

    my $LogObject         = $Kernel::OM->Get('Kernel::System::Log');
    my $UploadCacheObject = $Kernel::OM->Get('Kernel::System::Web::UploadCache');

    # check needed stuff
    NEEDED:
    for my $Needed (qw(AttachmentIndex FormID)) {

        next NEEDED if defined $Param{$Needed};

        $LogObject->Log(
            Priority => 'error',
            Message  => "Parameter '$Needed' is needed!",
        );
        return;
    }

    my $FormID          = $Param{FormID};
    my $AttachmentIndex = $Param{AttachmentIndex};

    my @Data = $UploadCacheObject->FormIDGetAllFilesData(
        FormID => $FormID,
    );

    return if !@Data;

    my $Attachment = $Data[$AttachmentIndex];
    return if !IsHashRefWithData($Attachment);

    # remove the attachment from the upload cache
    $UploadCacheObject->FormIDRemoveFile(
        FormID => $FormID,
        FileID => $Attachment->{FileID},
    );

    return 1;
}

1;
