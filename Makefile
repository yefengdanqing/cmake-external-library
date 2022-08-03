.PHONY: all

docker:
	@docker exec -it cmake-external-library-debug /bin/bash

clean: scripts/clean.sh
	@bash $< $(tgt)