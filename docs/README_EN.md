# GIMS (Genshin Impact Mutiple Servers Creating Tool)

English | [ÖÐÎÄ](https://github.com/ELPSI/GIMS/blob/main/README.md)

A tool of creating **mutiple** game servers of **Genshin Impact** on one computer with **64-bit operating system of Windows 10,11**.

## Background
  As we know, Genshin Impact has three game servers:

1. **Sky-Island server** (**official server**, and ID starts with the number **1 or 2**);

2. **World-Tree server** (**bilibili server**, and ID starts with the number **5**);

3. **International server** (including America, Europe, Asia and TW,HK,MO, and ID starts with the number **6, 7, 8 or 9**).

And the the first two servers belong to **mainland Chinese servers**.

As of now, if you fully install **1 server** of the game, it takes about **56 GB** of space on your computer's disk, and if you install **double**, it takes **double**. To avoid this, This tool used the **"mklink"** command to create link files on demand, greatly reducing the required disk space.

This tool is mainly designed for **mainland Chinese players** to easily play games on three servers of Genshin Impact on only one computer, so that you don't have to fully download multiple game resources, which will cause to run out of the hard disk space. 

If you create another **2 servers** with this tool, it will take up to about **1 GB** of disk space (not counting space of resource pack, because you can delete them after creation), and if you only create only **1 server**, it will take up to **500~600 MB** of disk space.

## Install
This is a **batch file** and does not require installation, and only resource packs need to be downloaded and unzipped.

## Usage
1. **Download** this tool and **unzip** it to be a folder named `GIMS` on your computer.

2. If needed, **download one or more** of these three files to this unzipped directory: `PCGameSDK.dll` (especially for **World-Tree server**), `CNRes_Vx.x.x.exe` and `SeaRes_Vx.x.x.exe` (zipped packages in self-extracting format, and **x.x.x** indicating the **version number**). You can download the file according to these several situations below:

3. **Double-click** to run `GIMS_CN.bat` (Chinese) or `GIMS_EN.bat` (English).

4. In the **command prompt window** that pops up, you need to **select the server** to be created by inputting a number from **1, 2 or 3**, and press "**Enter**" key to continue(**1: Sky-Island server; 2: World-Tree server; 3: International server**). By the way, if the game server represented by the number which you input already exists or an illegal value is inputted, the program will prompt you to re-input.

5. If you belong to **Situation 3 or 4**, the program will prompt you to put the "**.exe**" file under `GIMS` folder and unzip it, then you only need to click "**Extract**" by default and wait a while.

6. Then the program will run automatically, and finally you just need to press the "**Enter**" key to exit the command prompt window.

7. Now you can see a newly created **shortcut** of Genshin Impact game on your **computer desktop**, **double click** it and enjoy yourself!

> **Situation 1:** If the **initial server** is **Sky-Island server**, the **new server** is **World-Tree server**, you need to download `PCGameSDK.dll` to `GIMS` folder. 
>
> **Situation 2:** If the **initial server** is **World-Tree server**, the **new server** is **Sky-Island server**, you don't need to download any other files.
>
> **Situation 3:** If the **initial server** is **Sky-Island server** or **World-Tree server**, the **new server** is **International server**, you need to download `SeaRes_Vx.x.x.exe` to `GIMS` folder.
>
> **Situation 4:** If the **initial server** is **International server**, the **new server** is **Sky-Island server** or **World-Tree server**, you need to download `CNRes_Vx.x.x.exe` to `GIMS` folder.

## Notice
1. Please ensure that your game can run normally before using this tool.

2. If you can't connect to the server, maybe you need to use a network tool such as a game accelerator.

3. The resource files used by this tool are all extracted from the **official resource files** of Genshin Impact. Except for `config.ini`, there is **no modification** of the original game resource files, which will not affect the use of the original server. If you don't want to use this tool later, you can delete the newly created `GenshinImpactNew` folder and `GIMS` folder.

## Author
[@elpsi](https://github.com/ELPSI)

## Thanks
- [@wanting0521](https://github.com/wanting0521) - provided the inspiration for this tool.

## License
[MIT](https://github.com/ELPSI/blob/master/LICENSE)