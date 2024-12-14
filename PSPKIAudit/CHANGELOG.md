# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.8] - 2024-02-16

* Fixed function to test if current user is a member of Protected Users

## [0.3.7] - 2023-02-08

* Fix manifest to include RootModule 
* Improved RequiredModules to include minimum version and ensure the correct dependencies are loaded
* Debundle PSPKI as latest version is available on github and newer version may include additional fixes

## [0.3.6] - 2021-09-21

* Fix for the -Requester flag in Get-CertRequest

## [0.3.5] - 2021-06-17

* Bundle PSPKI audit with the code. These will fix https://github.com/GhostPack/PSPKIAudit/issues/1 and some other issues.

## [0.3.4] - 2021-06-17

* Initial release
