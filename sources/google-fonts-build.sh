#!/bin/bash
set -e
# This script makes a fork of Cascadia Code renamed Caskaydia
# Cove and builds new fonts with various fixes applied that
# can be submitted to the Google Fonts GitHub repo in full
# complience with the SIL Open Font License v1.1.
#
# All steps needed to build new fonts are contained within
# this script, so font builds are repeatable and documented.
#
# Requirements: Python3[3] and a Unix-like environment
# (Linux, MacOS, Windows Subsystem for Linux, etc),
# with a Bash-like shell(most Unix terminal applications).
#
# All Python dependencies will be installed in a temporary
# virtual environment by the script. If you want to set up your own
# virtual environment, disable the setting in the Build Settings section
# of this scrpt's header.
#
# To build new fonts, open a terminal in the root directory
# of this project(Git repository) and run the script:
#
# $ sh build.sh
#
# If you are updating the font for Google Fonts, you can
# use the "-gf" flag to run additional pull-request-helper
# commands as well. Just remember to change the "GOOGLE_FONTS_DIR"
# file path constant if you aren't building to ~/Google/fonts/ofl/.../:
#
# $ sh build.sh -gf
#
# The default settings should produce output that will conform
# to the Google Fonts Spec [1] and pass all FontBakery QA Tests [2].
# However, the Build Script Settings below are designed to be easily
# modified for other platforms and use cases.
#
# See the GF Spec [1] and the FontBakery QA Tool [2] for more info.
#
# Script by Eli H. If you have questions, please send an email [4].
#
# [1] https://github.com/googlefonts/gf-docs/tree/master/Spec
# [2] https://pypi.org/project/fontbakery/
# [3] https://www.python.org/
# [4] elih@protonmail.com

##################
# BUILD SETTINGS #
##################
alias ACTIVATE_PY_VENV=". BUILD_VENV/bin/activate"  # Starts a Python 3 virtual environment when invoked
GOOGLE_FONTS_DIR="~/Google/fonts"                   # Where the Google Fonts repo is cloned: https://github.com/google/fonts
OUTPUT_DIR="fonts"                                  # Where the output from this script goes
FAMILY_NAME="Caskaydia Cove"                        # Font family name for output files
DESIGNSPACE="CascadiaCode.designspace"              # Set the source file to build from
MAKE_NEW_VENV=true                                  # Set to `true` if you want to build and activate a python3 virtual environment
BUILD_STATIC_FONTS=true                             # Set to `true` if you want to build static fonts
#AUTOHINT=false                                     # Set to `true` if you want to use auto-hinting (ttfautohint)
NOHINTING=true                                      # Set to `true` if you want the fonts unhinted

#################
# BUILD PROCESS #
#################
echo "\n* ** **** ** * STARTING THE CASKAYDIA COVE BUILD SCRIPT * ** **** ** *"
echo "[INFO] Build start time: \c"
date

if [ "$1" = "-gf" ]; then
    echo "\n[INFO] gf-flag(-gf): Preparing a pull request to Google Fonts at: $GOOGLE_FONTS_DIR";
fi

if [ "$MAKE_NEW_VENV" = true ]; then
  echo "\n[INFO] Building a new Python3 virtual environment"
  python3 -m venv BUILD_VENV > /dev/null
  ACTIVATE_PY_VENV > /dev/null
  echo "[INFO] Python3 setup..."
  pip install --upgrade pip > /dev/null
  pip install --upgrade fontmake > /dev/null
  pip install --upgrade fonttools > /dev/null
  pip install --upgrade git+https://github.com/googlefonts/gftools > /dev/null
  which python  # Test to see if the VENV setup worked
  echo "[INFO] Done with Python3 virtual environment setup"
fi

# BUILD SETUP
echo "\n[INFO] Setting up build output directories: $OUTPUT_DIR"
mkdir -p $OUTPUT_DIR
mkdir -p gf_sources
#cp -r sources/CascadiaCode-Bold.ufo gf_sources/CaskaydiaCove-Bold.ufo
#cp -r sources/CascadiaCode-ExtraLight.ufo gf_sources/CaskaydiaCove-ExtraLight.ufo
#cp -r sources/CascadiaCode-Regular.ufo gf_sources/CaskaydiaCove-Regular.ufo
#cp -r sources/CascadiaCode.designspace gf_sources/CaskaydiaCove.designspace
cp -r sources/CascadiaCode-Bold.ufo gf_sources/
cp -r sources/CascadiaCode-ExtraLight.ufo gf_sources/
cp -r sources/CascadiaCode-Regular.ufo gf_sources/
cp -r sources/google-fonts-scripts/CaskaydiaCove.designspace gf_sources/
cp -r sources/*.plist gf_sources/
cp -r sources/features gf_sources/

# SOURCE FILE EDITING
#echo "[INFO] Editing source files"
# CHANGES NAME FROM CASCADIA CODE TO CASKAYDIA COVE 
#sed 's_Cascadia Code _Caskaydia Cove _' gf_sources/CaskaydiaCove.designspace > gf_sources/temp_a
#sed 's_CascadiaCode_CaskaydiaCove_' gf_sources/temp_a > gf_sources/temp_b
#cp gf_sources/temp_b gf_sources/CaskaydiaCove.designspace
#rm -rf gf_sources/temp_*


# FONTMAKE (building the variable font)
echo "\n[INFO] Building $FAMILY_NAME variable fonts with Fontmake..."
fontmake --mm-designspace gf_sources/CaskaydiaCove.designspace -o variable \
  --output-path $OUTPUT_DIR/CaskaydiaCove\[wght\].ttf
#  --verbose ERROR

echo "\n[INFO] Making fixes to the fontmake output"
# FONTTOOLS HOTFIXES
#ttx fonts/CascadiaCode\[wght\].ttf
# CHANGES NAME FROM CASCADIA CODE TO CASKAYDIA COVE 
#sed 's_Cascadia Code _Caskaydia Cove _' fonts/CascadiaCode\[wght].ttx > fonts/temp_a
#sed 's_CascadiaCode_CaskaydiaCove_' fonts/temp_a > fonts/temp_b
#cp fonts/temp_b fonts/foo.ttx

# GFTOOLS HOTFIXES
# FIXES FONTBAKERY CHECK: com.google.fonts/check/dsig
gftools fix-dsig -f fonts/*.ttf > /dev/null
# FIXES FONTBAKERY CHECK: com.google.fonts/check/smart_dropout
gftools fix-nonhinting fonts/CaskaydiaCove[wght].ttf fonts/temp.ttf >/dev/null
mv fonts/temp.ttf fonts/CaskaydiaCove[wght].ttf
rm -rf fonts/*backup-fonttools-prep-gasp.ttf

# PYTHON SCRIPTS
#python3 sources/google-fonts-scripts/hello.py fonts/CascadiaCode\[wght\].ttf
python3 sources/google-fonts-scripts/fix_os2_metrics_match_hhea.py fonts/CaskaydiaCove\[wght\].ttf
python3 sources/google-fonts-scripts/fix_win_ascent_and_descent.py fonts/CaskaydiaCove\[wght\].ttf
python3 sources/google-fonts-scripts/fix_name_table.py fonts/CaskaydiaCove\[wght\].ttf

# CLEAN UP BUILD FILES
rm -rf BUILD_VENV

# GOOGLE FONTS FLAG (-gf) SECTION


METADATA='name: "Caskaydia Cove"
designer: "Aaron Bell"
license: "OFL"
category: "MONOSPACE"
date_added: "2020-07-20"
fonts {
  name: "Caskaydia Cove"
  style: "normal"
  weight: 400
  filename: "CaskaydiaCove[wght].ttf"
  post_script_name: "CaskaydiaCove-Regular"
  full_name: "Caskaydia Cove Regular"
  copyright: "Copyright 2020 The Cascadia Code Project Authors (https://github.com/microsoft/cascadia-code)"
}
subsets: "latin"
subsets: "menu"
axes {
  tag: "wght"
  min_value: 400.0
  max_value: 900.0
}'
OFL='Copyright 2019 The Caskaydia Cove Project Authors (https://github.com/microsoft/cascadia-code)

This Font Software is licensed under the SIL Open Font License, Version 1.1.
This license is copied below, and is also available with a FAQ at:
http://scripts.sil.org/OFL


-----------------------------------------------------------
SIL OPEN FONT LICENSE Version 1.1 - 26 February 2007
-----------------------------------------------------------

PREAMBLE
The goals of the Open Font License (OFL) are to stimulate worldwide
development of collaborative font projects, to support the font creation
efforts of academic and linguistic communities, and to provide a free and
open framework in which fonts may be shared and improved in partnership
with others.

The OFL allows the licensed fonts to be used, studied, modified and
redistributed freely as long as they are not sold by themselves. The
fonts, including any derivative works, can be bundled, embedded,
redistributed and/or sold with any software provided that any reserved
names are not used by derivative works. The fonts and derivatives,
however, cannot be released under any other type of license. The
requirement for fonts to remain under this license does not apply
to any document created using the fonts or their derivatives.

DEFINITIONS
"Font Software" refers to the set of files released by the Copyright
Holder(s) under this license and clearly marked as such. This may
include source files, build scripts and documentation.

"Reserved Font Name" refers to any names specified as such after the
copyright statement(s).

"Original Version" refers to the collection of Font Software components as
distributed by the Copyright Holder(s).

"Modified Version" refers to any derivative made by adding to, deleting,
or substituting -- in part or in whole -- any of the components of the
Original Version, by changing formats or by porting the Font Software to a
new environment.

"Author" refers to any designer, engineer, programmer, technical
writer or other person who contributed to the Font Software.

PERMISSION & CONDITIONS
Permission is hereby granted, free of charge, to any person obtaining
a copy of the Font Software, to use, study, copy, merge, embed, modify,
redistribute, and sell modified and unmodified copies of the Font
Software, subject to the following conditions:

1) Neither the Font Software nor any of its individual components,
in Original or Modified Versions, may be sold by itself.

2) Original or Modified Versions of the Font Software may be bundled,
redistributed and/or sold with any software, provided that each copy
contains the above copyright notice and this license. These can be
included either as stand-alone text files, human-readable headers or
in the appropriate machine-readable metadata fields within text or
binary files as long as those fields can be easily viewed by the user.

3) No Modified Version of the Font Software may use the Reserved Font
Name(s) unless explicit written permission is granted by the corresponding
Copyright Holder. This restriction only applies to the primary font name as
presented to the users.

4) The name(s) of the Copyright Holder(s) or the Author(s) of the Font
Software shall not be used to promote, endorse or advertise any
Modified Version, except to acknowledge the contribution(s) of the
Copyright Holder(s) and the Author(s) or with their explicit written
permission.

5) The Font Software, modified or unmodified, in part or in whole,
must be distributed entirely under this license, and must not be
distributed under any other license. The requirement for fonts to
remain under this license does not apply to any document created
using the Font Software.

TERMINATION
This license becomes null and void if any of the above conditions are
not met.

DISCLAIMER
THE FONT SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT
OF COPYRIGHT, PATENT, TRADEMARK, OR OTHER RIGHT. IN NO EVENT SHALL THE
COPYRIGHT HOLDER BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
INCLUDING ANY GENERAL, SPECIAL, INDIRECT, INCIDENTAL, OR CONSEQUENTIAL
DAMAGES, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF THE USE OR INABILITY TO USE THE FONT SOFTWARE OR FROM
OTHER DEALINGS IN THE FONT SOFTWARE.
'

if [ "$1" = "-gf" ]; then
  echo ""
  echo "[INFO] Preparing a pull request to Google Fonts at ~/Google/fonts/ofl";
  cp sources/google-fonts-scripts/DESCRIPTION.en_us.html ~/Google/fonts/ofl/caskaydiacove/
  cp FONTLOG.txt ~/Google/fonts/ofl/caskaydiacove/
  echo "$METADATA" > ~/Google/fonts/ofl/caskaydiacove/METADATA.pb
  echo "$OFL" > ~/Google/fonts/ofl/caskaydiacove/OFL.txt
  cp fonts/CaskaydiaCove\[wght\].ttf ~/Google/fonts/ofl/caskaydiacove/
  mkdir -p ~/Google/fonts/ofl/caskaydiacove/static
  cp fonts/CaskaydiaCove\[wght\].ttf ~/Google/fonts/ofl/caskaydiacove/static/a.ttf
  cp fonts/CaskaydiaCove\[wght\].ttf ~/Google/fonts/ofl/caskaydiacove/static/b.ttf
fi

echo "\n[INFO] Done!😃"

