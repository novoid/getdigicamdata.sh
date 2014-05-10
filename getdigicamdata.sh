#!/bin/sh

FILENAME=$(basename $0)
OUTPUTTOOLNAME="${FILENAME}"

## This script gets data from the SD storage card of my digital camera
## to my computer. It rotates portrait format images and renames files
## according to my file name convention.

## Please note: this is a quick-hack script that needs clean-up, a
## more beautiful formatting, and proably a re-implementation in
## Python (to be platform-independent).

# ------------------------------------------------
#  please modify following lines to your values!
# ------------------------------------------------

# download-directory:
DLDIR="/home/vk/tmp/Tools/digicam-tmpdir"

# destination-directory for user:
DESTDIR="/home/vk/tmp/digicam/tmp"

## # user, group for DESTDIR-user:
## DESTUSER="vk"
## ## [ ${HOSTNAME} = "lisa" ] && DESTGRP="users"
## ## [ ${HOSTNAME} = "maggie" ] && DESTGRP="vk"
## [ ${HOSTNAME} = "marge.local" ] && DESTGRP="vk"

#TOOLPATH="$1/Contents/Resources"

# path to jhead (>= v2.0)
JHEAD="/usr/bin/jhead"
JHEAD_DATEPAR="-nf%Y-%m-%dT%H.%M.%S_%f"

# adds a timestamp to a file
DATE_TO_NAME_TOOL="${HOME}/bin/date2name --withtime "

# path to tool, which lowers all filenames:
LOWERTOOL="$HOME/bin/lowerall"

MOUNTPOINT="/media/digicam"

DOWNLOADTOOL=`which find`

## DOWNLOADTOOLPAR="-L ${MOUNTPOINT} \( -name \*avi -o -name \*jpg -o -name \*AVI -o -name \*JPG \) -print -exec mv {} ${DLDIR} \;"
DOWNLOADTOOLPAR="-L ${MOUNTPOINT} \( -name \*.MP* -o -name \*.MOV -o -name \*avi -o -name \*jpg -o -name \*AVI -o -name \*JPG \) -print -exec cp -a {} ${DLDIR} \;"

#COCOADIALOG="/Applications/MacPorts/CocoaDialog.app/Contents/MacOS/CocoaDialog"

## FIXXME: causes problems with special characters or blanks in filename:
#GROWLCMD=`which growlnotify`" -t ${FILENAME} -m "
#COCOADIALOG_GLOBAL_PARAMETERS="--title ${OUTPUTTOOLNAME}"
#OUTPUT_SHORT_INFO_CMD="${COCOADIALOG} bubble ${COCOADIALOG_GLOBAL_PARAMETERS} --icon info --independent --text "
#OUTPUT_CONFIRMED_INFO_CMD="${COCOADIALOG} ok-msgbox ${COCOADIALOG_GLOBAL_PARAMETERS} --float --no-cancel --icon info --text "

# if you have modified all lines according to your
# needs, please alter following value to YES:
#USERCONFIG="NO"
USERCONFIG="YES"


# ------------------------------------------------
#  usually you need not modify anything below this line!
# ------------------------------------------------

FILENAME=`echo "$0"|sed 's!.*/!!'`


# if parameter 1 is given, just do lowering, rotating and renaming:
[ "x${1}" != "x" ] && JUSTDLDIRPROCESSING=yes

short_unconfirmed_info()
{
        report "${1}"
#        ${OUTPUT_SHORT_INFO_CMD} "${1}" &
}

confirmed_info()
{
        report "${1}" "${2}"
#        ${OUTPUT_CONFIRMED_INFO_CMD} "${1}" --informative-text "${2}"
}

report()
{
	echo "======================================== ${FILENAME}"
	echo "  ${1}"
    [ "x${2}" = "x" ] || echo "  ${2}"
	echo "======================================================"
}


# # if parameter 1 is given, just do lowering, rotating and renaming
# if [ ! ${JUSTDLDIRPROCESSING} ]; then
# 
#     #${OUTPUT_SHORT_INFO_CMD} "An inserted digicam has been detected."
# 
#     ## ask for starting action
#    RETURNVALUE=`${COCOADIALOG} ok-msgbox ${COCOADIALOG_GLOBAL_PARAMETERS} \
#        --text "Du you want to download DigiCam-data?" \
#        --informative-text "(Target directory: \"${DESTDIR}\")" \
#        --style informational \
#        --no-newline`
#    if [ "$RETURNVALUE" == "1" ]; then
#        echo "User said OK" >/dev/null
#    elif [ "$RETURNVALUE" == "2" ]; then
#        report "You canceled."
#        exit
#    fi
# 
# fi


echo
echo "  $FILENAME gets all images from a digital camera"
echo "  and saves them to a directory occupied by root."
echo "  Then $FILENAME converts the files to lowercase and moves them"
echo "  to a dedicated user-directory."
echo "  If parameter 1 is given, just do lowering, rotating and renaming."
echo
echo "  NOTE: this script needs to be executed by user root!"
echo
echo "  USES: jhead, jpegtran ... for manipulating jpeg-pictures"
echo "        lowerall (perl-script, avaliable e.g. at http://llg.cubic.org/tools/)"
echo "        date2name (shell-script, avaliable e.g. at http://www.Karl-Voit.at/scripts/)"
echo "        cocoadialog ... for notification of and interaction with user"
echo
echo "                           AUTHOR: Karl Voit, scripts@Karl-Voit.at"
echo "                          VERSION: v0.5 @ 2008-08-16"
echo "                        COPYRIGHT: GPL (http://www.gnu.org/copyleft/gpl.html)"
echo

if test "$USERCONFIG" = "NO" ; then
	echo
	echo "========================================================="
	echo "  YOU HAVE TO EDIT THIS SCRIPT TO CONFIGURE IT FIRST!!!"
	echo "========================================================="
	echo "  Script aborted."
	echo
	confirmed_info "You have to edit this script to configure it first! (Location: ${0})"
	exit 1
fi

## ---------------------------------------------------------

myexit()
{
#    doreport debug "function myexit($1) called"

    [ "$1" -lt 1 ] && echo "$FILENAME done."
    if [ "$1" -gt 0 ]; then
        print_help
        echo
        echo "$FILENAME aborted with errorcode $1:  $2"
        echo
    fi

    exit $1
}


## ---------------------------------------------------------


# if parameter 1 is given, just do lowering, rotating and renaming
if [ ! ${JUSTDLDIRPROCESSING} ]; then

    [ ! -d "${DLDIR}" ] && myexit 1 "DLDIR \"${DLDIR}\" is not an existing directory"
    [ ! -d "${DESTDIR}" ] && myexit 2 "DESTDIR \"${DESTDIR}\" is not an existing directory"
    [ ! -d "${MOUNTPOINT}" ] && myexit 3 "MOUNTPOINT \"${MOUNTPOINT}\" is not an existing directory"

    report "switching to $DLDIR and invoking download"
    #[ -d "${DLDIR}" ] || mkdir "${DLDIR}"
    cd "${DLDIR}"

    eval "${DOWNLOADTOOL} ${DOWNLOADTOOLPAR}"
fi


#NOTE: "camera_get_last_ls error" is not a problem but unfortunately has 
#      the same exitcode (1) as other errors, which _are_ a problem, which
#      in fact _is_ a problem ;-)

#FIXXME: check, if some files were downloaded at all

short_unconfirmed_info "lowering all filenames of downloaded files"
${LOWERTOOL} *

short_unconfirmed_info "rotating all images to correct position"
${JHEAD} -autorot *.jpg

short_unconfirmed_info "adding date and time to filenames of images"
${JHEAD} ${JHEAD_DATEPAR} *.jpg

## following line is NOT solved by using jhead any more because of my
## current DigiCam A80 is capable of making avi-movie files which
## don't have EXIF-data. 'date2name' takes the file timestamp (which
## is equal to the timestamp when the photo was taken) and adds it
## to the filename.
report "adding date and time to filenames of movies"
${DATE_TO_NAME_TOOL} *.avi *.mp* 

#short_unconfirmed_info "changing all files for user $DESTUSER"
#TMP#chown ${DESTUSER}:${DESTGRP} ${DLDIR}/*

#FIXXME: check, if valid destdir

# if parameter 1 is given, just do lowering, rotating and renaming
if [ ! ${JUSTDLDIRPROCESSING} ]; then
    short_unconfirmed_info "moving al files to $DESTDIR"
    mv "${DLDIR}"/* "${DESTDIR}"
fi

#FIXXME: check error-code of mv-stmt

confirmed_info "${OUTPUTTOOLNAME} is finished." "New photos can be found at \"${DESTDIR}\"."

#end
