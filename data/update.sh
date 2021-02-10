if [ ! -f "./data/urbit" ]; then
    echo "File not found: ./data/urbit"
    echo "wrong directory?"
    exit 0;
fi

# Restore piers from backups, or create backups

if [ -f "./data/fakezod.tar" ]; then
    echo "restore piers from backups"; sleep 2;
    rm -rf "./data/fakezod" "./data/fakewet"
    tar xf "./data/fakezod.tar"
    tar xf "./data/fakewet.tar"
else

    # create piers if needed
    if [ ! -d "./data/fakezod" ]; then
        echo "create piers"; sleep 2;
        "./data/urbit" -x -F zod -c "./data/fakezod"
        "./data/urbit" -x -F wet -c "./data/fakewet"
    fi

    echo "create backups"; sleep 2;
    tar cf "./data/fakezod.tar" "./data/fakezod"
    tar cf "./data/fakewet.tar" "./data/fakewet"
fi

