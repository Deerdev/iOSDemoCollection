#!/bin/sh

#  WaterMarkIconForDebug.sh
#  XcconfigExample
#
#  Created by daoquan on 2018/1/29.
#  Copyright © 2018年 deerdev. All rights reserved.
export PATH=/opt/local/bin/:/opt/local/sbin:$PATH:/usr/local/bin:

convertPath=`which convert`

if [[ ! -f ${convertPath} || -z ${convertPath} ]]; then
    echo "==============
    WARNING: 你需要先安装 ImageMagick！！！！:
    brew install imagemagick
    =============="
    exit 0;
fi

debugIconDirPath="./XcconfigExample/Assets.xcassets/AppIcon-Dev.appiconset"
preIconDirPath="./AppIcon-Pre.appiconset"


function generateIcon() {
	echo "process..."
    base_file=$1
    caption=$2
    base_path=`find . -name ${base_file}`
    # 打印路径
    echo "base path ${base_path}"
    # 路径是否存在
    if [[ ! -f ${base_path} || -z ${base_path} ]]; then
        return;
    fi

    width=`identify -format %w ${base_path}`
    height=`identify -format %h ${base_path}`
    band_height=$((($height * 47) / 100))
    band_position=$(($height - $band_height))
    text_position=$(($band_position - 3))
    point_size=$(((20 * $width) / 100))
    echo "Image dimensions ($width x $height) - band height $band_height @ $band_position - point size $point_size"
    #
    # 模糊+文字
    #
    convert ${base_path} -blur 10x8 /tmp/blurred.png
    convert /tmp/blurred.png -crop ${width}x${band_height}+0+${band_position} /tmp/mask.png
    convert -background none -fill white -size ${width}x${band_height} -pointsize ${point_size} -gravity center caption:"${caption}" /tmp/mask.png +swap -composite /tmp/labels.png

    rm /tmp/blurred.png
    rm /tmp/mask.png
    #
    # 组合模糊图片和源文件
    #
    filename=New${base_file}
	composite -geometry +0+${band_position} /tmp/labels.png ${base_path} ${base_path}
    # 清理文件
    rm /tmp/labels.png
    echo "process finished"
}

icon_count=`ls -l "$debugIconDirPath" | wc -l`

echo "$icon_count"

cd "$debugIconDirPath"

for icon in `ls`; do
	echo "process $icon ..."
	if [[ $icon == *.png ]] || [[ $icon == *.PNG ]]
    then
        generateIcon $icon "Debug"
    fi
done

cd ..
cd "$preIconDirPath"
for icon in `ls`; do
	echo "process $icon ..."
	if [[ $icon == *.png ]] || [[ $icon == *.PNG ]]
    then
        generateIcon $icon "Pre"
    fi
done
