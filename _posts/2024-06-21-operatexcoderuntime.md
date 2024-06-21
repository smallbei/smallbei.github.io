---
layout: post
title: "Xcode 模拟器 Runtime"
date: 2024-06-21
tags: "Mac Xcode"
category: 
---


**查看 本地 `runtime` 版本**
```
xcrun simctl runtime list
```
![alt text](/assets/image/simctl_runtime_list.png)

**删除 `runtime` 版本**
```
xcrun simctl runtime delete
```

![alt text](/assets/image/simctl_runtime_delete.png)

**添加 `runtime` 版本**
```
xcrun simctl runtime add /Users/youzhenbei/Downloads/Dmg/Xcode/iOS_17.2_Simulator_Runtime.dmg
```

