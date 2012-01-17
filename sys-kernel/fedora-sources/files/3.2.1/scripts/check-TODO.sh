#!/bin/sh

for i in `grep ^* TODO  | awk '{ print $2 }'`
do
 if [ ! -f $i ]; then
   echo "$i referenced in the TODO, but isn't in CVS!"
 fi;
done

# sometimes dead stuff lingers in cvs, even though it's not in the specfile.
for i in *.patch
do
   for j in $(grep $i kernel.spec | grep Apply.*Patch | awk '{ print $2 }' | wc -l)
   do
     if [ "$j" = "0" ]; then
       echo $i is in CVS, but not applied in spec file.
       grep $i TODO | awk '{ print $2 " is also still in the TODO" }'
     fi
   done
done

#for i in `grep ApplyPatch kernel.spec | awk '{ print $2 }'`
#do
#	R=$(grep $i TODO)
#	echo "$i is in CVS, but not mentioned in the TODO!"
#done

