curl -sL https://talos.dev/install | sudo sh
curl -s https://fluxcd.io/install.sh | sudo bash
git config --global user.email 'brotherlogic-automation@gmail.com'
git config --global user.name 'Brotherlogic Automation'
tic -x ghostty.terminfo

# Install tmux and emacs
sudo apt-get update && sudo apt-get install -y emacs
