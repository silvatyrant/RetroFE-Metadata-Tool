#! /bin/bash

#################################################################################################################################################
#	RetroFE Metadata Tool - Created by Silvatyrant - 2017-07-19
#
#	This script works based on the following assumptions:
#
#	1. 	You're using RetroFE (http://retrofe.nl).
#	2.	You've used XMS (https://github.com/Universal-Rom-Tools/Universal-XML-Scraper) to scrape your metadata using the RetroPIE format.
#	3.	You've used the retrofeConvert (https://github.com/JamesInDigital/retrofeConvert) tool from JamesInDigital to create your game-
#		lists and story folder. I've made a modified (incomplete) version of this script and will link it here as soon as I publish it.
#	4.	You're using a linux-based system
#	5. 	That you've configured XMS to pull down the coverart as the default image and the logo as the marquee.
#
#
#################################################################################################################################################


### Update assets_home, roms_home and rfe_home values to suit your environment ###
assets_home=""
av_assets="$assets_home/downloaded_images"
gl_assets="$assets_home/gamelists"
rfe_home=""
roms_home=""


# WILL IMPLEMENT LATER - Will make it unnecessary to supply system-specific RetroFE and asset locations (auto-detect functionality)
#id_system() {
#	systems_list=`ls -1 $assets_home/assets/dowloaded_images`
#		system=$1
#		
#	done
#}


create_imglnk() {
	system_id="$1"
	rfe_coll="$2"
	old_IFS=IFS
	IFS=$'\n'
	if [ -z $1 ]; then
		echo "No parameters for create_imglnk function. Quitting..."
		exit
	fi
	for fname in `ls -1 $av_assets/$system_id | grep image`; do
		if [ $fname == "" ]; then
			echo "No assets found. Nothing to do."
		else
			cd $rfe_home/collections/"$rfe_coll"/medium_artwork/artwork_front
			link_name=`echo $fname | sed 's/-image//'`
			ln -s $av_assets/$system_id/$fname $link_name
		fi
	done
	IFS=$old_IFS
}

create_vidlnk() {
	system_id="$1"
	rfe_coll="$2"
	old_IFS=IFS
	IFS=$'\n'
	for fname in `ls -1 $av_assets/$system_id | grep video`; do
		if [ $fname == "" ]; then
			echo "No assets found. Nothing to do."
		else
			echo $fname
		        cd $rfe_home/collections/"$rfe_coll"/medium_artwork/video
		        link_name=`echo $fname | sed 's/-video//'`
		        ln -s $av_assets/$system_id/$fname $link_name
		fi
	done
	IFS=$old_IFS
}

create_loglnk() {
	system_id="$1"
	rfe_coll="$2"
	old_IFS=IFS
	IFS=$'\n'
	for fname in `ls -1 $av_assets/$system_id | grep marquee`; do
		if [ $fname == "" ]; then
			echo "No assets found. Nothing to do."
		else
			echo $fname
		        cd $rfe_home/collections/"$rfe_coll"/medium_artwork/logo
		        link_name=`echo $fname | sed 's/-marquee//'`
		        ln -s $av_assets/$system_id/$fname $link_name
		fi
	done
	IFS=$old_IFS
}


copy_glist() {
        system_id="$1"
        rfe_coll="$2"
        old_IFS=IFS
        IFS=$'\n'
	if [ ! -f $gl_assets/$system_id/gamelist.xml ]; then
		echo "No 'gamelist.xml' exists for system '$system_id' in '$gl_assets/$system_id/'. Either the directory does not exist or the gamelist doesn't."
	else
        	cp $gl_assets/$system_id/gamelist.xml $rfe_home/meta/hyperlist/"$rfe_coll".xml
	fi
        IFS=$old_IFS
}

help_cnt=0
print_help() {
	echo -e "Usage:   -v, Create links for videos"
        echo -e "         -i, Create links for images/coverart"
	echo -e " 	  -l, Create links for logos"
	echo -e "         -g, Copy gamelist in hyperspin format"
	echo -e "Example: $0 -vi 'System ID (as named in assets location)' 'Name of collection in RetroFE home'"
}


param_leng=${#1}

for (( j=0; j < $param_leng; j++ ));  do
	if [ $j -eq 0 ]; then
		if [ "${1:0:1}" != "-" ]; then
			echo "Incorrect usage."
			if [ $help_cnt -eq 0 ]; then
				print_help
			else
				help_cnt=$((help_cnt+1))
				exit
			fi
		fi
	else
		case "${1:$j:1}" in
			v) create_vidlnk  "$2" "$3"
				;;	
			i) create_imglnk "$2" "$3"
				;;
			l) create_loglnk "$2" "$3"
				;;
			g) copy_glist "$2" "$3"
				;;
			*) if [ $help_cnt -eq 0 ]; then
				print_help
				help_cnt=$((help_cnt+1))
			   fi
				
		esac
	fi
done
			

