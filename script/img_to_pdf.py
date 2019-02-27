#!/usr/bin/python

import os
import sys
import shutil
from pathlib import Path
import img2pdf

def imgs_to_pdf(name, images):
    # name: string
    # images: PosixPath[]

    if Path(name).suffix != ".pdf":
        print("Not pdf file")
        return

    print(name)
    with open(name, "wb") as f:
        f.write(
            img2pdf.convert(
                [str(image)
                    for image in images
                    if image.match("*.jpg") or image.match("*.png")]))

def main():
    if len(sys.argv) < 2:
        print("required args")
        return

    root = Path(sys.argv[1])
    for dir in root.iterdir():
        if dir.is_file():
            print("Not directory")
            continue
        inputPath = os.path.abspath(dir)
        outputPath = inputPath + ".pdf"
        try:
            imgs_to_pdf(outputPath, sorted(list(dir.iterdir())))
        except Exception as e:
            print(e)
        else:
            # 存在しないか確認
            # 日付を使ってディレクトリを作成する
            shutil.move(inputPath, "./input/")
            shutil.move(outputPath, "./pdf")

if __name__ == '__main__':
    main()
