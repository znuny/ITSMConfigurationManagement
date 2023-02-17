# --
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
## nofilter(TidyAll::Plugin::Znuny::CodeStyle::GuardClause)

package Kernel::System::ITSMConfigItem::XML::Type::CI;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::System::GeneralCatalog',
    'Kernel::System::ITSMConfigItem',
    'Kernel::System::Log'
);

=head1 NAME

Kernel::System::ITSMConfigItem::XML::Type::CI - xml backend module for CI objects

=head1 SYNOPSIS

All xml functions of CI objects

=head2 new()

create an object

    my $BackendObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItem::XML::Type::CI');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

=head2 ValueLookup()

get the xml data of a version

    my $Value = $BackendObject->ValueLookup(
        Value => 1, # (optional)
    );

=cut

sub ValueLookup {
    my ( $Self, %Param ) = @_;

    my $ITSMConfigItemObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItem');

    return '' if !$Param{Value};

    my $CIVersionData = $ITSMConfigItemObject->VersionGet(
        ConfigItemID => $Param{Value},
        XMLDataGet   => 0,
    );
    my $CIName = $Param{Value};

    #if ( $CIVersionData && ( ref($CIVersionData) eq 'HASH' ) && $CIVersionData->{Name})
    return $CIName if !IsHashRefWithData($CIVersionData);
    return $CIName if !$CIVersionData->{Name};

    $CIName = $CIVersionData->{Name} . " (" . $CIVersionData->{Number} . ")";

    return $CIName;
}

=head2 StatsAttributeCreate()

create a attribute array for the stats framework

    my $Attribute = $BackendObject->StatsAttributeCreate(
        Key  => 'Key::Subkey',
        Name => 'Name',
        Item => $ItemRef,
    );

=cut

sub StatsAttributeCreate {
    my ( $Self, %Param ) = @_;

    my $LogObject = $Kernel::OM->Get('Kernel::System::Log');

    # check needed stuff
    PARAM:
    for my $Argument (qw(Key Name Item)) {
        next PARAM if $Param{$Argument};

        $LogObject->Log(
            Priority => 'error',
            Message  => "Need $Argument!"
        );
        return;
    }

    # create arrtibute
    my $Attribute = [
        {
            Name             => $Param{Name},
            UseAsXvalue      => 0,
            UseAsValueSeries => 0,
            UseAsRestriction => 1,
            Element          => $Param{Key},
            Block            => 'InputField',
        },
    ];

    return $Attribute;
}

=head2 ExportSearchValuePrepare()

prepare search value for export

    my $ArrayRef = $BackendObject->ExportSearchValuePrepare(
        Value => 1, # (optional)
    );

=cut

sub ExportSearchValuePrepare {
    my ( $Self, %Param ) = @_;

    my $ITSMConfigItemObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItem');

    return    if !defined $Param{Value};
    return '' if !$Param{Value};

    # lookup CI number
    my $CI = $ITSMConfigItemObject->ConfigItemGet(
        ConfigItemID => $Param{Value},
    );

    #if ( $CI && ref $CI eq 'HASH' && $CI->{Number} ) {
    if ( IsHashRefWithData($CI) && $CI->{Number} ) {
        return $CI->{Number};
    }

    return '';
}

=head2 ExportValuePrepare()

prepare value for export

    my $Value = $BackendObject->ExportValuePrepare(
        Value => 11, # (optional)
    );

=cut

sub ExportValuePrepare {
    my ( $Self, %Param ) = @_;

    my $ITSMConfigItemObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItem');
    my $GeneralCatalogObject = $Kernel::OM->Get('Kernel::System::GeneralCatalog');

    return    if !defined $Param{Value};
    return '' if !$Param{Value};

    my $SearchAttr = $Param{Item}->{Input}->{CIAttributeKey} || '';

    if ($SearchAttr) {

        my $VersionData = $ITSMConfigItemObject->VersionGet(
            ConfigItemID => $Param{Value},
        );

        #if ( $VersionData && ref $VersionData eq 'HASH' ) {
        if ( IsHashRefWithData($VersionData) ) {

            # get ConfigItem class ID
            my $CIClassID = "";

            if (
                IsHashRefWithData( $Param{Item} )
                && IsHashRefWithData( $Param{Item}->{Input} )
                && $Param{Item}->{Input}->{CIClassName}
                )
            {

                my $ItemDataRef = $GeneralCatalogObject->ItemGet(
                    Class => 'ITSM::ConfigItem::Class',
                    Name  => $Param{Item}->{Input}->{CIClassName} || '',
                );

                # if ( $ItemDataRef && ref($ItemDataRef) eq 'HASH' && $ItemDataRef->{ItemID} ) {
                if ( IsHashRefWithData($ItemDataRef) && $ItemDataRef->{ItemID} ) {
                    $CIClassID = $ItemDataRef->{ItemID} || '';
                }

                my $XMLDefinition =
                    $ITSMConfigItemObject->DefinitionGet(
                    ClassID => $CIClassID,
                    );

                my $ArrRef = $Self->{CIACUtilsObject}->GetAttributeValuesByKey(
                    KeyName       => $SearchAttr,
                    XMLData       => $VersionData->{XMLData}->[1]->{Version}->[1],
                    XMLDefinition => $XMLDefinition->{DefinitionRef},
                );

                if ( $ArrRef && $ArrRef->[0] ) {
                    return $ArrRef->[0];
                }
            }
        }
    }

    # lookup CI number for given CI ID
    my $CI = $ITSMConfigItemObject->ConfigItemGet(
        ConfigItemID => $Param{Value},
    );

    #if ( $CI && ref $CI eq 'HASH' && $CI->{Number} ) {
    if ( IsHashRefWithData($CI) && $CI->{Number} ) {
        return $CI->{Number};
    }

    return '';
}

=head2 ImportSearchValuePrepare()

prepare search value for import

    my $ArrayRef = $BackendObject->ImportSearchValuePrepare(
        Value => 11, # (optional)
    );

=cut

sub ImportSearchValuePrepare {
    my ( $Self, %Param ) = @_;

    my $ITSMConfigItemObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItem');

    return    if !defined $Param{Value};
    return '' if !$Param{Value};

    # check if CI number was given
    my $CIID = $ITSMConfigItemObject->ConfigItemLookup(
        ConfigItemNumber => $Param{Value},
    );
    return $CIID if $CIID;

    # check if given value is a valid CI ID
    if ( $Param{Value} !~ /\D/ ) {
        my $CINumber = $ITSMConfigItemObject->ConfigItemLookup(
            ConfigItemID => $Param{Value},
        );
        return $Param{Value} if $CINumber;
    }

    return '';
}

=head2 ImportValuePrepare()

prepare value for import

    my $Value = $BackendObject->ImportValuePrepare(
        Value => 11, # (optional)
    );

=cut

sub ImportValuePrepare {
    my ( $Self, %Param ) = @_;

    my $ITSMConfigItemObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItem');
    my $GeneralCatalogObject = $Kernel::OM->Get('Kernel::System::GeneralCatalog');

    return    if !defined $Param{Value};
    return '' if !$Param{Value};

    my $SearchAttr = $Param{Item}->{Input}->{CIAttributeKey} || '';

    # make CI-Number out of given value
    if ($SearchAttr) {

        # get ConfigItem class ID
        my $CIClassID = "";

        if (
            IsHashRefWithData( $Param{Item} )
            && IsHashRefWithData( $Param{Item}->{Input} )
            && $Param{Item}->{Input}->{CIClassName}
            )
        {

            my $ItemDataRef = $GeneralCatalogObject->ItemGet(
                Class => 'ITSM::ConfigItem::Class',
                Name  => $Param{Item}->{Input}->{CIClassName} || '',
            );

            if ( IsHashRefWithData($ItemDataRef) && $ItemDataRef->{ItemID} ) {
                $CIClassID = $ItemDataRef->{ItemID} || '';
            }

            # prepare search params
            my %SearchParams = ();
            my %SearchData   = ();

            $SearchData{$SearchAttr} = $Param{Value};

            my $XMLDefinition =
                $ITSMConfigItemObject->DefinitionGet(
                ClassID => $CIClassID,
                );

            my @SearchParamsWhat;
            $Self->_XMLSearchDataPrepare(
                XMLDefinition => $XMLDefinition->{DefinitionRef},
                What          => \@SearchParamsWhat,
                SearchData    => \%SearchData,
            );

            if (@SearchParamsWhat) {
                $SearchParams{What} = \@SearchParamsWhat;
            }

            # search the config items
            my $ConfigItemIDs = $ITSMConfigItemObject->ConfigItemSearchExtended(
                %SearchParams,
                ClassIDs              => [$CIClassID],
                PreviousVersionSearch => 0,
            );

            # get and return CofigItem ID
            my $CIID = "";
            if ( $ConfigItemIDs && ref($ConfigItemIDs) eq 'ARRAY' ) {
                $CIID = $ConfigItemIDs->[0] || '';
            }
            return $CIID;
        }
    }

    my $CIID = $ITSMConfigItemObject->ConfigItemLookup(
        ConfigItemNumber => $Param{Value},
    );
    return $CIID if $CIID;

    # make CI-Number out of given Name...
    my $CIClassID = "";

    if (
        IsHashRefWithData( $Param{Item} )
        && $Param{Item}->{Input}
        && IsHashRefWithData( $Param{Item}->{Input} )
        && $Param{Item}->{Input}->{CIClassName}
        )
    {

        my $RefClassName = $Param{Item}->{Input}->{CIClassName};
        my $ItemDataRef  = $GeneralCatalogObject->ItemGet(
            Class => 'ITSM::ConfigItem::Class',
            Name  => $Param{Item}->{Input}->{CIClassName} || '',
        );

        if ( IsHashRefWithData($ItemDataRef) && $ItemDataRef->{ItemID} ) {
            $CIClassID = $ItemDataRef->{ItemID} || '';
        }
        my $ConfigItemIDs = $ITSMConfigItemObject->ConfigItemSearchExtended(
            Name     => $Param{Value},
            ClassIDs => [$CIClassID],
        );
        my $CIID = "";
        if ( $ConfigItemIDs && ref($ConfigItemIDs) eq 'ARRAY' ) {
            $CIID = $ConfigItemIDs->[0] || '';
        }
        return $CIID if $CIID;
    }

    # check if given value is a valid CI ID
    if ( $Param{Value} !~ /\D/ ) {
        my $CINumber = $ITSMConfigItemObject->ConfigItemLookup(
            ConfigItemID => $Param{Value},
        );
        return $Param{Value} if $CINumber;
    }

    return '';
}

sub _XMLSearchDataPrepare {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    return if !$Param{XMLDefinition} || ref $Param{XMLDefinition} ne 'ARRAY';
    return if !$Param{What}          || ref $Param{What} ne 'ARRAY';
    return if !$Param{SearchData}    || ref $Param{SearchData} ne 'HASH';

    ITEM:
    for my $Item ( @{ $Param{XMLDefinition} } ) {

        # create key
        my $Key =
            $Param{Prefix} ? $Param{Prefix} . '::' . $Item->{Key} : $Item->{Key};

        if ( $Param{SearchData}->{$Key} ) {

            # create search key
            my $SearchKey = $Key;
            $SearchKey =~ s{ :: }{\'\}[%]\{\'}xmsg;

            # create search hash
            my $SearchHash =
                {
                '[1]{\'Version\'}[1]{\''
                    . $SearchKey
                    . '\'}[%]{\'Content\'}' => $Param{SearchData}->{$Key},
                };
            push @{ $Param{What} }, $SearchHash;
        }
        next ITEM if !$Item->{Sub};

        # start recursion, if "Sub" was found
        $Self->_XMLSearchDataPrepare(
            XMLDefinition => $Item->{Sub},
            What          => $Param{What},
            SearchData    => $Param{SearchData},
            Prefix        => $Key,
        );
    }
    return 1;
}

1;
