# For persistence
mkdir -p /home/coder/coursera/.coursera-dotfiles/

# Persist VSCode files
mkdir -p /home/coder/coursera/vscode/projects
ln -s /home/coder/coursera/vscode/projects /home/coder/vscode/projects

# Set up Python Extension
code --install-extension ms-python.python &
# Install vscode extensions
# code --install-extension formulahendry.code-runner &
# Lock in this version to maintain documented testing UI
# code --install-extension vscjava.vscode-java-test &
# code --install-extension vscjava.vscode-maven &

# clone openschc if it does not already exist & persist
FOLDER=/home/coder/coursera/openschc
URL=https://github.com/ltn22/openschc.git
if [ ! -d "$FOLDER" ] ; then
    git clone $URL $FOLDER && cd $FOLDER && git checkout MOOC
fi
# else
    # cd "$FOLDER"
    # git pull $URL
ln -s /home/coder/coursera/openschc /home/coder/openschc

# start the core-daemon
sudo env PATH=$PATH core-daemon &

# set wallpaper
# xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-path -s /usr/share/backgrounds/schc-wg.png
# xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVNC-0/workspace0/last-image -s /usr/share/backgrounds/schc-wg.png
# xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVNC-0/workspace0/image-style -s 3
