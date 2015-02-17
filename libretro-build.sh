#! /usr/bin/env bash
# vim: set ts=3 sw=3 noet ft=sh : bash

SCRIPT="${0#./}"
BASE_DIR="${SCRIPT%/*}"
WORKDIR=$PWD

if [ "$BASE_DIR" = "$SCRIPT" ]; then
	BASE_DIR="$WORKDIR"
else
	if [[ "$0" != /* ]]; then
		# Make the path absolute
		BASE_DIR="$WORKDIR/$BASE_DIR"
	fi
fi

if [ "$FORMAT_COMPILER_TARGET" != "ios" ]; then
	. ${BASE_DIR}/libretro-config.sh
else
	# FIXME: libretro-config.sh should eventually do this stuff for iOS
	DIST_DIR="ios"
	FORMAT_EXT=dylib
	IOS=1
	FORMAT=_ios
	FORMAT_COMPILER_TARGET=ios
	export IOSSDK=$(xcrun -sdk iphoneos -show-sdk-path)
	IOSVER_MAJOR=$(xcrun -sdk iphoneos -show-sdk-platform-version | cut -c '1')
	IOSVER_MINOR=$(xcrun -sdk iphoneos -show-sdk-platform-version | cut -c '3')
	IOSVER=${IOSVER_MAJOR}${IOSVER_MINOR}
fi

if [ -z "$RARCH_DIST_DIR" ]; then
	RARCH_DIR="$WORKDIR/dist"
	RARCH_DIST_DIR="$RARCH_DIR/$DIST_DIR"
fi

if [ -z "$JOBS" ]; then
	JOBS=7
fi

if [ "$HOST_CC" ]; then
	CC="${HOST_CC}-gcc"
	CXX="${HOST_CC}-g++"
	CXX11="${HOST_CC}-g++"
	STRIP="${HOST_CC}-strip"
fi

if [ -z "$MAKE" ]; then
	if uname -s | grep -i MINGW32 > /dev/null 2>&1; then
		MAKE=mingw32-make
	else
		if type gmake > /dev/null 2>&1; then
			MAKE=gmake
		else
			MAKE=make
		fi
	fi
fi

if [ -z "$CC" ]; then
	if [ "$FORMAT_COMPILER_TARGET" = "ios" ]; then
		CC="clang -arch armv7 -miphoneos-version-min=5.0 -isysroot $IOSSDK"
	elif [ $FORMAT_COMPILER_TARGET = "osx" ]; then
		CC=cc
	elif uname -s | grep -i MINGW32 > /dev/null 2>&1; then
		CC=mingw32-gcc
	else
		CC=gcc
	fi
fi

if [ -z "$CXX" ]; then
	if [ "$FORMAT_COMPILER_TARGET" = "ios" ]; then
		CXX="clang++ -arch armv7 -miphoneos-version-min=5.0 -isysroot $IOSSDK"
		CXX11="clang++ -std=c++11 -stdlib=libc++ -arch armv7 -miphoneos-version-min=5.0 -isysroot $IOSSDK"
	elif [ $FORMAT_COMPILER_TARGET = "osx" ]; then
		CXX=c++
		CXX11="clang++ -std=c++11 -stdlib=libc++"
		# FIXME: Do this right later.
		if [ "$ARCH" = "i386" ]; then
			CC="cc -arch i386"
			CXX="c++ -arch i386"
			CXX11="clang++ -arch i386 -std=c++11 -stdlib=libc++"
		fi
	elif uname -s | grep -i MINGW32 > /dev/null 2>&1; then
		CXX=mingw32-g++
		CXX11=mingw32-g++
	else
		CXX=g++
		CXX11=g++
	fi
fi

FORMAT_COMPILER_TARGET_ALT=$FORMAT_COMPILER_TARGET


if [ "$FORMAT_COMPILER_TARGET" = "ios" ]; then
	echo "iOS path: ${IOSSDK}"
	echo "iOS version: ${IOSVER}"
fi
echo "CC = $CC"
echo "CXX = $CXX"
echo "CXX11 = $CXX11"
echo "STRIP = $STRIP"


. $BASE_DIR/libretro-build-common.sh

mkdir -p "$RARCH_DIST_DIR"

if [ -n "$1" ]; then
	while [ -n "$1" ]; do
		"$1"
		shift
	done
else
	build_libretro_2048
	build_libretro_4do
	build_libretro_bluemsx
	build_libretro_fmsx
	build_libretro_bsnes_cplusplus98
	build_libretro_bsnes
	build_libretro_bsnes_mercury
	build_libretro_beetle_lynx
	build_libretro_beetle_gba
	build_libretro_beetle_ngp
	build_libretro_beetle_pce_fast
	build_libretro_beetle_supergrafx
	build_libretro_beetle_pcfx
	build_libretro_beetle_vb
	build_libretro_beetle_wswan
	build_libretro_mednafen_psx
	build_libretro_beetle_snes
	build_libretro_catsfc
	build_libretro_snes9x
	build_libretro_snes9x_next
	build_libretro_genesis_plus_gx
	build_libretro_fb_alpha
	build_libretro_vbam
	build_libretro_vba_next
	build_libretro_fceumm
	build_libretro_gambatte
	build_libretro_meteor
	build_libretro_nx
	build_libretro_prboom
	build_libretro_stella
	build_libretro_quicknes
	build_libretro_nestopia
	build_libretro_tyrquake
	build_libretro_mame078
	build_libretro_mame
	build_libretro_dosbox
	build_libretro_scummvm
	build_libretro_picodrive
	build_libretro_handy
	build_libretro_desmume
	if [ $FORMAT_COMPILER_TARGET != "win" ]; then
		build_libretro_pcsx_rearmed
	fi
	if [ $FORMAT_COMPILER_TARGET = "ios" ]; then
		# For self-signed iOS (without jailbreak)
		build_libretro_pcsx_rearmed_interpreter
	fi
	build_libretro_yabause
	build_libretro_vecx
	build_libretro_tgbdual
	build_libretro_prosystem
	build_libretro_dinothawr
	build_libretro_virtualjaguar
	build_libretro_mupen64
	build_libretro_3dengine
	if [ $FORMAT_COMPILER_TARGET != "ios" ]; then
		# These don't currently build on iOS
		build_libretro_bnes
		build_libretro_ffmpeg
		build_libretro_ppsspp
	fi
	build_libretro_o2em
	build_libretro_hatari
	build_libretro_gpsp
	build_libretro_emux
	build_libretro_test
	if [ $FORMAT_COMPILER_TARGET != "ios" ]; then
		build_libretro_testgl
	fi
	build_summary
fi

