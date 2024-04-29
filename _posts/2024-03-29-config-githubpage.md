---
layout: post
title: "配置GitHubPage"
date: 2024-03-29
tags: jekyll DNS配置 工具
category: 
---

## 环境配置 [jekyll](https://jekyllrb.com/)
![](https://jekyllcn.com/img/logo-2x.png)


### 安装 [Homebrew](https://brew.sh/zh-cn/) 

安装 HomeBrew

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

提示成功后 ⚠️ 注意 iterm2 ｜ 终端 提示文案 执行下面两行
```
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/youMacName/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### rvm & ruby 安装
安装 rvm
```
 \curl -sSL https://get.rvm.io | bash -s stable
```
执行 `rvm -v` 查看是否按转过成功

使用 `rvm list` ｜ `rvm list known` 查看本地 或者远端有哪些 `ruby` 版本
```ruby
 * ruby-3.0.0 [ arm64 ]

# => - current
# =* - current && default
#  * - default
```

```ruby
# MRI Rubies
[ruby-]1.8.6[-p420]
[ruby-]1.8.7[-head] # security released on head
[ruby-]1.9.1[-p431]
[ruby-]1.9.2[-p330]
[ruby-]1.9.3[-p551]
[ruby-]2.0.0[-p648]
[ruby-]2.1[.10]
[ruby-]2.2[.10]
[ruby-]2.3[.8]
[ruby-]2.4[.10]
[ruby-]2.5[.8]
[ruby-]2.6[.6]
[ruby-]2.7[.2]
[ruby-]3[.0.0]
ruby-head
```
以 `ruby-3.0.0` 为例：`rvm install 3.0.0`。如果本地存在多分 可以使用 `rvm use 3.0.0` 来使用 `3.0` 版本

### jekyll & jekyll-theme-chirpy





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