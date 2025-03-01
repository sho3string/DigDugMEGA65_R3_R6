#!/bin/bash

# Get the current working directory
WorkingDirectory=$(pwd)
length=56

clear
echo " .------------------------."
echo " | Building Dig Dug ROMs  |"
echo " '------------------------'"

# Create directories
mkdir -p "$WorkingDirectory/arcade/digdug"

echo "Copying Dig Dug ROMs"
# Concatenate the files into one
cat "$WorkingDirectory/dd1a.1" "$WorkingDirectory/dd1a.2" "$WorkingDirectory/dd1a.3" "$WorkingDirectory/dd1a.4" > "$WorkingDirectory/arcade/digdug/rom1.rom"

echo "Copying Gfx #2 ROMs"
# Concatenate the files into one
cat "$WorkingDirectory/dd1.15" "$WorkingDirectory/dd1.14" "$WorkingDirectory/dd1.13" "$WorkingDirectory/dd1.12" > "$WorkingDirectory/arcade/digdug/gfx2.rom"

echo "Copying Gfx #3 ROM"
cp "$WorkingDirectory/dd1.10b" "$WorkingDirectory/arcade/digdug/dd1.10b"

echo "Copying Gfx #4 ROM"
cp "$WorkingDirectory/dd1.11" "$WorkingDirectory/arcade/digdug/dd1.11"

echo "Copying font ROM"
cp "$WorkingDirectory/dd1.9" "$WorkingDirectory/arcade/digdug/dd1.9"

echo "Copying font Sound PROM"
cp "$WorkingDirectory/136007.110" "$WorkingDirectory/arcade/digdug/136007.110"

echo "Copying font Sprite PROM"
cp "$WorkingDirectory/136007.111" "$WorkingDirectory/arcade/digdug/136007.111"

echo "Copying font Char PROM"
cp "$WorkingDirectory/136007.112" "$WorkingDirectory/arcade/digdug/136007.112"

echo "Copying font Palette PROM"
cp "$WorkingDirectory/136007.113" "$WorkingDirectory/arcade/digdug/136007.113"

echo "Generating blank config file"
# Generate blank config file
dd if=/dev/zero bs=1 count=$length | tr '\0' '\377' > "$WorkingDirectory/arcade/digdug/ddcfg"

echo "All done!"
