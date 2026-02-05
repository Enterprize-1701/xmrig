SHELL := /bin/bash
list:
	@echo ""
	@echo "Targets:"
	@echo ""
	@echo "  - 'start.local' > start local miner"
	@echo "  - 'start' > start rig"

start.local:
	sudo ./build/xmrig -c config.json --threads=6

start:
	sudo ./build/xmrig -c $(CURDIR)/config.x.json

start.50:
	sudo ./build/xmrig -c $(CURDIR)/config.x.json --cpu-max-threads-hint=50

start.100:
	sudo ./build/xmrig -c $(CURDIR)/config.x.json --cpu-max-threads-hint=100
