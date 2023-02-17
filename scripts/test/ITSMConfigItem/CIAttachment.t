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

my $HelperObject                 = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');
my $CIAttachmentObject           = $Kernel::OM->Get('Kernel::System::ITSMConfigItem::CIAttachment');
my $UnitTestITSMConfigItemObject = $Kernel::OM->Get('Kernel::System::UnitTest::ITSMConfigItem');
my $ConfigItemObject             = $Kernel::OM->Get('Kernel::System::ITSMConfigItem');

my $ConfigItem = $UnitTestITSMConfigItemObject->ConfigItemCreate(
    Name          => 'Mac',
    ClassName     => 'Computer',
    DeplStateName => 'Production',
    InciStateName => 'Operational',
);

my $AttachmentID = $HelperObject->GetRandomID();

my $Success = $CIAttachmentObject->CIAttachmentAdd(
    AttachmentID    => $AttachmentID,
    ConfigItemField => 'TestField',
    ConfigItemID    => $ConfigItem->{ConfigItemID},
    VersionID       => 1,
    Filename        => 'asdf.txt',
    Content         => 'content blubs',
    ContentType     => 'text/plain',
);

$Self->True(
    $Success,
    'CIAttachmentAdd successfull.',
);

my %Attachment = $CIAttachmentObject->CIAttachmentGet(
    AttachmentID => $AttachmentID,
);

my %ExpectedAttachment = (
    Content     => 'content blubs',
    ContentType => 'text/plain',
    Filename    => 'asdf.txt',
    FilesizeRaw => '13',
    Type        => 'attachment',
    Filesize    => '13 B',
);

$Self->IsDeeply(
    \%Attachment,
    \%ExpectedAttachment,
    'CIAttachmentGet was successfull.',
);

my @ExpectedCIAttachmentList = ($AttachmentID);

my @CIAttachmentList = $CIAttachmentObject->CIAttachmentList(
    ConfigItemField => 'TestField',
    ConfigItemID    => $ConfigItem->{ConfigItemID},
    VersionID       => 1,
);

$Self->IsDeeply(
    \@CIAttachmentList,
    \@ExpectedCIAttachmentList,
    "CIAttachmentList was successfull. (after CIAttachmentAdd)",
);

my @ConfigItemAttachmentList = $ConfigItemObject->ConfigItemAttachmentList(
    ConfigItemID => $ConfigItem->{ConfigItemID},
);

$Self->IsDeeply(
    \@ConfigItemAttachmentList,
    [],
    "ConfigItemAttachmentList was successfull.",
);

$Success = $CIAttachmentObject->CIAttachmentDelete(
    AttachmentID => $AttachmentID,
);

$Self->True(
    $Success,
    'CIAttachmentDelete successfull.',
);

@CIAttachmentList = $CIAttachmentObject->CIAttachmentList(
    ConfigItemField => 'TestField',
    ConfigItemID    => $ConfigItem->{ConfigItemID},
    VersionID       => 1,
);

$Self->IsDeeply(
    \@CIAttachmentList,
    [],
    'CIAttachmentGet was successfull. (after CIAttachmentDelete)',
);

1;
