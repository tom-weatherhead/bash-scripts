#!/bin/sh

# Re: Fix : Asus WiFi Disabled (Hard-blocked), Fn+F2 won't work

# Setting a HotKey to Toggle the WiFi On/Off (Alternative to the Fn+F2 switch)

# Until this issue is fixed with newer updates, you may use "xbindkeys" tool to set a hotkey (can be a single key or a key-combination) of your choice to toggle the WiFi enabled/disabled.

# This is how -

# A. Create a Script to do it smartly :

# 1) First, we create a script (for ease of use, and so that we can toggle it on/off using the same hotkey) -
# Code:

# #!/bin/bash
# Script to toggle the wireless blocked/unblocked

# index no. of phy interface
IFACE=`rfkill list all | grep phy | cut -c 1`

# WiFi block state 0=active, 1=blocked
BLOCKED=`rfkill list all | grep -iA1 phy | grep -ic soft.*yes`

if [ $BLOCKED -eq 1 ]; then
	rfkill unblock $IFACE
else
	rfkill block $IFACE
fi

# Copy-paste the contents of the above box in a text file and save this file in your Home directory with the name - "wifitoggle.sh". Make sure the first line is (without double quotes) "#!/bin/bash" and last one is "fi".

# 2) Make the script executable by running the following command in a terminal -
# Code:

# chmod +x wifitoggle.sh

# 3) Run the following command to Create a symlink to this script in /bin directory -
# Code:

# sudo ln -s $HOME/wifitoggle.sh /bin


# Now proceed to binding it with a hotkey as follows -

# B. Bind the Script with a HotKey of your choice :

# 1) Install xbindkeys-config (a GUI frontend to xbindkeys - the program that captures and binds hotkeys with commands) -
# Code:

# sudo apt-get install xbindkeys-config

# 2) Create a default config file for it (else it would crash on key capture step) -
# Code:

# xbindkeys --defaults > ~/.xbindkeysrc

# 3) Run the program from terminal or "Alt+F2" (because it does not create a launcher in Unity dash) -
# Code:

# xbindkeys-config

# let the terminal running in the background..
# In the GUI box that opens, 3 example shortcuts are already present. You may leave them.

# 4) Click on "New" button at the bottom of the GUI.

# 5) In the right hand pane of the GUI, fill in a suitable name in the "Name" field, e.g. "Toggle Wifi"

# 6) Click on "Get Key" button. This will open a tiny blank box doing nothing but waiting for your input.

# 7) Press the desired key (or key combination) that you want for toggling Wifi on/off. For example, "F3" key (as it remains mostly unused). The tiny box will disappear and the key will be recorded.

# 8) In the "Action" field, type this -
# Code:

# /bin/bash /bin/wifitoggle.sh

# 9) Click on "Apply" button and test the hotkey to see if it works as expected.

# 10) Click on "Save & Apply & Exit" to save the new hotkey to the default file and exit.

# From now on, as soon as you will press this key or the key-combination, the wifi will change its state from On to Off, or Off to On.

# The Fn key doesn't seem to be noticed by any key capture program I could find (probably that's why it is considered "Hardware Switch"), so it's not possible to use it yet.
