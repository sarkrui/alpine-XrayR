# alpinelinux-install XrayR

English | [中文(简体)](README_zh-cn.md) | [中文(繁体)](README_zh-tw.md)

## Install dependencies

### Install cURL

```
# apk add curl
```

## Download

```
$ curl -O https://raw.githubusercontent.com/sarkrui/alpine-XrayR/main/install-xrayr.sh
```

## Use

```
# ash install-xrayr.sh
```

## Commands

### Enable

```
# rc-update add XrayR
```

### Disable

```
# rc-update del XrayR
```

### Start

```
# rc-service XrayR start
```

### Stop

```
# rc-service XrayR stop
```

### Restart

```
# rc-service XrayR restart
```
