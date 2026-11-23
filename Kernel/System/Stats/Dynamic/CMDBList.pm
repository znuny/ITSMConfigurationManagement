# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.

package Kernel::System::Stats::Dynamic::CMDBList;

use strict;
use warnings;
use utf8;

use List::Util       qw(first);
use Kernel::Language qw(Translatable);

our @ObjectDependencies = (
    'Kernel::Language',
    'Kernel::System::GeneralCatalog',
    'Kernel::System::ITSMConfigItem',
    'Kernel::System::Log',
    'Kernel::System::Stats',
);

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {};
    bless $Self, $Type;

    return $Self;
}

sub GetObjectName {
    my ( $Self, %Param ) = @_;

    return 'CMDBList';
}

sub GetObjectBehaviours {
    my ( $Self, %Param ) = @_;

    return (
        ProvidesDashboardWidget => 0,
    );
}

sub GetObjectAttributes {
    my ( $Self, %Param ) = @_;

    my $GeneralCatalogObject = $Kernel::OM->Get('Kernel::System::GeneralCatalog');

    my $ConfigItemObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItem');

    my $ClassList = $GeneralCatalogObject->ItemList(
        Class => 'ITSM::ConfigItem::Class',
    );

    my $DeplStateList = $GeneralCatalogObject->ItemList(
        Class => 'ITSM::ConfigItem::DeploymentState',
    );

    my $InciStateList = $GeneralCatalogObject->ItemList(
        Class => 'ITSM::Core::IncidentState',
    );

    $ClassList     ||= {};
    $DeplStateList ||= {};
    $InciStateList ||= {};

    my %Limit = (
        10        => 10,
        20        => 20,
        50        => 50,
        100       => 100,
        250       => 250,
        500       => 500,
        unlimited => Translatable('unlimited'),
    );

    my %SortSequence = (
        Up   => Translatable('ascending'),
        Down => Translatable('descending'),
    );

    #
    # Key columns in the report.
    #
    my %PrintAttributes = (
        Number           => Translatable('Number'),
        ConfigItemID     => 'ConfigItemID',
        Name             => Translatable('Name'),
        Class            => Translatable('Class'),
        CurDeplState     => Translatable('Deployment State'),
        CurInciState     => Translatable('Incident State'),
        CreateTime       => Translatable('Create Time'),
        ChangeTime       => Translatable('Change Time'),
        LastVersionID    => 'LastVersionID',
        ConfigItemNumber => Translatable('Config Item Number'),
    );

    my @SortedAttributes = qw(
        Number
        ConfigItemNumber
        ConfigItemID
        Name
        Class
        CurDeplState
        CurInciState
        CreateTime
        ChangeTime
        LastVersionID
    );

    #
    # Dynamic columns from CMDB class definitions
    #

    CLASSID:
    for my $ClassID ( sort { $a <=> $b } keys %{$ClassList} ) {

        my $Definition = $ConfigItemObject->DefinitionGet(
            ClassID => $ClassID,
        );

        next CLASSID if !$Definition;
        next CLASSID if ref $Definition ne 'HASH';
        next CLASSID if !$Definition->{DefinitionID};
        next CLASSID if ref $Definition->{DefinitionRef} ne 'ARRAY';

        $Self->_DefinitionAttributesAdd(
            XMLDefinition   => $Definition->{DefinitionRef},
            ClassID         => $ClassID,
            ClassName       => $ClassList->{$ClassID},
            PrintAttributes => \%PrintAttributes,
            Sorted          => \@SortedAttributes,
        );
    }

    $Self->{PrintAttributes}  = \%PrintAttributes;
    $Self->{SortedAttributes} = \@SortedAttributes;

    my %OrderBy = %PrintAttributes;
    delete $OrderBy{Number};

    my @ObjectAttributes = (
        {
            Name             => Translatable('Attributes to be printed'),
            UseAsXvalue      => 1,
            UseAsValueSeries => 0,
            UseAsRestriction => 0,
            Element          => 'ConfigItemAttributes',
            Block            => 'MultiSelectField',
            Translation      => 1,
            Values           => \%PrintAttributes,
            Sort             => 'IndividualKey',
            SortIndividual   => \@SortedAttributes,
        },
        {
            Name             => Translatable('Order by'),
            UseAsXvalue      => 0,
            UseAsValueSeries => 1,
            UseAsRestriction => 0,
            Element          => 'OrderBy',
            Block            => 'SelectField',
            Translation      => 1,
            Values           => \%OrderBy,
            Sort             => 'IndividualKey',
            SortIndividual   => \@SortedAttributes,
        },
        {
            Name             => Translatable('Sort sequence'),
            UseAsXvalue      => 0,
            UseAsValueSeries => 1,
            UseAsRestriction => 0,
            Element          => 'SortSequence',
            Block            => 'SelectField',
            Translation      => 1,
            Values           => \%SortSequence,
        },
        {
            Name             => Translatable('Limit'),
            UseAsXvalue      => 0,
            UseAsValueSeries => 0,
            UseAsRestriction => 1,
            Element          => 'Limit',
            Block            => 'SelectField',
            Translation      => 1,
            Values           => \%Limit,
            Sort             => 'IndividualKey',
            SortIndividual   => [
                '10', '20', '50', '100', '250', '500', 'unlimited',
            ],
        },
        {
            Name                => Translatable('Class'),
            UseAsXvalue         => 0,
            UseAsValueSeries    => 0,
            UseAsRestriction    => 1,
            Element             => 'ClassIDs',
            Block               => 'MultiSelectField',
            LanguageTranslation => 0,
            Values              => $ClassList,
        },
        {
            Name             => Translatable('Deployment State'),
            UseAsXvalue      => 0,
            UseAsValueSeries => 0,
            UseAsRestriction => 1,
            Element          => 'DeplStateIDs',
            Block            => 'MultiSelectField',
            Values           => $DeplStateList,
        },
        {
            Name             => Translatable('Incident State'),
            UseAsXvalue      => 0,
            UseAsValueSeries => 0,
            UseAsRestriction => 1,
            Element          => 'InciStateIDs',
            Block            => 'MultiSelectField',
            Values           => $InciStateList,
        },
        {
            Name             => Translatable('Config Item Number'),
            UseAsXvalue      => 0,
            UseAsValueSeries => 0,
            UseAsRestriction => 1,
            Element          => 'Number',
            Block            => 'InputField',
        },
        {
            Name             => Translatable('Name'),
            UseAsXvalue      => 0,
            UseAsValueSeries => 0,
            UseAsRestriction => 1,
            Element          => 'Name',
            Block            => 'InputField',
        },
        {
            Name             => Translatable('Create Time'),
            UseAsXvalue      => 0,
            UseAsValueSeries => 0,
            UseAsRestriction => 1,
            Element          => 'CreateTime',
            TimePeriodFormat => 'DateInputFormat',
            Block            => 'Time',
            Values           => {
                TimeStart => 'ConfigItemCreateTimeNewerDate',
                TimeStop  => 'ConfigItemCreateTimeOlderDate',
            },
        },
        {
            Name             => Translatable('Change Time'),
            UseAsXvalue      => 0,
            UseAsValueSeries => 0,
            UseAsRestriction => 1,
            Element          => 'ChangeTime',
            TimePeriodFormat => 'DateInputFormat',
            Block            => 'Time',
            Values           => {
                TimeStart => 'ConfigItemChangeTimeNewerDate',
                TimeStop  => 'ConfigItemChangeTimeOlderDate',
            },
        },
    );

    #
    # XML filters use the mechanism employed by the original ITSMConfigItem statistics object.
    #
    CLASSID:
    for my $ClassID ( sort { $a <=> $b } keys %{$ClassList} ) {

        my $Definition = $ConfigItemObject->DefinitionGet(
            ClassID => $ClassID,
        );

        next CLASSID if !$Definition;
        next CLASSID if ref $Definition ne 'HASH';
        next CLASSID if !$Definition->{DefinitionID};
        next CLASSID if ref $Definition->{DefinitionRef} ne 'ARRAY';

        $Self->_XMLRestrictionAttributesAdd(
            ObjectAttributes => \@ObjectAttributes,
            XMLDefinition    => $Definition->{DefinitionRef},
            Prefix           => 'XML::' . $ClassID,
            PrefixName       => $ClassList->{$ClassID},
        );
    }

    return @ObjectAttributes;
}

sub GetStatTablePreview {
    my ( $Self, %Param ) = @_;

    return $Self->GetStatTable(
        %Param,
        Preview => 1,
    );
}

sub GetStatTable {
    my ( $Self, %Param ) = @_;

    my $ConfigItemObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItem');

    my $Preview = $Param{Preview};

    my %SelectedAttributes = map { $_ => 1 }
        @{ $Param{XValue}{SelectedValues} || [] };

    my $AddEnumeration = 0;

    if ( $SelectedAttributes{Number} ) {
        $AddEnumeration = 1;
        delete $SelectedAttributes{Number};
    }

    my $OrderRef = first {
        $_->{Element} eq 'OrderBy'
    } @{ $Param{ValueSeries} || [] };

    my $OrderBy = $OrderRef
        ? $OrderRef->{SelectedValues}->[0]
        : 'Name';

    my $SortRef = first {
        $_->{Element} eq 'SortSequence'
    } @{ $Param{ValueSeries} || [] };

    my $Sort = $SortRef
        ? $SortRef->{SelectedValues}->[0]
        : 'Up';

    my %Restrictions = %{ $Param{Restrictions} || {} };

    my $Limit = delete $Restrictions{Limit};

    if ( !$Limit || $Limit eq 'unlimited' ) {
        $Limit = 100_000;
    }

    if ($Preview) {
        %Restrictions = (
            Limit => 10,
        );
    }
    else {
        $Restrictions{Limit} = $Limit;
    }

    my @XMLParams = grep {
        $_ =~ m{\AXML::}
    } sort keys %Restrictions;

    if ( @XMLParams && !$Restrictions{ClassIDs} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  =>
                'CMDBList: XML restrictions require at least one ClassID.',
        );
        return;
    }

    my %XMLDateFields;
    my %XMLClassIDs;

    XMLPARAM:
    for my $ParamKey (@XMLParams) {

        my $SearchValues = delete $Restrictions{$ParamKey};

        if ( !ref $SearchValues ) {
            $SearchValues = [$SearchValues];
        }

        next XMLPARAM if ref $SearchValues ne 'ARRAY';
        next XMLPARAM if !@{$SearchValues};

        my ( $ClassID, $SearchKey ) = $ParamKey =~ m{
            \AXML::(\d+)::(.+)\z
        }xms;

        next XMLPARAM if !$ClassID;
        next XMLPARAM if !$SearchKey;

        $XMLClassIDs{$ClassID} = 1;

        $SearchKey =~ s[ :: ]['}[%]{']xmsg;
        if ( $SearchKey =~ m{\A(.+)(NewerDate|OlderDate)\z}xms ) {
            $XMLDateFields{$1}->{$2} = $SearchValues->[0];
            next XMLPARAM;
        }

        push @{ $Restrictions{What} }, {
            '[1]{\'Version\'}[1]{\''
                . $SearchKey
                . '\'}[%]{\'Content\'}' => $SearchValues,
        };
    }
    DATEFIELD:
    for my $DateFieldName ( sort keys %XMLDateFields ) {

        my $NewerDate = $XMLDateFields{$DateFieldName}->{NewerDate};
        my $OlderDate = $XMLDateFields{$DateFieldName}->{OlderDate};

        next DATEFIELD if !$NewerDate && !$OlderDate;

        my %DateCondition;

        if ( $NewerDate && $OlderDate ) {
            $DateCondition{'-between'} = [
                $NewerDate,
                $OlderDate,
            ];
        }
        elsif ($NewerDate) {
            $DateCondition{'-greater-than-equals'} = $NewerDate;
        }
        else {
            $DateCondition{'-smaller-than-equals'} = $OlderDate;
        }

        push @{ $Restrictions{What} }, {
            '[1]{\'Version\'}[1]{\''
                . $DateFieldName
                . '\'}[%]{\'Content\'}' => \%DateCondition,
        };
    }

    if ( %XMLClassIDs && $Restrictions{ClassIDs} ) {

        my @MatchingClasses = grep {
            $XMLClassIDs{$_}
        } @{ $Restrictions{ClassIDs} };

        return if !@MatchingClasses;
    }

    my $ConfigItemIDs = $ConfigItemObject->ConfigItemSearchExtended(
        %Restrictions,
    );

    if ( ref $ConfigItemIDs ne 'ARRAY' ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'CMDBList: ConfigItemSearchExtended did not return an array reference.',
        );
        return;
    }

    my @Rows;

    CONFIGITEM:
    for my $ConfigItemID ( @{$ConfigItemIDs} ) {

        my $ConfigItem = $ConfigItemObject->ConfigItemGet(
            ConfigItemID => $ConfigItemID,
        );

        next CONFIGITEM if ref $ConfigItem ne 'HASH';

        my %RowData = (
            ConfigItemID     => $ConfigItemID,
            ConfigItemNumber => $ConfigItem->{Number}        // '',
            Name             => $ConfigItem->{Name}          // '',
            Class            => $ConfigItem->{Class}         // '',
            CurDeplState     => $ConfigItem->{CurDeplState}  // '',
            CurInciState     => $ConfigItem->{CurInciState}  // '',
            CreateTime       => $ConfigItem->{CreateTime}    // '',
            ChangeTime       => $ConfigItem->{ChangeTime}    // '',
            LastVersionID    => $ConfigItem->{LastVersionID} // '',
        );

        if ( $ConfigItem->{LastVersionID} ) {

            #
            # Get the current ConfigItem version including XMLData.
            #
            my $Version = $ConfigItemObject->VersionGet(
                VersionID  => $ConfigItem->{LastVersionID},
                XMLDataGet => 1,
            );

            if ( ref $Version eq 'HASH' ) {

                #
                # The ConfigItem name is a property of the version.
                #
                if ( defined $Version->{Name} ) {
                    $RowData{Name} = $Version->{Name};
                }

                my $ClassID = $ConfigItem->{ClassID};

                if (
                    $ClassID
                    && ref $Version->{XMLData} eq 'ARRAY'
                    && ref $Version->{XMLData}->[1] eq 'HASH'
                    && ref $Version->{XMLData}->[1]->{Version} eq 'ARRAY'
                    && ref $Version->{XMLData}->[1]->{Version}->[1] eq 'HASH'
                    )
                {
		#
		# This section of XMLData contains the ConfigItem
		# attribute values.
		#
                    my $CurrentXMLData = $Version->{XMLData}->[1]->{Version}->[1];

                    #
                    # Get the ConfigItem class definition.
                    #
                    my $Definition = $ConfigItemObject->DefinitionGet(
                        ClassID => $ClassID,
                    );

                    if (
                        ref $Definition eq 'HASH'
                        && ref $Definition->{DefinitionRef} eq 'ARRAY'
                        )
                    {
                        $Self->_XMLValuesGet(
                            Definition => $Definition->{DefinitionRef},
                            XMLData    => $CurrentXMLData,
                            RowData    => \%RowData,
                            ClassID    => $ClassID,
                            Prefix     => '',
                        );
                    }
                }
            }
        }

        my @ResultRow;

        ATTRIBUTE:
        for my $Attribute ( @{ $Self->_SortedAttributes() } ) {

            next ATTRIBUTE if !$SelectedAttributes{$Attribute};

            my $Value = $RowData{$Attribute};

            $Value = '' if !defined $Value;

            if (
                $Param{TimeZone}
                && $Value =~ m{
                    \A\d{4}-\d{2}-\d{2}
                    \s
                    \d{2}:\d{2}:\d{2}\z
                }xms
                )
            {
                my $StatsObject = $Kernel::OM->Get('Kernel::System::Stats');

                $Value = $StatsObject->_FromOTRSTimeZone(
                    String   => $Value,
                    TimeZone => $Param{TimeZone},
                );

                $Value .= ' (' . $Param{TimeZone} . ')';
            }

            push @ResultRow, $Value;
        }

        push @Rows, {
            SortValue => $RowData{$OrderBy} // '',
            Data      => \@ResultRow,
        };
    }

    if ( $Sort eq 'Down' ) {
        @Rows = sort {
            lc( $b->{SortValue} ) cmp lc( $a->{SortValue} )
        } @Rows;
    }
    else {
        @Rows = sort {
            lc( $a->{SortValue} ) cmp lc( $b->{SortValue} )
        } @Rows;
    }

    if ( !$Preview && $Limit && $Limit < @Rows ) {
        $#Rows = $Limit - 1;
    }

    if ($AddEnumeration) {

        my $Counter = 0;

        for my $Row (@Rows) {
            unshift @{ $Row->{Data} }, ++$Counter;
        }
    }

    return map { $_->{Data} } @Rows;
}

sub GetHeaderLine {
    my ( $Self, %Param ) = @_;

    my %SelectedAttributes = map { $_ => 1 }
        @{ $Param{XValue}{SelectedValues} || [] };

    my $LanguageObject = $Kernel::OM->Get('Kernel::Language');

    my $Attributes = $Self->_PrintAttributes();

    my @HeaderLine;

    ATTRIBUTE:
    for my $Attribute ( @{ $Self->_SortedAttributes() } ) {

        next ATTRIBUTE if !$SelectedAttributes{$Attribute};

        push @HeaderLine,
            $LanguageObject->Translate(
            $Attributes->{$Attribute} // $Attribute
            );
    }

    return \@HeaderLine;
}

sub ExportWrapper {
    my ( $Self, %Param ) = @_;

    return \%Param;
}

sub ImportWrapper {
    my ( $Self, %Param ) = @_;

    return \%Param;
}

sub _PrintAttributes {
    my $Self = shift;

    $Self->GetObjectAttributes()
        if !$Self->{PrintAttributes};

    return $Self->{PrintAttributes};
}

sub _SortedAttributes {
    my $Self = shift;

    $Self->GetObjectAttributes()
        if !$Self->{SortedAttributes};

    return $Self->{SortedAttributes};
}

sub _DefinitionAttributesAdd {
    my ( $Self, %Param ) = @_;

    return if ref $Param{XMLDefinition} ne 'ARRAY';
    return if ref $Param{PrintAttributes} ne 'HASH';
    return if ref $Param{Sorted} ne 'ARRAY';

    my $Prefix     = $Param{Prefix}     // '';
    my $PrefixName = $Param{PrefixName} // '';

    ITEM:
    for my $Item ( @{ $Param{XMLDefinition} } ) {

        next ITEM if ref $Item ne 'HASH';

        my $Key  = $Item->{Key}  // '';
        my $Name = $Item->{Name} // $Key;

        next ITEM if !$Key;

        my $FullKey = $Prefix
            ? $Prefix . '::' . $Key
            : $Key;

        my $FullName = $PrefixName
            ? $PrefixName . '::' . $Name
            : $Name;

        if ( $Item->{Searchable} ) {

            my $AttributeKey = 'XML::'
                . $Param{ClassID}
                . '::'
                . $FullKey;

            $Param{PrintAttributes}->{$AttributeKey} = $Param{ClassName} . '::' . $FullName;

            push @{ $Param{Sorted} }, $AttributeKey;
        }

        if ( ref $Item->{Sub} eq 'ARRAY' ) {
            $Self->_DefinitionAttributesAdd(
                %Param,
                XMLDefinition => $Item->{Sub},
                Prefix        => $FullKey,
                PrefixName    => $FullName,
            );
        }
    }

    return 1;
}

sub _XMLRestrictionAttributesAdd {
    my ( $Self, %Param ) = @_;

    return if ref $Param{ObjectAttributes} ne 'ARRAY';
    return if ref $Param{XMLDefinition} ne 'ARRAY';

    my $Prefix     = $Param{Prefix}     // '';
    my $PrefixName = $Param{PrefixName} // '';

    ITEM:
    for my $Item ( @{ $Param{XMLDefinition} } ) {

        next ITEM if ref $Item ne 'HASH';
        next ITEM if !$Item->{Searchable} && !$Item->{Sub};

        my $Key = $Prefix
            ? $Prefix . '::' . $Item->{Key}
            : $Item->{Key};

        my $Name = $PrefixName
            ? $PrefixName . '::' . $Item->{Name}
            : $Item->{Name};

        my $Attributes = $Kernel::OM->Get('Kernel::System::ITSMConfigItem')->XMLStatsAttributeCreate(
            Key  => $Key,
            Item => $Item,
            Name => $Name,
        );

        if (
            ref $Attributes eq 'ARRAY'
            && @{$Attributes}
            )
        {
            ATTRIBUTE:
            for my $Attribute ( @{$Attributes} ) {

                next ATTRIBUTE if ref $Attribute ne 'HASH';

		#
		# CMDBList is a list-type statistic.
		#
		# XML attributes of ConfigItem classes:
		# - are not exposed as separate X-axis elements,
		# - are not available as value series,
		# - remain available as restrictions.
		#
		# For column output, these attributes are added separately
		# to the printable attributes by _DefinitionAttributesAdd().
		#

                $Attribute->{UseAsXvalue}      = 0;
                $Attribute->{UseAsValueSeries} = 0;
                $Attribute->{UseAsRestriction} = 1;
            }

            push @{ $Param{ObjectAttributes} }, @{$Attributes};
        }
        if ( ref $Item->{Sub} eq 'ARRAY' ) {
            $Self->_XMLRestrictionAttributesAdd(
                ObjectAttributes => $Param{ObjectAttributes},
                XMLDefinition    => $Item->{Sub},
                Prefix           => $Key,
                PrefixName       => $Name,
            );
        }
    }

    return 1;
}

sub _XMLValuesGet {
    my ( $Self, %Param ) = @_;

    return if ref $Param{Definition} ne 'ARRAY';
    return if ref $Param{XMLData} ne 'HASH';
    return if ref $Param{RowData} ne 'HASH';
    return if !$Param{ClassID};

    my $Prefix = $Param{Prefix} // '';

    ITEM:
    for my $Item ( @{ $Param{Definition} } ) {

        next ITEM if ref $Item ne 'HASH';
        next ITEM if !$Item->{Key};

        my $Key = $Item->{Key};

        my $FullKey = $Prefix
            ? $Prefix . '::' . $Key
            : $Key;

        if (
            exists $Param{XMLData}->{$Key}
            && ref $Param{XMLData}->{$Key} eq 'ARRAY'
            )
        {
            my @Values;
            ENTRY:
            for my $Entry ( @{ $Param{XMLData}->{$Key} } ) {

                next ENTRY if ref $Entry ne 'HASH';

		#
		# Get Content using the same approach as
		# AgentITSMConfigItemPrint.
		#

                if (
                    exists $Entry->{Content}
                    && defined $Entry->{Content}
                    && !ref $Entry->{Content}
                    && $Entry->{Content} ne ''
                    )
                {
                    my $Value = $Kernel::OM->Get(
                        'Kernel::System::ITSMConfigItem'
                    )->XMLValueLookup(
                        Item  => $Item,
                        Value => $Entry->{Content},
                    );

                    if ( !defined $Value || ref $Value ) {
                        $Value = $Entry->{Content};
                    }

                    push @Values, $Value;
                }
            }

            if (@Values) {

                my $AttributeKey = 'XML::'
                    . $Param{ClassID}
                    . '::'
                    . $FullKey;

                $Param{RowData}->{$AttributeKey} = join ', ', @Values;
            }

		#
		# Process nested attributes recursively if the item
		# contains a Sub definition.
		#

            if ( ref $Item->{Sub} eq 'ARRAY' ) {
                SUBENTRY:
                for my $Entry ( @{ $Param{XMLData}->{$Key} } ) {

                    next SUBENTRY if ref $Entry ne 'HASH';

                    $Self->_XMLValuesGet(
                        Definition => $Item->{Sub},
                        XMLData    => $Entry,
                        RowData    => $Param{RowData},
                        ClassID    => $Param{ClassID},
                        Prefix     => $FullKey,
                    );
                }
            }
        }
    }

    return 1;
}
1;
