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

# 获取工程名称
for file in `ls`; do
    if [[ $file == *.xcodeproj ]]
    then
        name=${file%.*}
        echo "$name"
        break
    fi
done

# 图标的路径(手动配置)
assetsPath="/Assets.xcassets/"

# 配置工程目录
appIconPath="${name}${assetsPath}AppIcon.appiconset"
if [ ! -d ${appIconPath} ]; then
    echo "=================="
    echo "error: [$appIconPath] is not exist, please check "assetsPath" manually in line:30"
    echo "=================="
    exit 0
fi

echo "$appIconPath"

debugIconDirPath="${name}${assetsPath}AppIcon-Dev.appiconset"
preIconDirPath="${name}${assetsPath}AppIcon-Pre.appiconset"

# 路径是否存在
if [ -d ${debugIconDirPath} ]; then
    echo "=================="
    echo "error: [$debugIconDirPath] is already existed!"
    echo "=================="
    exit 0
fi

if [ -d ${preIconDirPath} ]; then
    echo "=================="
    echo "error: [$preIconDirPath] is already existed!"
    echo "=================="
    exit 0
fi

cp -R $appIconPath $debugIconDirPath
cp -R $appIconPath $preIconDirPath


# exit 0

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
    convert /tmp/mask.png -fill 'rgba(0,0,0,0.1)' -draw "rectangle 0,0,$width,$band_height" /tmp/mask-cover.png
    convert -background none -fill white -size ${width}x${band_height} -pointsize ${point_size} -gravity center caption:"${caption}" /tmp/mask-cover.png +swap -composite /tmp/labels.png

    rm /tmp/blurred.png
    rm /tmp/mask.png
    rm /tmp/mask-cover.png
    #
    # 组合模糊图片和源文件
    #
    filename=New${base_file}
    composite -geometry +0+${band_position} /tmp/labels.png ${base_path} ${base_path}
    # 清理文件
    rm /tmp/labels.png
    echo "process finished"
}

cd "$debugIconDirPath"

for icon in `ls`; do
    echo "process $icon ..."
    if [[ $icon == *.png ]] || [[ $icon == *.PNG ]]
    then
        generateIcon $icon "Debug"
    fi
done

cd ../../..
cd "$preIconDirPath"
for icon in `ls`; do
    echo "process $icon ..."
    if [[ $icon == *.png ]] || [[ $icon == *.PNG ]]
    then
        generateIcon $icon "Pre"
    fi
done
