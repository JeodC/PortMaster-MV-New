#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

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
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

# Set variables
GAMEDIR="/$directory/ports/zelda-bookofmudora"
runtime="solarus-1.6.5"
solarus_dir="$HOME/portmaster-solarus"
solarus_file="$controlfolder/libs/${runtime}.squashfs"

# Exports
export LD_LIBRARY_PATH="/usr/lib:$GAMEDIR/libs:$solarus_dir"

cd $GAMEDIR

# Check for runtime
if [ ! -f "$controlfolder/libs/${runtime}.squashfs" ]; then
  # Check for runtime if not downloaded via PM
  if [ ! -f "$controlfolder/harbourmaster" ]; then
    echo "This port requires the latest PortMaster to run, please go to https://portmaster.games/ for more info." > /dev/tty0
    sleep 5
    exit 1
  fi
  $ESUDO $controlfolder/harbourmaster --quiet --no-check runtime_check "${runtime}.squashfs"
fi

# Setup Solarus
$ESUDO mkdir -p "$solarus_dir"
$ESUDO umount "$solarus_file" || true
$ESUDO mount "$solarus_file" "$solarus_dir"
PATH="$solarus_dir:$PATH"

# Setup controls
$ESUDO chmod 666 /dev/tty0
$ESUDO chmod 666 /dev/tty1
$ESUDO chmod 666 /dev/uinput
$GPTOKEYB "$runtime" -c "zbom.gptk" & 

# Run the game
echo "Loading, please wait... (might take a while!)" > /dev/tty0
"$runtime" $GAMEDIR/*.solarus 2>&1 | tee -a ./"log.txt"

# Cleanup
pm_finish
