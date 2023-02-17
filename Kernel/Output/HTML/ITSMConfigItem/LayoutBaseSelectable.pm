# --
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
package Kernel::Output::HTML::ITSMConfigItem::LayoutBaseSelectable;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Output::HTML::Layout',
    'Kernel::System::Log',
    'Kernel::System::Web::Request',
);

=head1 NAME

Kernel::Output::HTML::ITSMConfigItem::LayoutBaseSelectable - layout backend module

=head1 SYNOPSIS

Base layout module for select-able values

=head2 new()

create an object

    my $BackendObject = $Kernel::OM->Get('Kernel::Output::HTML::ITSMConfigItem::LayoutBaseSelectable');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    #allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

=head2 OutputStringCreate()

create output string

    my $Value = $BackendObject->OutputStringCreate(
        Value => 11,       # (optional)
    );

=cut

sub OutputStringCreate {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # transform ascii to html
    $Param{Value} = $LayoutObject->Ascii2Html(
        Text           => $Param{Value} || '',
        HTMLResultMode => 1,
    );

    return $Param{Value};
}

=head2 FormDataGet()

get form data as hash

    my $FormDataRef = $BackendObject->FormDataGet(
        Key  => 'Item::1::Node::2,
        Item => $ItemRef,
    );

=cut

sub FormDataGet {
    my ( $Self, %Param ) = @_;

    my $LogObject   = $Kernel::OM->Get('Kernel::System::Log');
    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

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

    my %FormData;
    $FormData{Value} = $ParamObject->GetParam( Param => $Param{Key} );

    return \%FormData if !$Param{Item}->{Input}->{Required};
    return \%FormData if $FormData{Value};

    $FormData{Invalid} = 1;
    $Param{Item}->{Form}->{ $Param{Key} }->{Invalid} = 1;

    return \%FormData;

}

=head2 SearchFormDataGet()

get search form data

    my $Value = $BackendObject->SearchFormDataGet(
        Key => 'Item::1::Node::2',
        Item => $ItemRef,
    );

=cut

sub SearchFormDataGet {
    my ( $Self, %Param ) = @_;

    my $LogObject   = $Kernel::OM->Get('Kernel::System::Log');
    my $ParamObject = $Kernel::OM->Get('Kernel::System::Web::Request');

    # check needed stuff
    ARGUMENT:
    for my $Argument (qw(Key Item)) {
        next ARGUMENT if $Param{$Argument};

        $LogObject->Log(
            Priority => 'error',
            Message  => "Need $Argument!",
        );
        return;
    }

    # get form data
    my $Value;
    if ( $Param{Value} ) {
        $Value = $Param{Value};
    }
    else {
        $Value = $ParamObject->GetParam( Param => $Param{Key} );
    }

    return $Value;
}

=head2 SearchInputCreate()

create a search input string

    my $Value = $BackendObject->SearchInputCreate(
        Key => 'Item::1::Node::2',
    );

=cut

sub SearchInputCreate {
    my ( $Self, %Param ) = @_;

    my $LogObject = $Kernel::OM->Get('Kernel::System::Log');

    # check needed stuff
    ARGUMENT:
    for my $Argument (qw(Key Item)) {
        next ARGUMENT if $Param{$Argument};

        $LogObject->Log(
            Priority => 'error',
            Message  => "Need $Argument!",
        );
        return;
    }

    my %FormData;
    if ( $Param{Value} ) {
        $FormData{Value} = $Param{Value};
    }

    # create input field
    my $InputString = $Self->InputCreate(
        %FormData,
        Key  => $Param{Key},
        Item => $Param{Item},
    );

    return $InputString;
}

1;
