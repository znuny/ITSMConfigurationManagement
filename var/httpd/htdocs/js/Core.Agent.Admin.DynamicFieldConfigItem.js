// --
// Copyright (C) 2021 Znuny GmbH, https://znuny.org/
// --
// This software comes with ABSOLUTELY NO WARRANTY. For details, see
// the enclosed file COPYING for license information (AGPL). If you
// did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
// --

"use strict";

var Core   = Core || {};

Core.Agent = Core.Agent || {};
Core.Agent.Admin = Core.Agent.Admin || {};

/**
 * @namespace
 * @exports TargetNS as Core.Agent.Admin.DynamicFieldConfigItem
 * @description
 *      This namespace contains the special functions for DynamicFieldConfigItem.
 */
Core.Agent.Admin.DynamicFieldConfigItem = (function (TargetNS) {

    TargetNS.Init = function () {
        InitLinkTypeSelection();
    }

    function InitLinkTypeSelection() {
        $('#ConfigItemLinkType').on('change', function() {
            var ConfigItemLinkType = $(this).val();

            if (ConfigItemLinkType) {
                ShowLinkSourceSelection();
                return;
            }

            HideLinkSourceSelection();
        })
        .trigger('change');
    }

    function ShowLinkSourceSelection() {
        $('#ConfigItemLinkSource').closest('div').show();
        $('label[for="ConfigItemLinkSource"]').show();

        $('#ConfigItemLinkRemoval').closest('div').show();
        $('label[for="ConfigItemLinkRemoval"]').show();

        Core.UI.InputFields.Activate();
    }

    function HideLinkSourceSelection() {
        $('#ConfigItemLinkSource').closest('div').hide();
        $('label[for="ConfigItemLinkSource"]').hide();

        $('#ConfigItemLinkRemoval').closest('div').hide();
        $('label[for="ConfigItemLinkRemoval"]').hide();
    }

    return TargetNS;
}(Core.Agent.Admin.DynamicFieldConfigItem || {}));
