docker build -t your-docker-images-name:your-docker-images-tags . 
docker run -p your-own-port:22 --gpus all --restart always -v /your-host-dir/:/root/project -it your-docker-images-name:your-docker-images-tags
/usr/sbin/sshd -D &