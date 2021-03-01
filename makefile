# NOTE need to run "|mount %" on old.ship manually

dopzod-deep-clean:
	tmux has-session -t dopzod || (echo "\n\nRUN: tmux new -s dopzod"; exit 1)
	tmux send-keys -t dopzod "C-c"; sleep 0.3
	tmux send-keys -t dopzod "C-z"; sleep 0.3
	tmux send-keys -t dopzod "C-c"; sleep 0.3
	tmux send-keys -t dopzod "z lfs" "ENTER"
	rsync -a --delete ./data/old.dopzod/ ./data/dopzod
	tmux send-keys -t dopzod "./data/urbit -L ./data/dopzod" "ENTER"
	sleep 2.5 # startup eats ''enter keys'
	make dopzod-clean

dopzod-clean:
	tmux send-keys -t dopzod "C-l"; sleep 0.4
	tmux send-keys -t dopzod "|fade %lfs-provider" "ENTER"; sleep 0.4
	tmux send-keys -t dopzod "|fade %lfs-client" "ENTER"; sleep 0.4
	rsync -a --ignore-times ./src/ ./data/dopzod/home/
	tmux send-keys -t dopzod "|commit %home" "ENTER"; sleep 0.5
	tmux send-keys -t dopzod "|start %lfs-provider" "ENTER"; sleep 1
	tmux send-keys -t dopzod "|start %lfs-client" "ENTER"; sleep 1


.PHONY: dopzod-deep-clean dopzod-clean

