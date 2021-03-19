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
	make dopzod-clean

dopzod-clean:
	tmux send-keys -t dopzod "C-l"; sleep 0.4
	tmux send-keys -t dopzod "|fade %lfs-client" "ENTER"; sleep 0.4
	rsync -a --ignore-times ./src/ ./data/dopzod/home/
	tmux send-keys -t dopzod "|commit %home" "ENTER"; sleep 1
	tmux send-keys -t dopzod "|start %lfs-client" "ENTER"; sleep 2
	tmux send-keys -t dopzod ":lfs-client &lfs-client-action [%add-provider ~zod]" "ENTER"; sleep 0.5
	#tmux send-keys -t dopzod ":lfs-client &lfs-client-action [%request-upload ~dopzod]" "ENTER"; sleep 0.5

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
	make zod-clean

zod-clean:
	tmux send-keys -t zod "C-l"; sleep 0.4
	tmux send-keys -t zod "|fade %lfs-provider" "ENTER"; sleep 0.4
	tmux send-keys -t zod "|fade %lfs-client" "ENTER"; sleep 0.4
	rsync -a --ignore-times ./src/ ./data/zod/home/
	tmux send-keys -t zod "|commit %home" "ENTER"; sleep 1
	tmux send-keys -t zod "|start %lfs-provider" "ENTER"; sleep 2
	tmux send-keys -t zod "|start %lfs-client" "ENTER"; sleep 2
	tmux send-keys -t zod ":lfs-provider &lfs-provider-action [%connect-server loopback=\"localhost:8081\" fileserver=\"localhost:8000\" token=\"hunter2\"]"; sleep 0.5; tmux send-keys -t zod "ENTER"; sleep 0.5
	tmux send-keys -t zod ":lfs-client &lfs-client-action [%add-provider ~zod]" "ENTER"; sleep 1
	tmux send-keys -t zod ":lfs-client &lfs-client-action [%request-upload ~zod]" "ENTER"; sleep 1

.PHONY: zod-deep-clean zod-clean
