from fontTools.ttLib import TTFont
import sys

def main(font_path):
    font = TTFont(font_path)
    current_typo_ascender = font["OS/2"].sTypoAscender
    print("[INFO] Current sTypoAscender: ", current_typo_ascender)
    font['OS/2'].sTypoAscender = 1977
    current_typo_ascender = font["OS/2"].sTypoAscender
    print("[INFO] New sTypoAscender: ", current_typo_ascender)
    #font.save(font.reader.file.name + ".fix")
    font.save(font.reader.file.name)

if __name__ == "__main__":
    main(sys.argv[1])
