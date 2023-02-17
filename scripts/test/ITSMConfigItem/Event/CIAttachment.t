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

use Kernel::System::ObjectManager;

use Kernel::System::VariableCheck qw(:all);

$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        RestoreDatabase => 1,
    },
);

my $CIAttachmentObject           = $Kernel::OM->Get('Kernel::System::ITSMConfigItem::CIAttachment');
my $ConfigItemObject             = $Kernel::OM->Get('Kernel::System::ITSMConfigItem');
my $HelperObject                 = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
my $LayoutCIAttachmentObject     = $Kernel::OM->Get('Kernel::Output::HTML::ITSMConfigItem::LayoutCIAttachment');
my $UnitTestITSMConfigItemObject = $Kernel::OM->Get('Kernel::System::UnitTest::ITSMConfigItem');
my $UnitTestParamObject          = $Kernel::OM->Get('Kernel::System::UnitTest::Param');
my $UploadCacheObject            = $Kernel::OM->Get('Kernel::System::Web::UploadCache');

my $AttachmentID = $HelperObject->GetRandomID();
my $FormID       = $UploadCacheObject->FormIDCreate();

my %TestAttachment = (
    Filename    => 'test.txt',
    ContentType => 'text/plain',
    Content     => 'blub blub',
);

$UnitTestParamObject->ParamSet(
    Name  => 'TestField::1',
    Value => $AttachmentID,
);
$UnitTestParamObject->ParamSet(
    Name  => 'TestField::1::CIAttachment',
    Value => 1,
);
$UnitTestParamObject->ParamSet(
    Name  => 'FormID',
    Value => $FormID,
);

my $FormIDAttachment = $LayoutCIAttachmentObject->FormIDGet(
    AttachmentKey => 'TestField',
);

$UploadCacheObject->FormIDAddFile(
    %TestAttachment,
    FormID => $FormIDAttachment,
);

my $ConfigItem = $UnitTestITSMConfigItemObject->ConfigItemCreate(
    Name          => 'Mac',
    ClassName     => 'Computer',
    DeplStateName => 'Production',
    InciStateName => 'Operational',
);

my @Attachments = $CIAttachmentObject->CIAttachmentList(
    ConfigItemField => 'TestField',
    ConfigItemID    => $ConfigItem->{ConfigItemID},
    VersionID       => $ConfigItem->{LastVersionID},
);

$Self->Is(
    $Attachments[0],
    $AttachmentID,
    'Found attachment in CIAttachmentList',
);

my %Attachment = $CIAttachmentObject->CIAttachmentGet(
    AttachmentID => $AttachmentID,
);

$Self->True(
    ( %Attachment ? 1 : 0 ),
    'Found attachment in CIAttachmentGet',
);

$ConfigItemObject->VersionDelete(
    VersionID => $ConfigItem->{LastVersionID},
    UserID    => 1,
);

@Attachments = $CIAttachmentObject->CIAttachmentList(
    ConfigItemField => 'TestField',
    ConfigItemID    => $ConfigItem->{ConfigItemID},
    VersionID       => $ConfigItem->{LastVersionID},
);

$Self->False(
    @Attachments ? 1 : 0,
    $AttachmentID,
    'Found no attachment in CIAttachmentList',
);

%Attachment = $CIAttachmentObject->CIAttachmentGet(
    AttachmentID => $AttachmentID,
);

$Self->False(
    %Attachment ? 1 : 0,
    'Found no attachment in CIAttachmentGet',
);

1;
