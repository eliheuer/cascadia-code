#!/usr/bin/env python
from fontTools.ttLib import TTFont
import sys

NAME_ID = 13
LICENSE = "This Font Software is licensed under the SIL Open Font License, Version 1.1. This license is available with a FAQ at: http://scripts.sil.org/OFL"
METADATA = "Copyright 2020 The Cascadia Code Project Authors (https://github.com/microsoft/cascadia-code)"
FULL_NAME = "Caskaydia Cove Regular"
FAMILY_NAME = "Caskaydia Cove"
UNIQUE_ID = "4.300;SAJA;CaskaydiaCove-Regular"
POSTSCRIPT_NAME  = "CaskaydiaCove-Regular"

def main(font_path):
    font = TTFont(font_path)
    for name in font['name'].names:
        #print("nameID: ", name.nameID)
        if name.nameID == NAME_ID:
            print("[INFO] Found NameID 13: License Description")

    font['name'].setName(LICENSE,13,3,1,0x409)
    font['name'].setName(METADATA,0,3,1,0x409)
    font['name'].setName(FULL_NAME,4,3,1,0x409)
    font['name'].setName(FAMILY_NAME,1,3,1,0x409)
    font['name'].setName(UNIQUE_ID,3,3,1,0x409)
    font['name'].setName(POSTSCRIPT_NAME,6,3,1,0x409)

    font.save(font.reader.file.name)

if __name__ == "__main__":
    main(sys.argv[1])
