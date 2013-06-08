#!/bin/bash
# a not so awesome script to copy my webdamlog implementation into rails project

FROMPATH="../webdamlogengine/lib/"
FROMFILE="wlbud.rb"
FROMFILE2="webdamlog_runner.rb"
FROMSUBDIR="wlbud"
FROMSUBSUBDIR="tools"

TOLIB="lib"
TOPATH="${TOLIB}/webdamlog"
TOSUBPATH="${TOPATH}/${FROMSUBDIR}"
TOSUBSUBPATH="${TOSUBPATH}/${FROMSUBSUBDIR}"

if [ -d  "${FROMPATH}" ] ; then
    if [ -f  "${FROMPATH}${FROMFILE}" -a -f  "${FROMPATH}${FROMFILE2}" -a -d "${FROMPATH}${FROMSUBDIR}" -a -d "${FROMPATH}${FROMSUBDIR}/${FROMSUBSUBDIR}" ] ; then
	if ! [[ -d ${TOPATH} ]] ; then
	    mkdir $TOPATH ;
	fi
# clean rule directory
        rm -r ${TOPATH}
# copy root file
        rm ${TOPATH}/*.rb
	cp ${FROMPATH}*.rb $TOPATH ;
	if ! [[ -d ${TOSUBPATH} ]] ; then
	    mkdir $TOSUBPATH ;
	fi
# copy sub directories and content
        rm ${TOSUBPATH}/*.rb ;
	rm ${TOSUBPATH}/*.treetop ;
	cp ${FROMPATH}${FROMSUBDIR}/*.rb ${TOSUBPATH} ;
	cp ${FROMPATH}${FROMSUBDIR}/*.treetop $TOSUBPATH ;
	if ! [[ -d ${TOSUBSUBPATH} ]] ; then
	    mkdir ${TOSUBSUBPATH}
	fi
        rm ${TOSUBSUBPATH}/* ;
	cp ${FROMPATH}${FROMSUBDIR}/${FROMSUBSUBDIR}/* ${TOSUBSUBPATH} ;
	exit 0 ;
    else
	echo "don't find the right directory hierachy from source";
	exit 1;
    fi
else
    echo "don't find the root of source";
    exit 1;
fi