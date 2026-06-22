#! /bin/sh

for f in /root/Desktop/*.desktop; do
  chmod +x "$f"
  dbus-launch gio set -t string "$f" metadata::xfce-exe-checksum "$(sha256sum "$f" | cut -d ' ' -f 1)"
done
