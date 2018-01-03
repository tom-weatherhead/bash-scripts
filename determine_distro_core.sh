determine_distro()
{
	# Find the Distributor ID:
	if [ "$(uname -o)" == "Cygwin" ]; then
		echo 'Cygwin'
	elif grep -q Microsoft /proc/version; then # WSL; See https://stackoverflow.com/questions/38859145/detect-ubuntu-on-windows-vs-native-ubuntu-from-bash-script
		echo 'Ubuntu on Windows' # This string delibrately starts with Ubuntu, so that both WSL and genuine Ubuntu return results that match the regex /^Ubuntu/
	elif which lsb_release 1>/dev/null 2>&1; then
		lsb_release -is
	elif [ -e /etc/os-release ]; then
		cat /etc/os-release | perl -nle 'print $1 if /^NAME="?(.*?)"?$/'
	else
		echo 'Unknown distribution'
	fi
}
