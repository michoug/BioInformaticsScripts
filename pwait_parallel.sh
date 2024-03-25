## From https://stackoverflow.com/questions/38160/parallelize-bash-script-with-maximum-number-of-processes/880864#880864

function pwait() {
    while [ $(jobs -p | wc -l) -ge $1 ]; do
        sleep 1
    done
}

for i in *; do
    do_something $i &
    pwait 10
done
