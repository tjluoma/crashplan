#!/bin/zsh
# Purpose: Load or unload crashplan
# From:	Timothy J. Luoma
# Mail:	luomat at gmail dot com
# Date:	2013-02-26
#
#	NOTE: In order for this script to work, the following lines must be added to /etc/sudoers (without the leading '#' of course)
#
#	%admin ALL=NOPASSWD: /bin/launchctl list
#	%admin ALL=NOPASSWD: /bin/launchctl load   /Library/LaunchDaemons/com.crashplan.engine.plist
# 	%admin ALL=NOPASSWD: /bin/launchctl unload /Library/LaunchDaemons/com.crashplan.engine.plist

NAME="$0:t"

	# used for 'msg' which is part of ~/.zshenv
GROWL_APP='CrashPlan'

LD_PLIST='/Library/LaunchDaemons/com.crashplan.engine.plist'
LA_PLIST="$HOME/Library/LaunchAgents/com.crashplan.engine.plist"

if [ -e "$LD_PLIST" ]
then
		SUDO='sudo'
		PLIST="$LD_PLIST"

elif [ -e "${HOME}/$PLIST" ]
then
		SUDO=''
		PLIST="$LA_PLIST"
else

		msg --die "No $LD_PLIST or $LA_PLIST found"
		exit 1
fi

####|####|####|####|####|####|####|####|####|####|####|####|####|####|####
#
#		Functions
#

function runCrashPlanMenuBar { open -g -a 'CrashPlan menu bar' }

function quitCrashPlanMenuBar { pkill 'CrashPlan menu bar' }

function loadCrashplan {

	${SUDO} /bin/launchctl load "$PLIST"

	EXIT="$?"

	if [ "$EXIT" = "0" ]
	then

			msg "Loaded CrashPlan successfully"
			runCrashPlanMenuBar
			return 0
	else
			msg sticky "FAILED to load CrashPlan"
			return 1
	fi

 }

function unloadCrashplan {

	${SUDO} /bin/launchctl unload "$PLIST"

	EXIT="$?"

	if [ "$EXIT" = "0" ]
	then

			msg "Unloaded CrashPlan successfully"
			quitCrashPlanMenuBar
			return 0
	else
			msg sticky "FAILED to unload CrashPlan"
			return 1
	fi

 }

#
####|####|####|####|####|####|####|####|####|####|####|####|####|####|####

ACTION=status

for ARGS in "$@"
do
	case "$ARGS" in
		-l|--load)
					ACTION='load'
					shift
		;;

		-u|--unload)
					ACTION='unload'
					shift
		;;

		-t|--toggle)
					ACTION='toggle'
		;;

		-*|--*)
				echo "	$NAME [warning]: Don't know what to do with arg: $1 so I'm ignoring it"
				shift
		;;

	esac

done # for args


case "$ACTION" in
	unload)
				unloadCrashplan
	;;

	load)
				loadCrashplan
	;;

	toggle)
				${SUDO} /bin/launchctl list | egrep -q 'com.crashplan.engine$'

				EXIT="$?"

				if [ "$EXIT" = "0" ]
				then
						# loaded, needs to be unloaded

						unloadCrashplan

				else
						# unloaded, needs to be loaded

						loadCrashplan
				fi
	;;


	*)

				${SUDO} /bin/launchctl list | egrep -q 'com.crashplan.engine$'

				EXIT="$?"

				if [ "$EXIT" = "0" ]
				then
						# loaded, needs to be unloaded
						echo "$NAME: CrashPlan is loaded"
				else
						# unloaded, needs to be loaded
						echo "$NAME: CrashPlan is unloaded"
				fi

				exit 0
	;;

esac


#
#EOF
