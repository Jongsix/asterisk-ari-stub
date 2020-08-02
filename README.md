asterisk docker image

```
docker build . -t xyz/asterisk
docker run -ti --rm --net=host -e SIP_USERNAME=xxx -e SIP_PASSWORD=xxx -e ARI_USERNAME=xxx -e ARI_PASSWORD=xxx xyz/asterisk:latest
```

