# Set Default Apps on macOS / Howto make Outlook and Chrome default URL handlers for http and mailto:
 
Guess many want to have some specific apps handling defined URL handlers like mailto and http. Below some details on how to do this
 
The Handlers for the Applications are located in a binary encoded file here:  ~/Library/Preferences/com.apple.LauchServices.plist
To modify, you first need to convert to XML, modify and re-encode again. You can do it like this:

1) plutil -convert xml1 file
2) Edit using "defaults write"
3) plutil -convert binary1 file
 
Find attached a script that sets Outlook as default Mail/Calendar app and Chrome as default browser.
Prerequisites: None, tested on macOS 10.12.4.
 
