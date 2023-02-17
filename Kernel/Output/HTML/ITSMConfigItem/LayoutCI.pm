# --
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
## nofilter(TidyAll::Plugin::Znuny::CodeStyle::GuardClause)

package Kernel::Output::HTML::ITSMConfigItem::LayoutCI;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Language',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::GeneralCatalog',
    'Kernel::System::ITSMConfigItem',
    'Kernel::System::Log',
    'Kernel::System::Web::Request',
);

=head1 NAME

Kernel::Output::HTML::ITSMConfigItem::LayoutCI - layout backend module

=head1 SYNOPSIS

All layout functions of CIClass objects

=head2 new()

create an object

    my $BackendObject = $Kernel::OM->Get('Kernel::Output::HTML::ITSMConfigItemLayoutCI');

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
    NEEDED:
    for my $Needed (qw(Key Item)) {

        next NEEDED if defined $Param{$Needed};

        $LogObject->Log(
            Priority => 'error',
            Message  => "Parameter '$Needed' is needed!",
        );
        return;
    }

    my %FormData;

    #get selected CIClass
    $FormData{Value} = $ParamObject->GetParam( Param => $Param{Key} );

    #check search button..
    if ( $ParamObject->GetParam( Param => $Param{Key} . '::ButtonSearch' ) ) {
        $Param{Item}->{Form}->{ $Param{Key} }->{Search} = $ParamObject->GetParam( Param => $Param{Key} . '::Search' );
    }

    #check select button
    elsif ( $ParamObject->GetParam( Param => $Param{Key} . '::ButtonSelect' ) ) {
        $FormData{Value} = $ParamObject->GetParam( Param => $Param{Key} . '::Select' );
    }

    #check clear button
    elsif ( $ParamObject->GetParam( Param => $Param{Key} . '::ButtonClear' ) ) {
        $FormData{Value} = '';
    }
    else {

        #reset value if search field is empty
        if (
            !$ParamObject->GetParam( Param => $Param{Key} . '::Search' )
            && defined $FormData{Value}
            )
        {
            $FormData{Value} = '';
        }

        #check required option
        if ( $Param{Item}->{Input}->{Required} && !$FormData{Value} ) {
            $Param{Item}->{Form}->{ $Param{Key} }->{Invalid} = 1;
            $FormData{Invalid} = 1;
        }
    }

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

    my $LogObject            = $Kernel::OM->Get('Kernel::System::Log');
    my $GeneralCatalogObject = $Kernel::OM->Get('Kernel::System::GeneralCatalog');
    my $ITSMConfigItemObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItem');
    my $LayoutObject         = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $LanguageObject       = $Kernel::OM->Get('Kernel::Language');
    my $ConfigObject         = $Kernel::OM->Get('Kernel::Config');

    # check needed stuff
    NEEDED:
    for my $Needed (qw(Key Item)) {

        next NEEDED if defined $Param{$Needed};

        $LogObject->Log(
            Priority => 'error',
            Message  => "Parameter '$Needed' is needed!",
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
                Message  => "ITSMConfigItemLayoutCI: CI-Class <"
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

    my $Size         = $Param{Item}->{Input}->{Size} || 50;
    my $Search       = '';
    my $StringOption = '';
    my $StringSelect = '';

    # AutoComplete CIClass
    my $Class = 'W50pc CIClassSearch';

    my $Required = $Param{Required} || '';
    my $Invalid  = $Param{Invalid}  || '';

    # CIClass search
    if ( $Param{Item}->{Form}->{ $Param{Key} }->{Search} ) {

        # search for name
        my %CISearchList    = ();
        my $CISearchListRef = $ITSMConfigItemObject->ConfigItemSearchExtended(
            Name     => '*' . $Param{Item}->{Form}->{ $Param{Key} }->{Search} . '*',
            ClassIDs => [ $Self->{CIID} ],
        );

        for my $SearchResult ( @{$CISearchListRef} ) {
            my $CurrVersionData = $ITSMConfigItemObject->VersionGet(
                ConfigItemID => $SearchResult,
                XMLDataGet   => 0,
            );

            if ( IsHashRefWithData($CurrVersionData) && $CurrVersionData->{Name} && $CurrVersionData->{Number} ) {
                $CISearchList{$SearchResult} = $CurrVersionData->{Name} . " (" . $CurrVersionData->{Number} . ")";
            }
        }

        # search for number
        $CISearchListRef = $ITSMConfigItemObject->ConfigItemSearchExtended(
            Number   => '*' . $Param{Item}->{Form}->{ $Param{Key} }->{Search} . '*',
            ClassIDs => [ $Self->{CIID} ],
        );

        for my $SearchResult ( @{$CISearchListRef} ) {
            my $CurrVersionData = $ITSMConfigItemObject->VersionGet(
                ConfigItemID => $SearchResult,
                XMLDataGet   => 0,
            );
            if (
                $CurrVersionData
                &&
                ( ref($CurrVersionData) eq 'HASH' ) &&
                $CurrVersionData->{Name} &&
                $CurrVersionData->{Number}
                )
            {
                $CISearchList{$SearchResult} = $CurrVersionData->{Name}
                    . " ("
                    . $CurrVersionData->{Number}
                    . ")";
            }
        }

        # build search result presentation
        if ( %CISearchList && scalar( keys %CISearchList ) > 1 ) {

            #create option list
            $StringOption = $LayoutObject->BuildSelection(
                Name  => $Param{Key} . '::Select',
                Data  => \%CISearchList,
                Class => 'Modernize W50pc',
            );
            $StringOption .= '<br>';

            # create select button
            $StringSelect = '<input class="button" type="submit" name="' . $Param{Key} . '::ButtonSelect" '
                . 'value="' . $LanguageObject->Translate("Select") . '">&nbsp;';

            # set search
            $Search = $Param{Item}->{Form}->{ $Param{Key} }->{Search};
        }
        elsif (%CISearchList) {

            $Value = ( keys %CISearchList )[0];
            my $CIVersionDataRef = $ITSMConfigItemObject->VersionGet(
                ConfigItemID => $Value,
                XMLDataGet   => 0,
            );
            my $CIName = "";

            if ( IsHashRefWithData($CIVersionDataRef) && $CIVersionDataRef->{Name} && $CIVersionDataRef->{Number} ) {
                $CIName = $CIVersionDataRef->{Name} . " (" . $CIVersionDataRef->{Number} . ")";
            }

            #transform ascii to html
            $Search = $LayoutObject->Ascii2Html(
                Text           => $CIName || '',
                HTMLResultMode => 1,
            );
        }
    }

    # create CIClass string
    elsif ($Value) {

        my $CIVersionDataRef = $ITSMConfigItemObject->VersionGet(
            ConfigItemID => $Value,
            XMLDataGet   => 0,
        );
        my $CIName = "";

        if ( IsHashRefWithData($CIVersionDataRef) && $CIVersionDataRef->{Name} && $CIVersionDataRef->{Number} ) {
            $CIName = $CIVersionDataRef->{Name} . " (" . $CIVersionDataRef->{Number} . ")";
        }

        #transform ascii to html
        $Search = $LayoutObject->Ascii2Html(
            Text           => $CIName || '',
            HTMLResultMode => 1,
        );
    }

    my $String = '<input type="hidden" name="' . $Param{Key} . '" value="' . $Value . '">'
        . '<input type="Text" name="'
        . $Param{Key}
        . '::Search" class="'
        . $Class
        . '" size="'
        . $Size
        . '" value="'
        . $Search . '">'
        . '<br>'
        . $StringOption
        . $StringSelect
        . '<input class="button" type="submit" name="'
        . $Param{Key}
        . '::ButtonSearch" value="'
        . $LanguageObject->Translate("Search") . '">';

    if ($Search) {
        $String .= '&nbsp;' . '<input class="button" type="submit" name="' . $Param{Key} . '::ButtonClear" value="'
            . $LanguageObject->Translate("Clear") . '">';
    }

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
    my $ParamObject          = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $ITSMConfigItemObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItem');

    # check needed stuff
    NEEDED:
    for my $Needed (qw(Key Item)) {

        next NEEDED if defined $Param{$Needed};

        $LogObject->Log(
            Priority => 'error',
            Message  => "Parameter '$Needed' is needed!",
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
                    Message  => "ITSMConfigItemLayoutCI: CI-Class <"
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
        }

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
    NEEDED:
    for my $Needed (qw(Key Item)) {

        next NEEDED if defined $Param{$Needed};

        $LogObject->Log(
            Priority => 'error',
            Message  => "Parameter '$Needed' is needed!",
        );
        return;
    }

    my $InputString = '';

    if ( $Param{Item}->{Input}->{SearchInputType} && $Param{Item}->{Input}->{SearchInputType} eq 'Pattern' ) {
        my $Value = $Param{Value};
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
        $InputString = "<input type=\"Text\" name=\"$Param{Key}\" class=\"W50pc\" value=\"$Value\">";
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
