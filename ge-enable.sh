#!/bin/bash

# enable caffeine
gsettings --schemadir ~/.local/share/gnome-shell/extensions/caffeine@patapon.info/schemas/ set org.gnome.shell.extensions.caffeine user-enabled true

# enable hue-lights
gnome-extensions enable hue-lights@chlumskyvaclav.gmail.com

echo "Enabled the gnome extensions"
