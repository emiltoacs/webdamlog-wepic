#!/bin/bash
# a not so awesome script to copy my webdamlog implementation into rails project

FROMPATH="../webdamlogengine/lib/"
FROMFILE="wlbud.rb"
FROMSUBDIR="wlbud"
FROMSUBSUBDIR="tools"

TOLIB="lib"
TOPATH="${TOLIB}/webdamlog"
TOSUBPATH="${TOPATH}/${FROMSUBDIR}"
TOSUBSUBPATH="${TOSUBPATH}/${FROMSUBSUBDIR}"

if [ -d  "${FROMPATH}" ] ; then
    if [ -f  "${FROMPATH}${FROMFILE}" -a -d "${FROMPATH}${FROMSUBDIR}" -a -d "${FROMPATH}${FROMSUBDIR}/${FROMSUBSUBDIR}" ] ; then
	if ! [[ -d ${TOPATH} ]] ; then
	    mkdir $TOPATH ;
	fi
	cp ${FROMPATH}${FROMFILE} $TOPATH ;
	if ! [[ -d ${TOSUBPATH} ]] ; then
	    mkdir $TOSUBPATH ;
	fi
	cp ${FROMPATH}${FROMSUBDIR}/*.rb ${TOSUBPATH} ;
	cp ${FROMPATH}${FROMSUBDIR}/*.treetop $TOSUBPATH ;
	if ! [[ -d ${TOSUBSUBPATH} ]] ; then
	    mkdir ${TOSUBSUBPATH}
	fi
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