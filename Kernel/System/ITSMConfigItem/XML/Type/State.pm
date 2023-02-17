# --
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::ITSMConfigItem::XML::Type::State;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::System::State',
);

use parent 'Kernel::System::ITSMConfigItem::XML::Type::BaseSelectable';

=head1 NAME

Kernel::System::ITSMConfigItem::XML::Type::State - xml backend module

=head1 SYNOPSIS

XML functions for State objects

=head2 ValueLookup()

get the xml data of a version

    my $Value = $BackendObject->ValueLookup(
        Value => 11, # (optional)
    );

=cut

sub ValueLookup {
    my ( $Self, %Param ) = @_;

    return '' if !$Param{Value};

    my $StateObject = $Kernel::OM->Get('Kernel::System::State');
    my $StateName   = $StateObject->StateLookup( StateID => $Param{Value} );
    return $Param{Value} if !defined $StateName;

    return $StateName;
}

1;
