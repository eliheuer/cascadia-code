from fontTools.ttLib import TTFont
import sys

def main(font_path):
    font = TTFont(font_path)

    # usWinAscent
    current_us_win_ascent = font["OS/2"].usWinAscent
    print("[INFO] Current usWinAscent: ", current_us_win_ascent)
    font['OS/2'].usWinAscent = 2280
    current_us_win_ascent = font["OS/2"].usWinAscent
    print("[INFO] Current usWinAscent: ", current_us_win_ascent)

    # usWinAscent
    current_us_win_descent = font["OS/2"].usWinDescent
    print("[INFO] Current usWinDescent: ", current_us_win_descent)
    font['OS/2'].usWinDescent = 1220
    current_us_win_descent = font["OS/2"].usWinDescent
    print("[INFO] Current usWinDescent: ", current_us_win_descent)

    font.save(font.reader.file.name)

if __name__ == "__main__":
    main(sys.argv[1])
