<div align="center">

# SubConverter-Extended

**A Modern Evolution of subconverter**

[![Version](https://img.shields.io/badge/version-1.0.5-blue?style=for-the-badge&logo=github)](https://github.com/Aethersailor/SubConverter-Extended/releases)
[![Docker Pulls](https://img.shields.io/docker/pulls/aethersailor/subconverter-extended?style=for-the-badge&logo=docker)](https://hub.docker.com/r/aethersailor/subconverter-extended)
[![License](https://img.shields.io/badge/license-GPL--3.0-orange?style=for-the-badge)](LICENSE)
[![Mihomo](https://img.shields.io/badge/mihomo-integrated-brightgreen?style=for-the-badge&logo=go)](https://github.com/MetaCubeX/mihomo)

<h3>⚡ 现代化的订阅转换后端 | 完美兼容 Mihomo 内核 ⚡</h3>

<p align="center">
  <a href="#-项目简介">项目简介</a> •
  <a href="#-设计理念">设计理念</a> •
  <a href="#-核心特性">核心特性</a> •
  <a href="#-快速开始">快速开始</a> •
  <a href="#-使用文档">使用文档</a> •
  <a href="#-docker-部署">Docker 部署</a>
</p>

</div>

---

## 📖 项目简介

> [!NOTE]
> **SubConverter-Extended** 是基于 [subconverter v0.9.9](https://github.com/asdlokj1qpi233/subconverter) 深度二次开发的订阅转换后端增强版本。

它专为协同 [Mihomo](https://github.com/MetaCubeX/mihomo) 内核优化，提供更现代、更强大的订阅转换服务。

**核心定位转变**：
SubConverter-Extended 不再充当客户端和机场之间的"中转站"，而是成为独立的**"配置融合器"**——只对客户端服务，不连接机场订阅服务器。同时基于 Mihomo 内核源码，在编译时自动跟进协议支持。

---

## 💡 立项原因

<details open>
<summary><strong>点击收起/展开详细背景</strong></summary>

### 遇到的问题

在长期使用 subconverter 的过程中，我遇到了几个不如人意的痛点：

#### 1. 协议支持滞后 🐢

subconverter 对新节点格式的支持完全取决于维护者的积极性。许多新兴协议（如 `hysteria2`、`tuic`、`anytls` 等）往往在相当长的时间内无法得到支持，而一些老协议至今也未能做到完美的转换。

#### 2. 机场屏蔽问题 🚫

由于 subconverter 需要连接机场订阅服务器拉取节点，而部分机场出于安全考虑：

* 屏蔽海外 IP 访问
* 直接屏蔽 subconverter 的 User-Agent
* 限制非客户端的订阅请求

这导致许多用户根本无法正常使用订阅转换服务。

#### 3. 新手友好度不足 🤯

由于上述问题，subconverter 逐渐被一些开发者和 UP 主视为"过时产物"，开始推崇使用 YAML 文件手动管理配置。

对于 **Custom_OpenClash_Rules** 项目而言，由于公共后端使用了旧版 subconverter，导致许多用户的体验不佳，让没有基本排障能力的小白碰上了自己根本无法处理的问题。

<br>

**💥 也就是在这时，我试图改进现状……**

> 可惜不能如愿，因为我最常使用的 subconverter 分支仓库，我无法提交 PR、无法发起 Issue，甚至连 Star 都不行——可能是被维护者屏蔽了。😞
>
> **只好自己动手了……**

</details>

### ❤️ 我们的坚持

正如 [Custom_OpenClash_Rules](https://github.com/Aethersailor/Custom_OpenClash_Rules) 项目所坚持的：

> [!IMPORTANT]
> **最适合新手以及最具普适性的操作流程，永远是基于 UI 界面的操作流程。**
>
> 用户应当拿着订阅链接，点几下鼠标就能根据自己的实际情况配置出最佳效果，并自动享受完善的分流规则更新，而不是繁琐的"上传文件"、"手动修改参数"，甚至还得到处问问题。

### 🎯 我们的解决方案

**SubConverter-Extended 因此诞生**。致力于让转换工具更匹配现代 Clash 内核的使用场景，**服务于所有保留“订阅转换”接口的 Clash 客户端**。

---

## ✨ 核心特性

### 🚀 相对原版的重大改进

| 功能 | 原版 Subconverter | SubConverter-Extended |
| :--- | :--- | :--- |
| **协议支持** | 🛠️ 人工维护解析器 | 🤖 **集成 Mihomo 内核**，自动支持所有新协议 |
| **订阅链接处理** | 📥 下载并解析节点 | 🔗 生成 `proxy-provider`，由 **用户的 Mihomo 内核直接拉取** |
| **节点链接处理** | ⚠️ 有限的协议支持 | ✅ **Mihomo 解析器 100% 兼容** |
| **配置文件大小** | 📦 展开所有规则和节点 (MB级) | ⚡ **使用 provider 模式**，配置精简 (KB级) |
| **新协议支持** | ⏳ 人工添加维护 | 🔄 **编译时自动扫描** Mihomo 源码添加 |
| **全局参数透传** | 📝 人工维护参数列表 | 🔍 **编译时自动识别** 可覆写参数 |

### 🔥 独特功能

#### 1. Proxy-Provider 模式 🛡️

**使用 Mihomo 的 Proxy-Provider 机制**

订阅链接**不再下载解析**，而是生成客户端可直接使用的配置，交由用户客户端的 Mihomo 内核自行拉取订阅：

```yaml
proxy-providers:
  provider_1:
    type: http
    url: https://your-subscription-url  # <-- 客户端直接连接机场
    interval: 3600
    path: ./providers/provider_1.yaml
    health-check:
      enable: true
      interval: 600
      url: http://www.gstatic.com/generate_204
```

> [!TIP]
> **优势**：
>
> * ✅ 不再干涉用户节点，交由内核原生处理
> * ✅ 订阅更新由客户端控制，无需重新转换
> * ✅ 避免机场屏蔽转换服务器的问题

#### 2. Mihomo 内核模块集成 🧩

直接使用 Mihomo Go 库解析节点链接，确保：

* ✅ 支持 Mihomo 的所有协议（包括 `hysteria2`, `tuic`, `anytls` 等）
* ✅ 参数完全兼容，无需手动适配
* ✅ 新协议零延迟支持（编译时跟随 Mihomo 更新）

#### 3. 兼容性保证 🤝

* ✅ **无缝切换**：完全兼容旧版 subconverter 的 API 接口，确保客户端用户零学习成本，无缝切换。
* ✅ **模板兼容**：继续沿用旧版的订阅转换外部模板，无需修改任何内容，由后端内置逻辑确保 `proxy-provider` 模式在分流规则中正确生成。

#### 4. 新手友好 👶

* ✅ 使用 **[Custom_OpenClash_Rules](https://github.com/Aethersailor/Custom_OpenClash_Rules)** 远程配置模板替代默认模板
* ✅ 锁死 API 模式，避免新手误配置降低安全性
* ✅ 简化参数，专注核心功能

---

## 🚀 快速开始

### 🌍 使用公共后端 (无需部署)

如果你不想折腾服务器，可以直接使用我们提供的公共后端：

> [!TIP]
> **公共后端地址**：`https://api.asailor.org`

你可以在任何支持自定义后端的订阅转换网站或客户端中填入此地址即可使用。

### 🐳 自行部署 (Docker)

如果你拥有自己的服务器，推荐使用 Docker 进行部署。

> [!NOTE]
> *由于开发者业余时间有限，以下部署指南部分内容由 AI 生成，仅供参考。*

#### 1. 一键启动

```bash
docker run -d \
  --name subconverter \
  -p 25500:25500 \
  --restart unless-stopped \
  aethersailor/subconverter-extended:latest
```

访问 `http://localhost:25500/version` 验证部署。

#### 2. 自定义配置启动

```bash
# 1. 创建配置目录
mkdir -p ~/subconverter/base

# 2. 下载配置文件模板（可选）
wget -O ~/subconverter/base/pref.toml \
  https://raw.githubusercontent.com/Aethersailor/SubConverter-Extended/master/base/pref.example.toml

# 3. 启动容器并挂载配置
docker run -d \
  --name subconverter \
  -p 25500:25500 \
  -v ~/subconverter/base:/base \
  --restart unless-stopped \
  aethersailor/subconverter-extended:latest
```

---

## 📚 使用文档

使用方式与原版 subconverter 完全相同。

### 基础转换

将机场订阅转换为 Clash 配置：

```bash
curl "http://localhost:25500/sub?target=clash&url=https://your-sub-url"
```

### 🌟 推荐配置

配合 **Custom_OpenClash_Rules** 项目使用：

```bash
curl "http://localhost:25500/sub?target=clash&url=YOUR_SUB&config=https://raw.githubusercontent.com/Aethersailor/Custom_OpenClash_Rules/main/cfg/Custom_Clash.ini"
```

### 常用参数一览

| 参数 | 说明 | 示例 |
| :--- | :--- | :--- |
| `target` | 目标格式 | `clash`, `surge`, `quanx` |
| `url` | 订阅链接或节点链接（`\|` 分隔） | `https://sub.com\|vless://...` |
| `config` | 外部配置文件 | `https://config-url` |
| `include` | 包含节点（正则） | `香港\|台湾` |
| `exclude` | 排除节点（正则） | `过期\|剩余` |
| `emoji` | 添加 Emoji | `true`/`false` |

---

## 🛠️ 配置说明

### 主配置文件

支持三种格式：`pref.toml`（推荐）、`pref.yml`、`pref.ini`。

```toml
[common]
api_mode = true                    # API 模式（强制开启）
default_url = []                   # 默认订阅（已禁用，必须传 url 参数）
enable_insert = true               # 启用节点插入

[node_pref]
udp_flag = false                   # UDP 支持
tfo_flag = false                   # TCP Fast Open
skip_cert_verify_flag = false      # 跳过证书验证

[managed_config]
managed_config_prefix = "http://localhost:25500"  # 托管配置前缀
```

---

## 🔍 Docker Hub 镜像标签

| 标签 | 用途 | 更新频率 |
| :--- | :--- | :--- |
| `latest` | 🟢 **稳定版本**（master 分支） | 有 release 时更新 |
| `dev` | 🟡 **开发版本**（dev 分支） | 每次 dev 分支推送 |

---

## 🤝 致谢

本项目使用或引用了以下开源项目，在此表示感谢：

* [Mihomo](https://github.com/MetaCubeX/mihomo) - Clash 内核，提供节点解析能力
* [Custom_OpenClash_Rules](https://github.com/Aethersailor/Custom_OpenClash_Rules) - OpenClash 规则集项目
* [subconverter](https://github.com/asdlokj1qpi233/subconverter) - 原版项目

---

## 📄 开源协议

本项目基于 [GPL-3.0](LICENSE) 协议开源。

> 内置的 Mihomo 解析器模块遵循 [MIT](https://github.com/MetaCubeX/mihomo/blob/Meta/LICENSE) 协议。

---

<div align="center">

**如果这个项目对你有帮助，请给个 ⭐ Star 支持一下！**

Made with ❤️ by [Aethersailor](https://github.com/Aethersailor)

</div>
