#! /bin/zsh -
zmodload zsh/stat
zmodload zsh/zselect
zmodload zsh/system
set -o extendedglob

typeset -A tracked
typeset -F SECONDS=0

pattern=${1?}; shift

drain() {
  while sysread -s 65536 -i $1 -o 1; do
    continue
  done
}

for ((t = 1; ; t++)); do
  typeset -A still_there
  still_there=()
  for file in $^@/$~pattern(#q-.NoN); do
    stat -H stat -- $file || continue
    inode=$stat[device]:$stat[inode]
    if
      (($+tracked[$inode])) ||
    { exec {fd}< $file && tracked[$inode]=$fd; }
    then
      still_there[$inode]=
    fi
  done
  for inode fd in ${(kv)tracked}; do
    drain $fd
    if ! (($+still_there[$inode])); then
      exec {fd}<&-
      unset "tracked[$inode]"
    fi
  done
  ((t <= SECONDS)) || zselect -t $((((t - SECONDS) * 100) | 0))
done
