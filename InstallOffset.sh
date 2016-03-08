#!/bin/bash

# Change directory to current script directory
# Based on code from http://stackoverflow.com/a/246128
cd "$( dirname "${BASH_SOURCE[0]}" )"
sudo echo "$(date) - Changing directory to script directory." >> /var/log/offset.log


# Check that the offset script is in the same directory as this installer script
if [ -f "offset" ] && [ -f "com.github.offset.logout.plist" ]; then

	sudo echo "$(date) - Installing Offset." >> /var/log/offset.log

	# Make the appropriate folders
	sudo mkdir -p /usr/local/offset/logout-every

	sudo echo "$(date) - Creating folders." >> /var/log/offset.log
	
	# Copy the offset file to the new location
	sudo cp offset /usr/local/offset

	sudo echo "$(date) - Copying Offset script." >> /var/log/offset.log

	# Change ownership recursively of the offset folder
	sudo chown -R root:wheel /usr/local/offset
	
	# Change permissions for all scripts in logout-every (including .pkg files)... relevant only for upgrades
	sudo chmod -R 755 /usr/local/offset/logout-every
	
	# Correct permissions for any .pkg files that may be in there... relevant only for upgrades
	if ls /usr/local/offset/logout-every/*.pkg 1> /dev/null 2>&1; then
		sudo chmod -R 644 /usr/local/offset/logout-every/*.pkg
	fi

	sudo echo "$(date) - Correcting permissions and ownership." >> /var/log/offset.log

	# Copy the launch agent
	sudo cp com.github.offset.logout.plist /Library/LaunchAgents

	sudo echo "$(date) - Copying launch agent." >> /var/log/offset.log

	# Launching the launch anget
	sudo launchctl load /Libary/LaunchAgents/com.github.offset.logout.plist
	
	sudo echo "$(date) - Launching the launch agent." >> /var/log/offset.log

	sudo echo "$(date) - Installation complete." >> /var/log/offset.log

	
else

	# Log the error
	sudo echo "$(date) - The offset and launch agent files do not exist in the same directory as the installer script. Installation aborted." >> /var/log/offset.log

fi
