drone-demo
==

### 1. 本项目用于验证 drone 实现 CI/CD

流水线如图所示

![](./images/53ABDC84-E0BB-4818-8C60-98A7606D1048.png)

### 2. 目录结构如下

```shell script
.
├── .drone.yml
├── .gitignore
├── Dockerfile
├── README.md
├── docker-compose.yml
├── go.mod
├── images
│   └── 53ABDC84-E0BB-4818-8C60-98A7606D1048.png
├── main.go
├── main_test.go
└── script
    └── build.sh
```

### 3. .drone.yml

```yaml
kind: pipeline
name: demo

# 工作目录 [module 模式下 path 不能在 go 下]
workspace:
  base: /go
  path: /usr/local/

steps:
  - name: test
    image: golang:latest
    commands:
      - go test 

  - name: build
    image: golang:latest
    commands:
      - go build .

  - name: scp
    image: appleboy/drone-scp
    settings:
      host: 
        from_secret: scp_host
      username: 
        from_secret: scp_uname
      password: 
        from_secret: scp_password
      port: 22
      target: /var/www/deploy/${DRONE_REPO_OWNER}/${DRONE_REPO_NAME}
      source:
        - ./*

  - name: ssh
    image: appleboy/drone-ssh
    settings:
      host: 
        from_secret: ssh_host
      username: 
        from_secret: ssh_uname
      password: 
        from_secret: ssh_password
      port: 22
      command_timeout: 2m
      script:
        - echo "------------------< 进入项目目录 >------------------"
        - cd /var/www/deploy/${DRONE_REPO_OWNER}/${DRONE_REPO_NAME}
        - echo "------------------< 停止容器 >------------------"
        - docker stop demo-golang
        - echo "------------------< 删除容器 >------------------"
        - docker rm -v demo-golang
        - echo "------------------< 删除旧镜像 >------------------"
        - docker rmi golang
        - echo "------------------< 拉取新镜像 >------------------"
        - docker pull golang
        - echo "------------------< 运行新镜像 >------------------"
        - docker-compose up -d
        - echo "------------------< 开放端口 >------------------"
        - firewall-cmd --zone=public --remove-port=8088/tcp --permanent
        - exit
```

### 4. `.drone.yml` 中的敏感信息配置

敏感信息请访问 `drone` 管理界面

如图所示

![](./images/6F7CB882-D50D-49DB-AE9A-89D3B25051A6.png)


