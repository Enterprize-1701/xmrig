SHELL := /bin/bash
list:
	@echo ""
	@echo "Targets:"
	@echo ""
	@echo "  - 'start.local' > start local miner"
	@echo "  - 'start.x4' > start 4 threads"
	@echo "  - 'start.x256' > start 128 threads"

start.local:
	sudo ./build/xmrig -c config.json --donate-level 0 --threads=6

start.x4:
	sudo ./build/xmrig -c config.x4.json --donate-level 0 --threads=4

start.x128:
	sudo ./build/xmrig -c config.x256.json --donate-level 0

start.x256:
	sudo ./build/xmrig -c config.x256.json

start.67:
	sudo ./build/xmrig -c $(CURDIR)/config.x256.json --pass="rig-67"
