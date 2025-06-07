## check if sudo frst other wise exist

## setup docker
apt-get update -y
apt-get install docker.io docker-compose tor make -y

cp torrc /etc/tor/torrc
cp -r config/nodes/* /var/lib/tor/

## build base files
cd .. && make skip-tests

cd docker/seednode && docker compose up --build 
