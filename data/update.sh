data=$(dirname "$(readlink -f "$0")")

if [ -f "$data/fakezod.tar"]; then
    # restore piers from backups
    rm -rf "$data/fakezod" "$data/fakewet"
    tar xf "$data/fakezod.tar"
    tar xf "$data/fakewet.tar"
else

    # create piers if needed
    if [ ! -d "$data/fakezod"]; then
        # create piers
        "$data/urbit" -x -F zod -c "$data/fakezod"
        "$data/urbit" -x -F wet -c "$data/fakewet"
    fi

    # backups
    tar cf "$data/fakezod.tar" "$data/fakezod"
    tar cf "$data/fakewet.tar" "$data/fakewet"
fi

