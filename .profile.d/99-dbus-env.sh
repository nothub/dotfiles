# shellcheck shell=sh

# D-Bus/systemd-activated services (e.g. Thunar) don't inherit this login
# shell's PATH, since they're started on demand by the session's systemd
# --user manager. Push the PATH built above into that manager's environment
# so those services see it too.
if command -v dbus-update-activation-environment > /dev/null 2>&1; then
    dbus-update-activation-environment --systemd PATH
fi
