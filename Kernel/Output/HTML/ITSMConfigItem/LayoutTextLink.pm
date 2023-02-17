# --
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::ITSMConfigItem::LayoutTextLink;

use strict;
use warnings;

use parent qw( Kernel::Output::HTML::ITSMConfigItem::LayoutText );

our @ObjectDependencies = ();

=head1 NAME

Kernel::Output::HTML::ITSMConfigItem::LayoutTextLink - layout backend module

=head1 DESCRIPTION

All layout functions of textlink objects

=head2 OutputStringCreate()

create output string

    my $Value = $BackendObject->OutputStringCreate(
        Value => 11,       # (optional)
        Item => $ItemRef,
    );

=cut

sub OutputStringCreate {
    my ( $Self, %Param ) = @_;

    my $Result = $Self->SUPER::OutputStringCreate(%Param);
    return $Result if !$Result;

    my $Link = $Param{Item}->{Input}->{URL};
    $Link =~ s/<VALUE>/$Result/;

    $Result = <<"HTML";
<a href="$Link" target="_blank">$Result</a>
HTML

    return $Result;
}

1;
