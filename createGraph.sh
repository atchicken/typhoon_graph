#!/bin/bash

tyYear=21

for n in `seq -f %02g 8`; do
    tyNum=$tyYear$n
    dataDir=./data/$tyNum
    tyData=$dataDir/${tyNum}.txt
    
    presTxt=$dataDir/${tyNum}_Pressure.txt
    mswTxt=$dataDir/${tyNum}_MaximamSustainedWind.txt
    
    imgDir=./img/$tyNum
    if [ ! -d $imgDir ]; then
	mkdir $imgDir
    fi
    
    savePs=$imgDir/${tyNum}.ps
    savePng=$imgDir/${tyNum}.png
    
    if [ -e $mswTxt ]; then
	rm -f $mswTxt
    fi
    if [ -e $presTxt ]; then
	rm -f $presTxt
    fi
    if [ -e $savePs ]; then
	rm -f $savePs
    fi
    if [ -e $savePng ]; then
	rm -f $savePng
    fi
    
    count=0
    while read line; do
	
	# ヘッダ行読み飛ばし
	if [ $count -ne 0 ]; then
	    
	    # GMT用の日付表示に変更（Ex. 21010100 -> 2021-01-01T00:00:00）
	    date=`echo $line | awk '{printf $1}'`
	    year=20${date:0:2}
	    month=${date:2:2}
	    day=${date:4:2}
	    hour=${date:6:2}
	    gmtDate=${year}-${month}-${day}T${hour}:00:00
	    
	    # 描画用にデータ開始時刻を保存
	    if [ $count -eq 1 ]; then
		startDate=${gmtDate:0:11}00:00:00
	    fi
	    
	    hpa=`echo $line | awk '{printf $6}'`
	    msw=`echo $line | awk '{printf $7}'`
	    echo $gmtDate $hpa >> $presTxt
	    echo $gmtDate $msw >> $mswTxt
	fi
	
	count=$((count+1))
	
    done < $tyData
    
    # データ表示間隔調整(描画用)
    diffDay=$((${gmtDate:8:2}-${startDate:8:2}))
    if [ $diffDay -lt 0 ]; then
	diffDay=$((30-${startDate:8:2}+${gmtDate:8:2}))
    fi
    timeInterval=`echo "scale=5; 0.00031 / ${diffDay}" | bc`
    
    # 表示間隔変更（描画用）
    if [ $diffDay -ge 10 ]; then
	dispTime=a3Df12Hg1D
    elif [ $diffDay -lt 2 ]; then
	dispTime=a1Df1Hg3H
    else
	dispTime=a1Df3Hg6H
    fi
    
    gmt psxy $presTxt -B$dispTime:"UTC":/a20g10:"Pressure[hPa]"::."20${tyNum:0:2} No.${tyNum:2:2}":WSn -R$startDate/$gmtDate/940/1020 -Jx${timeInterval}T/0.15 -Sc0.2 -Gblue -K > $savePs
    gmt psxy $presTxt -B -R -J -W1,blue -P -K -O >> $savePs
    gmt psxy $mswTxt -B/a10:"MSW[kt]":E -R$startDate/$gmtDate/0.1/100 -Jx${timeInterval}T/0.12 -Ss0.2 -Ggreen -P -K -O >> $savePs
    gmt psxy $mswTxt -B -R -J -W1,green -P -K -O >> $savePs
    gmt pslegend -R -J -Dx1.8/11.5/2.5/1.2 -F+p1,black+gwhite -P -O <<EOF >> $savePs
S 0.2 c 0.2 blue black 0.5 Pressure
S 0.2 c 0.2 green black 0.5 MSW
EOF
    gmt ps2raster $savePs -E100 -Tg
    echo $tyNum Save
done
