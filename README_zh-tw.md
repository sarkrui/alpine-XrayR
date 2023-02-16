# alpinelinux-install-xray

English(README.md) | [中文(简体)](README_zh-cn.md) | 中文(繁体)


## 依賴軟體

### 安裝 cURL

```
# apk add curl
```

## 下載

```
$ curl -O https://raw.githubusercontent.com/sarkrui/alpine-XrayR/main/install-xrayr.sh
```

## 使用

```
# ash install-xrayr.sh
```

## 管理指令

### 啟用

```
# rc-update add xray
```

### 禁用

```
# rc-update del xray
```

### 啟動

```
# rc-service xray start
```

### 關閉

```
# rc-service xray stop
```

### 重啟

```
# rc-service xray restart
```
