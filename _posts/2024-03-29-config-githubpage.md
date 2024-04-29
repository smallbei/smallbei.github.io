---
layout: post
title: "配置GitHubPage"
date: 2024-03-29
tags: jekyll DNS配置 工具
category: 
---

## 配置 GitHub Pages 站点的自定义域
验证 [参考文档：](https://docs.github.com/zh/pages/configuring-a-custom-domain-for-your-github-pages-site/verifying-your-custom-domain-for-github-pages)
Page [参考文档：](https://docs.github.com/zh/pages/configuring-a-custom-domain-for-your-github-pages-site/about-custom-domains-and-github-pages)

1. 配置 Github Page Domain
2. 验证自定义 Domain
3. 添加可用 DNS 节点

### 添加 Page 自定义 Domain
![alt text](/assets/image/PageSetting.png){:width="70%"}

### 验证 自定义 Domain

- 在任何页面的右上角，单击个人资料照片，然后单击“设置”。

  - ![alt text](/assets/image/setting.png){:width="50%"}
- 在边栏的“代码、规划和自动化”部分中，单击“Pages”。
  
-  在“要添加什么域？”下，输入要验证的域，然后选择“添加域”
   - ![alt text](/assets/image/addDomain.png){:width="70%"}
-  按照“添加 DNS TXT 记录”下的说明，使用域托管服务创建 TXT 记录。
   - ![alt text](/assets/image/Txt.png){:width="70%"}
- 到自己域名下的 DNS 解析服务中添加 TXT
  -  ![alt text](/assets/image/dnsTxt.png){:width="70%"}
- 提示验证成功即可
  - ![alt text](/assets/image/domainVerified.png){:width="70%"}

### 设置正确可解析的 DNS

Ipv4 相关 DNS

```sh
185.199.108.153
185.199.109.153
185.199.110.153
185.199.111.153
```
Ipv6 相关 DNS

```sh
2606:50c0:8000::153
2606:50c0:8001::153
2606:50c0:8002::153
2606:50c0:8003::153
```

![alt text](/assets/image/ipv4-6.png){:width="70%"}