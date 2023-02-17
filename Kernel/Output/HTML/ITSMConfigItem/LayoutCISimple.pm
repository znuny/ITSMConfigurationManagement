# --
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
package Kernel::Output::HTML::ITSMConfigItem::LayoutCISimple;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Output::HTML::Layout',
    'Kernel::System::GeneralCatalog',
    'Kernel::System::ITSMConfigItem',
    'Kernel::System::Log',
    'Kernel::System::Web::Request',
);

=head1 NAME

Kernel::Output::HTML::ITSMConfigItem::LayoutCISimple - layout backend module

=head1 SYNOPSIS

All layout functions of CIClass objects

=head2 new()

create an object

    my $BackendObject = $Kernel::OM->Get('Kernel::Output::HTML::ITSMConfigItemLayoutCISimple');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    #allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    $Self->{CIID} = 0;

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

    #transform ascii to html
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

    my %FormData;

    # get selected CIClass
    $FormData{Value} = $ParamObject->GetParam( Param => $Param{Key} );

    # check required option
    return \%FormData if !$Param{Item}->{Input}->{Required};
    return \%FormData if $FormData{Value};

    $Param{Item}->{Form}->{ $Param{Key} }->{Invalid} = 1;
    $FormData{Invalid} = 1;

    return \%FormData;
}

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

    my $ConfigItemObject     = $Kernel::OM->Get('Kernel::System::ITSMConfigItem');
    my $GeneralCatalogObject = $Kernel::OM->Get('Kernel::System::GeneralCatalog');
    my $LayoutObject         = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $LogObject            = $Kernel::OM->Get('Kernel::System::Log');

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

    my $Value = '';
    if ( defined $Param{Value} ) {
        $Value = $Param{Value};
    }
    elsif ( $Param{Item}->{Input}->{ValueDefault} ) {
        $Value = $Param{Item}->{Input}->{ValueDefault};
    }

    if (
        !$Param{Item}->{Input}->{CIClassID}
        && $Param{Item}->{Input}->{CIClassName}
        )
    {

        my $ItemDataRef = $GeneralCatalogObject->ItemGet(
            Class => 'ITSM::ConfigItem::Class',
            Name  => $Param{Item}->{Input}->{CIClassName},
        );

        if ( !$ItemDataRef || !( $ItemDataRef->{ItemID} ) ) {
            $LogObject->Log(
                Priority => 'error',
                Message  => "ITSMConfigItemLayoutCISimple: CI-Class <"
                    . $Param{Item}->{Input}->{CIClassName}
                    . "> not defined in GeneralCatalog!",
            );
        }
        else {
            $Self->{CIID} = $ItemDataRef->{ItemID};
        }

    }
    elsif ( $Param{Item}->{Input}->{CIClassID} ) {
        $Self->{CIID} = $Param{Item}->{Input}->{CIClassID};
    }

    my $ConfigItemListRef = $ConfigItemObject->ConfigItemResultList(
        ClassID => $Self->{CIID},
        Start   => 0,
        Limit   => 1_000_000,
    );

    my @SelectionValues;
    for my $Item ( @{ $ConfigItemListRef || [] } ) {
        push @SelectionValues, {
            Key   => $Item->{ConfigItemID},
            Value => $Item->{Name}
                . " ("
                . $Item->{Number}
                . ")",
        };
    }

    my $String = $LayoutObject->BuildSelection(
        Data         => \@SelectionValues,
        Name         => $Param{Key},
        SelectedID   => $Value,
        PossibleNone => 1,
        Class        => 'Modernize',
    );

    return $String;
}

=head2 SearchFormDataGet()

get search form data

    my $Value = $BackendObject->SearchFormDataGet(
        Key  => 'Item::1::Node::2',
        Item => $ItemRef,
    );

=cut

sub SearchFormDataGet {
    my ( $Self, %Param ) = @_;

    my $LogObject            = $Kernel::OM->Get('Kernel::System::Log');
    my $GeneralCatalogObject = $Kernel::OM->Get('Kernel::System::GeneralCatalog');
    my $ITSMConfigItemObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItem');
    my $ParamObject          = $Kernel::OM->Get('Kernel::System::Web::Request');

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

    if ( $Param{Item}->{Input}->{SearchInputType} && $Param{Item}->{Input}->{SearchInputType} eq 'Pattern' ) {
        my @Values = qw{};
        if ( !$Self->{CIID} ) {

            my $ItemDataRef = $GeneralCatalogObject->ItemGet(
                Class => 'ITSM::ConfigItem::Class',
                Name  => $Param{Item}->{Input}->{CIClassName},
            );

            if ( !$ItemDataRef || !( $ItemDataRef->{ItemID} ) ) {
                $LogObject->Log(
                    Priority => 'error',
                    Message  => "ITSMConfigItemLayoutCISimple: CI-Class <"
                        . $Param{Item}->{Input}->{CIClassName}
                        . "> not defined in GeneralCatalog!",
                );
            }
            else {
                $Self->{CIID} = $ItemDataRef->{ItemID};
            }

        }

        my @SearchValues = $ParamObject->GetParam( Param => $Param{Key} );

        SEARCHVALUE:
        for my $CurrSearchValue (@SearchValues) {
            next SEARCHVALUE if ( !$CurrSearchValue );

            my @SearchValueParts = split( '\|\|', $CurrSearchValue );

            SEARCHVALUEPART:
            for my $CurrSearchValuePart (@SearchValueParts) {
                next SEARCHVALUEPART if ( !$CurrSearchValuePart );

                # check pattern for id
                if ( $CurrSearchValuePart =~ m/^\[ID\]([0-9]+)$/i ) {
                    push( @Values, $1 );

                    next SEARCHVALUEPART;
                }

                if ( $CurrSearchValuePart =~ m/^\[Number\]([0-9*]+)$/i ) {
                    my $CISearchListRef = $ITSMConfigItemObject->ConfigItemSearchExtended(
                        Number   => $1,
                        ClassIDs => [ $Self->{CIID} ],
                    );
                    for my $SearchResult ( @{$CISearchListRef} ) {
                        push( @Values, $SearchResult );
                    }

                    next SEARCHVALUEPART;
                }

                my $CISearchListRef = $ITSMConfigItemObject->ConfigItemSearchExtended(
                    Name     => $CurrSearchValuePart,
                    ClassIDs => [ $Self->{CIID} ],
                );
                for my $SearchResult ( @{$CISearchListRef} ) {
                    push( @Values, $SearchResult );
                }
            }
        }    # no guard clause ;)

        if ( scalar(@Values) < 1 || !$Values[0] ) {
            @Values = @SearchValues;
        }

        return \@Values;
    }
    else {

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
            Message  => "Need $Argument!"
        );
        return;
    }

    my $InputString = '';

    if ( $Param{Item}->{Input}->{SearchInputType} && $Param{Item}->{Input}->{SearchInputType} eq 'Pattern' ) {
        my $Value = '';
        if ( ref( $Param{Value} ) eq 'ARRAY' ) {
            for my $ItemValue ( @{ $Param{Value} } ) {
                if ($Value) {
                    $Value .= "||";
                }
                if ( $ItemValue =~ m/^[0-9]+$/ ) {
                    $Value .= "[ID]" . $ItemValue;
                }
                else {
                    $Value .= $ItemValue;
                }
            }
        }
        $InputString = "<input type=\"Text\" name=\"$Param{Key}\" size=\"30\" value=\"$Value\">";
    }
    else {
        # hash with values for the input field
        my %FormData;

        if ( $Param{Value} ) {
            $FormData{Value} = $Param{Value};
        }

        # create input field
        $InputString = $Self->InputCreate(
            %FormData,
            Key  => $Param{Key},
            Item => $Param{Item},
        );
    }

    return $InputString;
}

1;
