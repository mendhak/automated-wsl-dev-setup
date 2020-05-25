
export DEBIAN_FRONTEND=noninteractive
sudo -E apt-get -y update
sudo -E apt-get -y upgrade
mkdir -p ~/.local/bin
source ~/.profile

# Essential tools
sudo -E apt-get install -y unzip git figlet jq screenfetch
sudo -E apt-get install -y apt-transport-https ca-certificates curl software-properties-common
sudo -E apt-get install -y python3 python3-pip build-essential libssl-dev libffi-dev python-dev  

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo -E apt-key add -

sudo -E add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo -E apt-get -y update

 
# Install the latest version of Docker CE 
sudo -E apt-get install -y docker-ce 
 
# Allow your user to access the Docker CLI without needing root access.
sudo -E usermod -aG docker $USER

# Install Docker Compose into your user's home directory.
pip3 install --user docker-compose


# Tell Docker client where Docker Desktop is listening.
echo "export DOCKER_HOST=tcp://localhost:2375" >> ~/.bashrc && source ~/.bashrc

# Tell GPG what kind of terminal this is
echo 'export GPG_TTY=$(tty)' >> ~/.bashrc

# workaround for umask gets ignored Issue: https://github.com/microsoft/WSL/issues/352
echo '[[ "$(umask)" == '\''0000'\'' ]] && umask 0022' >> ~/.bashrc

# SSH directory 
mkdir -p ~/.ssh/
chmod 700 ~/.ssh

