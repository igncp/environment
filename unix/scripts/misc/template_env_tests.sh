#!/usr/bin/env bash

set -e

cat > docker_env.sh <<"EOF"
#!/usr/bin/env bash

set -e

if [ -f /root/finished ]; then
  /bin/bash
  exit 0
fi

touch /root/finished

apt-get update
apt-get install -y \
  git sudo rsync bsdmainutils openssh-server \
  cron vim

useradd -m -s /bin/bash igncp
echo "igncp ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

cp -r /app/environment /home/igncp/environment
chown -R igncp:igncp /home/igncp/environment
su - igncp -c "cp environment/unix/os/ubuntu/installation/vm2.sh . && bash ./vm2.sh"
su - igncp -c "mkdir -p ~/development/environment/project/.config && touch ~/development/environment/project/.config/inside"
su - igncp -c "bash project/provision/provision.sh"

echo "Finished preparing docker env"
EOF

if [ -z "$ENV_TESTS_RECREATE" ] && [ -n "$(docker ps -a | grep env-tests)" ]; then
  docker start -i env-tests
  exit 0
fi

docker rm env-tests || true

rm -rf environment
cp -r ~/development/environment .

docker run \
  -it \
  -v $(pwd):/app \
  --name env-tests \
  ubuntu:latest \
  /bin/bash /app/docker_env.sh
