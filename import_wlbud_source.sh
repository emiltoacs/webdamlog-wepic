#!/bin/bash
# a not so awesome script to copy my webdamlog implementation into rails project

FROMPATH="../webdamlogengine/lib/"
FROMFILE="wlbud.rb"
FROMFILE2="webdamlog_runner.rb"
FROMSUBDIR="wlbud"
FROMSUBDIR2="bud"
FROMSUBSUBDIR="tools"

TOLIB="lib"
TOPATH="${TOLIB}/webdamlog"
TOSUBPATH="${TOPATH}/${FROMSUBDIR}"
TOSUBPATH2="${TOPATH}/${FROMSUBDIR2}"
TOSUBSUBPATH="${TOSUBPATH}/${FROMSUBSUBDIR}"

if [ -d  "${FROMPATH}" ] ; then
    if [ -f  "${FROMPATH}${FROMFILE}" -a -f  "${FROMPATH}${FROMFILE2}" -a -d "${FROMPATH}${FROMSUBDIR}" -a -d "${FROMPATH}${FROMSUBDIR}/${FROMSUBSUBDIR}" ] ; then
	if ! [[ -d ${TOPATH} ]] ; then
	    mkdir $TOPATH ;
	else
	    rm ${TOPATH}/*.rb
	fi
	# clean rule directory
	if [ -d  "${TOPATH}/wlrule_to_bud/" ] ; then
            rm -r ${TOPATH}/wlrule_to_bud/
	fi
	# copy root file
	cp ${FROMPATH}*.rb $TOPATH ;
	if ! [[ -d ${TOSUBPATH} ]] ; then
	    mkdir $TOSUBPATH ;
	else
	    rm ${TOSUBPATH}/*.rb ;
	    rm ${TOSUBPATH}/*.treetop ;
	fi
	if ! [[ -d ${TOSUBPATH2} ]] ; then
	    mkdir $TOSUBPATH2 ;
	else
	    rm ${TOSUBPATH2}/*.rb ;
	fi
	# copy sub directories and content
	cp ${FROMPATH}${FROMSUBDIR}/*.rb ${TOSUBPATH} ;
	cp ${FROMPATH}${FROMSUBDIR}/*.treetop $TOSUBPATH ;
	cp ${FROMPATH}${FROMSUBDIR2}/*.rb ${TOSUBPATH2} ;
	if ! [[ -d ${TOSUBSUBPATH} ]] ; then
	    mkdir ${TOSUBSUBPATH}
	else
	    rm ${TOSUBSUBPATH}/* ;
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