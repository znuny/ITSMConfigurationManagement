# --
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::ITSMConfigItem::XML::Type::SLA;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::System::SLA',
);

use parent 'Kernel::System::ITSMConfigItem::XML::Type::BaseSelectable';

=head1 NAME

Kernel::System::ITSMConfigItem::XML::Type::SLA - xml backend module

=head1 SYNOPSIS

XML functions for SLA objects

=head2 ValueLookup()

get the xml data of a version

    my $Value = $BackendObject->ValueLookup(
        Value => 11, # (optional)
    );

=cut

sub ValueLookup {
    my ( $Self, %Param ) = @_;

    return '' if !$Param{Value};

    my $SLAObject = $Kernel::OM->Get('Kernel::System::SLA');
    my $SLAName   = $SLAObject->SLALookup( SLAID => $Param{Value} );
    return $Param{Value} if !defined $SLAName;

    return $SLAName;
}

1;
