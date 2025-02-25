# LinuxSetupUtils
ToolBox with several configuration scripts and tips for your Linux system.

## Syncronization
Located in ``Sync`` dir, tools and scripts to sync your data keeping it safe and FLOSS.

### Thunderbird configuration
Script to sync thunderbird configuration in your nextcloud, so it can be available in all your devices. 

The script detects the specific profile, moves the config files to Nextcloud and synlinks them to the config path in Thunderbird.


## Remarkable
Tools used for remarkable:
### Autorun of Remouse
Remouse is a FLOSS tool to use your tablet as graphic tablet. It is available at: https://github.com/evidlo/remarkable_mouse

``run_remouse.sh`` simply runs pyhton instance of remouse receiving the screen id. 

Use:
  sh run_remouse.sh 

