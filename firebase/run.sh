clear

if [[ $1 == "--temp" ]]; then
    echo "Temp mode"
    firebase emulators:start 
else
    echo "Save mode"
    firebase emulators:start --import ./firebase_saves --export-on-exit
fi

