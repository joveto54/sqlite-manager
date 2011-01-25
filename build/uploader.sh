#!/bin/bash

project="sqlite-manager"

rootDir="/home/user/sqlite-manager"

buildDir=$rootDir/build
releaseDir=$rootDir/release
outDir=$rootDir/out

guser=""
gpass=""

getUserAndPass () {
  #hgrc contains username & password
  hgrcFile=$rootDir/.hg/hgrc

  #read the line containing 'https://' which should be like:
  #default = https://username:password@sqlite-manager.googlecode.com/hg/
  importantLine=`grep 'https://' $hgrcFile`

  #remove the text after '@'
  importantLine=`echo ${importantLine%%@*}`
  #now, we have (default = https://username:password)

  #remove the text before last '/' (use ##)
  importantLine=`echo ${importantLine##*/}`
  #now, we have (username:password)

  #username is till the ':', password after it
  guser=`echo ${importantLine%%:*}`
  gpass=`echo ${importantLine##*:}`
}

getUserAndPass

verFile=$outDir/version.txt

version="xxx"
locale=""

populateVersion () {
  while read ver; do
    version=$ver
    break
  done < $verFile

  read -p "Specify version: ("$version")" -r version1
  if [ ! $version1 = "" ]; then
    version=$version1
  fi
}

getLocale () {
  read -p "Specify locale: ("$locale")" -r locale1
  if [ ! $locale1 = "" ]; then
    locale=$locale1
  fi
}

populateVersion
#getLocale

uploadFiles () {
  argLocale=$1

  fileNameSuffix=$version
  labels="Featured,Type-Extension-xpi,OpSys-All"
  summaryXpi="SQLite Manager "$version
  summaryXr="SQLiteManager "$version" as XULRunner App"
  if [ ! $argLocale = "" ]; then
    fileNameSuffix=$version"-"$argLocale
    labels="Type-Extension-xpi,OpSys-All"
    summaryXpi="$summaryXpi (for $argLocale locale)"
    summaryXr="$summaryXr (for $argLocale locale)"
  fi

  xrFile="sqlitemanager-xr-"$fileNameSuffix".zip"
  xpiFile="sqlitemanager-"$fileNameSuffix".xpi"

  cd $buildDir

  read -p "Upload files $xpiFile and $xrFile (y/n): " -r choice
  if [ $choice = "y" ]; then
    #upload .xpi later so that it appears on top in downloads tab at sqlite-manager.googlecode.com
    summary=$summaryXr
    ./googlecode_upload.py -s "$summary" -p $project -u $guser -w $gpass -l $labels $releaseDir/$xrFile

    summary=$summaryXpi
    ./googlecode_upload.py -s "$summary" -p $project -u $guser -w $gpass -l $labels $releaseDir/$xpiFile
  fi
}

uploadFiles "sv-SE"
uploadFiles "ru"
uploadFiles "es-ES"
uploadFiles "ja"
uploadFiles "fr"
uploadFiles "de"
uploadFiles ""  #en-US

echo "Press any key to exit..."
read xxx
exit
