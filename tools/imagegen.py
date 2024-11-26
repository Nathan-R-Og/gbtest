from glob import glob
import subprocess
#python script so i dont have to rely on make. lol.

#without these, autogen 'colors' get REALLLLLY annoying. tune to your preference
light_color = "#FFFFFF"
lightgray_color = "#A4A4A4"
darkgray_color = "#686868"
dark_color = "#000000"

images = glob("gfx/*.png", recursive=True)

for image in images:
    base = image.replace("gfx/", "").replace(".png", "")
    output = f"build_artifacts/{base}.2bpp"
    color_input = ",".join([light_color, lightgray_color, darkgray_color, dark_color])
    subprocess.run(['rgbgfx', "--colors", color_input,"-o", output, image])
