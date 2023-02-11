# alpinelinux-install-xray

English(README.md) | 中文(简体) | [中文(繁体)](README_zh-tw.md)


## 依赖软件

### 安装 cURL

```
# apk add curl
```

## 下载

```
$ curl -O https://raw.githubusercontent.com/sarkrui/alpine-XrayR/main/install-xrayr.sh
```

## 使用

```
# ash install-release.sh
```

## 管理命令

### 启用

```
# rc-update add xray
```

### 禁用

```
# rc-update del xray
```

### 启动

```
# rc-service xray start
```

### 关闭

```
# rc-service xray stop
```

### 重启

```
# rc-service xray restart
```
