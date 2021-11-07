#!/bin/bash

tyNum=2106
tyData="./data/${tyNum}/${tyNum}.txt"

basePath="./data/${tyNum}/${tyNum}_Pressure"
saveTxt=${basePath}".txt"
savePs=${basePath}".ps"
savePng=${basePath}".png"

if [ -e ${saveTxt} ]; then
    rm -f ${saveTxt}
fi
if [ -e ${savePs} ]; then
    rm -f ${savePs}
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
	if [ $count -eq 1 ]; then
	    startDate=${gmtDate:0:11}00:00:00
	fi
	hpa=`echo $line | awk '{printf $6}'`
	echo $gmtDate $hpa >> ${saveTxt}
    fi
    
    count=$((count+1))
    
done < $tyData

# データ表示間隔調整(0.0003が１日分でちょうど良く描画できる)
diffDay=$((${gmtDate:8:2}-${startDate:8:2}))
if [ $diffDay -lt 0 ]; then
    diffDay=$((30-${startDate:8:2}+${gmtDate:8:2}))
fi
echo $startDate $gmtDate $diffDay
timeInterval=`echo "scale=5; 0.0003 / ${diffDay}" | bc`

# データ期間が２日以上なら１日間隔で横軸表示
if [ ${diffDay} -ge 2 ]; then
    dispTime="a1Df3Hg6H"
else
    dispTime="a6Hf1Hg3H"
fi

gmt psxy ${saveTxt} -B${dispTime}:"UTC":/a20g10:"Pressure[hPa]"::."20${tyNum:0:2} No.${tyNum:2:2}":WSn -R${startDate}/${gmtDate}/940/1020 -Jx${timeInterval}T/0.1 -Sc0.2 -Gred -K > ${savePs}
gmt psxy ${saveTxt} -B -R -J -W1,red -O >> ${savePs}
