# NOTE
#
# create ./data/urbit -F dopzod
# on ship run  "|mount %"
# mv ./dopzod ./data/old.dopzod


# dopzod is only the client. run zod for provider&client
dopzod-clean-deep:
	tmux has-session -t dopzod ||      \
	    (echo "\n\nRUN: tmux new -s dopzod in other terminal"; exit 1)
	tmux send-keys -t dopzod "C-c"; sleep 0.3
	tmux send-keys -t dopzod "C-z"; sleep 0.3
	tmux send-keys -t dopzod "C-c"; sleep 0.3
	tmux send-keys -t dopzod "cd $$(pwd)" "ENTER"
	rsync -a --delete ./data/old.dopzod/ ./data/dopzod
	tmux send-keys -t dopzod "./data/urbit -L ./data/dopzod" "ENTER"
	sleep 1.5 # startup eats ''enter keys'
	tmux send-keys -t dopzod "C-l"; sleep 0.4
	rsync -a --ignore-times ./gall-app/ ./data/dopzod/home/
	tmux send-keys -t dopzod "|commit %home" "ENTER"; sleep 1
	tmux send-keys -t dopzod "|start %lfs-client" "ENTER"; sleep 2
	tmux send-keys -t dopzod ":lfs-client &lfs-client-action [threadid=~ [%add-provider ~zod]]" "ENTER"; sleep 0.5
	tmux send-keys -t dopzod ":lfs-client &lfs-client-action [threadid=~ [%request-upload ~zod ~]]" "ENTER"; sleep 0.5

.PHONY: dopzod-deep-clean dopzod-clean



# zod is both provider and client

zod-clean-deep:
	tmux has-session -t zod ||      \
	    (echo "\n\nRUN: tmux new -s zod in other terminal"; exit 1)
	tmux send-keys -t zod "C-c"; sleep 0.3
	tmux send-keys -t zod "C-z"; sleep 0.3
	tmux send-keys -t zod "C-c"; sleep 0.3
	tmux send-keys -t zod "cd $$(pwd)" "ENTER"
	rsync -a --delete ./data/old.zod/ ./data/zod
	tmux send-keys -t zod "./data/urbit -L ./data/zod" "ENTER"
	sleep 1.5 # startup eats ''enter keys'
	tmux send-keys -t zod "C-l"; sleep 0.4
	rsync -a --ignore-times ./gall-app/ ./data/zod/home/
	tmux send-keys -t zod "|commit %home" "ENTER"; sleep 1
	tmux send-keys -t zod "|start %lfs-provider" "ENTER"; sleep 3
	tmux send-keys -t zod "|start %lfs-client" "ENTER"; sleep 3
	tmux send-keys -t zod ":lfs-provider &lfs-provider-command "; sleep 2;
	tmux send-keys -t zod "[%connect-server loopback=\"http://localhost:8080\" fileserver=\"http://localhost:8000\" token=\"hunter2\"]"; sleep 0.5; tmux send-keys -t zod "ENTER"; sleep 0.5
	tmux send-keys -t zod ":lfs-provider &lfs-provider-command ";
	tmux send-keys -t zod "[%add-rule justification=[%ship ships=~[~zod ~dopzod]] size=1.000.000.000]"; sleep 0.5; tmux send-keys -t zod "ENTER"; sleep 0.5
	sleep 4;
	tmux send-keys -t zod ":lfs-client &lfs-client-action [threadid=~ %add-provider ~zod]"; sleep 0.5; tmux send-keys -t zod "ENTER"; sleep 0.5
	tmux send-keys -t zod ":lfs-client &lfs-client-action [threadid=~ %request-upload ~zod ~]"; sleep 0.5; tmux send-keys -t zod "ENTER"; sleep 0.5

reload-zod:
	tmux send-keys -t zod "C-l";
	rsync -a --ignore-times ./gall-app/ ./data/zod/home/; sleep 0.3
	tmux send-keys -t zod "|commit %home" "ENTER"; sleep 1
	#tmux send-keys -t zod "KP-"
	#tmux send-keys -t zod "lfs-client-action" "ENTER"

.PHONY: zod-deep-clean zod-clean reload-zod


start-fileserver:
	cd ./fileserver && ROCKET_PORT=8000 cargo run -- --UNSAFE_DEBUG_AUTH --add-cors-headers

.PHONY: start-fileserver


.PHONY: demo
demo:
	tmux has-session -t zod ||      \
	    (echo "\n\nRUN: tmux new -s zod in other terminal"; exit 1)
	tmux send-keys -t zod "C-c"; sleep 0.3
	tmux send-keys -t zod "C-z"; sleep 0.3
	tmux send-keys -t zod "C-c"; sleep 0.3
	tmux send-keys -t zod "cd $$(pwd)" "ENTER"
	rsync -a --delete ./data/old.zod/ ./data/zod
	tmux send-keys -t zod "./data/urbit -L ./data/zod" "ENTER"
	sleep 1.5 # startup eats ''enter keys'
	tmux send-keys -t zod "C-l"; sleep 0.4
	#
	rsync -a --ignore-times ./gall-app/ ./data/zod/home/
	tmux send-keys -t zod "|commit %home" "ENTER"; sleep 1
	tmux send-keys -t zod "|start %lfs-provider" "ENTER"; sleep 3
	#
	#
	tmux has-session -t dopzod ||      \
	    (echo "\n\nRUN: tmux new -s dopzod in other terminal"; exit 1)
	tmux send-keys -t dopzod "C-c"; sleep 0.3
	tmux send-keys -t dopzod "C-z"; sleep 0.3
	tmux send-keys -t dopzod "C-c"; sleep 0.3
	tmux send-keys -t dopzod "cd $$(pwd)" "ENTER"
	rsync -a --delete ./data/old.dopzod/ ./data/dopzod
	tmux send-keys -t dopzod "./data/urbit -L ./data/dopzod" "ENTER"
	sleep 1.5 # startup eats ''enter keys'
	tmux send-keys -t dopzod "C-l"; sleep 0.4
	rsync -a --ignore-times ./gall-app/ ./data/dopzod/home/
	tmux send-keys -t dopzod "|commit %home" "ENTER"; sleep 1
	tmux send-keys -t dopzod "|start %lfs-client" "ENTER"; sleep 2
