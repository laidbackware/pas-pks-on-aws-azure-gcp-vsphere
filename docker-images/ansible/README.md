# Image build instructions

You must download OVF tool and place it in the same folder as the docker file.
https://www.vmware.com/support/developer/ovf/

```
docker login

docker build . -t laidbackware/ansible-aio:latest

docker push laidbackware/ansible-aio:latest
```