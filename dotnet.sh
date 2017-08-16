#!bash
# Install .NET Core
# https://www.microsoft.com/net/core#ubuntu
# Test after installation:
#   mkdir hwapp
#   cd hwapp
#   dotnet new
#   dotnet restore
#   dotnet run

checkfail() {
    if [ $1 -gt 0 ]; then
        echo $2
        exit 1
    fi
}

# echo "deb [arch=amd64] https://apt-mo.trafficmanager.net/repos/dotnet-release/ xenial main" | sudo tee /etc/apt/sources.list.d/dotnetdev.list
# checkfail $? "apt sources failed"

# sudo apt-key adv --keyserver apt-mo.trafficmanager.net --recv-keys 417A0893
# checkfail $? "apt-key failed"

# sudo apt update
# checkfail $? "apt update failed"

# sudo apt-get install dotnet-dev-1.0.0-preview2-003121
# checkfail $? "install dotnet-dev-xxx failed"

mkdir ~/Downloads/dotnet
checkfail $? "tmp directory creation failed"

curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > ~/Downloads/dotnet/microsoft.gpg
checkfail $? "Curl failed"

sudo mv ~/Downloads/dotnet/microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
checkfail $? "Copy microsoft.gpg file failed"

sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-zesty-prod zesty main" > /etc/apt/sources.list.d/dotnetdev.list'
checkfail $? "Create apt dotnetdev.list file failed"

sudo apt-get update
