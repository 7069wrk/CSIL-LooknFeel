The intent of this is to create a build process that will work for creating the ISO.  It will also seperate all the major components of the OS build to make deployments easily customizable down to the individual applications.

at this time the process workflow will be to clone the repository and hope that dos2unix is not needed for the scripts so that these are the testing steps

for XUBUNTU
```
git clone https://github.com/7069wrk/CSIL-LooknFeel.git

cd CSIL-LooknFeel

bash 0_csil_looknfeel.sh

when prompted select SLIM for display manager

once complete reboot
```

for UBUNUTU (its gets twisted... and though it works it requires more lift and is not good for the ISO build)
```
test on UBUNTU if you want the only difference is that you will be prompted twice for DISPLAY MANAGER.
on the first select LIGHTDM,
on the second select SLIM

everything else should run out the same.
