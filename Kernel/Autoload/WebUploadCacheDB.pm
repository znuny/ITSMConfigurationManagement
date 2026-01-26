# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# $origin: Znuny - bae2fb28ba2e90d82f5f4915b2ef0274cd350138 - Kernel/System/Web/UploadCache/DB.pm
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

package Kernel::Autoload::WebUploadCacheDB;

use Kernel::System::Web::UploadCache::DB;

use strict;
use warnings;
use utf8;

our @ObjectDependencies = (
    'Kernel::System::Log',
);

# disable redefine warnings in this scope
{
    no warnings 'redefine';  ## no critic

    *Kernel::System::Web::UploadCache::DB::_FormIDValidate = sub { ## no critic
        my ( $Self, $FormID ) = @_;

        return if !$FormID;

# ---
# ITSMConfigurationManagement
# ---
#        if ( $FormID !~ m{^ \d+ \. \d+ \. \d+ $}xms ) {

        # Validate FormID of CIAttachments that contains an additional attachment key.
        if ( $FormID !~ m{^ \d+ \. \d+ \. \d+ (\. CIAttachment \. \S+)? $}xms ) {
# ---
            $Kernel::OM->Get('Kernel::System::Log')->Log(
                Priority => 'error',
                Message  => 'Invalid FormID!',
            );
            return;
        }

        return 1;
    }

}

1;
