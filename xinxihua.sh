#!/bin/bash
filepath='/hdp10/mc'
destpath='/hdp10/processed'
bakpath='/hdp10/bak'
uppath='/hdp10/upload'
fileprefix='CSODWAL04001A'
daytime=`date +%Y%m%d`
suffix='1000000.081'
File_p=`hdfs dfs -ls /carpo/buss/province_user_data |tail -n 5 |awk '{print $NF}'`
for dfsfile in $File_p
do
File_c=`echo $dfsfile |cut -b 32-50`
time=`echo "$dfsfile" |cut -b 34-50`'00'
bakfile=`ls -l -t $bakpath |sed -n '2p' |awk '{print $NF}'`
if [ "$File_c" != "$bakfile" ] && [ ! -d "$bakpath"/"$File_c" ]
then
hdfs dfs -get $dfsfile $filepath
fi
done
for i in `ls $filepath`
do
if [ -d "$filepath/$i" ]
then
cd "$filepath/$i"
file=`ls`
#awk '{$1="";print}'  "$filepath/$i/$file" >$destpath/$fileprefix$time$suffix
awk 'BEGIN {OFS="\t"}{print $2,$3,$4,$5,$6,$7,$8}'  "$filepath/$i/$file" >$destpath/$fileprefix$time$suffix
linenum=`wc -l $filepath/$i/$file |awk '{print $1}'`
sed -i "1i 01\t081\tODWAL04001A17\t01\t$daytime\t$daytime\t$linenum" $destpath/$fileprefix$time$suffix
cd $destpath
gzip -1  $destpath/$fileprefix$time$suffix
md5sum $destpath/$fileprefix$time$suffix.gz > $destpath/$fileprefix$time$suffix.MD5
mv $destpath/$fileprefix$time$suffix.gz $uppath
mv $destpath/$fileprefix$time$suffix.MD5 $uppath
mv $filepath/$i $bakpath 
fi
done
