#!bash
sudo add-apt-repository ppa:freecad-maintainers/freecad-stable
sudo add-apt-repository ppa:freecad-maintainers/freecad-daily

curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

echo "deb [arch=amd64] https://apt-mo.trafficmanager.net/repos/dotnet-release/ yakkety main" | sudo tee /etc/apt/sources.list.d/dotnetdev.list
sudo apt-key adv --keyserver apt-mo.trafficmanager.net --recv-keys 417A0893

sudo add-apt-repository ppa:inkscape.dev/stable

sudo add-apt-repository ppa:nginx/stable

curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash -

sudo add-apt-repository ppa:notepadqq-team/notepadqq

sudo add-apt-repository ppa:ubuntu-lxc/lxc-stable
sudo add-apt-repository ppa:ubuntu-lxc/lxd-stable

sudo add-apt-repository ppa:wireshark-dev/stable

echo "deb http://apt.postgresql.org/pub/repos/apt/ zesty-pgdg main" | sudo tee /etc/apt/sources.list.d/postgresql.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

