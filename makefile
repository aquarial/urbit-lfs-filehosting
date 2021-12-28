# NOTE https://github.com/aquarial/urbit-lfs-filehosting/issues/1
#
# make create-new-clean-zod     # build old.untouched.zod from scratch
#
# make create-modified-zod      # re builds desks using up to date urbit source
#
# make zod-clean-deep           # build lfs-client onto modified zod
#
# make reload-zod               # reload lfs-client
#


# make build-deploy             # copy latest lfs-client + src packages into /out
# make start-fileserver         # start debug fileserver


.PHONY: choose
choose:
	echo 'choose a target'

.PHONY: create-new-clean-zod
create-new-clean-zod:
	tmux has-session -t zod ||      \
	    (echo "\n\nRUN: tmux new -s zod in other terminal"; exit 1)
	rm -rf ./data/ignored/zod
	rm -rf ./data/ignored/old.zod
	rm -rf ./data/ignored/old.untouched.zod
	tmux send-keys -t zod "cd $$(pwd)" "ENTER"
	tmux send-keys -t zod "./data/ignored/urbit -F zod -c ./data/ignored/old.untouched.zod" "ENTER"
	echo "\n\n wait until boot to run create-modified-zod . will take a minute or two \n\n"

.PHONY: create-modified-zod
create-modified-zod:
	tmux has-session -t zod ||      \
	    (echo "\n\nRUN: tmux new -s zod in other terminal"; exit 1)
	tmux send-keys -t zod "C-c"; sleep 0.3
	tmux send-keys -t zod "C-z"; sleep 0.3
	tmux send-keys -t zod "C-c"; sleep 0.3
	tmux send-keys -t zod "cd $$(pwd)" "ENTER"
	rsync -a --delete ./data/ignored/old.untouched.zod/ ./data/ignored/old.zod
	tmux send-keys -t zod "./data/ignored/urbit ./data/ignored/old.zod" "ENTER"; sleep 1
	tmux send-keys -t zod "|mount %garden" "ENTER"; sleep 0.8
	tmux send-keys -t zod "|mount %webterm" "ENTER"; sleep 0.8
	tmux send-keys -t zod "|mount %landscape" "ENTER"; sleep 0.8
	 #tmux send-keys -t zod "|mount %base" "ENTER"; sleep 0.8
	tmux send-keys -t zod "|mount %bitcoin" "ENTER"; sleep 0.8
	sleep 3;
	rm -rf ./data/ignored/old.zod/*
	cp -RL ../urbit-git/pkg/garden ./data/ignored/old.zod/
	cp -RL ../urbit-git/pkg/webterm ./data/ignored/old.zod/
	cp -RL ../urbit-git/pkg/landscape ./data/ignored/old.zod/
	 # cp -RL ../urbit-git/pkg/base ./data/ignored/old.zod/
	cp -RL ../urbit-git/pkg/bitcoin ./data/ignored/old.zod/
	sleep 2;
	tmux send-keys -t zod "|commit %garden" "ENTER"; sleep 0.3
	tmux send-keys -t zod "|commit %webterm" "ENTER"; sleep 0.3
	tmux send-keys -t zod "|commit %landscape" "ENTER"; sleep 0.3
	 #tmux send-keys -t zod "|commit %base" "ENTER"; sleep 0.3
	tmux send-keys -t zod "|commit %bitcoin" "ENTER"; sleep 0.3
	tmux send-keys -t zod "C-d"; sleep 0.3
	echo "setup for zod-clean-deep"


.PHONY: zod-deep-clean
zod-clean-deep:
	tmux has-session -t zod ||      \
	    (echo "\n\nRUN: tmux new -s zod in other terminal"; exit 1)
	tmux send-keys -t zod "C-c"; sleep 0.3
	tmux send-keys -t zod "C-z"; sleep 0.3
	tmux send-keys -t zod "C-c"; sleep 0.3
	tmux send-keys -t zod "cd $$(pwd)" "ENTER"
	rsync -a --delete --ignore-times ./data/ignored/old.zod/ ./data/ignored/zod
	tmux send-keys -t zod "./data/ignored/urbit -L ./data/ignored/zod" "ENTER"
	sleep 1.5 # startup eats ''enter keys'
	tmux send-keys -t zod "C-l"; sleep 0.4
	tmux send-keys -t zod "|merge %lfs-client our %webterm" "ENTER"; sleep 3;
	 # update package
	tmux send-keys -t zod "|mount %lfs-client" "ENTER"; sleep 3
	rm -rf                              ./data/ignored/zod/lfs-client/*
	cp -RL ../urbit-git/pkg/landscape/* ./data/ignored/zod/lfs-client/
	cp -RL ../urbit-git/pkg/garden/*    ./data/ignored/zod/lfs-client/
	rsync -a --ignore-times ./gall-app/ ./data/ignored/zod/lfs-client/; sleep 1
	 #
	tmux send-keys -t zod "|commit %lfs-client" "ENTER"; sleep 3
	tmux send-keys -t zod "|install our %lfs-client" "ENTER"; sleep 10
	 #
	 # can't figure this out yet...
	 #curl --cookie "$$(curl -i localhost:8080/~/login -X POST -d 'password=lidlut-tabwed-pillex-ridrup' | rg set-cookie | sed 's/set-cookie..//' | sed 's/;.*//')" --form "desk=lfs-client" --form "glob=<html-glob/index.html;filename=html-glob/index.html" http://localhost:8080/docket/upload
	 # setup provider
	tmux send-keys -t zod "|rein %lfs-client [& %lfs-provider]" "ENTER"; sleep 5;
	tmux send-keys -t zod ":lfs-provider &lfs-provider-command "; sleep 2;
	tmux send-keys -t zod "[threadid=~ %connect-server loopback=\"http://localhost:8080\" fileserver=\"http://localhost:8000\" token=\"hunter2\"]"; sleep 0.5; tmux send-keys -t zod "ENTER"; sleep 2
	 #tmux send-keys -t zod ":lfs-provider &lfs-provider-command ";
	 #tmux send-keys -t zod "[threadid=~ %add-rule justification=[%ship ships=~[~zod ~dopzod]] size=1.000.000.000]"; sleep 0.5; tmux send-keys -t zod "ENTER"; sleep 0.5
	sleep 4;
	tmux send-keys -t zod ":lfs-client &lfs-client-action [threadid=~ %add-provider ~zod]"; sleep 0.5; tmux send-keys -t zod "ENTER"; sleep 0.5
	 #tmux send-keys -t zod ":lfs-client &lfs-client-action [threadid=~ %request-upload ~zod ~]"; sleep 0.5; tmux send-keys -t zod "ENTER"; sleep 0.5


.PHONY: build-deploy
build-deploy:
	mkdir -p ./out/
	rm -rf out/*
	cp -RL ../urbit-git/pkg/landscape/* ./out/
	cp -RL ../urbit-git/pkg/garden/*    ./out/
	rm ./out/desk.ship
	rsync -a --ignore-times ./gall-app/ ./out/

.PHONY: reload-zod
reload-zod:
	tmux send-keys -t zod "C-l";
	rsync -a --ignore-times ./gall-app/ ./data/ignored/zod/home/; sleep 0.3
	tmux send-keys -t zod "|commit %lfs-client" "ENTER"; sleep 1
	#tmux send-keys -t zod "KP-"
	#tmux send-keys -t zod "lfs-client-action" "ENTER"
	#tmux send-keys -t zod "=parse -build-file %/lib/parse/hoon" "ENTER"
	#tmux send-keys -t zod "a:parse" "ENTER"


.PHONY: start-fileserver
start-fileserver:
	cd ./fileserver && ROCKET_PORT=8000 cargo run -- --UNSAFE_DEBUG_AUTH --add-cors-headers

