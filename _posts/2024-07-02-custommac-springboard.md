---
layout: post
title: "启动台-自定义"
date: 2024-07-02
tags: "Mac iTerm2"
category: 
---

启动台（Launchpad）是 MacOS 上一个便于用户快速查找启动程序的快捷入口
## 自定义

默认情况下，它的网格布局为 7x5，7 列 5 行的布局，一屏可以承载 35 枚图标。

定义「列数」
```
defaults write com.apple.dock springboard-columns -int 8
```

定义「行数」
```
defaults write com.apple.dock springboard-rows -int 6
```
重置并重启启动台
```
defaults write com.apple.dock ResetLaunchPad -bool true;killall Dock
```

![alt text](/assets/image/custommac-springboard.png)

### 恢复默认设置

```
defaults delete com.apple.dock springboard-rows
defaults delete com.apple.dock springboard-columns
s write com.apple.dock ResetLaunchPad -bool TRUE;killall Dock
```



## 快速设置 Launchpad
如果你之前安装的 App 数目较多，在 Launchpad 中拖放排列工作量非常大。你可以考虑使用 [Launchpad Manager](https://www.launchpadmanager.com/) 来管理设置 Launchpad 中 App 的顺序。




