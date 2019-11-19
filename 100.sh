#!/bin/bash
#https://github.com/a15mirfeilor/p02
# Make sure the script is being executed with superuser privileges.
if [[ "${UID}" -eq 0 ]]; then
	# If the user doesn't supply at least one argument, then give them help.
	if [ "$#" -lt 1 ]; then
		echo -e "Exit status 1: Debes introducir al menos un parametro."
		echo -e "Usage: ./$(basename $0) USER_NAME [COMMENT]..."
		echo -e "Create an account on the local system with the name of USER_NAME and a comments field of COMMENT."
	else

		# The first parameter is the user name.
		USER_NAME=$1
		# The rest of the parameters are for the account comments.
		COMMENT="${@:2}"
		# Generate a password.
		PASSWORD=$(date | sha256sum)
		# Create the user with the parameters.
		sudo useradd -c "${COMMENT}" -m ${USER_NAME}
		if [[ $? -eq 0 ]]; then
			# Check to see if the useradd command succeeded.
			RESULT_CREATE_USER=$(tail /etc/passwd -n 1 | grep "^$USER_NAME:")
			if [[ -n "$RESULT_CREATE_USER" ]]; then
				# Set the password.
				echo -e "${PASSWORD}\n${PASSWORD}" | sudo passwd ${USER_NAME} &> /dev/null
				echo "passwd: Success"
				# Check to see if the passwd command succeeded.
				if [[ $? -eq 0 ]]; then
					# Force password change on first login.
					passwd -e ${USER_NAME}
					# Display the username, password, and the host where the user was created.
					echo -e "username:\n$USER_NAME\n\n"
					echo -e "password:\n$PASSWORD\n\n"
					echo -e "host:\n$HOSTNAME"
				else
					echo 'Exit status 1: No se ha podido asignar la contraseña.'
				fi
			else
				echo 'Exit status 1: No se ha encontrado el usuario.'
			fi
		else
			echo 'Exit status 1: No se ha podido crear el usuario.'
		fi
	fi
else
	echo 'Exit status 1: No eres usuario root.'
fi
