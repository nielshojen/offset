#!/bin/bash

# Change directory to current script directory
# Based on code from http://stackoverflow.com/a/246128
cd "$( dirname "${BASH_SOURCE[0]}" )"
sudo echo "$(date) - Changing directory to script directory." >> /var/log/offset.log


# Check that the offset script is in the same directory as this installer script
if [ -f "offset" ]; then

	sudo echo "$(date) - Installing Offset." >> /var/log/offset.log

	# Make the appropriate folders
	sudo mkdir -p /usr/local/offset/logout-every

	sudo echo "$(date) - Creating folders." >> /var/log/offset.log
	
	# Copy the offset file to the new location
	sudo cp offset /usr/local/offset

	sudo echo "$(date) - Copying Offset script." >> /var/log/offset.log
	
	# Change ownership recursively of the offset folder
	sudo chown -R root:wheel /usr/local/offset
	
	# Change permissions for all scripts in logout-every (including .pkg files)
	sudo chmod -R 755 /usr/local/offset/logout-every
	
	# Correct permissions for any .pkg files that may be in there
	if ls /usr/local/offset/logout-every/*.pkg 1> /dev/null 2>&1; then
		sudo chmod -R 644 /usr/local/offset/logout-every/*.pkg
	fi

	sudo echo "$(date) - Correcting permissions and ownership." >> /var/log/offset.log

	# Define offset script location
	offsetScript="/usr/local/offset/offset"

	# See if there is a logout hook already defined
	testExists=$(sudo defaults read com.apple.loginwindow | grep "LogoutHook")

	# If it's not empty output...
	if [ ! -z "$testExists" ]; then

		# Get the actual logout hook contents
		oldLocation=$(sudo defaults read com.apple.loginwindow LogoutHook)

		# If the contents are not the same as the Outset script...
		if [ "$oldLocation" != "$offsetScript" ]; then

			sudo echo "$(date) - There appears to be a non-Offset logout hook that exists already. Moving it to the new Offset location." >> /var/log/offset.log
	
			# Make sure it has the correct permissions and ownership
			sudo chown root:wheel "$oldLocation"
			sudo chmod 755 "$oldLocation"
		
			# Move the old script to the new location
			sudo mv "$oldLocation" /usr/local/offset/logout-every/
		fi
	
	fi

## Add the new logout hook
sudo defaults write com.apple.loginwindow LogoutHook "$offsetScript"

sudo echo "$(date) - Making sure Offset is now the logout hook." >> /var/log/offset.log
sudo echo "$(date) - Installation complete." >> /var/log/offset.log

	
else

	# Log the error
	sudo echo "$(date) - The offset file does not exist in the same directory as the installer script. Installation aborted." >> /var/log/offset.log

fi
