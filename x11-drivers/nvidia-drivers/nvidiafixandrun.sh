#Stefano Angeleri (c) 2012 - weltall2@gmail.com
#a quick and dirty script to get the patch done easily.
#to use just do ./script path_to_the_nvidia_installer params to the nvidia installer
#remember to run the script as root else the nvidia installer will ask for it
Directory=`$1 --info | grep "Target directory" | cut --delimiter=":" -f 2`
eval "$1 -x"
cd $Directory
sed -i  's/CFLAGS="$CFLAGS -I$SOURCES\/arch\/x86\/include"/CFLAGS="$CFLAGS -I$SOURCES\/arch\/x86\/include -I$SOURCES\/arch\/x86\/include\/generated"/' kernel/conftest.sh
shift 1
./nvidia-installer $*
cd ..
rm -rf $Directory

