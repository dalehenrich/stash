#!/usr/bin/env bash
#
# invocation
#		install.sh <stone-name> <stone-vers>

set -ex

stoneName="$1"
shift
stoneVers="$1"
shift

scriptFile=`realpath $0`
scriptDir=`dirname "$scriptFile"`

pushd  /usr/bin
	if [ ! -d gsdevkit ] ; then
		sudo mkdir gsdevkit
	fi
	cd gsdevkit
	if [ ! -e smalltalk ] ; then
		sudo ln -s $scriptDir/gsdevkit_smalltalk_interpretter smalltalk
		sudo ln -s $scriptDir/gsdevkit_smalltalk_350_interpretter smalltalk_350
		sudo ln -s $scriptDir/gsdevkit_topaz_interpretter topaz
		sudo ln -s $scriptDir/gsdevkit_topaz_350_interpretter topaz_350
	fi
popd

if [ -d "$GS_HOME/server/stones/$stoneName" ] ; then
	startStone -b $stoneName
else
	createStone -G $stoneName $stoneVers
fi

export GEMSTONE_SCRIPT_ARGS="$stoneName -lq"
export GEMSTONE_SCRIPT_SOLO_EXTENT="$GS_HOME/server/stones/$stoneName/snapshots/solo_extent0.dbf"
export GEMSTONE_SOLO_SCRIPT_ARGS="$stoneName -lq -C GEM_SOLO_EXTENT=\$GEMSTONE_SCRIPT_SOLO_EXTENT;"

$scriptDir/../scripts/install.tpz

stopStone $stoneName
cp "$GS_HOME/server/stones/$stoneName/extents/extent0.dbf" "$GEMSTONE_SCRIPT_SOLO_EXTENT"

