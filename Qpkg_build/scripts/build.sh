#!/bin/sh

# global defs
QPKG_PACKAGE_SCRIPT=./script/qpkg_build_QNAP.sh
QPKG_BUILTIN_SCRIPT=./script/built-in.sh 

QPKG_NAME=Hello_QNAP
QPKG_VER=0.1
QPKG_PKG_FILE_NAME=${QPKG_NAME}-${QPKG_VER}.tgz

QPKG_INSTALL_SCRIPT=qinstall.sh
QPKG_INSTALL_SCRIPT_ARM_X09=qinstall-x09.sh
QPKG_INSTALL_SCRIPT_ARM_X19=qinstall-x19.sh
QPKG_INSTALL_SCRIPT_X86_X39=qinstall-x39.sh
QPKG_INSTALL_SCRIPT_ALL=qinstall-all.sh

NAS_MODELS=""
ALL_ARM_BASED_X09_MODELS="TS-109 TS-209 TS-409 TS-409U"
ALL_ARM_BASED_X19_MODELS="TS-119 TS-219"
ALL_X86_BASED_X39_MODELS="TS-509 TS-439 TS-639 TS-809 TS-809U TS-239 SS-439 SS-839"
ALL_MODELS="${ALL_ARM_BASED_X09_MODELS} ${ALL_ARM_BASED_X19_MODELS} ${ALL_X86_BASED_X39_MODELS}"

SRC_DIR_NAME=""
SRC_DIR_NAME_X09=src-x09
SRC_DIR_NAME_X19=src-x19
SRC_DIR_NAME_X39=src-x39
SRC_DIR_NAME_ALL=src-all

install(){
	echo "Stage 1 - compressing installation files... "
	mkdir temp
	cd temp
	cp -af ../$SRC_DIR_NAME/* .
	cp -af ../src-shared/* .
	tar -czf ../$QPKG_NAME.tgz . --exclude-tag-all=all-wcprops
	cd ../
	rm -rf temp
	
	echo "Stage 2 - inserting qinstall.sh..."
	tar -czf $QPKG_PKG_FILE_NAME $QPKG_INSTALL_SCRIPT $QPKG_NAME.tgz 
	rm -rf $QPKG_INSTALL_SCRIPT
	
	echo "Stage 3 - adding encrypted header & wrapping up into .qpkg files..."
		/bin/mkdir -p ../../../build
	for model in $NAS_MODELS; do
	        $QPKG_PACKAGE_SCRIPT  ${QPKG_NAME} ${QPKG_PKG_FILE_NAME} ${QPKG_BUILTIN_SCRIPT} -f QNAPQPKG -v ${QPKG_VER} -m ${model} #2>>/dev/null 
	done
	/bin/mv *.qpkg ../../../build
	/bin/rm -rf *.tgz
	echo "Done!"
}

case "$1" in
  x09)
	SRC_DIR_NAME=$SRC_DIR_NAME_X09	
	cp -af $QPKG_INSTALL_SCRIPT_ARM_X09 $QPKG_INSTALL_SCRIPT
	NAS_MODELS=$ALL_ARM_BASED_X09_MODELS
	install
	;;
	
  x19)
	SRC_DIR_NAME=$SRC_DIR_NAME_X19
	cp -af $QPKG_INSTALL_SCRIPT_ARM_X19 $QPKG_INSTALL_SCRIPT
	NAS_MODELS=$ALL_ARM_BASED_X19_MODELS  
        install
        ;;
	
  x39)
	SRC_DIR_NAME=$SRC_DIR_NAME_X39
	cp -af $QPKG_INSTALL_SCRIPT_X86_X39 $QPKG_INSTALL_SCRIPT
	NAS_MODELS=$ALL_X86_BASED_X39_MODELS  
        install
       	;;  

  all)
	SRC_DIR_NAME=$SRC_DIR_NAME_ALL
	cp -af $QPKG_INSTALL_SCRIPT_ALL $QPKG_INSTALL_SCRIPT
	NAS_MODELS=$ALL_MODELS
	install
	;;
  *)
	echo "Usage: $0 {x09|x19|x39|all}"
	exit 1
esac  
  
 
