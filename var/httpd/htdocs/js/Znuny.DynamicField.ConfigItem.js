// --
// Copyright (C) 2021 Znuny GmbH, https://znuny.org/
// --
// This software comes with ABSOLUTELY NO WARRANTY. For details, see
// the enclosed file COPYING for license information (AGPL). If you
// did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
// --

"use strict";

var Znuny = Znuny || {};
var Core = Core || {};
/**
 * @namespace
 * @exports TargetNS as Znuny.DynamicField.ConfigItem
 * @description
 *      This namespace contains the special functions for DynamicFieldConfigItem.
 */
Znuny.DynamicField.ConfigItem = (function (TargetNS) {

    var CustomerRestrictionInitialized = {};
    var LastKnownPossibleValues = {};

    /**
     * @name InitAdditionalDFStorage
     * @memberof Znuny.DynamicField.ConfigItem.InitAdditionalDFStorage
     * @function
     * @param {String} DynamicFieldName - Name of dynamic field which contains the config item selection.
     * @description
     *      Initializes additional dynamic field storage for selection of config items.
     */

    TargetNS.InitAdditionalDFStorage = function (DynamicFieldName) {
        $('#DynamicField_' + DynamicFieldName).on('change', function() {
            FillAdditionalDynamicFields(DynamicFieldName);
        });
    }

    /**
     * @name InitCustomerRestriction
     * @memberof Znuny.DynamicField.ConfigItem.InitCustomerRestriction
     * @function
     * @param {String} DynamicFieldName - Name of dynamic field which contains the config item selection.
     * @description
     *      Re-fetches the (customer-restricted) list of selectable config items whenever the
     *      ticket customer changes on-screen (agent interface, e.g. during new ticket creation,
     *      where no TicketID exists yet to derive the customer from), and re-applies the last
     *      known correct list whenever any ACL-driven field refresh repopulates this field with
     *      the unrestricted list (both interfaces, e.g. Process Management activity dialogs).
     */

    TargetNS.InitCustomerRestriction = function (DynamicFieldName) {
        if (CustomerRestrictionInitialized[DynamicFieldName]) {
            return;
        }
        CustomerRestrictionInitialized[DynamicFieldName] = true;

        // Seed the cache from the field's current (correctly restricted, server-rendered)
        // options, so it is available to reapply synchronously before the very first generic
        // update ever fires.
        CacheCurrentPossibleValues(DynamicFieldName);

        Core.App.Subscribe('Event.Agent.CustomerSearch.GetCustomerInfo.Callback', function () {
            UpdatePossibleValuesByCustomer(DynamicFieldName);
        });

        // Changing the customer, or any other field in the same dialog, also triggers Znuny's
        // generic ACL-driven field refresh (Core.AJAX.FormUpdate), which repopulates this same
        // field with the *unrestricted* list. Re-fetching the restricted list over the network
        // to correct this leaves a visible window (a full extra round trip) during which the
        // wrong options are shown and selectable. Reapply the last known correct list from the
        // local cache instead: this runs synchronously, in the same tick as the generic update,
        // so the incorrect state is never actually rendered to the user.
        Core.App.Subscribe('Event.AJAX.FormUpdate.Callback', function () {
            if (!ReapplyCachedPossibleValues(DynamicFieldName)) {
                UpdatePossibleValuesByCustomer(DynamicFieldName);
            }
        });
    }

    function CacheCurrentPossibleValues(DynamicFieldName) {
        var $Select = $('#DynamicField_' + DynamicFieldName);

        if (!$Select.length) {
            return;
        }

        LastKnownPossibleValues[DynamicFieldName] = $Select.find('option').map(function () {
            return [ [ this.value, this.text ] ];
        }).get();
    }

    function ReapplyCachedPossibleValues(DynamicFieldName) {
        var Cached = LastKnownPossibleValues[DynamicFieldName];

        if (!Cached) {
            return false;
        }

        ApplyPossibleValues(DynamicFieldName, Cached);

        return true;
    }

    function ApplyPossibleValues(DynamicFieldName, Response) {

        // Re-query the field instead of reusing a reference captured earlier: a concurrent
        // update (e.g. the generic AJAXUpdate cascade also triggered by the customer/field
        // change) may have replaced the element in the meantime, which would leave an earlier
        // reference pointing at a detached, no-longer-visible node.
        var $Select = $('#DynamicField_' + DynamicFieldName),
            CurrentValues;

        if (!Response || !$Select.length) {
            return;
        }

        CurrentValues = Znuny.Form.Input.Get('DynamicField_' + DynamicFieldName);
        if (typeof(CurrentValues) === 'string') {
            CurrentValues = [CurrentValues];
        }
        CurrentValues = CurrentValues || [];

        $Select.empty();

        $.each(Response, function (Index, Pair) {
            var $Option = $('<option/>').val(Pair[0]).text(Pair[1]);

            if ($.inArray(String(Pair[0]), CurrentValues) > -1) {
                $Option.prop('selected', true);
            }

            $Select.append($Option);
        });

        if ($Select.hasClass('Modernize')) {

            // The 'redraw.InputField' event only refreshes the Modernized widget's internal
            // option list; it does not reliably resync the visible search/selection UI in
            // every state. Force a full rebuild of the widget instead: drop its existing
            // wrapper and re-run InitSelect so the visible field is guaranteed to reflect the
            // freshly loaded options.
            $Select.prev('.InputField_Container').remove();
            $Select.removeData('modernized');
            Core.UI.InputFields.InitSelect($Select, { Force: true });
        }
    }

    function UpdatePossibleValuesByCustomer(DynamicFieldName) {
        var Data = {
            Action:           'AJAXDynamicFieldConfigItem',
            Subaction:        'GetPossibleValues',
            DynamicFieldName: DynamicFieldName,
            CustomerUserID:   $('#SelectedCustomerUser').val() || '',
            CustomerID:       $('#CustomerID').val() || '',
        };

        if (!$('#DynamicField_' + DynamicFieldName).length) {
            return;
        }

        Core.AJAX.FunctionCall(
            Core.Config.Get('Baselink'),
            Data,
            function (Response) {
                if (!Response) {
                    return;
                }

                LastKnownPossibleValues[DynamicFieldName] = Response;
                ApplyPossibleValues(DynamicFieldName, Response);
            },
            'json'
        );
    }

    function FillAdditionalDynamicFields(SourceDynamicFieldName) {
        var URL  = Core.Config.Get('Baselink'),
            SelectedConfigItemIDs,
            Data = {
                Action:                 'AJAXDynamicFieldConfigItem',
                Subaction:              'GetAdditionalDFStorageData',
                SourceDynamicFieldName: SourceDynamicFieldName,
            };

        // Support single and multi select.
        SelectedConfigItemIDs = Znuny.Form.Input.Get('DynamicField_' + SourceDynamicFieldName);
        if (typeof(SelectedConfigItemIDs) === 'string') {
            SelectedConfigItemIDs = [SelectedConfigItemIDs];
        }
        Data['SelectedConfigItemIDs'] = SelectedConfigItemIDs;

        Core.AJAX.FunctionCall(
            URL,
            Data,
            function (Response) {
                if (!Response) {
                    return;
                }

                $.each(Response, function(DestinationDynamicFieldName, Value) {
                    var FieldID   = Znuny.Form.Input.FieldID('DynamicField_' + DestinationDynamicFieldName),
                        FieldType = Znuny.Form.Input.Type(FieldID),
                        DateTimeParts;

                    if (Value && (FieldType == 'DynamicField_Date' || FieldType == 'DynamicField_DateTime')) {
                        DateTimeParts = Value.match(/^(\d{4})-(\d{2})-(\d{2})( (\d{2}):(\d{2}):(\d{2}))?$/);
                        if (DateTimeParts.length != 8) {
                            return;
                        }

                        Value = {
                            Year:   parseInt(DateTimeParts[1], 10),
                            Month:  parseInt(DateTimeParts[2], 10),
                            Day:    parseInt(DateTimeParts[3], 10),
                            Hour:   parseInt(DateTimeParts[5], 10),
                            Minute: parseInt(DateTimeParts[6], 10),
                            Used:   true,
                        };
                    }

                    Znuny.Form.Input.Set(
                        'DynamicField_' + DestinationDynamicFieldName,
                        Value
                    );
                });
            }
        );
    }

    return TargetNS;
}(Znuny.DynamicField.ConfigItem || {}));
