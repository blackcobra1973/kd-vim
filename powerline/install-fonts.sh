#!/bin/bash

# Set source and target directories
powerline_fonts_dir=$( cd "$( dirname "$0" )" && pwd )

find_font_command="find \"$powerline_fonts_dir\" \( -name '*.[o,t]tf' -or -name '*.pcf.gz' \) -type f -print0"
find_conf_command="find \"$powerline_fonts_dir\" \( -name '*.conf' \) -type f"

if [[ `uname` == 'Darwin' ]]; then
  # MacOS
  font_dir="$HOME/Library/Fonts"
else
  # Linux
  font_dir="/usr/share/fonts/powerline"
  mkdir -p $font_dir
  ln -s /usr/share/fonts/powerline /etc/X11/fontpath.d/powerline-fonts
  font_conf_dir="/usr/share/fontconfig/conf.avail"
  mkdir -p $font_conf_dir
fi

# Copy all fonts to fonts directory
echo "Copying fonts..."
eval $find_font_command | xargs -0 -I % cp "%" "$font_dir/"

# Copy all fonts config to fonts directory
echo "Copying fonts configs..."
eval $find_conf_command -print0 | xargs -0 -I % cp "%" "$font_conf_dir/"
eval $find_conf_command -printf '%f\n' | xargs -0 -I % cp $font_conf_dir/"%" /etc/fonts/conf.d/"%"

# Reset font cache on Linux
if command -v fc-cache @>/dev/null ; then
    echo "Resetting font cache, this may take a moment..."
    fc-cache -f $font_dir
fi

echo "All Powerline fonts installed to $font_dir"

