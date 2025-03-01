DigDug for MEGA65
=================

Dig Dug is a classic arcade game originally released by Namco in 1982. In this timeless action-puzzle game, players control a character named Dig Dug, who must clear underground levels of enemies by either inflating them with an air pump until they burst or by dropping rocks on them. The game features two types of enemies: Pookas, red, round creatures with goggles, and Fygars, fire-breathing green dragons. As players dig through the dirt, they create tunnels, making strategic decisions to outmaneuver and eliminate their foes. With its engaging gameplay and iconic graphics, Dig Dug has remained a beloved title among retro gaming enthusiasts.

This core is based on the
[Arcade-DigDug_MiSTer](https://github.com/MiSTer-devel/Arcade-DigDug_MiSTer)
DigDug core which
itself is based on the wonderful work of [MrX-8B](AUTHORS).

The core uses the [MiSTer2MEGA65](https://github.com/sy2002/MiSTer2MEGA65)
framework and [QNICE-FPGA](https://github.com/sy2002/QNICE-FPGA) for
FAT32 support (loading ROMs, mounting disks) and for the
on-screen-menu.

How to install on your MEGA65
---------------------------------------------
Download the powershell or shell script depending on your preferred platform ( Windows, Linux/Unix and MacOS supported )

Run the script: a) First extract all the files within the zip to any working folder.

b) Copy the powershell or shell script to the same folder and execute it to create the following files.

**Ensure the following files are present and sizes are correct**
![image](https://github.com/user-attachments/assets/8ab0ae37-2d3c-4f61-b26f-44a72960b8c7)


For Windows run the script via PowerShell - digdug_rom_installer.ps1  
Simply select the script and with the right mouse button select the Run with Powershell  
![image](https://github.com/user-attachments/assets/3666e465-c6a6-4794-bfd0-1643042983e1)
 
For Linux/Unix/MacOS execute ./digdug_rom_installer.sh  

The script will automatically create the /arcade/digdug folder where the generated ROMs will reside.  

The output produced as a result of running the script(s) from the cmd line should match the following depending on your target platform.

![image](https://github.com/user-attachments/assets/0072d4ec-17ab-4f54-980e-4c6188fb0dbf)



Copy or move "arcade/digdug" to your MEGA65 SD card: You may either use the bottom SD card tray of the MEGA65 or the tray at the backside of the computer (the latter has precedence over the first).  
