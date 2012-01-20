#!/bin/sh
# Easy application of new patches.
# Always adds to the very end. (Bumps last patch nr by 100)
# Parameters:
# $1 - patch filename 
# $2 - description

OLD=$(grep ^Patch kernel.spec  | tail -n1 | awk '{ print $1 }' | sed s/Patch// | sed s/://)
NEW=$(($OLD/100*100+100))

sed -i "/^Patch$OLD:\ /a#\ $2\nPatch$NEW:\ $1" kernel.spec

LAST=$(grep ^ApplyPatch kernel.spec | tail -n1 | awk '{ print $2 }')

sed -i "/^ApplyPatch $LAST/aApplyPatch $1" kernel.spec

cvs add $1

scripts/bumpspecfile.py kernel.spec "- $2"
make clog

