// --
// Copyright (C) 2021 Znuny GmbH, https://znuny.org/
// --
// This software comes with ABSOLUTELY NO WARRANTY. For details, see
// the enclosed file COPYING for license information (AGPL). If you
// did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
// --

"use strict";

var Core   = Core || {},
ITSM = ITSM || {};

Core.Agent = Core.Agent || {};
ITSM.Agent = ITSM.Agent || {};
ITSM.Agent.ConfigItem = ITSM.Agent.ConfigItem || {};

/**
 * @namespace
 * @exports TargetNS as ITSM.Agent.ConfigItem.CustomerCIsWidget
 * @description
 *      This namespace contains the special functions for AgentConfigItemCustomerCIsWidget.
 */
ITSM.Agent.ConfigItem.CustomerCIsWidget = (function (TargetNS) {
    var GetCustomerInfoHandler,
        LastCustomerUserCount;

    TargetNS.Init = function (Param) {
        TargetNS.CreateWidget(Param);

        return true;
    }

    TargetNS.ShowWidgetLoading = function ($Widget) {
        $Widget.show();
        $Widget.children('.WidgetIsLoading').show();
        $Widget.children('.Header').addClass('Hidden');
        $Widget.children('.Content').addClass('Hidden');
        $Widget.fadeIn();
    }

    TargetNS.ShowWidgetResults = function ($Widget) {
        $Widget.hide();
        $Widget.children('.WidgetIsLoading').hide();
        $Widget.children('.Header.Hidden').removeClass('Hidden');
        $Widget.children('.Content.Hidden').removeClass('Hidden');
        $Widget.fadeIn();
    }

    TargetNS.CreateWidget = function (Param) {
        var Action = Core.Config.Get('Action'),
            ConfigItemIDs = '',
            URL = Core.Config.Get('Baselink') + TargetNS.SerializeData({
                Action: 'AgentITSMConfigItemCustomerCIsWidget',
                Subaction: 'LoadWidget',
                TicketID: Param.TicketID,
            }),
            $Element,
            $WidgetElement;

        // check if widget exists
        if ($('#AgentITSMConfigItemCustomerCIsWidget').length > 0) return;

        // append widget to sidebar
        $('.SidebarColumn').append(Param.Widget);

        $Element = $('#AgentITSMConfigItemCustomerCIs');
        $WidgetElement = $('#AgentITSMConfigItemCustomerCIsWidget');

        if ($Element.length === 0){
            TargetNS.ShowWidgetResults($WidgetElement);
            return true;
        }

        TargetNS.ShowWidgetLoading($WidgetElement);

        Core.AJAX.ContentUpdate($Element, URL, function() {

            // wait for content update
            $($Element).find("a.AsPopup").on('click', function () {
                var Matches,
                    PopupType = 'TicketAction';

                Matches = $(this).attr('class').match(/PopupType_(\w+)/);
                if (Matches) {
                    PopupType = Matches[1];
                }

                Core.UI.Popup.OpenPopup($(this).attr('href'), PopupType);
                return false;
            });

            if (Action == 'AgentTicketPhone' || Action == 'AgentTicketEmail') {
                $('form[name=compose]').append('<input type="hidden" id="ITSMConfigItemCustomerCIList" name="ITSMConfigItemCustomerCIList" />');

                    $.each($(".ConfigItemLink:checked"), function() {
                        if (ConfigItemIDs) {
                            ConfigItemIDs += ',';
                        }
                        ConfigItemIDs += $(this).val();
                    });

                    $('#ITSMConfigItemCustomerCIList').val(ConfigItemIDs);
                }

            TargetNS.ShowWidgetResults($WidgetElement);
            Core.UI.InitWidgetActionToggle();
            LastCustomerUserCount = 1;
            TargetNS.SetEventHandler();
        });
        return true;
    };

    TargetNS.SetEventHandler = function () {
        var Action = Core.Config.Get('Action');

        if (Action == 'AgentTicketZoom') {
            $('.ConfigItemLink').off('change').on('change', function() {
                var TicketID     = Core.Config.Get('TicketID'),
                    ConfigItemID = $(this).val(),
                    Subaction    = 'LinkDelete',
                    Data;

                if ($(this).is(":checked")) {
                    Subaction = 'LinkAdd';
                }

                Data = {
                    Action:       'AgentITSMConfigItemCustomerCIsWidget',
                    Subaction:    Subaction,
                    TicketID:     TicketID,
                    ConfigItemID: ConfigItemID,
                };

                // show ajax loader
                $(this).parent().append('<span id="AJAXLoader" class="AJAXLoader"></span>');

                // disable all checkboxes
                $('.ConfigItemLink').attr('disabled', 'disabled');

                Core.AJAX.FunctionCall(
                    Core.Config.Get('CGIHandle'),
                    Data,
                    function () {
                        location.reload();
                    },
                    'json'
                );
            });
        }
        else {
            if (!GetCustomerInfoHandler) {
                GetCustomerInfoHandler = Core.App.Subscribe(
                    'Event.Agent.CustomerSearch.GetCustomerInfo.Callback',
                    function () {
                        $('#ITSMConfigItemCustomerCIList').val('');
                        TargetNS.GetCustomerCIs();
                    }
                );

                window.setTimeout(
                    UpdateCustomerCIsOnRemovalOfLastCustomerUser,
                    1000
                );
            }

            $('.ConfigItemLink').off('change').on('change', function() {
                var ConfigItemIDs = '';

                $('#ITSMConfigItemCustomerCIList').val('');

                $.each($(".ConfigItemLink:checked"), function() {
                    if (ConfigItemIDs) {
                        ConfigItemIDs += ',';
                    }
                    ConfigItemIDs += $(this).val();
                });

                $('#ITSMConfigItemCustomerCIList').val(ConfigItemIDs);
            });
        }

        return true;
    };

    TargetNS.GetCustomerCIs = function () {
        var CustomerUserID = $('#SelectedCustomerUser').val();
        var CustomerID = $('#CustomerID').val(),
            Data = {
            Action:         'AgentITSMConfigItemCustomerCIsWidget',
            Subaction:      'CustomerUpdate',
            CustomerUserID: CustomerUserID,
            CustomerID:     CustomerID,
        };
        var $WidgetObj = $('#AgentITSMConfigItemCustomerCIsWidget');

        TargetNS.ShowWidgetLoading($WidgetObj);

        Core.AJAX.FunctionCall(
            Core.Config.Get('CGIHandle'),
            Data,
            function (Param) {
                $('#AgentITSMConfigItemCustomerCIs').empty();

                if (Param.ConfigItems) {
                    $('#AgentITSMConfigItemCustomerCIs').append(Param.ConfigItems);
                    TargetNS.SetEventHandler();
                }
                else {
                    $('#AgentITSMConfigItemCustomerCIs').append(Core.Language.Translate('none'));
                }
                TargetNS.ShowWidgetResults($WidgetObj);
            },
            'json'
        );

        return true;
    };

    // Workaround for clearing config item list if the last customer user was removed
    // from the dialog. The one remaining "CustomerSelected" element is from the
    // template that is being used to add customer users to the dialog.
    function UpdateCustomerCIsOnRemovalOfLastCustomerUser() {
        var CurrentCustomerUserCount = $('input[name="CustomerSelected"]').length;

        if (CurrentCustomerUserCount == 1 && CurrentCustomerUserCount != LastCustomerUserCount) {
            $('#ITSMConfigItemCustomerCIList').val('');
            TargetNS.GetCustomerCIs();
        }

        LastCustomerUserCount = CurrentCustomerUserCount;

        window.setTimeout(
            UpdateCustomerCIsOnRemovalOfLastCustomerUser,
            1000
        );
    }

    // TODO check: maybe better to load Znuny.App.js into AgentTicketZoom/AgentTicketPhone/AgentTicketEmail somehow?
    // But then, something else can also load it with other priority (like 099-ZnunyMigrator), that's why i did
    // not go in that direction, rather just copied this function

    TargetNS.SerializeData = function (Data) {

        var QueryString = '';

        $.each(Data, function (Key, Value) {
            QueryString += encodeURIComponent(Key) + '=' + encodeURIComponent(Value) + ';';
        });

        return QueryString;
    }

    return TargetNS;
}(ITSM.Agent.ConfigItem.CustomerCIsWidget || {}));
