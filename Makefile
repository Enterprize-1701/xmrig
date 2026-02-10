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

start.15:
	sudo ./build/xmrig -c $(CURDIR)/config.x.json --cpu-max-threads-hint=15

start.20:
	sudo ./build/xmrig -c $(CURDIR)/config.x.json --cpu-max-threads-hint=20

start.25:
	sudo ./build/xmrig -c $(CURDIR)/config.x.json --cpu-max-threads-hint=25

start.30:
	sudo ./build/xmrig -c $(CURDIR)/config.x.json --cpu-max-threads-hint=30

start.35:
	sudo ./build/xmrig -c $(CURDIR)/config.x.json --cpu-max-threads-hint=35

start.40:
	sudo ./build/xmrig -c $(CURDIR)/config.x.json --cpu-max-threads-hint=40

start.50:
	sudo ./build/xmrig -c $(CURDIR)/config.x.json --cpu-max-threads-hint=50

start.100:
	sudo ./build/xmrig -c $(CURDIR)/config.x.json --cpu-max-threads-hint=100
