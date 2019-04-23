#!/usr/bin/env bash
#
# invocation
#		install.sh <stone-name> <stone-vers>

set -e

if [ ! -d "$ROWAN_PROJECTS_HOME" ] ; then
	echo "expected environment variable \$ROWAN_PROJECTS_HOME to be defined"
	exit 1
fi

stoneName="$1"
shift

scriptFile=`realpath $0`
scriptDir=`dirname "$scriptFile"`

pushd  /usr/bin
	if [ ! -d gemstone ] ; then
		sudo mkdir gemstone
	fi
	cd gemstone
	if [ ! -e smalltalk ] ; then
		sudo ln -s $scriptDir/smalltalk_350_interpreter smalltalk
		sudo ln -s $scriptDir/topaz_350_interpreter topaz
	fi
popd

if [ ! -d "$ROWAN_PROJECTS_HOME/Rowan" ] ; then
	pushd $OWAN_PROJECTS_HOME
		git clone https://github.com/GemTalk/Rowan.git
		cd Rowan
		git checkout candidateV2.0
	popd
fi

if [ "$GS_HOME"x = "x" ] ; then
	# GsDevKit_home
	#		if $stoneName exists, then start it. Otherwise create a new stone
	#
	if [ -d "$GS_HOME/server/stones/$stoneName" ] ; then
		startStone -b $stoneName
	else
		stoneVers="$1"
		shift
		createStone -G $stoneName $stoneVers
	fi
	cat - >> $GS_HOME/server/stones/${stoneName}/custom_stone.env << EOF
export ROWAN_PROJECTS_HOME=$ROWAN_PROJECTS_HOME
EOF
	stopNetldi $stoneName
	startNetldi $stoneName

	$scriptDir/../scripts/install.tpz $stoneName $topazArgs
else
	# GEMSTONE - expect the stone to be running
	waitstone $stoneName

	$scriptDir/../scripts/install.tpz $topazArgs
fi



