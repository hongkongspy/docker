# mule-docker
build a docker image with Mule 4.x (no application bundled)

This repo provides an example on how to build a dockerized standalone Mule Runtime. As the Runtime starts, it will register itself to management plane. It will also remove itself when the docker container is destroyed

# Content
1. Sample Dockerfile
2. Sample mule start/stop script
3. Sample mule app definition for Mesos/Marathon
4. Sample hello world mule application
