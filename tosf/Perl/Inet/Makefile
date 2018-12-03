# Makefile to manage inet
# P Walsh Jan 2018

# Targets
#   clean --- clean all modules
#   tidy --- indent code in all modules 
#   runtest --- run bats in all modules
#   cover --- run cover in all modules

MODULES=Packet/Verification/Arp \
	Packet/Verification/Ethernet \
	Packet/Verification/Generic \
	Packet/Verification/Ip \
	Packet/Verification/Icmp \
	Packet/Verification/Udp \
	Record/Verification/Arp \
	Record/Verification/Nic \
	Record/Verification/Dcb \
	Record/Verification/Route \
	Table/Verification/ARP \
	Table/Verification/NIC \
	Table/Verification/DCB \
	Table/Verification/ROUTE \
	Fsm/Verification/SocConS \
	Fsm/Verification/SocConC \
	Fsm/Verification/StreamCon \

clean:
	@for m in $(MODULES); do \
		#((cd $$m; $(MAKE) clean;) > /dev/null) \
		(cd $$m; $(MAKE) clean;) \
	done

tidy:
	@for m in $(MODULES); do \
		((cd $$m; $(MAKE) tidy;) > /dev/null 2>&1) \
	done


runtest:
	@for m in $(MODULES); do \
		(cd $$m; $(MAKE) bats;) \
	done

cover:
	@for m in $(MODULES); do \
		(cd $$m; $(MAKE) cover;) \
	done

