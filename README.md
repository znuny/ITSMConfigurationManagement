<div align="center">
  <a href="https://www.znuny.org">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://www.znuny.com/assets/znuny-logo.svg">
      <img alt="Znuny" src="https://www.znuny.com/assets/znuny-logo-black.svg" width="300">
    </picture>
  </a>

  ![Build status](https://badge.proxy.znuny.com/ITSMConfigurationManagement/rel-6_5)
</div>

ITSM Configuration Management
=============================

**Feature List**

This package provides the ITSM Configuration Management (CMDB) functionality for Znuny. It includes:

- **Configuration Items (CIs)**: Create, edit, version and manage configuration items with flexible definitions
- **CI Definitions**: Admin interface to define CI classes, attributes and layout (Admin → ITSM Configuration Management)
- **Deployment States**: Track CI lifecycle via deployment states (e.g. productive, rollout, retired)
- **Relationships**: Link CIs to each other and to tickets; link object support for changes and work orders
- **Search & Reporting**: Full-text and attribute-based CI search, print view and bulk operations
- **Attachments**: Attach files to configuration items
- **History**: Version history and change log per CI
- **Customer Interface**: Customer-facing CI view and widget for related CIs in ticket screens
- **GenericInterface**: SOAP/REST operations for ConfigItem create, get, search, update and delete
- **Customer/Customer User Dashboard**: Config item widgets added for the dashboards
- **View Incident Status**: CIs have an incident status, Operational or Incident which indicate if the CI is in a working state, or needs attention.

**Prerequisites**

- Znuny 6.5
- ITSMCore 6.5.1

**Installation**

Install via Admin interface → Package Manager. The package is part of the Znuny ITSM stack and can be installed from the Znuny repository or from a built .opm file.

**Configuration**

Configuration is available in the System Configuration under ITSMConfigurationManagement and in Admin → Config Items (CI definitions, deployment states, link types). Relevant agent actions for ACLs include `AgentITSMConfigItem*` and `AdminITSMConfigItem`.

**Download**

Source code is available in the [ITSMConfigurationManagement repository](https://download.znuny.org/releases/itsm/latest/). For packaged releases, use the Znuny package repository or build from source.

**Commercial Support**

For this extension and for Znuny in general visit [www.znuny.com](https://www.znuny.com). Looking forward to hear from you!

Enjoy!

Your Znuny Team!

[www.znuny.com](https://www.znuny.com)
