# --
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
package Kernel::Output::HTML::ITSMConfigItem::LayoutPriority;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Output::HTML::Layout',
    'Kernel::System::Log',
    'Kernel::System::Priority',
);

use parent 'Kernel::Output::HTML::ITSMConfigItem::LayoutBaseSelectable';

=head1 NAME

Kernel::Output::HTML::ITSMConfigItem::LayoutPriority - layout backend module

=head1 SYNOPSIS

Layout functions for CI priority objects

=head2 new()

=head2 InputCreate()

create a input string

    my $Value = $BackendObject->InputCreate(
        Key   => 'Item::1::Node::3',
        Value => 11,       # (optional)
        Item  => $ItemRef,
    );

=cut

sub InputCreate {
    my ( $Self, %Param ) = @_;

    my $LogObject      = $Kernel::OM->Get('Kernel::System::Log');
    my $PriorityObject = $Kernel::OM->Get('Kernel::System::Priority');
    my $LayoutObject   = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    #check needed stuff
    ARGUMENT:
    for my $Argument (qw(Key Item)) {
        next ARGUMENT if $Param{$Argument};

        $LogObject->Log(
            Priority => 'error',
            Message  => "Need $Argument!"
        );
        return;
    }

    my $Class = 'W50pc Modernize';
    if ( $Param{Required} ) {
        $Class .= ' Validate_Required';
    }

    if ( $Param{Invalid} ) {
        $Class .= ' ServerError';
    }

    my $Value = '';
    if ( defined $Param{Value} ) {
        $Value = $Param{Value};
    }
    elsif ( $Param{Item}->{Input}->{ValueDefault} ) {
        $Value = $Param{Item}->{Input}->{ValueDefault};
    }

    my %Priorities        = $PriorityObject->PriorityList();
    my $PrioritySelection = $LayoutObject->BuildSelection(
        Name         => $Param{Key},
        ID           => $Param{ItemId},
        Data         => \%Priorities,
        Class        => $Class,
        TreeView     => 1,
        SelectedID   => $Value,
        PossibleNone => 1,
    );

    return $PrioritySelection;
}

1;
