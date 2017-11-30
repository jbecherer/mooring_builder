#!/bin/bash

echo copy all figures to: $2

if [ $1=='' ]
then
   echo input directoy set to 
   indir='../../../'
   echo $indir
else
   indir=$1
fi
if [ $2=='' ]
then
   echo output directoy set to 
   outdir='../../../pics/'
   echo $outdir
else
   outdir=$2
fi

# pitot-loop
ff=$(find $indir -name V0_fit*.png)
for f in $ff 
do
   echo $f
   unit=${f:(-28):4}
   dest=$(echo $outdir/pitot/${unit}_pitot_self.png)
   echo $dest
   cp -v $f $dest;
done
# pitot-loop
ff=$(find $indir -name Pitot_vs*.png)
for f in $ff 
do
   echo $f
   unit=${f:(-34):4}
   dest=$(echo $outdir/pitot/${unit}_pitot_adcp.png)
   echo $dest
   cp -v $f $dest;
done

# temp-loop
fftemp=$(find $indir -name temp_wh*.png)
for f in $fftemp 
do
   echo $f
   dest_temp=$(echo $outdir/temp_pics/${f:(-24):4}_temp.png)
   echo $dest_temp
   cp -v $f $dest_temp;
done

