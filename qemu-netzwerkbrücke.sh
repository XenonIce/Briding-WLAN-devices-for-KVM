#!/bin/bash

#-----------------------------------------------------------------------
#Ein Skript welches Netzwerkbrücken konfiguriert
#Copyright (C) 2017 Konstantin Wagner
#konstantinwagner@yahoo.de

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.
#-----------------------------------------------------------------------

dialog --backtitle 'Eine WLAN-Karte überbrücken' --title "Info"  --msgbox 'Mit diesem Programm können Sie eine WLAN-Karte überbrücken. Dazu werden Root-Rechte benötigt.' 7 60

#Variablen festlegen
username=$(dialog --backtitle 'Eine WLAN-Karte überbrücken' --title "Für welchen Benutzer soll eine Netzwerkbrücke eingerichtet werden?" --inputbox "Benutzername:" 7 100 3>&1 1>&2 2>&3)

wlan_device=$(dialog --backtitle 'Eine WLAN-Karte überbrücken' --title "Wie lautet der Name Ihrer WLAN-Karte?" --inputbox "Wlan-Karte:" 7 60 3>&1 1>&2 2>&3)

tap_interface=$(dialog --backtitle 'Eine WLAN-Karte überbrücken' --title "Wie soll der Name für das neue Tap-Interface lauten?" --inputbox "Tap-Interface:" 0 0 3>&1 1>&2 2>&3)

ip_adresse=$(dialog --backtitle 'Eine WLAN-Karte überbrücken' --title "Geben Sie eine IP-Adresse für $tap_interface an. Beispiel: 10.10.10.10/32" --inputbox "IP-Adresse:" 7 100 3>&1 1>&2 2>&3 )

mac_adresse=$(dialog --backtitle 'Eine WLAN-Karte überbrücken' --title "Geben Sie eine MAC-Adresse für $tap_interface an. Beispiel: 52:54:00:12:34:60" --inputbox "MAC-Adresse:" 7 100 3>&1 1>&2 2>&3)

#Aktiviere IP-Forwarding
sysctl net.ipv4.ip_forward=1

#Erstelle Tap-Interface
tunctl -t $tap_interface -u $username

ip link set dev tap0 address $mac_adresse

#Aktiviere arp
sysctl net.ipv4.conf.$tap_interface.proxy_arp=1

#Füge IP ein
ip addr add $ip_adresse dev $tap_interface

ip link set $tap_interface up 

parprouted $wlan_device $tap_interface

#Broadcast-Relay
bcrelay -d -i $tap_interface -o $wlan_device

dialog --backtitle 'Eine WLAN-Karte überbrücken' --title "Fertig"  --msgbox "Es wurde eine Netzwerkbrücke von $wlan_device nach $tap_interface für den Benutzer $username eingerichtet." 7 60

clear
