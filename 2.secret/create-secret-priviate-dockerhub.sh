#!/bin/bash

kubectl create secret docker-registry regcred --docker-server=https://hub.docker.com/repository/docker/swgu931 --docker-username=<계정아이디> --docker-password=<비밀번호> --docker-email=이메일 