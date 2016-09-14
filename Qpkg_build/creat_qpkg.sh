#!/bin/sh
	./qpkg_build_QNAP.sh debian6 debian6.tgz built-in.sh -f QNAPQPKG -v 1.1.0
	mv debian6_* delivery/
	chmod +x delivery/debian6_*
