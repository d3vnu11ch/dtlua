--[[
MOUNT_MLVFS

Automatically mounts Magic Lantern's *.mlv files through fuse and mlvfs

ADDITIANAL SOFTWARE NEEDED FOR THIS SCRIPT
* mlvfs (see https://bitbucket.org/dmilligan/mlvfs for download and howto install)
* fuse-dev even as a build depency to mlvfs (apt-get install libfuse-dev on Untuntu 14.04)

USAGE
* require this file from your main lua config file or enable it through "include_all.lua":

This plugin will mount/unmount all *.mlv files beneath a given directory on startup/shutdown.

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
  "mount_mlvfs_bin",
  "file", "MLVFS Binary",
  "Complete path to the mlvfs executable.",
  "/path/to/mlvfs/executable"
)

-- setup vars
local srcdir = dt.preferences.read("mount_mlvfs","mount_mlvfs_src","string")
local dstdir = dt.preferences.read("mount_mlvfs","mount_mlvfs_dst","string")
local mlvfs_mount_cmd = dt.preferences.read("mount_mlvfs","mount_mlvfs_bin","string").." "..dstdir.." --mlv_dir="..srcdir
local mlvfs_umount_cmd = "fusermount -u "..dstdir

-- mount on startup
-- dt.print_error(" - MLVFS: executing "..mlvfs_mount_cmd) -- DEBUG ONLY
local exitval = os.execute(mlvfs_mount_cmd)
if exitval == true then
  dt.print("Mounted mlvfs source "..srcdir.." to "..dstdir..".")
else
  dt.print("ERROR while mounting mlvfs source "..srcdir.." to "..dstdir..".")
end
  
-- unmount on shutdown
dt.register_event(
  "exit",
  function()
    -- dt.print_error(" - MLVFS: executing "..mlvfs_umount_cmd.." to unmount mlvfs under "..dstdir..".") -- DEBUG ONLY
    local exitval = os.execute(mlvfs_umount_cmd)
  end
)

--
-- vim: shiftwidth=2 expandtab tabstop=2 cindent syntax=lua
