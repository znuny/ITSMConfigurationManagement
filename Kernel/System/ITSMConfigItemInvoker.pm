# --
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::ITSMConfigItemInvoker;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::System::CustomerCompany',
    'Kernel::System::CustomerUser',
    'Kernel::System::GeneralCatalog',
    'Kernel::System::ITSMConfigItem',
    'Kernel::System::Log',
    'Kernel::System::XML',
);

use Kernel::System::VariableCheck qw(:all);

=head1 NAME

Kernel::System::ITSMConfigItemInvoker

=head1 PUBLIC INTERFACE

=head2 new()

    Don't use the constructor directly, use the ObjectManager instead:

    my $ITSMConfigItemInvokerObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItemInvoker');

=cut

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

=head2 GetConfigItemData()

    Returns hash with complete data of config item with given ID.

    my $ConfigItemData = $ITSMConfigItemInvokerObject->GetConfigItemData(
        ConfigItemID => 21,

        # OR
        VersionID => 52,

        Event => 'DeploymentStateUpdate', # optional; Will include data of previous version for certain events.
    );

=cut

sub GetConfigItemData {
    my ( $Self, %Param ) = @_;

    my $LogObject        = $Kernel::OM->Get('Kernel::System::Log');
    my $ConfigItemObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItem');

    if (
        ( !defined $Param{ConfigItemID} && !defined $Param{VersionID} )
        || ( defined $Param{ConfigItemID} && defined $Param{VersionID} )
        )
    {
        $LogObject->Log(
            Priority => 'error',
            Message  => 'Either parameter ConfigItemID or Version ID has to be given.',
        );
        return;
    }

    my $CurrentConfigItemVersion = $ConfigItemObject->VersionGet(
        ConfigItemID => $Param{ConfigItemID},
        VersionID    => $Param{VersionID},
        XMLDataGet   => 1,
    );
    return if !IsHashRefWithData($CurrentConfigItemVersion);

    my %ConfigItemData;
    $ConfigItemData{XMLData} ||= {};
    if ( IsHashRefWithData( $CurrentConfigItemVersion->{XMLData}->[1]->{Version}->[1] ) ) {
        $Self->_XML2Data(
            Result     => $ConfigItemData{XMLData},
            Data       => $CurrentConfigItemVersion->{XMLData}->[1]->{Version}->[1],
            Definition => $CurrentConfigItemVersion->{XMLDefinition},
        );
    }

    for my $Field (qw(ConfigItemID Name ClassID Class DefinitionID DeplStateID DeplState InciStateID InciState)) {
        $ConfigItemData{$Field} = $CurrentConfigItemVersion->{$Field};
    }

    return \%ConfigItemData if !defined $Param{Event};

    my %EventsToIncludePreviousVersion = (
        DeploymentStateUpdate => 1,
        IncidentStateUpdate   => 1,
        NameUpdate            => 1,
        ValueUpdate           => 1,
        VersionCreate         => 1,
    );

    return \%ConfigItemData if !$EventsToIncludePreviousVersion{ $Param{Event} };

    my $ConfigItemVersions = $ConfigItemObject->VersionList(
        ConfigItemID => $Param{ConfigItemID},
    );
    return if !IsArrayRefWithData($ConfigItemVersions);
    return if @{$ConfigItemVersions} < 2;

    my $PreviousVersionID = $ConfigItemVersions->[-2];

    $ConfigItemData{PreviousConfigItemVersion} = $Self->GetConfigItemData(
        VersionID => $PreviousVersionID,
    );

    if ( $Param{Event} eq 'DeploymentStateUpdate' ) {
        $ConfigItemData{DeploymentStateUpdate} = {
            Old => {
                ID      => $ConfigItemData{PreviousConfigItemVersion}->{DeplStateID},
                Content => $ConfigItemData{PreviousConfigItemVersion}->{DeplState},
            },
            New => {
                ID      => $ConfigItemData{DeplStateID},
                Content => $ConfigItemData{DeplState},
            },
        };
    }
    elsif ( $Param{Event} eq 'IncidentStateUpdate' ) {
        $ConfigItemData{IncidentStateUpdate} = {
            Old => {
                ID      => $ConfigItemData{PreviousConfigItemVersion}->{InciStateID},
                Content => $ConfigItemData{PreviousConfigItemVersion}->{InciState},
            },
            New => {
                ID      => $ConfigItemData{InciStateID},
                Content => $ConfigItemData{InciState},
            },
        };
    }
    elsif ( $Param{Event} eq 'NameUpdate' ) {
        $ConfigItemData{NameUpdate} = {
            Old => {
                Content => $ConfigItemData{PreviousConfigItemVersion}->{Name},
            },
            New => {
                Content => $ConfigItemData{Name},
            },
        };
    }
    elsif ( $Param{Event} eq 'ValueUpdate' ) {
        my $ChangedConfigItemValues = $Self->_FindChangedConfigItemValues(
            ConfigItemID => $Param{ConfigItemID},
        );

        $ConfigItemData{ValueUpdate} = $ChangedConfigItemValues // {};
    }

    return \%ConfigItemData;
}

=head2 _XML2Data()

    Turns XML into Perl structure.

    my $Success = $ITSMConfigItemInvokerObject->_XML2Data(
        Parent          => $Identifier,          # optional: contains the field name of the parent XML
        Result          => $Result,              # contains the reference to the result hash
        Data            => $Data{$Field}->[1],   # contains the XML hash to be parsed
    );

    Returns true value on success.

=cut

sub _XML2Data {
    my ( $Self, %Param ) = @_;

    my $Result = $Param{Result};
    my $Parent = $Param{Parent} || '';
    my %Data   = %{ $Param{Data} || {} };

    FIELD:
    for my $Field ( sort keys %Data ) {
        next FIELD if !IsArrayRefWithData( $Data{$Field} );

        my $FieldDefinitionIndex = 0;
        my $FieldType;

        FIELDDEFINITION:
        for my $FieldDefinition ( @{ $Param{Definition} // [] } ) {
            if ( defined $FieldDefinition->{Key} && $FieldDefinition->{Key} eq $Field ) {
                $FieldType = $FieldDefinition->{Input}->{Type};
                last FIELDDEFINITION;
            }

            $FieldDefinitionIndex++;
        }

        $Result->{$Field} = [];

        for my $Index ( 1 .. $#{ $Data{$Field} } ) {
            my $Value = $Data{$Field}->[$Index]->{Content};

            my $CurrentResult = {};

            my $Definition = $Param{Definition}->[$FieldDefinitionIndex]->{Sub} // [];

            $Self->_XML2Data(
                %Param,
                Parent     => $Field,
                Result     => $CurrentResult,
                Data       => $Data{$Field}->[$Index],
                Definition => $Definition,
            );

            if ( defined $Value ) {
                $CurrentResult->{Content} = $Value;

                my $ReadableValue = $Self->_GetReadableValue(
                    Value     => $Value,
                    FieldType => $FieldType,
                );

                if ( $ReadableValue ne $Value ) {
                    $CurrentResult->{ReadableValue} = $ReadableValue;
                }

                if ( keys %{$CurrentResult} ) {
                    push @{ $Result->{$Field} }, $CurrentResult;
                }
            }
        }
    }

    return 1;
}

=head2 _GetReadableValue()

    Maps value of certain field types (ID) to a value that can be read (name, text, etc.).

    my $ReadableValue = $ITSMConfigItemInvokerObject->_GetReadableValue(
        Value     => 4,
        FieldType => 'GeneralCatalog',
    );

    Returns the readable value depending on the field type or the original value
    if no readable value could be determined.

=cut

sub _GetReadableValue {
    my ( $Self, %Param ) = @_;

    my $GeneralCatalogObject  = $Kernel::OM->Get('Kernel::System::GeneralCatalog');
    my $CustomerCompanyObject = $Kernel::OM->Get('Kernel::System::CustomerCompany');
    my $CustomerUserObject    = $Kernel::OM->Get('Kernel::System::CustomerUser');

    my $Value = $Param{Value};

    return $Value if !defined $Param{Value};
    return $Value if !length $Param{Value};

    return $Value if !defined $Param{FieldType};
    return $Value if !length $Param{FieldType};

    my $ReadableValue = $Value;

    if ( $Param{FieldType} eq 'GeneralCatalog' ) {
        my $GeneralCatalogItemData = $GeneralCatalogObject->ItemGet(
            ItemID => $Value,
        );
        return $Value if !IsHashRefWithData($GeneralCatalogItemData);
        return $Value if !defined $GeneralCatalogItemData->{Name};

        $ReadableValue = $GeneralCatalogItemData->{Name};
    }
    elsif ( $Param{FieldType} eq 'CustomerCompany' ) {
        my %CustomerCompany = $CustomerCompanyObject->CustomerCompanyGet(
            CustomerID => $Value,
        );
        return $Value if !%CustomerCompany;

        delete $CustomerCompany{Config};
        delete $CustomerCompany{CompanyConfig};

        $ReadableValue = \%CustomerCompany;
    }
    elsif ( $Param{FieldType} eq 'Customer' ) {
        my %CustomerUser = $CustomerUserObject->CustomerUserDataGet(
            User => $Value,
        );
        return $Value if !%CustomerUser;

        delete $CustomerUser{Config};
        delete $CustomerUser{CompanyConfig};

        $ReadableValue = \%CustomerUser;
    }

    return $ReadableValue;
}

=head2 _FindChangedConfigItemValues()

The following function is based on Kernel::System::ITSMConfigurationManagement::_FindChangedXMLValues()

Origin: ITSMConfigurationManagement - f5afe974d300056e368a24237962d10bf25f1cd0 - Kernel/System/ITSMConfigItem/Version.pm
Copyright (C) 2001-2021 OTRS AG, https://otrs.com/

Compares XML data of current config item version with the previous one (if one exists).

    my $ChangedConfigItemValues = $ITSMConfigItemInvokerObject->_FindChangedConfigItemValues(
        ConfigItemID => 123,
    );

Returns:

    my $ChangedConfigItemValues = {
        'NIC::2::IPoverDHCP::1' => {
            New => {
                Content       => '38',
                ReadableValue => 'No',
            },
            Old => {
                Content => '',
            },
        },
    };

=cut

sub _FindChangedConfigItemValues {
    my ( $Self, %Param ) = @_;

    my $LogObject        = $Kernel::OM->Get('Kernel::System::Log');
    my $ConfigItemObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItem');
    my $XMLObject        = $Kernel::OM->Get('Kernel::System::XML');

    NEEDED:
    for my $Needed (qw(ConfigItemID)) {
        next NEEDED if $Param{$Needed};

        $LogObject->Log(
            Priority => 'error',
            Message  => "Need $Needed!",
        );
        return;
    }

    my $Versions = $ConfigItemObject->VersionList(
        ConfigItemID => $Param{ConfigItemID},
    );

    return if !@{$Versions};
    return if @{$Versions} < 2;

    my $PreviousVersion = $ConfigItemObject->VersionGet(
        VersionID => $Versions->[-2],
    );
    return if !IsHashRefWithData($PreviousVersion);

    my $CurrentVersion = $ConfigItemObject->VersionGet(
        VersionID => $Versions->[-1],
    );
    return if !IsHashRefWithData($CurrentVersion);

    my $CurrentXMLData  = $CurrentVersion->{XMLData};
    my $PreviousXMLData = $PreviousVersion->{XMLData};

    my $Definition = $CurrentVersion->{XMLDefinition};

    # Get all tag keys in current and previous XML data.
    # Use a side effect of XMLHash2D() which adds the tag keys to the passed in data structure.
    $XMLObject->XMLHash2D( XMLHash => $CurrentXMLData );
    my @TagKeys = $ConfigItemObject->_GrabTagKeys(
        Data => [
            $PreviousXMLData,
            $CurrentXMLData,
        ],
    );

    my %UniqueTagKeys = map { $_ => 1 } @TagKeys;

    my %ChangedConfigItemValues;
    my %SuppressVersionAdd;

    TAGKEY:
    for my $TagKey ( sort keys %UniqueTagKeys ) {
        my $CurrentContent  = eval '$CurrentXMLData->' . $TagKey . '->{Content}'  || '';    ## no critic
        my $PreviousContent = eval '$PreviousXMLData->' . $TagKey . '->{Content}' || '';    ## no critic

        next TAGKEY if $CurrentContent eq $PreviousContent;

        # Remove leading 'Version' key.
        ( my $HashKey = $TagKey ) =~ s{\A\[\d+\]\{'Version'\}\[\d+\]}{};

        # Remove {''} around keys.
        $HashKey =~ s{(\{'|'\})}{}g;

        # Substitute [1] (index) with ::1::
        $HashKey =~ s{\[(\d+)\]}{::$1::}g;

        # Remove trailing ::
        $HashKey =~ s{::\z}{};

        $ChangedConfigItemValues{$HashKey} = {
            Old => {
                Content => $PreviousContent,
            },
            New => {
                Content => $CurrentContent,
            },
        };

        # Check for general catalog entry and add its name.
        ( my $AttributePath = $HashKey ) =~ s{::\d+}{}g;
        next TAGKEY if !defined $AttributePath;
        next TAGKEY if !length $AttributePath;

        my $AttributeInfo = $ConfigItemObject->DefinitionAttributeInfo(
            AttributePath => $AttributePath,
            Definition    => $Definition,
        );
        next TAGKEY if !IsHashRefWithData($AttributeInfo);

        my $PreviousReadableValue = $Self->_GetReadableValue(
            Value     => $PreviousContent,
            FieldType => $AttributeInfo->{Input}->{Type} // '',
        );

        my $CurrentReadableValue = $Self->_GetReadableValue(
            Value     => $CurrentContent,
            FieldType => $AttributeInfo->{Input}->{Type} // '',
        );

        if ( $PreviousReadableValue ne $PreviousContent ) {
            $ChangedConfigItemValues{$HashKey}->{Old}->{ReadableValue} = $PreviousReadableValue;
        }

        if ( $CurrentReadableValue ne $CurrentContent ) {
            $ChangedConfigItemValues{$HashKey}->{New}->{ReadableValue} = $CurrentReadableValue;
        }
    }

    return \%ChangedConfigItemValues;
}

1;
