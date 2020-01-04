#!/bin/bash
# Fusioninventory agent installer for GNU/Linux
# fia-installer-4l.sh
#
# Copyright (C) 2018-2020 by TICgal
#
# https://github.com/ticgal/fia-installer-4l
#
# ------------------------------------------------------------------------
#
# LICENSE
#
# This file is part of the Fusioninventory agent installer for GNU/Linux project.
#
# Fusioninventory agent installer for GNU/Linux is free software: you can 
# redistribute it and/or modify it under the terms of the GNU Affero General 
# Public License as published by the Free Software Foundation, either version 3 
# of the License, or (at your option) any later version.
#
# Fusioninventory agent installer for GNU/Linux is distributed in the hope
# that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Notifications plugin. If not, see <http://www.gnu.org/licenses/>.
#
# ------------------------------------------------------------------------
#
# @package   Fusioninventory Agent Installer for GNU/Linux
# @author    TICgal
# @copyright Copyright (c) 2018-2020 TICgal
# @license   AGPL License 3.0 or (at your option) any later version
#            http://www.gnu.org/licenses/agpl-3.0-standalone.html
# @link      https://github.com/ticgal/fia-installer-4l
# @link      https://tic.gal/en/project/fusioninventory-agent-installer-for-gnu-linux/
#/

#Will install optional modules in modern distributions
#Old ones will only install localinventory


#BTN error handling
set -e -o pipefail -u #

#################################
#                               #
#        Review settings        #
#                               #
#################################

#Install only agent or agent with all modules
#Space separated modules
#0="fusioninventory-agent_" 
#1="fusioninventory-agent-task-network_"
#2="fusioninventory-agent-task-deploy_"
#3="fusioninventory-agent-task-esx_"
#4="fusioninventory-agent-task-collect_"
#
#Agent only
#fiainstallmodules=(0)
#All modules
#fiainstallmodules=(0 1 2 3 4) 
fiainstallmodules=(0)

#Just for upgrades
#If you want to get a new agent id set to 1. 
resetagent=0

#Fusioninventory agent version (Debian derivatives only)
fiaver='2.5.2-1'

#Config file name   
client='TICgal'     

#GLPi Tag                                           
fiatag=''   

#Fusioninventory server
#fiaglpiserver='https://glpiserver/plugins/fusioninventory/'                                                        
fiaglpiserver=''         

#Debug 
#(0,1,2,3)
fiadebug='1'

#no-SSL-Check 
#(0,1)
fianosslcheck='1'

#logger
#(stderr,file,syslog)
fialogger='file'

#no-category
#(antivirus battery controller cpu drive environment input licenseinfo local_group local_user 
#lvm memory modem monitor network port printer process remote_mgmt slot software sound storage usb user
# video virtualmachine)
fianocategory='printer'

#There are 3 more "hardcoded" parameters
#1.Creates a local inventory on /tmp
#2.Defaults log file to /var/log/fusioninventory.log file
#3.Enables coloured terminal 

#################################
#################################
#                               #
# Do not edit under this line   #
#                               #
#################################
#################################

#FIA config path
fiacfg='/etc/fusioninventory/conf.d/'

#Check if script is run as root.
        if [ "$(id -u)" != "0" ]; then
           echo "This script must be run as root" 1>&2
           exit 1
        fi

#If no server is set exit
if [ -z "$fiaglpiserver" ]; then
        echo "You need to setup at least a GLPI-Fusioninventory server!!!"
        exit 1
fi

#Check OS 
if [[ -r /etc/os-release ]]; then
    . /etc/os-release
	if [[ -n $ID ]]; then 
        	echo Detected OS: "$ID" "$VERSION_ID"
	fi
        
	if [[ $ID =~ ^(centos|fedora|ol)$  ]]; then
    
        ###########
        # CentOS  #
        ###########
        
        #Enable EPEL repository if not enabled
	if ! rpm -q --quiet epel-release; then
		if [[ $VERSION_ID = 8 ]]; then
		dnf install epel-release -y
		dnf config-manager --set-enabled PowerTools	
		
		elif [[ $VERSION_ID = 7 ]]; then
                yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
                
		elif [[ $VERSION_ID = 6 ]]; then
                yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
                fi
        fi

	# CENTOS 6 - 7 common dependencies and installation

	if [[ $VERSION_ID = 6 || $VERSION_ID = 7 ]]; then
	#Enable copr
        yum -y install yum-plugin-copr 
	yum -y copr enable trasher/fusioninventory-agent
        
	#Install modules
        for i in "${fiainstallmodules[@]}" 
        	do
        	#Agent is installed always
        	yum install -y fusioninventory-agent
        	#Which modules
		case $i in
        	        1)
 	                   yum install -y fusioninventory-agent-task-network*
                	    ;;
        	        2)
   	                 yum install -y fusioninventory-agent-task-deploy*
                	    ;;
        	        3)
	                    yum install -y fusioninventory-agent-task-esx*
                	    ;;
        	        4)
	                    yum install -y fusioninventory-agent-task-collect*
                	    ;;
            	esac
	done	
	fi
        
	#Centos 8
	dnf install fusioninventory-agent -y	
	
		#Not installed?
            	#fusioninventory-agent-cron.x86_64 : Cron for FusionInventory agent
            	#fusioninventory-agent-task-inventory.x86_64 : Inventory task for FusionInventory
            
            	# Enable and start service
            	if [[ $VERSION_ID = 7 || $VERSION_ID = 8 ]]; then
                	systemctl enable fusioninventory-agent
                	systemctl start fusioninventory-agent
               
            	elif [[ $VERSION_ID = 6 ]]; then
                	chkconfig fusioninventory-agent on
                	service fusioninventory-agent start
            	fi       
        	

        ###########
        # /CentOS #
        ###########
     
        elif [[ $ID =~ ^(debian|ubuntu)$ ]]; then
     
        ##########
        # Debian #
        ##########
       
        #Common#
        
        #Update repositories
        apt-get update 
	
        #Check if old manual version install exists
        if [ -f /usr/local/etc/fusioninventory/agent.cfg ]; then
            rm -rf /usr/local/bin/fusioninventory-* /usr/local/share/fusioninventory \
            /usr/local/share/fusioninventory/lib /usr/local/var/fusioninventory \
            /usr/local/etc/fusioninventory
            hash -r
            hash fusioninventory-agent
        fi

        #Reset agent if set on setup
        if [ $resetagent = 1 ]; then
            rm -rf /var/lib/fusioninventory-agent/
        fi
            
        #Recent Debian derivatives
        if  { [ "$ID" = "debian" ] && [ "$VERSION_ID" -ge 8 ]; } || \
            { [ "$ID" = "ubuntu" ] && [ "${VERSION_ID:0:2}" -ge 16 ]; }; then
        
            #Debianrepository
            fiarepository='https://github.com/fusioninventory/fusioninventory-agent/releases/download/'${fiaver%-*}'/'

            #FIA modules
            fiamodule[0]="fusioninventory-agent_" 
            fiamodule[1]="fusioninventory-agent-task-network_"
            fiamodule[2]="fusioninventory-agent-task-deploy_"
            fiamodule[3]="fusioninventory-agent-task-esx_"
            fiamodule[4]="fusioninventory-agent-task-collect_"

            #Remove previously downloaded deb files
            rm -f ./*glob*.deb

            #Just in case add-apt-repository is not installed
            apt-get install -y software-properties-common 
            
            #Add universe repository. Needed for Ubuntu installs.
            if [ "$ID" = "ubuntu" ]; then
                add-apt-repository universe
            fi

            #fusioninventory-agent dependencies
            apt-get install -y dmidecode hwdata ucf hdparm perl libuniversal-require-perl libwww-perl \
            libparse-edid-perl libproc-daemon-perl libfile-which-perl libxml-treepp-perl libyaml-perl \
            libnet-cups-perl libnet-ip-perl libdigest-sha-perl libsocket-getaddrinfo-perl \
            libtext-template-perl libxml-xpath-perl

		
            #Install package

            rm -f fusioninventory*.deb
	    for i in "${fiainstallmodules[@]}"
            do
                #Dependencies for fusioninventory-agent-task-network
                if [[ $i = 1 ]]; then
                        apt-get install -y nmap libnet-snmp-perl libcrypt-des-perl libnet-nbname-perl \
                libdigest-hmac-perl 
                fi	

                #Dependencies for fusioninventory-agent-task-deploy
                if [[ $i = 2 ]]; then
                       apt-get install -y libfile-copy-recursive-perl libparallel-forkmanager-perl  
                fi
                
                #Download and install packages    
                tempdeb="${fiamodule[$i]}${fiaver}_all.deb"
		  
		wget -q ${fiarepository}${tempdeb} 
                dpkg -i --force-confnew ${tempdeb}
                #Clean up#
                rm ${tempdeb}  
            done
        fi
        
       
        
#Debian 7  
elif  [[ -r /etc/debian-version ]]; then
    debianversion=$(</etc/debian-version)
    if [[ ${debianversion:0:1} -eq "7" ]]; then       
        echo "deb http://httpredir.debian.org/debian wheezy-backports main" >> /etc/apt/sources.list
        apt-get update 
        apt-get -y install -t wheezy-backports fusioninventory-agent
    fi

        
        #Enabling and starting service
            systemctl enable fusioninventory-agent
            systemctl start fusioninventory-agent

        ###########
        # /Debian #
        ###########
else
        echo "Running ID=$ID, VERSION=$VERSION. Not currently supported."
        echo "Please open an issue at github: https://github.com/ticgal/fia-installer-4l"
        exit 2
fi
else
    echo "Not running a distribution with /etc/os-release available"
    exit 3
fi

#Creates a config file
#Config file
{
    echo "#Added by fia-installer-4l.sh"
    echo "#TICgal https://tic.gal"
    echo "#$(date)" 
    echo "server = " $fiaglpiserver
    echo "tag = " $fiatag
    echo "debug = " $fiadebug
    echo "no-ssl-check = " $fianosslcheck
    echo "no-category = " $fianocategory
    echo "logger" = $fialogger
    echo "local = /tmp"
    echo "logfile = /var/log/fusioninventory.log"
    echo "color = 1"
} > $fiacfg$client.cfg

#Check version
fusioninventory-agent -v
#Start Agent
systemctl restart fusioninventory-agent
#Run inmediate inventory
pkill -USR1 -f -P 1 fusioninventory-agent

#Make sure an inventory is launched (sometimes it fails, needs debugging)
fusioninventory-agent

#Check if fusion is running (if more debugging is needed, uncomment)
#tail -f /var/log/fusioninventory.log
