# --
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::DynamicField::Driver::ConfigItem;

use strict;
use warnings;
use utf8;

use Kernel::System::VariableCheck qw(:all);

use mro 'c3';

our @ObjectDependencies = (
    'Kernel::Output::HTML::Layout',
    'Kernel::System::GeneralCatalog',
    'Kernel::System::ITSMConfigItem',
    'Kernel::System::ITSMConfigItemCustomerCIs',
    'Kernel::System::Ticket',
    'Kernel::System::Web::Request',
);

sub ValueGet {
    my ( $Self, %Param ) = @_;

    $Param{DynamicFieldConfig}->{Config}->{PossibleValues} = $Self->PossibleValuesGet(%Param);

    return $Self->next::method(%Param);
}

sub ValueSet {
    my ( $Self, %Param ) = @_;

    $Param{DynamicFieldConfig}->{Config}->{PossibleValues} = $Self->PossibleValuesGet(%Param);

    return $Self->next::method(%Param);
}

sub ValueValidate {
    my ( $Self, %Param ) = @_;

    $Param{DynamicFieldConfig}->{Config}->{PossibleValues} = $Self->PossibleValuesGet(%Param);

    return $Self->next::method(%Param);
}

sub SearchSQLGet {
    my ( $Self, %Param ) = @_;

    $Param{DynamicFieldConfig}->{Config}->{PossibleValues} = $Self->PossibleValuesGet(%Param);

    return $Self->next::method(%Param);
}

sub SearchSQLOrderFieldGet {
    my ( $Self, %Param ) = @_;

    $Param{DynamicFieldConfig}->{Config}->{PossibleValues} = $Self->PossibleValuesGet(%Param);

    return $Self->next::method(%Param);
}

sub EditFieldRender {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # Initialize storage of additional dynamic fields in frontend, if configured.
    # Only dynamic fields of object type 'Ticket' are supported for this.
    if ( $Param{DynamicFieldConfig}->{ObjectType} eq 'Ticket' ) {
        my $AdditionalDFStorageConfig = $Param{DynamicFieldConfig}->{Config}->{AdditionalDFStorage};
        if ( IsArrayRefWithData($AdditionalDFStorageConfig) ) {
            my @AdditionalDFStorageConfigForFrontend = grep { $_->{Type} ne 'Backend' }
                @{$AdditionalDFStorageConfig};

            if (@AdditionalDFStorageConfigForFrontend) {
                my $DynamicFieldName = $Param{DynamicFieldConfig}->{Name};

                $LayoutObject->AddJSOnDocumentComplete(
                    Code => "Znuny.DynamicField.ConfigItem.InitAdditionalDFStorage('$DynamicFieldName');",
                );
            }
        }

        # Initialize live re-filtering of the config item list, if customer restriction is
        # enabled for the current interface. This is needed not only for the agent interface's
        # customer-selection widget, but in both interfaces whenever AJAXUpdate is active: any
        # ACL-driven field refresh (e.g. via BaseSelect's own change-triggered Core.AJAX.FormUpdate
        # call, used for Process Management activity dialogs in both interfaces) repopulates this
        # field with the unrestricted list, which must be corrected again afterwards.
        my $IsCustomerInterface = $Self->_IsCustomerInterface();

        my $RestrictionEnabled = $IsCustomerInterface
            ? (
            $Param{DynamicFieldConfig}->{Config}->{RestrictByCustomerIDCustomer}
                || $Param{DynamicFieldConfig}->{Config}->{RestrictByCustomerUserIDCustomer}
            )
            : (
            $Param{DynamicFieldConfig}->{Config}->{RestrictByCustomerIDAgent}
                || $Param{DynamicFieldConfig}->{Config}->{RestrictByCustomerUserIDAgent}
            );

        if ($RestrictionEnabled) {
            my $DynamicFieldName = $Param{DynamicFieldConfig}->{Name};

            $LayoutObject->AddJSOnDocumentComplete(
                Code => "Znuny.DynamicField.ConfigItem.InitCustomerRestriction('$DynamicFieldName');",
            );
        }
    }

    my $PossibleValues = $Self->PossibleValuesGet(
        %Param,
        RestrictByCustomer => 1,
    );

    $Param{DynamicFieldConfig}->{Config}->{PossibleValues} = $PossibleValues;

    # The base driver's EditFieldRender (Dropdown/Multiselect) does not look at
    # Config->{PossibleValues}; it uses PossibleValuesFilter, falling back to a fresh,
    # *unrestricted* PossibleValuesGet call otherwise. Route the restriction through
    # PossibleValuesFilter too (intersecting with any existing ACL-based filter), so it
    # actually takes effect in the rendered field instead of being silently discarded.
    if ( IsHashRefWithData( $Param{PossibleValuesFilter} ) ) {
        KEY:
        for my $Key ( sort keys %{ $Param{PossibleValuesFilter} } ) {
            next KEY if exists $PossibleValues->{$Key};
            delete $Param{PossibleValuesFilter}->{$Key};
        }
    }
    else {
        $Param{PossibleValuesFilter} = $PossibleValues;
    }

    return $Self->next::method(%Param);
}

sub EditFieldValueGet {
    my ( $Self, %Param ) = @_;

    $Param{DynamicFieldConfig}->{Config}->{PossibleValues} = $Self->PossibleValuesGet(%Param);

    return $Self->next::method(%Param);
}

sub EditFieldValueValidate {
    my ( $Self, %Param ) = @_;

    $Param{DynamicFieldConfig}->{Config}->{PossibleValues} = $Self->PossibleValuesGet(%Param);

    return $Self->next::method(%Param);
}

sub FieldValueValidate {
    my ( $Self, %Param ) = @_;

    $Param{DynamicFieldConfig}->{Config}->{PossibleValues} = $Self->PossibleValuesGet(%Param);

    return $Self->next::method(%Param);
}

sub DisplayValueRender {
    my ( $Self, %Param ) = @_;

    $Param{DynamicFieldConfig}->{Config}->{PossibleValues} = $Self->PossibleValuesGet(%Param);

    return $Self->next::method(%Param);
}

sub SearchFieldRender {
    my ( $Self, %Param ) = @_;

    $Param{DynamicFieldConfig}->{Config}->{PossibleValues} = $Self->PossibleValuesGet(%Param);

    return $Self->next::method(%Param);
}

sub SearchFieldValueGet {
    my ( $Self, %Param ) = @_;

    $Param{DynamicFieldConfig}->{Config}->{PossibleValues} = $Self->PossibleValuesGet(%Param);

    return $Self->next::method(%Param);
}

sub SearchFieldParameterBuild {
    my ( $Self, %Param ) = @_;

    $Param{DynamicFieldConfig}->{Config}->{PossibleValues} = $Self->PossibleValuesGet(%Param);

    return $Self->next::method(%Param);
}

sub StatsFieldParameterBuild {
    my ( $Self, %Param ) = @_;

    $Param{DynamicFieldConfig}->{Config}->{PossibleValues} = $Self->PossibleValuesGet(%Param);

    return $Self->next::method(%Param);
}

sub StatsSearchFieldParameterBuild {
    my ( $Self, %Param ) = @_;

    $Param{DynamicFieldConfig}->{Config}->{PossibleValues} = $Self->PossibleValuesGet(%Param);

    return $Self->next::method(%Param);
}

sub ReadableValueRender {
    my ( $Self, %Param ) = @_;

    $Param{DynamicFieldConfig}->{Config}->{PossibleValues} = $Self->PossibleValuesGet(%Param);

    return $Self->next::method(%Param);
}

sub TemplateValueTypeGet {
    my ( $Self, %Param ) = @_;

    $Param{DynamicFieldConfig}->{Config}->{PossibleValues} = $Self->PossibleValuesGet(%Param);

    return $Self->next::method(%Param);
}

sub RandomValueSet {
    my ( $Self, %Param ) = @_;

    $Param{DynamicFieldConfig}->{Config}->{PossibleValues} = $Self->PossibleValuesGet(%Param);

    return $Self->next::method(%Param);
}

sub ObjectMatch {
    my ( $Self, %Param ) = @_;

    $Param{DynamicFieldConfig}->{Config}->{PossibleValues} = $Self->PossibleValuesGet(%Param);

    return $Self->next::method(%Param);
}

sub HistoricalValuesGet {
    my ( $Self, %Param ) = @_;

    $Param{DynamicFieldConfig}->{Config}->{PossibleValues} = $Self->PossibleValuesGet(%Param);

    return $Self->next::method(%Param);
}

sub ValueLookup {
    my ( $Self, %Param ) = @_;

    $Param{DynamicFieldConfig}->{Config}->{PossibleValues} = $Self->PossibleValuesGet(%Param);

    return $Self->next::method(%Param);
}

sub BuildSelectionDataGet {
    my ( $Self, %Param ) = @_;

    $Param{DynamicFieldConfig}->{Config}->{PossibleValues} = $Self->PossibleValuesGet(%Param);

    return $Self->next::method(%Param);
}

sub ColumnFilterValuesGet {
    my ( $Self, %Param ) = @_;

    $Param{DynamicFieldConfig}->{Config}->{PossibleValues} = $Self->PossibleValuesGet(%Param);

    return $Self->next::method(%Param);
}

sub PossibleValuesGet {
    my ( $Self, %Param ) = @_;

    my $ConfigItemObject     = $Kernel::OM->Get('Kernel::System::ITSMConfigItem');
    my $GeneralCatalogObject = $Kernel::OM->Get('Kernel::System::GeneralCatalog');

    # Add empty value, none of the config item fields can have a default or pre-selected value
    # because the selectable values may change depending on deployment state.
    my %PossibleValues = (
        '' => '-',
    );

    my $Class = $Param{DynamicFieldConfig}->{Config}->{ConfigItemClass};
    return \%PossibleValues if !$Class;

    # check all CI classes
    my $HashRef = $GeneralCatalogObject->ItemList(
        Class => 'ITSM::ConfigItem::Class',
    );
    my %Classes = reverse %{ $HashRef || {} };
    return \%PossibleValues if !$Classes{$Class};

    my $ConfigItemListRef = [];

    # limit selectable config items to those which have one of the configured
    # deployment states
    my $DeplStates = $Param{DynamicFieldConfig}->{Config}->{DeplStates} // [];
    if ( IsArrayRefWithData($DeplStates) ) {
        my $DeplStateNameByID = $GeneralCatalogObject->ItemList(
            Class => 'ITSM::ConfigItem::DeploymentState',
        );
        my %DeplStateIDByName = reverse %{$DeplStateNameByID};

        my %DeplStates   = map  { $_ => 1 } @{$DeplStates};
        my @DeplStateIDs = grep { defined $_ }
            map { $DeplStateIDByName{$_} }
            keys %DeplStates;

        my $ConfigItemIDs = $ConfigItemObject->ConfigItemSearch(
            ClassIDs     => [ $Classes{$Class}, ],
            DeplStateIDs => \@DeplStateIDs,
        );

        for my $ConfigItemID ( @{$ConfigItemIDs} ) {
            my $LastVersion = $ConfigItemObject->VersionGet(
                ConfigItemID => $ConfigItemID,
                XMLDataGet   => 0,
            );

            push @{$ConfigItemListRef}, $LastVersion;
        }
    }
    else {
        # get all config items of that class
        $ConfigItemListRef = $ConfigItemObject->ConfigItemResultList(
            ClassID => $Classes{$Class},
            Start   => 0,
            Limit   => 1_000_000,
        );
    }

    CONFIGITEM:
    for my $ConfigItem ( @{ $ConfigItemListRef || {} } ) {
        $PossibleValues{ $ConfigItem->{ConfigItemID} } = $ConfigItem->{Name};
    }

    # Restricting by customer is only relevant when rendering the list of config items for
    # selection (see EditFieldRender). All other callers of PossibleValuesGet (validation,
    # historical values, stats, ObjectMatch, ...) must keep seeing the full, unrestricted list.
    if ( $Param{RestrictByCustomer} ) {
        $Self->_RestrictPossibleValuesByCustomer(
            %Param,
            PossibleValues => \%PossibleValues,
        );
    }

    return \%PossibleValues;
}

# Removes config items from the given possible values hash ref that do not belong to the current
# customer (ID and/or user), based on the field's RestrictByCustomerID* / RestrictByCustomerUserID*
# config (chosen separately for the agent and customer interface).
sub _RestrictPossibleValuesByCustomer {
    my ( $Self, %Param ) = @_;

    my $PossibleValues = $Param{PossibleValues};
    my $Config         = $Param{DynamicFieldConfig}->{Config} // {};

    my ( $RestrictByCustomerID, $RestrictByCustomerUserID ) = $Self->_IsCustomerInterface()
        ? ( $Config->{RestrictByCustomerIDCustomer}, $Config->{RestrictByCustomerUserIDCustomer} )
        : ( $Config->{RestrictByCustomerIDAgent}, $Config->{RestrictByCustomerUserIDAgent} );

    return if !$RestrictByCustomerID && !$RestrictByCustomerUserID;

    my ( $CustomerID, $CustomerUserID ) = $Self->_GetCurrentCustomerContext(%Param);

    my $ITSMConfigItemCustomerCIsObject = $Kernel::OM->Get('Kernel::System::ITSMConfigItemCustomerCIs');

    my %AllowedConfigItemID;

    if ( $RestrictByCustomerUserID && $CustomerUserID ) {
        my @ConfigItemIDs = $ITSMConfigItemCustomerCIsObject->GetCustomerUserCIs(
            CustomerUserID => $CustomerUserID,
        );
        $AllowedConfigItemID{$_} = 1 for @ConfigItemIDs;
    }

    if ( $RestrictByCustomerID && $CustomerID ) {
        my @ConfigItemIDs = $ITSMConfigItemCustomerCIsObject->GetCustomerCIs(
            CustomerID => $CustomerID,
        );
        $AllowedConfigItemID{$_} = 1 for @ConfigItemIDs;
    }

    # Without any known customer context (e.g. a new ticket where no customer has been picked
    # yet) nothing is allowed, keeping only the empty '-' entry until the context is known.
    CONFIGITEMID:
    for my $ConfigItemID ( sort keys %{$PossibleValues} ) {
        next CONFIGITEMID if !$ConfigItemID;
        next CONFIGITEMID if $AllowedConfigItemID{$ConfigItemID};

        delete $PossibleValues->{$ConfigItemID};
    }

    return 1;
}

# Returns true if the current request is being processed in the customer interface.
sub _IsCustomerInterface {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    return ( ( $LayoutObject->{SessionSource} // '' ) eq 'CustomerInterface' ) ? 1 : 0;
}

# Determines the CustomerID and CustomerUserID that should be used to restrict the config item
# list, in this order of precedence:
# 1. Explicit CustomerID / CustomerUserID given in %Param (used by the AJAX live-update handler,
#    which already knows the values selected on-screen).
# 2. The ticket referenced by a TicketID request parameter (existing ticket screens, both agent
#    and customer interface).
# 3. In the customer interface, the logged in customer user (covers new ticket creation, where the
#    customer is always the logged in user).
# 4. In the agent interface, the customer currently selected on a new-ticket screen (read directly
#    from the customer search widget's request parameters).
sub _GetCurrentCustomerContext {
    my ( $Self, %Param ) = @_;

    my $TicketObject = $Kernel::OM->Get('Kernel::System::Ticket');

    if ( defined $Param{CustomerID} || defined $Param{CustomerUserID} ) {

        return (
            $Param{CustomerID} // '',
            $Param{CustomerUserID} // '', 1
        );
    }

    my $ParamObject = $Param{ParamObject} || $Kernel::OM->Get('Kernel::System::Web::Request');

    my $TicketID = $ParamObject->GetParam( Param => 'TicketID' );

    if ($TicketID) {
        my %Ticket = $TicketObject->TicketGet(
            TicketID => $TicketID,
            UserID   => 1,
        );

        return (
            $Ticket{CustomerID} // '',
            $Ticket{CustomerUserID} // '', 1
        );
    }

    if ( $Self->_IsCustomerInterface() ) {
        my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

        return (
            $LayoutObject->{UserCustomerID} // '',
            $LayoutObject->{UserID} // '', 1
        );
    }

    # Agent interface, new ticket not yet created: read from the customer selection widget.
    my $CustomerUserID = $ParamObject->GetParam( Param => 'SelectedCustomerUser' )
        || $ParamObject->GetParam( Param => 'PreSelectedCustomerUser' )
        || '';
    my $CustomerID = $ParamObject->GetParam( Param => 'CustomerID' ) || '';

    return ( $CustomerID, $CustomerUserID );
}

1;
