#!/bin/bash -
#title          :SetDefaultApps
#description    :Set Outlook as default Mail/Calendar app and Chrome as default users
#author         :Sebastien Harnist
#date           :2017-02-22
#version        :1.0
#usage          :./SetDefaultApps.sh
#notes          :
#============================================================================

### Revision History:
##
## Date				Version		Personnel			Notes
## ----          -------   ----------------       -----
## 2017-02-22		1.0			Sebastien Harnist				Script created
##
######################################################################################################
loggedInUser=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`
loggedInUserHome=$( dscl . read /Users/$loggedInUser NFSHomeDirectory | awk '{print $NF}' )
PLIST="$loggedInUserHome/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist"
ARGS=$#
ARG1=$1
ARG2=$2
######################################################################################################

if [ $ARGS -eq 1 ];
then
  if [ $ARG1 == "--revert" ];
    then
      if [ ! -f "$PLIST.changes"  ];
        then
          echo "In revert mode with no .changes file, bailing out"
        else
          echo "In revert mode, reverting changes"
          ITEMSBEFORE=`grep ItemsBefore $PLIST.changes | cut -f 2 -d ":"`
          ITEMSAFTER=`grep ItemsAfterChrome $PLIST.changes | cut -f 2 -d ":"`
          /usr/bin/plutil -convert xml1 "$PLIST"
          for i in $(seq $ITEMSAFTER $ITEMSBEFORE)
            do
              /usr/libexec/plistbuddy -c "delete:LSHandlers:$i" "$PLIST" >/dev/null 2>&1
            done
          /usr/bin/plutil -convert binary1 "$PLIST"
          rm "$PLIST.changes"
      fi
    fi
else
  if [ ! -f "$PLIST.changes"  ];
  then
    cp "$PLIST" "$PLIST.bkp"

    /usr/bin/plutil -convert xml1 "$PLIST"
    i=`grep "<dict>" "$PLIST" | wc -l`
    i=$((i-1))
    i=$((i/2))
    echo "ItemsBefore:$i" > "$PLIST.changes"

    #Set Microsoft Outlook as Default
    /usr/libexec/plistbuddy -c "add:LSHandlers:$i:LSHandlerURLScheme string mailto" "$PLIST" >/dev/null 2>&1
    /usr/libexec/plistbuddy -c "add:LSHandlers:$i:LSHandlerRoleAll string com.microsoft.outlook" "$PLIST" >/dev/null 2>&1
    i=$((i+1))
    /usr/libexec/plistbuddy -c "add:LSHandlers:$i:LSHandlerContentType string com.apple.mail.email" "$PLIST" >/dev/null 2>&1
    /usr/libexec/plistbuddy -c "add:LSHandlers:$i:LSHandlerRoleAll string com.microsoft.outlook" "$PLIST" >/dev/null 2>&1
    i=$((i+1))
    /usr/libexec/plistbuddy -c "add:LSHandlers:$i:LSHandlerContentType string com.microsoft.outlook16.email-message" "$PLIST" >/dev/null 2>&1
    /usr/libexec/plistbuddy -c "add:LSHandlers:$i:LSHandlerRoleAll string com.microsoft.outlook" "$PLIST" >/dev/null 2>&1
    i=$((i+1))
    /usr/libexec/plistbuddy -c "add:LSHandlers:$i:LSHandlerContentType string public.vcard" "$PLIST" >/dev/null 2>&1
    /usr/libexec/plistbuddy -c "add:LSHandlers:$i:LSHandlerRoleAll string com.microsoft.outlook" "$PLIST" >/dev/null 2>&1
    i=$((i+1))
    /usr/libexec/plistbuddy -c "add:LSHandlers:$i:LSHandlerContentType string com.apple.ical.ics" "$PLIST" >/dev/null 2>&1
    /usr/libexec/plistbuddy -c "add:LSHandlers:$i:LSHandlerRoleAll string com.microsoft.outlook" "$PLIST" >/dev/null 2>&1
    i=$((i+1))
    /usr/libexec/plistbuddy -c "add:LSHandlers:$i:LSHandlerContentType string com.microsoft.outlook16.icalendar" "$PLIST" >/dev/null 2>&1
    /usr/libexec/plistbuddy -c "add:LSHandlers:$i:LSHandlerRoleAll string com.microsoft.outlook" "$PLIST" >/dev/null 2>&1

    echo "ItemsAfterOutlook:$i" >> "$PLIST.changes"

    #Set Google Chrome as default Browser
    i=$((i+1))
    /usr/libexec/plistbuddy -c "add:LSHandlers:$i:LSHandlerContentType string public.url" "$PLIST" >/dev/null 2>&1
    /usr/libexec/plistbuddy -c "add:LSHandlers:$i:LSHandlerRoleAll string com.google.chrome" "$PLIST" >/dev/null 2>&1
    i=$((i+1))
    /usr/libexec/plistbuddy -c "add:LSHandlers:$i:LSHandlerURLScheme string http" "$PLIST" >/dev/null 2>&1
    /usr/libexec/plistbuddy -c "add:LSHandlers:$i:LSHandlerRoleAll string com.google.chrome" "$PLIST" >/dev/null 2>&1
    i=$((i+1))
    /usr/libexec/plistbuddy -c "add:LSHandlers:$i:LSHandlerURLScheme string https" "$PLIST" >/dev/null 2>&1
    /usr/libexec/plistbuddy -c "add:LSHandlers:$i:LSHandlerRoleAll string com.google.chrome" "$PLIST" >/dev/null 2>&1
    i=$((i+1))
    /usr/libexec/plistbuddy -c "add:LSHandlers:$i:LSHandlerContentType string public.html" "$PLIST" >/dev/null 2>&1
    /usr/libexec/plistbuddy -c "add:LSHandlers:$i:LSHandlerRoleAll string com.google.chrome" "$PLIST" >/dev/null 2>&1

    echo "ItemsAfterChrome:$i" >> "$PLIST.changes"

    /usr/bin/plutil -convert binary1 "$PLIST"

  else
    echo "Changes already implemented"
  fi
fi
