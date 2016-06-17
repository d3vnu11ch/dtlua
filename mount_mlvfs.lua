--[[
MOUNT_MLVFS
* this plugin will mount/unmount all *.mlv files beneath a given directory on startup/shutdown of darktable.
* should be useful when treating RAW-Video files recorded with Magic Lantern (http://www.magiclantern.fm/).
* so far, only tested on Debian 8 and Ubuntu 14.04

AUTHOR
Fabian Waeber (d3v@nu11.ch)

ADDITIONAL SOFTWARE NEEDED FOR THIS SCRIPT
* mlvfs (see https://bitbucket.org/dmilligan/mlvfs for download and howto install)
* fuse-dev needed as a build depency for mlvfs

INSTALLATION
* copy this file in $CONFIGDIR/lua/ where CONFIGDIR is your darktable configuration directory
* require this file from your main lua config file or enable it through "include_all.lua"
see http://www.darktable.org/usermanual/ch09.html.php#lua_basic_principles for basic darktable & lua usage.

USAGE
configure at least the following three options and restart darktable:
* MLVFS Binary: Location of the mlvfs binary.
* MLVFS Source Directory: Directory containing the *.mlv files to mount.
* MLVFS Destination Directory: Empty (!) target directory.

use any options described at https://bitbucket.org/dmilligan/mlvfs under "MLVFS Options", execpt: "-f" (foreground operation) as it would block darktable startup. Therefore the webinterface of mlvfs will not work with this plugin!

LICENSE
GPLv3
]]

local dt = require "darktable"
dt.configuration.check_version(...,{3,0,0})

-- register settings
dt.preferences.register(
  "mount_mlvfs",
  "mount_mlvfs_dst",
  "directory","MLVFS Destination Directory",
  "Target mountpoint for mlvfs - it's where all *.dng files will appear.",
  "/path/to/mlvfs/destination"
)

dt.preferences.register(
  "mount_mlvfs",
  "mount_mlvfs_src",
  "directory", "MLVFS Source Directory",
  "Directory containing all *.mlv files to mount.",
  "/path/to/mlvfs/source"
)

dt.preferences.register(
  "mount_mlvfs",
  "mount_mlvfs_opt",
  "string", "MLVFS Options",
  "Additional mlvfs parameters - see https://bitbucket.org/dmilligan/mlvfs for complete list.",
  ""
)

dt.preferences.register(
  "mount_mlvfs",
  "mount_mlvfs_bin",
  "file", "MLVFS Binary",
  "Complete path to the mlvfs executable.",
  "/path/to/mlvfs/executable"
)

-- setup vars
local mfsbin = dt.preferences.read("mount_mlvfs","mount_mlvfs_bin","string")
local srcdir = dt.preferences.read("mount_mlvfs","mount_mlvfs_src","string")
local dstdir = dt.preferences.read("mount_mlvfs","mount_mlvfs_dst","string")
local mfsopt = dt.preferences.read("mount_mlvfs","mount_mlvfs_opt","string")
local mlvfs_mount_cmd = mfsbin.." "..mfsopt.." --mlv_dir="..srcdir.." "..dstdir
local mlvfs_umount_cmd = "fusermount -u "..dstdir

-- mount on startup
local exitval = os.execute(mlvfs_mount_cmd)
if exitval == true then
  dt.print("Mounted mlvfs source "..srcdir.." to "..dstdir..".")
else
  dt.print("ERROR while mounting mlvfs - start darktable from commandline with \"-d lua\" to see more details.")
end
  
-- unmount on shutdown
dt.register_event(
  "exit",
  function()
    local exitval = os.execute(mlvfs_umount_cmd)
  end
)

--
-- vim: shiftwidth=2 expandtab tabstop=2 cindent syntax=lua
