#!/bin/bash

data="./data/typhoon2021.txt"
stdDir="./data"

while read line; do
    
    time=`echo $line | awk '{printf $1}'`

    # ヘッダ行の場合
    if [ $time -eq 66666 ]; then

	# Ex. 2021年１号 -> 2101
	tyNum=`echo $line | awk '{printf $2}'`

	# 保存先ディレクトリがなければ新規作成
	outDir=$stdDir/$tyNum
	if [ ! -d $outDir  ]; then
	    mkdir $outDir
	fi

	# 保存先パスに既にデータがあれば削除
	outPath=$outDir/$tyNum".txt"
	if [ -e $outPath ]; then
	    rm -f $outPath
	fi
	
	echo $outPath
    fi
    
    echo $line >> $outPath
done < $data
