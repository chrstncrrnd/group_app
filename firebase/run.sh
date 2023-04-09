clear

if [[ $1 == "--save" ]]; then
    echo "Save mode"
    firebase emulators:start --import ./firebase_saves --export-on-exit
else
    echo "Temp mode"
    firebase emulators:start 
fi

