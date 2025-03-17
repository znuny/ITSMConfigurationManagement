# --
# Copyright (C) 2021 Znuny GmbH, https://znuny.org/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::pl_ITSMConfigurationManagement;

use strict;
use warnings;
use utf8;

sub Data {
    my $Self = shift;

    # TT Template: Kernel/Output/HTML/Templates/Standard/AdminDynamicFieldConfigItem.tt
    $Self->{Translation}->{'This field is required and the value must be alphanumeric.'} = '';
    $Self->{Translation}->{'Must be unique and only accepts alphanumeric characters.'} = '';
    $Self->{Translation}->{'This is the order in which this field will be shown on the screens where it is active.'} =
        '';

    # TT Template: Kernel/Output/HTML/Templates/Standard/AdminDynamicFieldConfigItem/Config.tt
    $Self->{Translation}->{'Config item class'} = '';
    $Self->{Translation}->{'The selected config item class is invalid or does not exist.'} =
        '';
    $Self->{Translation}->{'Config item deployment states'} = '';
    $Self->{Translation}->{'Config item link type'} = '';
    $Self->{Translation}->{'Select a link type to enable linking between the ticket and the selected config items. Note that linking is only availabe for dynamic fields of tickets.'} =
        '';
    $Self->{Translation}->{'Config item link source'} = '';
    $Self->{Translation}->{'Config item link removal'} = '';
    $Self->{Translation}->{'Activate this option to remove links between the ticket and config items that are removed from this field.'} =
        '';
    $Self->{Translation}->{'Config item key'} = '';
    $Self->{Translation}->{'These dynamic fields will be filled with values of the same selected config item(s).'} =
        '';

    # TT Template: Kernel/Output/HTML/Templates/Standard/AdminITSMConfigItem.tt
    $Self->{Translation}->{'Change class definition'} = 'Zmień definicję klasy';
    $Self->{Translation}->{'Config Item Management'} = 'Zarządzanie Elementem Konfiguracji';
    $Self->{Translation}->{'Config Item Class'} = 'Klasa Elementu Konfiguracji';
    $Self->{Translation}->{'Definition'} = 'Definicja';
    $Self->{Translation}->{'Change'} = 'Zmiana';

    # TT Template: Kernel/Output/HTML/Templates/Standard/AgentDashboardITSMConfigItemGeneric.tt
    $Self->{Translation}->{'Incident State'} = 'Stan zdarzenia';
    $Self->{Translation}->{'Deployment State'} = 'Stan wdrożenia';
    $Self->{Translation}->{'Class'} = 'Klasa';
    $Self->{Translation}->{'Deployment State Type'} = 'Typ stanu wdrożenia';
    $Self->{Translation}->{'Current Incident State'} = 'Aktualny stan incydentu';
    $Self->{Translation}->{'Current Incident State Type'} = 'Aktualny typ stanu';
    $Self->{Translation}->{'Last changed'} = 'Ostatnio zmienione';

    # TT Template: Kernel/Output/HTML/Templates/Standard/AgentITSMConfigItemAdd.tt
    $Self->{Translation}->{'Filter for Classes'} = 'Filtr dla klas';
    $Self->{Translation}->{'Select a Class from the list to create a new Config Item.'} = 'Zaznacz klasę na liście aby utworzyć nowy element konfiguracji.';
    $Self->{Translation}->{'Config Item'} = 'Element Konfiguracji';

    # TT Template: Kernel/Output/HTML/Templates/Standard/AgentITSMConfigItemBulk.tt
    $Self->{Translation}->{'ITSM ConfigItem Bulk Action'} = 'Akcja grupowa na Elementach Konfiguracji ITSM';
    $Self->{Translation}->{'Deployment state'} = 'Stan wdrożenia';
    $Self->{Translation}->{'Incident state'} = 'Stan zdarzenia';
    $Self->{Translation}->{'Link to another'} = 'Połącz z innym';
    $Self->{Translation}->{'Invalid Configuration Item number!'} = 'Nieprawidłowy numer elementu konfiguracji!';
    $Self->{Translation}->{'The number of another Configuration Item to link with.'} = 'Numer innego elementu konfiguracji do połączenia.';

    # TT Template: Kernel/Output/HTML/Templates/Standard/AgentITSMConfigItemCustomerCIsWidget.tt
    $Self->{Translation}->{'Customer related config items'} = '';

    # TT Template: Kernel/Output/HTML/Templates/Standard/AgentITSMConfigItemDelete.tt
    $Self->{Translation}->{'Do you really want to delete this config item?'} = 'Czy na pewno chcesz usunąć ten element konfiguracji?';

    # TT Template: Kernel/Output/HTML/Templates/Standard/AgentITSMConfigItemEdit.tt
    $Self->{Translation}->{'The name of this config item'} = 'Nazwa tego elementu konfiguracji';
    $Self->{Translation}->{'Name is already in use by the ConfigItems with the following Number(s): %s'} =
        'Nazwa jest już używana przez CI o następujących numerach: %s';

    # TT Template: Kernel/Output/HTML/Templates/Standard/AgentITSMConfigItemHistory.tt
    $Self->{Translation}->{'History of Config Item: %s'} = 'Historia Elementu Konfiguracji: %s';
    $Self->{Translation}->{'History Content'} = 'Zawartość historii';
    $Self->{Translation}->{'Createtime'} = 'Utworzone';
    $Self->{Translation}->{'Zoom view'} = 'Widok szczegółowy';

    # TT Template: Kernel/Output/HTML/Templates/Standard/AgentITSMConfigItemOverviewNavBar.tt
    $Self->{Translation}->{'Context Settings'} = 'Ustawienia kontekstu';
    $Self->{Translation}->{'Config Items per page'} = 'Liczba Elementów Konfiguracji na stronę';

    # TT Template: Kernel/Output/HTML/Templates/Standard/AgentITSMConfigItemOverviewSmall.tt
    $Self->{Translation}->{'A generic ITSM Configuration Item table'} = 'Ogólna tabela elementów konfiguracji ITSM';

    # TT Template: Kernel/Output/HTML/Templates/Standard/AgentITSMConfigItemSearch.tt
    $Self->{Translation}->{'Also search in previous versions?'} = 'Uwzględnić poprzednie wersje?';

    # TT Template: Kernel/Output/HTML/Templates/Standard/AgentITSMConfigItemZoom.tt
    $Self->{Translation}->{'Configuration Item'} = 'Element Konfiguracji';
    $Self->{Translation}->{'Configuration Item Information'} = 'Informacje o Elemencie Konfiguracji';
    $Self->{Translation}->{'Current Deployment State'} = 'Aktualny stan wdrożenia';
    $Self->{Translation}->{'Last changed by'} = 'Ostatnio zmienione przez';
    $Self->{Translation}->{'Show one version'} = 'Pokaż jedną wersję';
    $Self->{Translation}->{'Show all versions'} = 'Pokaż wszystkie wersje';
    $Self->{Translation}->{'Version Incident State'} = 'Stan';
    $Self->{Translation}->{'Version Deployment State'} = 'Stan wdrożenia wersji';
    $Self->{Translation}->{'Version Number'} = 'Wersja';
    $Self->{Translation}->{'Configuration Item Version Details'} = 'Szczegóły wersji Elementu Konfiguracji';
    $Self->{Translation}->{'Property'} = 'Właściwość';

    # Perl Module: Kernel/Modules/AgentITSMConfigItem.pm
    $Self->{Translation}->{'No access to Class is given!'} = 'Nie udzielono dostępu do klasy!';

    # Perl Module: Kernel/Modules/AgentITSMConfigItemBulk.pm
    $Self->{Translation}->{'No ConfigItemID is given!'} = 'Nie określono ID dla elementu konfiguracji!';
    $Self->{Translation}->{'You need at least one selected Configuration Item!'} = 'Potrzebny jest co najmniej jeden wybrany element konfiguracji!';
    $Self->{Translation}->{'You don\'t have write access to this configuration item: %s.'} =
        'Nie masz prawa zapisu do tego elementu konfiguracji: %s.';

    # Perl Module: Kernel/Modules/AgentITSMConfigItemDelete.pm
    $Self->{Translation}->{'Config item "%s" not found in database!'} = 'Element konfiguracji "%s" nie znaleziony w bazie danych!';
    $Self->{Translation}->{'Was not able to delete the configitem ID %s!'} = 'Nie można było usunąć elementu konfiguracji o identyfikatorze %s!';
    $Self->{Translation}->{'No version found for ConfigItemID %s!'} = 'Nie znaleziono wersji dla elementu konfiguracji o identyfikatorze %s!';

    # Perl Module: Kernel/Modules/AgentITSMConfigItemEdit.pm
    $Self->{Translation}->{'No ConfigItemID, DuplicateID or ClassID is given!'} = 'Nie określono ID elementu konfiguracji, zduplikowanego ID lub ID klasy!';
    $Self->{Translation}->{'No access is given!'} = 'Nie udzielono dostępu!';
    $Self->{Translation}->{'No definition was defined for class %s!'} = 'Brak definicji dla klasy %s!';

    # Perl Module: Kernel/Modules/AgentITSMConfigItemHistory.pm
    $Self->{Translation}->{'Can\'t show history, no ConfigItemID is given!'} = 'Nie można wyświetlić historii, nie podano ID elementu konfiguracji!';
    $Self->{Translation}->{'Can\'t show history, no access rights given!'} = 'Nie można wyświetlić historii, nie udzielono prawa dostępu!';
    $Self->{Translation}->{'New ConfigItem (ID=%s)'} = 'Nowy element konfiguracji (ID=%s)';
    $Self->{Translation}->{'New version (ID=%s)'} = 'Nowa wersja (ID=%s)';
    $Self->{Translation}->{'Deployment state updated (new=%s, old=%s)'} = 'Zaktualizowano stan wdrożenia (nowy=%s, stary=%s)';
    $Self->{Translation}->{'Incident state updated (new=%s, old=%s)'} = 'Zaktualizowano stan zdarzenia (nowy=%s, stary=%s)';
    $Self->{Translation}->{'ConfigItem (ID=%s) deleted'} = 'Element konfiguracji (ID=%s) usunięty';
    $Self->{Translation}->{'Link to %s (type=%s) added'} = 'Łącze do %s (typ=%s) dodane';
    $Self->{Translation}->{'Link to %s (type=%s) deleted'} = 'Łącze do %s (typ=%s) usunięte';
    $Self->{Translation}->{'ConfigItem definition updated (ID=%s)'} = '';
    $Self->{Translation}->{'Name updated (new=%s, old=%s)'} = '';
    $Self->{Translation}->{'Attribute %s updated from "%s" to "%s"'} = 'Atrybut %s zmieniony z "%s" na "%s"';
    $Self->{Translation}->{'Version %s deleted'} = 'Wersja %s usunięta';

    # Perl Module: Kernel/Modules/AgentITSMConfigItemPrint.pm
    $Self->{Translation}->{'No ConfigItemID or VersionID is given!'} = '';
    $Self->{Translation}->{'Can\'t show config item, no access rights given!'} = '';
    $Self->{Translation}->{'ConfigItemID %s not found in database!'} = '';
    $Self->{Translation}->{'VersionID %s not found in database!'} = '';
    $Self->{Translation}->{'ConfigItem'} = 'Element Konfiguracji';
    $Self->{Translation}->{'printed by %s at %s'} = '';

    # Perl Module: Kernel/Modules/AgentITSMConfigItemSearch.pm
    $Self->{Translation}->{'Invalid ClassID!'} = '';
    $Self->{Translation}->{'No ClassID is given!'} = '';
    $Self->{Translation}->{'No access rights for this class given!'} = '';
    $Self->{Translation}->{'No Result!'} = 'Brak Wyników!';
    $Self->{Translation}->{'Config Item Search Results'} = 'Wyniki wyszukiwania Elementów Konfiguracji';

    # Perl Module: Kernel/Modules/AgentITSMConfigItemZoom.pm
    $Self->{Translation}->{'Can\'t show item, no access rights for ConfigItem are given!'} =
        '';
    $Self->{Translation}->{'operational'} = 'operacyjny';
    $Self->{Translation}->{'warning'} = 'ostrzeżenie';
    $Self->{Translation}->{'incident'} = 'incydent';
    $Self->{Translation}->{'The deployment state of this config item'} = 'Stan wdrożenia tego CI';
    $Self->{Translation}->{'The incident state of this config item'} = 'Stan zdarzenia tego CI';

    # Perl Module: Kernel/Output/HTML/Dashboard/ITSMConfigItemGeneric.pm
    $Self->{Translation}->{'Shown config items'} = 'Pokazane elementy konfiguracji';

    # Perl Module: Kernel/Output/HTML/ITSMConfigItem/LayoutDate.pm
    $Self->{Translation}->{'Between'} = 'Pomiędzy';

    # Perl Module: Kernel/System/ImportExport/ObjectBackend/ITSMConfigItem.pm
    $Self->{Translation}->{'Maximum number of one element'} = 'Maksymalna liczba wystąpień pojednyczego elemetntu';
    $Self->{Translation}->{'Empty fields indicate that the current values are kept'} = 'Puste pola znaczają, że zatrzymane będą bieżące wartości';
    $Self->{Translation}->{'Skipped'} = 'Pominięte';

    # Perl Module: var/packagesetup/ITSMConfigurationManagement.pm
    $Self->{Translation}->{'Model'} = 'Model';
    $Self->{Translation}->{'Customer Company'} = '';
    $Self->{Translation}->{'Serial Number'} = 'Numer seryjny';
    $Self->{Translation}->{'CPU'} = 'Procesor';
    $Self->{Translation}->{'Ram'} = 'RAM';
    $Self->{Translation}->{'Hard Disk'} = 'Dysk twardy';
    $Self->{Translation}->{'Capacity'} = 'Pojemność';
    $Self->{Translation}->{'FQDN'} = '';
    $Self->{Translation}->{'Network Adapter'} = 'Karta sieciowa';
    $Self->{Translation}->{'IP over DHCP'} = 'Adres IP z DHCP';
    $Self->{Translation}->{'IP Address'} = 'Adres IP';
    $Self->{Translation}->{'Graphic Adapter'} = 'Karta graficzna';
    $Self->{Translation}->{'Other Equipment'} = 'Pozostałe wyposażenie';
    $Self->{Translation}->{'Warranty Expiration Date'} = 'Data wygaśnięcia gwarancji';
    $Self->{Translation}->{'Install Date'} = 'Data instalacji';
    $Self->{Translation}->{'Phone 1'} = 'Telefon 1';
    $Self->{Translation}->{'Phone 2'} = 'Telefon 2';
    $Self->{Translation}->{'E-Mail'} = '';
    $Self->{Translation}->{'Network Address'} = 'Adres sieciowy';
    $Self->{Translation}->{'Subnet Mask'} = 'Maska sieci';
    $Self->{Translation}->{'Gateway'} = 'Brama';
    $Self->{Translation}->{'Licence Type'} = 'Typ licencji';
    $Self->{Translation}->{'Licence Key'} = 'Klucz licencyjny';
    $Self->{Translation}->{'Quantity'} = 'Ilość';
    $Self->{Translation}->{'Expiration Date'} = 'Data wygaśnięcia';
    $Self->{Translation}->{'Media'} = 'Nośnik';

    # XML Definition: ITSMConfigurationManagement.sopm
    $Self->{Translation}->{'Computer'} = '';
    $Self->{Translation}->{'Hardware'} = '';
    $Self->{Translation}->{'Network'} = '';
    $Self->{Translation}->{'Software'} = '';
    $Self->{Translation}->{'Expired'} = 'Wygasło';
    $Self->{Translation}->{'Maintenance'} = 'Utrzymanie';
    $Self->{Translation}->{'Pilot'} = 'Pilotaż';
    $Self->{Translation}->{'Planned'} = 'Planowany';
    $Self->{Translation}->{'Production'} = '';
    $Self->{Translation}->{'Repair'} = 'Naprawa';
    $Self->{Translation}->{'Retired'} = 'Wycofany';
    $Self->{Translation}->{'Review'} = 'Przegląd';
    $Self->{Translation}->{'Test/QA'} = 'Test/QA';
    $Self->{Translation}->{'Laptop'} = 'Laptop';
    $Self->{Translation}->{'Desktop'} = 'Desktop';
    $Self->{Translation}->{'PDA'} = 'PDA';
    $Self->{Translation}->{'Server'} = 'Serwer';
    $Self->{Translation}->{'Other'} = 'Inne';
    $Self->{Translation}->{'Monitor'} = 'Monitor';
    $Self->{Translation}->{'Printer'} = 'Drukarka';
    $Self->{Translation}->{'Switch'} = 'Switch';
    $Self->{Translation}->{'Router'} = 'Ruter';
    $Self->{Translation}->{'WLAN Access Point'} = 'Access Point';
    $Self->{Translation}->{'Security Device'} = 'Urządzenie zabezpieczające';
    $Self->{Translation}->{'Backup Device'} = 'Urządzenie do tworzenia kopii zapasowej';
    $Self->{Translation}->{'Mouse'} = 'Myszka';
    $Self->{Translation}->{'Keyboard'} = 'Klawiatura';
    $Self->{Translation}->{'Camera'} = 'Kamera';
    $Self->{Translation}->{'Beamer'} = 'Projektor';
    $Self->{Translation}->{'Modem'} = 'Modem';
    $Self->{Translation}->{'PCMCIA Card'} = 'Karta PCMCIA';
    $Self->{Translation}->{'USB Device'} = 'Urządzenie USB';
    $Self->{Translation}->{'Docking Station'} = 'Stacja dokująca';
    $Self->{Translation}->{'Scanner'} = 'Skaner';
    $Self->{Translation}->{'Building'} = 'Budynek';
    $Self->{Translation}->{'Office'} = 'Biuro';
    $Self->{Translation}->{'Floor'} = 'Piętro';
    $Self->{Translation}->{'Room'} = 'Pokój';
    $Self->{Translation}->{'Rack'} = 'Rack';
    $Self->{Translation}->{'Workplace'} = 'Miejsce pracy';
    $Self->{Translation}->{'Outlet'} = 'Punkt sprzedaży';
    $Self->{Translation}->{'IT Facility'} = 'Dział IT';
    $Self->{Translation}->{'LAN'} = 'LAN';
    $Self->{Translation}->{'WLAN'} = 'WLAN';
    $Self->{Translation}->{'Telco'} = 'Telco';
    $Self->{Translation}->{'GSM'} = 'GSM';
    $Self->{Translation}->{'Client Application'} = 'Aplikacja kliencka';
    $Self->{Translation}->{'Middleware'} = 'Middleware';
    $Self->{Translation}->{'Server Application'} = 'Aplikacja serwerowa';
    $Self->{Translation}->{'Client OS'} = 'System kliencki';
    $Self->{Translation}->{'Server OS'} = 'System serwerowy';
    $Self->{Translation}->{'Admin Tool'} = 'Narzędzie administratora';
    $Self->{Translation}->{'User Tool'} = 'Narzędzie Użytkownika';
    $Self->{Translation}->{'Embedded'} = 'Osadzony';
    $Self->{Translation}->{'Single Licence'} = 'Pojedyńcza licencja';
    $Self->{Translation}->{'Per User'} = 'Na Użytkownika';
    $Self->{Translation}->{'Per Processor'} = 'Na procesor';
    $Self->{Translation}->{'Per Server'} = 'Na serwer';
    $Self->{Translation}->{'Per Node'} = 'Na urządzenie';
    $Self->{Translation}->{'Volume Licence'} = 'Zbiorcza licencja';
    $Self->{Translation}->{'Enterprise Licence'} = 'Licencja Enterprise';
    $Self->{Translation}->{'Developer Licence'} = 'Licencja developerska';
    $Self->{Translation}->{'Demo'} = 'Demo';
    $Self->{Translation}->{'Time Restricted'} = 'Czasowo ograniczona';
    $Self->{Translation}->{'Freeware'} = 'Freeware';
    $Self->{Translation}->{'Open Source'} = 'Open source';
    $Self->{Translation}->{'Unlimited'} = 'Bez limitu';

    # JS File: var/httpd/htdocs/js/ITSM.Agent.ConfigItem.Zoom.js
    $Self->{Translation}->{'Ok'} = 'Ok';

    # SysConfig
    $Self->{Translation}->{'AlternativeTo'} = '';
    $Self->{Translation}->{'Assigned CIs'} = '';
    $Self->{Translation}->{'Autoloading of upload cache.'} = '';
    $Self->{Translation}->{'CIs assigned to customer company'} = '';
    $Self->{Translation}->{'CIs assigned to customer user'} = '';
    $Self->{Translation}->{'CMDB Settings'} = '';
    $Self->{Translation}->{'Check for a unique name only within the same ConfigItem class (\'class\') or globally (\'global\'), which means every existing ConfigItem is taken into account when looking for duplicates.'} =
        '';
    $Self->{Translation}->{'Config Items'} = '';
    $Self->{Translation}->{'Config item (Dropdown)'} = '';
    $Self->{Translation}->{'Config item (Multiselect)'} = '';
    $Self->{Translation}->{'Config item add.'} = '';
    $Self->{Translation}->{'Config item edit.'} = '';
    $Self->{Translation}->{'Config item event module that enables logging to history in the agent interface.'} =
        '';
    $Self->{Translation}->{'Config item history.'} = '';
    $Self->{Translation}->{'Config item print.'} = '';
    $Self->{Translation}->{'Config item zoom.'} = '';
    $Self->{Translation}->{'ConfigItemNumber'} = '';
    $Self->{Translation}->{'Configuration Item Limit'} = 'Limit liczby CI';
    $Self->{Translation}->{'Configuration Item limit per page.'} = '';
    $Self->{Translation}->{'Configuration Management Database.'} = '';
    $Self->{Translation}->{'Configuration item bulk module.'} = '';
    $Self->{Translation}->{'Configuration item search backend router of the agent interface.'} =
        '';
    $Self->{Translation}->{'Create and manage the definitions for Configuration Items.'} = 'Tworzenie i zarządzanie definicjami elementów konfiguracji.';
    $Self->{Translation}->{'Define Actions where a settings button is available in the linked objects widget (LinkObject::ViewMode = "complex"). Please note that these Actions must have registered the following JS and CSS files: Core.AllocationList.css, Core.UI.AllocationList.js, Core.UI.Table.Sort.js, Core.Agent.TableFilters.js and Core.Agent.LinkObject.js.'} =
        'Określa akcje dla których jest dostępny przycisk ustawień w widżecie połączonych obiektów (LinkObject::ViewMode = "complex"). Zwróć uwagę, że te akcje muszą mieć zarejestrowane następujące pliki JS i CSS: Core.AllocationList.css, Core.UI.AllocationList.js, Core.UI.Table.Sort.js, Core.Agent.TableFilters.js and Core.Agent.LinkObject.js.';
    $Self->{Translation}->{'Define a mapping between CI classes and a Fontawesome icons which are shown in the agent interface.'} =
        '';
    $Self->{Translation}->{'Defines Required permissions to create ITSM configuration items using the Generic Interface.'} =
        '';
    $Self->{Translation}->{'Defines Required permissions to delete ITSM configuration items using the Generic Interface.'} =
        '';
    $Self->{Translation}->{'Defines Required permissions to get ITSM configuration items using the Generic Interface.'} =
        '';
    $Self->{Translation}->{'Defines Required permissions to search ITSM configuration items using the Generic Interface.'} =
        '';
    $Self->{Translation}->{'Defines Required permissions to update ITSM configuration items using the Generic Interface.'} =
        '';
    $Self->{Translation}->{'Defines an overview module to show the small view of a configuration item list.'} =
        '';
    $Self->{Translation}->{'Defines regular expressions individually for each ConfigItem class to check the ConfigItem name and to show corresponding error messages.'} =
        '';
    $Self->{Translation}->{'Defines the default subobject of the class \'ITSMConfigItem\'.'} =
        '';
    $Self->{Translation}->{'Defines the number of rows for the CI definition editor in the admin interface.'} =
        '';
    $Self->{Translation}->{'Defines the order of incident states from high (e.g. cricital) to low (e.g. functional).'} =
        '';
    $Self->{Translation}->{'Defines the relevant deployment states where linked tickets can affect the status of a CI.'} =
        '';
    $Self->{Translation}->{'Defines the search limit for the AgentITSMConfigItem screen.'} =
        '';
    $Self->{Translation}->{'Defines the search limit for the AgentITSMConfigItemSearch screen.'} =
        '';
    $Self->{Translation}->{'Defines the shown columns in the config item overview. This option has no effect on the position of the column. Note: Class column is always available if filter \'All\' is selected.'} =
        '';
    $Self->{Translation}->{'Defines the shown columns in the config item search. This option has no effect on the position of the column.'} =
        '';
    $Self->{Translation}->{'Defines the shown columns of CIs in the config item overview depending on the CI class. Each entry must be prefixed with the class name and double colons (i.e. Computer::). There are a few CI-Attributes that are common to all CIs (example for the class Computer: Computer::Name, Computer::CurDeplState, Computer::CreateTime). To show individual CI-Attributes as defined in the CI-Definition, the following scheme must be used (example for the class Computer): Computer::HardDisk::1, Computer::HardDisk::1::Capacity::1, Computer::HardDisk::2, Computer::HardDisk::2::Capacity::1. If there is no entry for a CI class, then the default columns are shown as defined in the setting ITSMConfigItem::Frontend::AgentITSMConfigItem###ShowColumns.'} =
        '';
    $Self->{Translation}->{'Defines the shown columns of CIs in the config item search depending on the CI class. Each entry must be prefixed with the class name and double colons (i.e. Computer::). There are a few CI-Attributes that are common to all CIs (example for the class Computer: Computer::Name, Computer::CurDeplState, Computer::CreateTime). To show individual CI-Attributes as defined in the CI-Definition, the following scheme must be used (example for the class Computer): Computer::HardDisk::1, Computer::HardDisk::1::Capacity::1, Computer::HardDisk::2, Computer::HardDisk::2::Capacity::1. If there is no entry for a CI class, then the default columns are shown as defined in the setting ITSMConfigItem::Frontend::AgentITSMConfigItem###ShowColumns.'} =
        '';
    $Self->{Translation}->{'Defines the shown columns of CIs in the config item widget depending on the CI class. Each entry must be prefixed with the class name and double colons (i.e. Computer::). There are a few CI-Attributes that are common to all CIs (example for the class Computer: Computer::Name, Computer::CurDeplState, Computer::CreateTime). To show individual CI-Attributes as defined in the CI-Definition, the following scheme must be used (example for the class Computer): Computer::HardDisk::1, Computer::HardDisk::1::Capacity::1, Computer::HardDisk::2, Computer::HardDisk::2::Capacity::1. If there is no entry for a CI class, then the default columns are shown as defined in the setting AgentCustomerInformationCenter::Backend###0060-CIC-ITSMConfigItemCustomerCompany (key DefaultColumns).'} =
        '';
    $Self->{Translation}->{'Defines the shown columns of CIs in the link table complex view for all CI classes. If there is no entry, then the default columns are shown.'} =
        '';
    $Self->{Translation}->{'Defines the shown columns of CIs in the link table complex view, depending on the CI class. Each entry must be prefixed with the class name and double colons (i.e. Computer::). There are a few CI-Attributes that common to all CIs (example for the class Computer: Computer::Name, Computer::CurDeplState, Computer::CreateTime). To show individual CI-Attributes as defined in the CI-Definition, the following scheme must be used (example for the class Computer): Computer::HardDisk::1, Computer::HardDisk::1::Capacity::1, Computer::HardDisk::2, Computer::HardDisk::2::Capacity::1. If there is no entry for a CI class, then the default columns are shown.'} =
        '';
    $Self->{Translation}->{'Defines which type of link (named from the ticket perspective) can affect the status of a linked CI.'} =
        '';
    $Self->{Translation}->{'Defines which type of link (named from the ticket perspective) is used to link tickets and config items.'} =
        '';
    $Self->{Translation}->{'Defines which type of ticket can affect the status of a linked CI.'} =
        '';
    $Self->{Translation}->{'Delete Configuration Item'} = '';
    $Self->{Translation}->{'DependsOn'} = '';
    $Self->{Translation}->{'Deployment State Color'} = '';
    $Self->{Translation}->{'Duplicate'} = 'Duplikat';
    $Self->{Translation}->{'Dynamic fields administration'} = '';
    $Self->{Translation}->{'DynamicFieldConfigItem'} = '';
    $Self->{Translation}->{'Enable search for config items based on the customer id.'} = '';
    $Self->{Translation}->{'Enable search for config items based on the customer user id.'} =
        '';
    $Self->{Translation}->{'Enables configuration item bulk action feature for the agent frontend to work on more than one configuration item at a time.'} =
        '';
    $Self->{Translation}->{'Enables configuration item bulk action feature only for the listed groups.'} =
        '';
    $Self->{Translation}->{'Enables/disables the functionality to check ConfigItems for unique names. Before enabling this option you should check your system for already existing config items with duplicate names. You can do this with the script bin/znuny.Console.pl Admin::ITSM::Configitem::ListDuplicates.'} =
        '';
    $Self->{Translation}->{'Event Module that links a ConfigItem.'} = '';
    $Self->{Translation}->{'Event module to set configitem-status on ticket-configitem-link.'} =
        '';
    $Self->{Translation}->{'Filters the customer company config items by depoyment states into the customer config item widget.'} =
        '';
    $Self->{Translation}->{'Filters the customer config items by depoyment states into the customer config item widget.'} =
        '';
    $Self->{Translation}->{'ITSM config item overview.'} = '';
    $Self->{Translation}->{'Limit for config item search.'} = '';
    $Self->{Translation}->{'List of events that are available for generic interface event object type ITSMConfigItem.'} =
        '';
    $Self->{Translation}->{'Module to check the group responsible for a class.'} = '';
    $Self->{Translation}->{'Module to check the group responsible for a configuration item.'} =
        '';
    $Self->{Translation}->{'Module to generate ITSM config item statistics.'} = '';
    $Self->{Translation}->{'No longer in use. Do not change. Required due to compatibility with previous package versions.'} =
        '';
    $Self->{Translation}->{'Object backend module registration for the import/export module.'} =
        '';
    $Self->{Translation}->{'Overview.'} = 'Przegląd.';
    $Self->{Translation}->{'Parameters for the dashboard backend of the customer company config item overview of the agent interface . "Limit" is the number of entries shown by default. "Group" is used to restrict the access to the plugin (e. g. Group: admin;group1;group2;). "Default" determines if the plugin is enabled by default or if the user needs to enable it manually. "CacheTTLLocal" is the cache time in minutes for the plugin.'} =
        '';
    $Self->{Translation}->{'Parameters for the deployment states color in the preferences view of the agent interface.'} =
        '';
    $Self->{Translation}->{'Parameters for the deployment states in the preferences view of the agent interface.'} =
        '';
    $Self->{Translation}->{'Parameters for the example permission groups of the general catalog attributes.'} =
        'Parametry dla przykładowych grup uprawnień atrybutów katalogu głównego.';
    $Self->{Translation}->{'Parameters for the pages (in which the configuration items are shown).'} =
        '';
    $Self->{Translation}->{'Permission Group'} = 'Uprawnienia grup';
    $Self->{Translation}->{'Registers a ITSMConfigItem-EventModule that will save related attachments.'} =
        '';
    $Self->{Translation}->{'Registers an output filter that shows a config item widget.'} = '';
    $Self->{Translation}->{'RelevantTo'} = '';
    $Self->{Translation}->{'Required group permissions to use the customer config item widget in the agent interface.'} =
        '';
    $Self->{Translation}->{'Required permissions to use the ITSM configuration item screen in the agent interface.'} =
        '';
    $Self->{Translation}->{'Required permissions to use the ITSM configuration item search screen in the agent interface.'} =
        '';
    $Self->{Translation}->{'Required permissions to use the ITSM configuration item zoom screen in the agent interface.'} =
        '';
    $Self->{Translation}->{'Required permissions to use the add ITSM configuration item screen in the agent interface.'} =
        '';
    $Self->{Translation}->{'Required permissions to use the config item dialog in the agent interface.'} =
        '';
    $Self->{Translation}->{'Required permissions to use the edit ITSM configuration item screen in the agent interface.'} =
        '';
    $Self->{Translation}->{'Required permissions to use the history ITSM configuration item screen in the agent interface.'} =
        '';
    $Self->{Translation}->{'Required permissions to use the print ITSM configuration item screen in the agent interface.'} =
        '';
    $Self->{Translation}->{'Required privileges to delete config items.'} = '';
    $Self->{Translation}->{'Search config items.'} = '';
    $Self->{Translation}->{'Selects the configuration item number generator module. "AutoIncrement" increments the configuration item number, the SystemID, the ConfigItemClassID and the counter are used. The format is "SystemID.ConfigItemClassID.Counter", e.g. 1205000004, 1205000005.'} =
        '';
    $Self->{Translation}->{'Set the incident state of a CI automatically when a Ticket is Linked to a CI.'} =
        '';
    $Self->{Translation}->{'Sets the deployment state in the configuration item bulk screen of the agent interface.'} =
        '';
    $Self->{Translation}->{'Sets the incident state in the configuration item bulk screen of the agent interface.'} =
        '';
    $Self->{Translation}->{'Shows a link in the menu that allows linking a configuration item with another object in the config item zoom view of the agent interface.'} =
        '';
    $Self->{Translation}->{'Shows a link in the menu to access the history of a configuration item in the configuration item overview of the agent interface.'} =
        '';
    $Self->{Translation}->{'Shows a link in the menu to access the history of a configuration item in the its zoom view of the agent interface.'} =
        '';
    $Self->{Translation}->{'Shows a link in the menu to delete a configuration item in its zoom view of the agent interface.'} =
        '';
    $Self->{Translation}->{'Shows a link in the menu to duplicate a configuration item in the configuration item overview of the agent interface.'} =
        '';
    $Self->{Translation}->{'Shows a link in the menu to duplicate a configuration item in the its zoom view of the agent interface.'} =
        '';
    $Self->{Translation}->{'Shows a link in the menu to edit a configuration item in the its zoom view of the agent interface.'} =
        '';
    $Self->{Translation}->{'Shows a link in the menu to go back in the configuration item zoom view of the agent interface.'} =
        '';
    $Self->{Translation}->{'Shows a link in the menu to print a configuration item in the its zoom view of the agent interface.'} =
        '';
    $Self->{Translation}->{'Shows a link in the menu to zoom into a configuration item in the configuration item overview of the agent interface.'} =
        '';
    $Self->{Translation}->{'Shows the config item history (reverse ordered) in the agent interface.'} =
        '';
    $Self->{Translation}->{'The identifier for a configuration item, e.g. ConfigItem#, MyConfigItem#. The default is ConfigItem#.'} =
        '';
    $Self->{Translation}->{'This configuration registers a frontend module for the agent interface that provides the AJAX interface for AgentITSMConfigItemCustomerCIsWidget.'} =
        '';
    $Self->{Translation}->{'Ticket event module that creates and removes links between tickets and config items.'} =
        '';
    $Self->{Translation}->{'Ticket event module that updates DynamicFields.'} = '';
    $Self->{Translation}->{'class'} = '';
    $Self->{Translation}->{'global'} = '';
    $Self->{Translation}->{'postproductive'} = '';
    $Self->{Translation}->{'preproductive'} = '';
    $Self->{Translation}->{'productive'} = '';


    push @{ $Self->{JavaScriptStrings} //= [] }, (
    'No',
    'Ok',
    'Please enter at least one search value or * to find anything.',
    'Settings',
    'Submit',
    'Yes',
    'none',
    );

}

1;
