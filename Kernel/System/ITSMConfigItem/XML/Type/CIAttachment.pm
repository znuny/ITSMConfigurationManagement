# --
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::ITSMConfigItem::XML::Type::CIAttachment;

use strict;
use warnings;

our @ObjectDependencies = (
);

use parent 'Kernel::System::ITSMConfigItem::XML::Type::BaseSelectable';

=head1 NAME

Kernel::System::ITSMConfigItem::XML::Type::CIAttachment - xml backend module

=head1 SYNOPSIS

All xml functions of attachment objects

=head2 ValueLookup()

get the xml data of a version

    my $Value = $BackendObject->ValueLookup(
        Item  => $ItemRef,
        Value => 1.1.1.1,
    );

=cut

sub ValueLookup {
    my ( $Self, %Param ) = @_;

    return $Param{Value};
}

1;
