#!/bin/bash
# foldList=( brcm_directfb_1.7.7 setupWizard entone_vkb diagmenu opera4 PlatformUtils entone_mediaplayer EPL_APP EPL QtApps qt socket_source )
# foldList=( qt QtApps entone_mediaplayer EPL EPL_APP conaxDRM opera4 )
# foldList=( qt QtApps entone_mediaplayer EPL EPL_APP conaxDRM opera4 )
# foldList=( EPL EPL_APP verimatrixVr20 entone_mediaplayer opera4 )
# foldList=( EPL EPL_APP MvEPL entone_mediaplayer )
foldList=( EPL EPL_APP socket_source entone_mediaplayer )
# foldList=( WidevineCDM entone_mediaplayer EPL EPL_APP opera4 brcm_refsw_arm64 )
buildPath="$PWD"
tempPath="${buildPath}/../tempForTagMaking"

if [ ! -d ${tempPath} ]; then
    mkdir ${tempPath}
fi

# remove old tags
rm ${buildPath}/GPATH
rm ${buildPath}/GRTAGS
rm ${buildPath}/GTAGS

rm ${buildPath}/cscope.files
rm ${buildPath}/cscope.out
rm ${buildPath}/cscope.in.out
rm ${buildPath}/cscope.po.out

# move all folders to temp folder
mv ${buildPath}/* ${tempPath}

# pick the needed folders
for i in "${foldList[@]}"
do
    mv ${tempPath}/$i ${buildPath}
done
# make tags
echo "######### make GTag"
gtags
echo "######### prepare clang"
/home/sulfred/Documents/bin/prepareClang.sh
echo "######### make cscope"
find . -name "*.cc" -o -name "*.c" -o -name "*.cpp" -o -name "*.h" -o -name "*.hpp" > cscope.files
cscope -q -R -b -k -i cscope.files

# fall back to normal
mv ${tempPath}/* ${buildPath}
rm -rf ${tempPath}
