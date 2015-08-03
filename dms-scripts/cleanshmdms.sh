#!/bin/sh
SHM=${SHM}
##======================================================================
##-- cleanshmdms
##
##-- Cleanup Shared Memory
##
##======================================================================
echo "`date`"

if [ "${SHM}" != "" ]
then

	echo "Cleaning shared memory (${SHM})..."
	ipcrm -M ${SHM} 2> /dev/null
	if [ $? -ne 0 ]; then
		echo "WARNINIG: Shared memory (${SHM}) was not removed ..."
	fi

	echo "Cleaning semaphore (${SHM})..."
	ipcrm -S ${SHM} 2> /dev/null
	if [ $? -ne 0 ]; then
		echo "WARNINIG: Semaphore (${SHM}) was not removed ..."
	fi

fi

