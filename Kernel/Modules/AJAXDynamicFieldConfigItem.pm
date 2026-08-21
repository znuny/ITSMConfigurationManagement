# --
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AJAXDynamicFieldConfigItem;

use strict;
use warnings;
use utf8;

use Kernel::System::VariableCheck qw(:all);

our @ObjectDependencies = (
    'Kernel::Output::HTML::Layout',
    'Kernel::System::Log',
    'Kernel::System::Web::Request',
    'Kernel::System::DynamicField',
    'Kernel::System::DynamicField::Backend',
    'Kernel::System::DynamicField::ConfigItem',
);

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $LogObject                    = $Kernel::OM->Get('Kernel::System::Log');
    my $LayoutObject                 = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject                  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $DynamicFieldConfigItemObject = $Kernel::OM->Get('Kernel::System::DynamicField::ConfigItem');
    my $DynamicFieldObject           = $Kernel::OM->Get('Kernel::System::DynamicField');
    my $DynamicFieldBackendObject    = $Kernel::OM->Get('Kernel::System::DynamicField::Backend');

    if ( !$Self->{Subaction} ) {
        $LogObject->Log(
            Priority => 'error',
            Message  => 'Parameter Subaction is missing.',
        );

        return;
    }

    my $Data;

    if ( $Self->{Subaction} eq 'GetAdditionalDFStorageData' ) {
        my $SourceDynamicFieldName = $ParamObject->GetParam( Param => 'SourceDynamicFieldName' );
        if ( !defined $SourceDynamicFieldName || !length $SourceDynamicFieldName ) {
            $LogObject->Log(
                Priority => 'error',
                Message  => 'Parameter SourceDynamicFieldName is missing.',
            );

            return;
        }

        my @SelectedConfigItemIDs = $ParamObject->GetArray(
            Param => 'SelectedConfigItemIDs[]',
            Raw   => 1,
        );

        # If no config item IDs were given, the array contains one element with an empty string.
        # Remove it.
        @SelectedConfigItemIDs = grep { defined $_ && length $_ } @SelectedConfigItemIDs;

        $Data = $DynamicFieldConfigItemObject->GetAdditionalDFStorageData(
            SourceDynamicFieldName => $SourceDynamicFieldName,
            SelectedConfigItemIDs  => \@SelectedConfigItemIDs,
            StorageType            => 'Frontend',
            UserID                 => $Self->{UserID},
        );
    }
    elsif ( $Self->{Subaction} eq 'GetPossibleValues' ) {

        my $DynamicFieldName = $ParamObject->GetParam( Param => 'DynamicFieldName' );

        if ( !defined $DynamicFieldName || !length $DynamicFieldName ) {
            $LogObject->Log(
                Priority => 'error',
                Message  => 'GetPossibleValues: Parameter DynamicFieldName is missing.',
            );

            return;
        }

        my $DynamicFieldConfig = $DynamicFieldObject->DynamicFieldGet(
            Name => $DynamicFieldName,
        );

        if ( !IsHashRefWithData($DynamicFieldConfig) ) {
            $LogObject->Log(
                Priority => 'error',
                Message  => "Could not get config for dynamic field $DynamicFieldName.",
            );

            return;
        }

        # Only trust client-supplied CustomerID/CustomerUserID from the agent interface, where the
        # agent is picking the ticket's customer. In the customer interface, always fall back to
        # the logged in customer's own identity (handled by the driver) to prevent a customer from
        # querying another customer's config items by passing arbitrary values here.
        my %CustomerOverride;
        if ( ( $LayoutObject->{SessionSource} // '' ) ne 'CustomerInterface' ) {
            my $CustomerID     = $ParamObject->GetParam( Param => 'CustomerID' )     // '';
            my $CustomerUserID = $ParamObject->GetParam( Param => 'CustomerUserID' ) // '';

            %CustomerOverride = (
                CustomerID     => $CustomerID,
                CustomerUserID => $CustomerUserID,
            );
        }

        my $PossibleValues = $DynamicFieldBackendObject->PossibleValuesGet(
            DynamicFieldConfig => $DynamicFieldConfig,
            RestrictByCustomer => 1,
            %CustomerOverride,
        );

        # Return as a sorted array of [ Key, Value ] pairs so the option order survives the
        # JSON round trip (the empty '-' entry is always sorted first).
        $Data = [
            sort { ( $a->[0] eq '' ) ? -1 : ( $b->[0] eq '' ) ? 1 : ( $a->[1] cmp $b->[1] ) }
            map  { [ $_, $PossibleValues->{$_} ] } keys %{ $PossibleValues || {} }
        ];
    }

    my $JSON = $LayoutObject->JSONEncode(
        Data => $Data,
    );

    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSON // '[]',
        Type        => 'inline',
        NoCache     => 1,
    );
}

1;
