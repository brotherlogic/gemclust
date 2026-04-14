curl -sL https://talos.dev/install.sh | sudo sh
curl -s https://fluxcd.io/install.sh | sudo bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin
git config --global user.email 'brotherlogic-automation@gmail.com'
git config --global user.name 'Brotherlogic Automation'
tic -x ghostty.terminfo