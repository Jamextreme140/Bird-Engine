# Friday Night Funkin' - Bird Engine

![BirdEngine_banner](https://github.com/user-attachments/assets/00806e96-798e-4c40-8867-c2fd21d06ade)

## CHECK THE [DOCUMENTATION](https://github.com/Jamextreme140/Bird-Engine/tree/main/docs/lua)

Want to use Codename Engine but you want to use Lua (hi psych users :3) or are you still learning Haxe (for HScript)? This is the perfect fork to start with.

Originally developed for FNF Vs SC. This custom engine includes the following features

- Full Lua Script support with OOP-like programming **(Not compatible with Psych Lua)**
  - Gameplay Scripting
  - Customizable States/Substates (and Custom ones too)
  - NDLL management
- Modchart system by [TheoDevelops](https://github.com/TheoDevelops/FunkinModchart) (on early stage)

**NOTE**: Even with the improved Lua flexibility, do not consider it as a Scripting replacement, but as a complement. Remember that the main scripting system of this engine is HScript.

Known issues in the beta:

- Some options are missing

Build instructions are below. Press TAB on the main menu to switch mods.

Also, the command `.\bird test` uses the source assets folder instead of the export one for easier development (Although you can still use `lime test windows` normally).

<details>
  <summary><h2>Credits</h2></summary>

- Credits to [superpowers04](https://github.com/superpowers04) for [linc_luajit](https://github.com/superpowers04/linc_luajit) (Lua support).
- Credits to [TheoDevelops](https://github.com/TheoDevelops) for the [FunkinModchart](https://github.com/TheoDevelops/FunkinModchart) framework.
</details>

## DISCLAIMER - THIS IS A SUB-ENGINE OF [CODENAME ENGINE](https://github.com/CodenameCrew/CodenameEngine)

### Original Engine Info

## Codename Engine

Codename Engine is a new Friday Night Funkin' Engine aimed at simplifying modding, along with extensiblity and ease of use.<br>
### Before making issues or need help with something, check the official website [HERE](https://codename-engine.com/) (it contains a wiki of how to mod with EXAMPLES, an api, lists of mods made with Codename Engine and more)!!!
#### The Base Engine includes many new features, as seen [here](FEATURES.md)<br>
#### Wanna see the new features added in the most recent update? Click [here](PATCHNOTES.md)<br>

## How to download

Latest builds for the engine can be found in the [Actions](https://github.com/YoshiCrafter29/CodenameEngine/actions) tab.<br>
In the future (when the engine won't be a WIP anymore) we're gonna also publish the engine on platforms like Gamebanana; stay tuned!

<details>
  <summary><h2>How to build</h2></summary>

> **Open the instructions for your platform**
<details>
    <summary>Windows</summary>

##### Tested on Windows 10 21H2
1. Install [version 4.2.5 of Haxe](https://haxe.org/download/version/4.2.5/).
2. Download and install [`git-scm`](https://git-scm.com/download/win).
    - Leave all installation options as default.
3. Run `update.bat` using cmd or double-clicking it, and wait for the libraries to install.
4. Once the libraries are installed, run `haxelib run lime test windows` to compile and launch the game (may take a long time)
    - ℹ You can run `haxelib run lime setup` to make the lime command global, allowing you to execute `lime test windows` directly.
</details>
<details>
    <summary>Linux</summary>

##### Requires testing
1. Install [version 4.2.5 of Haxe](https://haxe.org/download/version/4.2.5/).
2. Install `g++`, if not present already.
3. Download and install [`git-scm`](https://git-scm.com/download/linux).
4. Open a terminal in the Codename Engine source folder, and run `update.sh`.
5. Once the libraries are installed, run `haxelib run lime test linux` to compile and launch the game (may take a long time)
    - ℹ You can run `haxelib run lime setup` to make the lime command global, allowing you to execute `lime test linux` directly.
</details>
<details>
    <summary>MacOS</summary>

##### Requires testing
1. Install [version 4.2.5 of Haxe](https://haxe.org/download/version/4.2.5/).
2. Install `Xcode` to allow C++ app building.
3. Download and install [`git-scm`](https://git-scm.com/download/mac).
4. Open a terminal in the Codename Engine source folder, and run `update.sh`.
5. Once the libraries are installed, run `haxelib run lime test mac` to compile and launch the game (may take a long time)
    - ℹ You can run `haxelib run lime setup` to make the lime command global, allowing you to execute `lime test mac` directly.
</details>
</details>

<details>
  <summary><h2>What can you do or not do</h2></summary>

  ### You can:
  - Download and play the engine with its mods and modpacks
  - Mod and fork the engine (without using it for illicit purposes)
  - Contribute to the engine (for example through *Pull Requests*, *Issues*, etc)
  - Create a sub engine with Codename Engine as **TEMPLATE** with **CREDITS** (for example leaving the *credits menu submenu with the GitHub contributors* and putting the *[main devs](https://github.com/CodenameCrew)* in a *README* specifying that it's a *sub engine from Codename Engine*)
  - Release excutable mods that use Codename Engine as source (Specifing that uses Codename Engine by for example the same way written above this)
  - Release modpacks

  ### You can't:
  - Create a *side/new/etc* engine (or mod that doesn't use Codename Engine) using Codename Engine's code
  - Steal code from Codename Engine for another different project that is not Codename Engine related (Codename Engine mods excluded) without properly crediting
  - Release the entire Codename Engine on platforms (Mods that use Codename Engine as source are fine, if it's specified even better)

  #### *If you need more info or feel like asking to do something which is not listed here, ask us directly on our discord (linked in the wiki)!*
</details>

<details>
  <summary><h2>Credits</h2></summary>

- Credits to [Ne_Eo](https://twitter.com/Ne_Eo_Twitch) and the [3D-HaxeFlixel](https://github.com/lunarcleint/3D-HaxeFlixel) repository for Away3D Flixel support
- Credits to the [FlxAnimate](https://github.com/Dot-Stuff/flxanimate) team for the Animate Atlas support
- Credits to Smokey555 for the backup Animate Atlas to spritesheet code
- Credits to MAJigsaw77 for [hxvlc](https://github.com/MAJigsaw77/hxvlc) (video cutscene/mp4 support) and [hxdiscord_rpc](https://github.com/MAJigsaw77/hxdiscord_rpc) (discord rpc integration)
</details>
