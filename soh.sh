#!/bin/bash

# Set up environment variables
export HOME=/root
PORTNAME="The Legend of Zelda: Ocarina of Time"
XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
SHDIR=$(dirname "$0")
GAMEDIR="$SHDIR/soh"

cd $GAMEDIR

# Find control folder
if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

# Load control configurations and device info
source $controlfolder/control.txt
source $controlfolder/device_info.txt

[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

# Exports
export LD_LIBRARY_PATH="libs:/usr/lib"

# Permissions
$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1

rm -rf logs/* && exec > >(tee "log.txt") 2>&1
cp -f "bin/performance.elf" soh.elf

$ESUDO chmod 777 $GAMEDIR/soh.elf
$GPTOKEYB "soh.elf" -c "soh.gptk" & 
./soh.elf

rm -rf "soh.log"

$ESUDO kill -9 $(pidof gptokeyb)
$ESUDO systemctl restart oga_events & 
printf "\033c" > /dev/tty1
printf "\033c" > /dev/tty0
