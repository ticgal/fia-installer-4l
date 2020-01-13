# Fusioninventory Agent Installer for GNU/Linux
<img src="https://raw.githubusercontent.com/ticgal/fia-installer-4l/master/fia-installer-4l-logo.png" alt="Fusioninventory agent Installer for GNU/Linux Logo" height="250px" width="250px" class="js-lazy-loaded">

[![License](https://img.shields.io/badge/License-GNU%20AGPLv3-blue.svg?style=flat-square)](https://github.com/ticgal/taskdrop/blob/master/LICENSE)
[![Twitter](https://img.shields.io/badge/Twitter-TICgal-blue.svg?style=flat-square)](https://twitter.com/ticgalcom)
[![Web](https://img.shields.io/badge/Web-TICgal-blue.svg?style=flat-square)](https://tic.gal/)

## English
A little step into achieving a universal GNU/Linux installer for GLPI with 

### Supported Distros

- Debian 7+
- Ubuntu 16.04 +
- Elementary OS 5+
- Centos 6+
- Oracle Linux 7 (not tested)
- Redhat 7 (not tested)

### Setup
1. Download the script
`wget https://raw.githubusercontent.com/ticgal/fia-installer-4l/master/fia-installer-4l.sh`
2. Edit the file and configure. 
   - Minimum settings:
     - Server:`fiaglpiserver`
   - Other settings:
     - Modules to install
     - Reset agent
     - FIA version 
     - tag
     - debub mode
     - no ssl check
     - logger
     - no-category
   - Fixed settings:
     - Local inventory by default in /tmp
     - Logfile /var/log/fusioninventory.log
     - Colored terminal

### Run

`bash ./fia-installer-4l.sh`

### Contribute

Please fell free to contribute. Open an issue to discuss it and a related PR with your suggested changes. Looking for:

- Support more distros
- Other script enhancements 


