if [ ! -f "./data/urbit" ]; then
    echo "File not found: ./data/urbit"
    echo "wrong directory?"
    exit 0;
fi

# Restore piers from backups, or create backups

if [ -f "./data/molnut.tar" ]; then
    echo "restore piers from backups"; sleep 2;
    rm -rf "./data/molnut" # "./data/fakewet"
    tar xf "./data/molnut.tar" --strip-components 1
    # tar xf "./data/fakewet.tar" --strip-components 1
else

    # create piers if needed
    if [ ! -d "./data/molnut" ]; then
        echo "create piers"; sleep 2;
        "./data/urbit" -x -F zod -c "./data/molnut"
        # "./data/urbit" -x -F wet -c "./data/fakewet"
    fi

    echo "create backups"; sleep 2;
    tar cf "./data/molnut.tar" "./data/molnut"
    # tar cf "./data/fakewet.tar" "./data/fakewet"
fi

