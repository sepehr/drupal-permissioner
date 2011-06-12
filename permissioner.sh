#!/bin/sh
#
# Drupal Permissioner - http://github.com/sepehr/permissioner
# Fixes Drupal permissioning issues. Reference: http://drupal.org/node/244924
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

path=${1%/}
user=${2}
group="www-data"
help="\nHelp: This script is used to fix permissions of a Drupal installation\nYou need to provide the following arguments:\n\t 1) Path to your Drupal installation\n\t 2) Username of the user that you want to give files/directories ownership\nNote: \"www-data\" (apache default) is assumed as the group the server is belonging to, if this is different you need to modify it manually by editing this script\n\nUsage: (sudo) bash ${0##*/} Drupal_path user_name\n"

if [ -z "${path}" ] || [ ! -d "${path}/sites" ] || [ ! -f "${path}/modules/system/system.module" ]; then
echo "Please provide a valid Drupal path."
echo -e $help
exit
fi

if [ -z "${user}" ] || [ "`id -un ${user} 2> /dev/null`" != "${user}" ]; then
echo "Please provide a valid user."
echo -e $help
exit
fi

cd $path;

echo -e "Changing ownership of all contents of \"${path}\" :\n user => \"${user}\" \t group => \"${group}\"\n"
chown -R ${user}:${group} .
echo "Changing permissions of all directories inside \"${path}\" to \"750\"..."
find . -type d -exec chmod u=rwx,g=rx,o= {} \;
echo -e "Changing permissions of all files inside \"${path}\" to \"640\"...\n"
find . -type f -exec chmod u=rw,g=r,o= {} \;

cd $path/sites;

echo "Changing permissions of \"files\" directories in \"${path}/sites\" to \"770\"..."
find . -type d -name files -exec chmod ug=rwx,o= '{}' \;
echo "Changing permissions of all files inside all \"files\" directories in \"${path}/sites\" to \"660\"..."
find . -name files -type d -exec find '{}' -type f \; | while read FILE; do chmod ug=rw,o= "$FILE"; done
echo "Changing permissions of all directories inside all \"files\" directories in \"${path}/sites\" to \"770\"..."
find . -name files -type d -exec find '{}' -type d \; | while read DIR; do chmod ug=rwx,o= "$DIR"; done

