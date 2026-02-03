SHELL := /bin/bash
list:
	@echo ""
	@echo "Targets:"
	@echo ""
	@echo "  - 'start.local' > start local miner"
	@echo "  - 'start.67' > start rig-67"

start.local:
	sudo ./build/xmrig -c config.json --threads=6

start.67:
	sudo ./build/xmrig -c $(CURDIR)/config.x.json
