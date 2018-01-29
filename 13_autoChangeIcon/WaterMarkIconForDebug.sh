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


# Release 不执行
echo "Configuration: $CONFIGURATION"
if [ ${CONFIGURATION} = "Release" ]; then
    exit 0;
fi

config="Debug"

if [ ${CONFIGURATION} = "PreRelease" ]; then
config="Pre"
fi

commit=`git rev-parse --short HEAD`
branch=`git rev-parse --abbrev-ref HEAD`
version=`/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "${CONFIGURATION_BUILD_DIR}/${INFOPLIST_PATH}"`
buildNumber=`/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${CONFIGURATION_BUILD_DIR}/${INFOPLIST_PATH}"`
caption="${config} ${version} \n${branch}\n${commit}"

echo "caption: ${caption}"
echo "product_path: ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/"


#function abspath() { }
#pushd . > /dev/null; if [ -d "$1" ]; then cd "$1"; dirs -l +0; else cd "`dirname \"$1\"`"; cur_dir=`dirs -l +0`; if [ "$cur_dir" == "/" ]; then echo "$cur_dir`basename \"$1\"`"; else echo "$cur_dir/`basename \"$1\"`"; fi; fi; popd > /dev/null;
#}

function generateIcon() {
    base_file=$1
    cd "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
    base_path=`find . -name ${base_file}`
    # 打印路径
    real_path=$( abspath "${base_path}" )
    echo "base path ${real_path}"
    # 路径是否存在
    if [[ ! -f ${base_path} || -z ${base_path} ]]; then
        return;
    fi

    # TODO: if they are the same we need to fix it by introducing temp
    target_file=`basename $base_path`
    target_path="${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/${target_file}"
    base_tmp_normalizedFileName="${base_file%.*}-normalized.${base_file##*.}"
    base_tmp_path=`dirname $base_path`
    base_tmp_normalizedFilePath="${base_tmp_path}/${base_tmp_normalizedFileName}"
    stored_original_file="${base_tmp_normalizedFilePath}-tmp"
    if [[ -f ${stored_original_file} ]]; then
        echo "found previous file at path ${stored_original_file}, using it as base"
        mv "${stored_original_file}" "${base_path}"
    fi

#    if [ $CONFIGURATION = "Release" ]; then
#        cp "${base_path}" "$target_path"
#        return 0;
#    fi

    # 恢复优化的PNG（因为此时的PNG已经被Xcode压缩）
    echo "Reverting optimized PNG to normal"
    # 恢复到正常PNG
    echo "xcrun -sdk iphoneos pngcrush -revert-iphone-optimizations -q ${base_path} ${base_tmp_normalizedFilePath}"
    xcrun -sdk iphoneos pngcrush -revert-iphone-optimizations -q "${base_path}" "${base_tmp_normalizedFilePath}"
    # 将原始文件(压缩过)转为临时文件
    echo "moving pngcrushed png file at ${base_path} to ${stored_original_file}"
    #rm "$base_path"
    mv "$base_path" "${stored_original_file}"
    # 将恢复后的PNG转为base_path
    echo "Moving normalized png file to original one ${base_tmp_normalizedFilePath} to ${base_path}"
    mv "${base_tmp_normalizedFilePath}" "${base_path}"
    width=`identify -format %w ${base_path}`
    height=`identify -format %h ${base_path}`
    band_height=$((($height * 47) / 100))
    band_position=$(($height - $band_height))
    text_position=$(($band_position - 3))
    point_size=$(((13 * $width) / 100))
    echo "Image dimensions ($width x $height) - band height $band_height @ $band_position - point size $point_size"
    #
    # 模糊+文字
    #
    convert ${base_path} -blur 10x8 /tmp/blurred.png
   convert /tmp/blurred.png -gamma 0 -fill white -draw "rectangle 0,$band_position,$width,$height" /tmp/mask.png
   convert -size ${width}x${band_height} xc:none -fill 'rgba(0,0,0,0.2)' -draw "rectangle 0,0,$width,$band_height" /tmp/labels-base.png
   convert -background none -size ${width}x${band_height} -pointsize $point_size -fill white -gravity center -gravity South caption:"$caption" /tmp/labels.png
   convert ${base_path} /tmp/blurred.png /tmp/mask.png -composite /tmp/temp.png

    rm /tmp/blurred.png
    rm /tmp/mask.png
    #
    # 组合模糊图片和源文件
    #
    filename=New${base_file}
   convert /tmp/temp.png /tmp/labels-base.png -geometry +0+$band_position -composite /tmp/labels.png -geometry +0+$text_position -geometry +${w}-${h} -composite "${target_path}"

    # 清理文件
    rm /tmp/temp.png
    rm /tmp/labels-base.png
    rm /tmp/labels.png
    # rm "${stored_original_file}"
    echo "Overlayed ${target_path}"
}

icon_count=`/usr/libexec/PlistBuddy -c "Print CFBundleIcons:CFBundlePrimaryIcon:CFBundleIconFiles" "${CONFIGURATION_BUILD_DIR}/${INFOPLIST_PATH}" | wc -l`


# Array {
# AppIcon29x29
# AppIcon40x40
# AppIcon60x60
# }
# -2 的原因是因为输出是五行
real_icon_index=$((${icon_count} - 2))

# ========= for =========
for ((i=0; i<$real_icon_index; i++)); do
    # 去 plist 中顺着路径找到 icon 名
    icon=`/usr/libexec/PlistBuddy -c "Print CFBundleIcons:CFBundlePrimaryIcon:CFBundleIconFiles:$i" "${CONFIGURATION_BUILD_DIR}/${INFOPLIST_PATH}"`

    echo "icon: ${icon}"

    if [[ $icon == *.png ]] || [[ $icon == *.PNG ]]
    then
        generateIcon $icon
    else
#        generateIcon "${icon}.png"
        generateIcon "${icon}@2x.png"
        generateIcon "${icon}@3x.png"
    fi

done
# ========= end for =========
