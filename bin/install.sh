#!/usr/bin/env bash
#
# invocation
#		install.sh <stone-name> <stone-vers>

set -e

stoneName="$1"
shift
stoneVers="$1"
shift

scriptFile=`realpath $0`
scriptDir=`dirname "$scriptFile"`

pushd  /usr/bin
	if [ ! -d gemstone ] ; then
		sudo mkdir gemstone
	fi
	cd gemstone
	if [ ! -e smalltalk ] ; then
		sudo ln -s $scriptDir/gsdevkit_smalltalk_350_interpretter smalltalk
		sudo ln -s $scriptDir/gsdevkit_topaz_350_interpretter topaz
		sudo ln -s $scriptDir/gsdevkit_topaz_solo_interpretter topaz_solo
	fi
popd

if [ -d "$GS_HOME/server/stones/$stoneName" ] ; then
	startStone -b $stoneName
else
	createStone -G $stoneName $stoneVers
	cat - >> $GS_HOME/server/stones/${stoneName}/custom_stone.env << EOF
	export ROWAN_PROJECTS_HOME=$GS_HOME/shared/repos
EOF
	stopNetldi $stoneName
	startNetldi $stoneName
fi

export ROWAN_PROJECTS_HOME=$GS_HOME/shared/repos

if [ ! -d "$GS_HOME/shared/repos/Rowan" ] ; then
	pushd $GS_HOME/shared/repos
		git clone https://github.com/GemTalk/Rowan.git
		cd Rowan
		git checkout candidateV2.0
	popd
fi

$scriptDir/../scripts/install.tpz $stoneName -l

# create the solo extent
snapshotDir="$Gs_HOME/server/stones/$stoneName/snapshots"
$scriptDir/../scripts/snapshot.st --dir=$snapshotDir stash.dbf -- $stoneName -l

