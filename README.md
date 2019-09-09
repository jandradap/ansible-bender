# ansible-bender [![](https://images.microbadger.com/badges/version/jorgeandrada/ansible-bender:latest.svg)](https://microbadger.com/images/jorgeandrada/ansible-bender:latest "Get your own version badge on microbadger.com") [![](https://images.microbadger.com/badges/image/jorgeandrada/ansible-bender:latest.svg)](https://microbadger.com/images/jorgeandrada/ansible-bender:latest "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/commit/jorgeandrada/ansible-bender:latest.svg)](https://microbadger.com/images/jorgeandrada/ansible-bender:latest "Get your own commit badge on microbadger.com")

ansible-bender image for CI/CD

<a href='https://ko-fi.com/A417UXC' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://az743702.vo.msecnd.net/cdn/kofi2.png?v=0' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>

## Example with nginx rol

Run the container:

```bash
docker run --name nginxexample \
--rm --privileged \
-v $HOME/.ssh:/root/.ssh:ro \
-v /var/run/docker.sock:/var/run/docker.sock \
-v $(pwd):/usr/src:rw \
-it jorgeandrada/ansible-bender bash
```

Download and install the role and the example:

```bash
ansible-galaxy install nginxinc.nginx
wget https://raw.githubusercontent.com/jandradap/ansible-bender/master/examples/nginx-playbook.yml
```

Build and push to the local daemon, for other storage [check here](https://github.com/containers/libpod/blob/master/docs/podman-push.1.md).

```bash
ansible-bender build nginx-playbook.yml
ansible-bender list-builds
ansible-bender push docker-daemon:bender-nginx:latest 1
exit
```

Check local images:

```bash
docker images | grep bender-nginx
```

Run the example container and check:

```bash
docker run -d -p 8080:80 bender-nginx

curl http://localhost:8080
```
