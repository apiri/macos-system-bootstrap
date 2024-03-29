#!/bin/sh -e

# Inspiration from https://github.com/mathiasbynens/dotfiles/blob/master/.macos

# Make scrolling actually natural
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Enable right click for our mouse
defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseButtonMode TwoButton

# Enable tap to click for everything
# http://osxdaily.com/2014/01/31/turn-on-mac-touch-to-click-command-line/
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
sudo defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
sudo defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
sudo defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

## Enable SSH
sudo systemsetup -setremotelogin on

## Enable Screensharing / VNC
sudo defaults write /var/db/launchd.db/com.apple.launchd/overrides.plist com.apple.screensharing -dict Disabled -bool false
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.screensharing.plist
sudo defaults write /Library/Preferences/com.apple.RemoteManagement.plist VNCOnlyLocalConnections -bool no

# Bounce Finder to enable preferences
killall Finder

# Setup homebrew if it is not installed.  This will also install XCode development tools
if test ! $(which brew); then
  echo "Installing homebrew..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
  echo "Homebrew already installed..."
fi

# Apply configuration
## Oh My Zsh
if [ ! -d "${HOME}/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "Oh My Zsh already initialized..."
fi

brew install autojump

echo "Setting up home config..."
# Setup system configuration files
if [ ! -d "${HOME}/.home_config" ]; then
  git clone --bare git@github.com:apiri/home-config.git ${HOME}/.home_config

  config_cmd="/usr/bin/git --git-dir=${HOME}/.home_config/ --work-tree=${HOME}"
  ${config_cmd} checkout --force
  ${config_cmd} config --local status.showUntrackedFiles no
fi

# Install default applications using global bundle
brew bundle install --global
