.PHONY: test
test:
	echo "yes"

molnut:
	rm -rf data/molnut; cp -r ./data/old.molnut ./data/molnut; ./data/urbit -L ./data/molnut

zod:
	rm -rf data/zod; cp -r ./data/old.zod ./data/zod; ./data/urbit -L ./data/zod

dopzod:
	rm -rf data/dopzod; cp -r ./data/old.dopzod ./data/dopzod; ./data/urbit -L ./data/dopzod


.PHONY: molnut zod dopzod
