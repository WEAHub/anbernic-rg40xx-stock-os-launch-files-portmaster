#!/bin/bash
# Built from https://github.com/alexbatalov/fallout2-ce
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export TEXTINPUTPRESET="Name"
export TEXTINPUTINTERACTIVE="Y"
export TEXTINPUTNOAUTOCAPITALS="Y"

SHDIR=$(dirname "$0")
PORTNAME="Fallout 1"
PORTDIR="$SHDIR/fallout1"

cd "$PORTDIR"

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt

to_lower_case() {
    for SRC in $(find "$1" -depth); do
    DST=$(dirname "${SRC}")/$(basename "${SRC}" | tr '[A-Z]' '[a-z]')
    if [ "${SRC}" != "${DST}" ]; then
        [ ! -e "${DST}" ] && $ESUDO mv -vT "${SRC}" "${DST}" || echo "- ${SRC} was not renamed"
    fi
    done
}

get_controls

$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput

for file in data critter.dat master.dat; do
    if [[ ! -e "$file" ]]; then
        file_uc=$(echo "$file" | tr '[a-z]' '[A-Z]')

        if [[ -e "$file_uc" ]]; then
            # File exists but it is in uppercase, make it lowercase.
            to_lower_case "${PORTDIR}"

            if [[ ! -e "$file" ]]; then
                echo "Missing file: $file" > /dev/tty1
                sleep 5
                printf "\033c" >> /dev/tty1
                exit 1
            fi
        else
            echo "Missing file: $file" > /dev/tty1
            sleep 5
            printf "\033c" >> /dev/tty1
            exit 1
        fi
    fi
done

$GPTOKEYB "fallout-ce" -c "./fallout1.gptk.$ANALOG_STICKS" textinput &
./fallout-ce 2>&1 | tee -a ./log.txt

$ESUDO kill -9 $(pidof gptokeyb)
unset SDL_GAMECONTROLLERCONFIG
$ESUDO systemctl restart oga_events &
printf "\033c" >> /dev/tty1
