<p align="center">
  <img src="assets/images/app_icon.png" width="112" alt="OronBox Lite">
</p>

<h1 align="center">OronBox Lite</h1>

<p align="center">OronBox 的鸿蒙单机离线精简版，去掉全部联网功能，只做本地设备管理</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-AGPL--3.0-blue" alt="License"></a>
  <a href="https://appgallery.huawei.com/"><img src="https://img.shields.io/badge/HarmonyOS-AppGallery-C00" alt="HarmonyOS AppGallery"></a>
  <a href="https://github.com/zxor-org/OronBox"><img src="https://img.shields.io/badge/upstream-OronBox-informational" alt="Upstream"></a>
</p>

## 快速入口

- **下载**：[华为应用市场](https://appgallery.huawei.com/) 搜索 `OronBox`
- [上游项目 OronBox](https://github.com/zxor-org/OronBox)
- [用户文档](https://oronbox.zxor.org/user)
- [问题反馈](https://github.com/diana9905454/OronBox-Lite/issues)

> 仓库名带 `Lite` 以区别于全功能版；**应用在华为应用市场内的上架名称仍为 `OronBox`**。

## OronBox Lite 是什么？

OronBox Lite 是 [OronBox](https://github.com/zxor-org/OronBox) 的**鸿蒙单机离线精简版**，仅面向 HarmonyOS，仅通过**华为应用市场**分发。保留连接、管理 VelaOS / ZeppOS 设备与安装本地资源的完整能力，移除全部需要联网或账号的功能。

## 与原版的区别

| 项目 | OronBox | OronBox Lite |
|------|---------|--------------|
| 定位 | 全功能，含社区与账号 | 鸿蒙单机离线设备管理 |
| 平台 | 6 个 | 仅 HarmonyOS |
| 分发 | 各平台自行构建 | 仅华为应用市场 |
| Dart 文件 | ~462 | 271 |
| 联网 / 账号 | ✅ | ❌ |

## 支持平台

| 平台 | 状态 | 说明 |
|------|------|------|
| HarmonyOS | ✅ 官方支持 | OH API 23+，通过华为应用市场分发 |
| Windows / Android / Linux / macOS / Web / iOS | ❌ 不支持 | Lite 只在鸿蒙端维护与分发 |

> 源码树保留了上游的 `windows/` 与 `android/` 工程目录，但 Lite **不为这两个平台提供构建、维护与分发**。

## 设备支持

### Xiaomi VelaOS

| 设备/系列 | 状态 |
|----------|------|
| Xiaomi Smart Band 8 Pro / 9 / 9 Pro / 10 / 10 Pro | ✅ 已支持 |
| Xiaomi Watch S1 Pro / S3系列 / S4系列 / S5 | ✅ 已支持 |
| REDMI Watch 4 / 5 / 5 eSIM / 6 | ✅ 已支持 |

### ZeppOS

| 设备/系列 | 状态 |
|----------|------|
| Amazfit ZeppOS 设备 | ✅ 已支持 |
| Xiaomi Smart Band 7 | ✅ 已支持 |

## 功能支持

| 功能 | 说明 |
|------|------|
| 连接 VelaOS 与 ZeppOS 设备 | 管理已配对设备及其连接状态 |
| 查看设备状态与资源概览 | 展示电量、存储空间、应用和表盘信息 |
| 安装表盘和应用资源 | 从本地文件安装到设备 |
| 设置设备应用布局 | 调整设备应用列表的展示方式 |
| 管理设备闹钟 | 支持新增、编辑和删除 |
| 本地固件安装 | 从本地固件包安装 |
| 同步音乐到设备 | 将 MP3 文件传输到设备音乐 |
| 同步并导出设备录音 | 从设备取回录音并保存 |
| 本地健康数据同步 | 运动健康数据仅留存本机 |
| 首次引导 OOBE | 引导与基础设置 |

## 移除的功能

| 分类 | 移除内容 |
|------|----------|
| 账号与社区 | 小米账号登录 / OAuth / 2FA、AstroBox 与米坛资源浏览、创作者中心、CLI 与调试服务器 |
| 联网能力 | 在线固件下载、天气同步、GNSS 星历同步、后台定时同步、应用内更新检查 |
| 扩展框架 | 插件系统 / WASM / JS 运行时 |

## 从源码构建

仅鸿蒙端，需 `flutter` 鸿蒙分支（`oh-3.41.9-release`）与 DevEco Studio。

```bash
flutter pub get

cd ohos
export DEVECO_SDK_HOME="<DevEco>/sdk"
export NODE_OPTIONS="--require=<repo>/ohpm_local/bin/fs_hook.js"
./hvigorw assembleHap -p product=default -p buildMode=release -p TARGET_PLATFORM=ohos-arm64 --no-daemon
```

> 本仓库**不含**发布签名材料（`.p12` / `.p7b` / `.cer`）。自行构建上架华为应用市场，请在 DevEco Studio 中配置自己的 AGC 签名。

## AI 开发声明

本项目使用了 AI Agent 工具模型DeepSeek4.1协助开发

## 鸣谢

OronBox Lite 的代码来自 OronBox，后者参考和使用了以下项目的部分代码：

| 项目 | 参考的内容 |
|------|----------------|
| [AstroBox-Public](https://github.com/AstralSightStudios/AstroBox-Public) | 界面结构、资源流程与交互设计 |
| [AstroBox-NG-Module-Core](https://github.com/AstralSightStudios/AstroBox-NG-Module-Core) | 小米设备协议、安装流程与传输行为 |
| [AstroBox-NG-Module-Bluetooth](https://github.com/AstralSightStudios/AstroBox-NG-Module-Bluetooth) | 蓝牙连接行为 |
| [AstroBox-NG-Module-Account](https://github.com/AstralSightStudios/AstroBox-NG-Module-Account) | 设备授权与 authkey 相关协议实现 |
| [Gadgetbridge](https://codeberg.org/Freeyourgadget/Gadgetbridge) | ZeppOS 与可穿戴设备协议研究 |
| [Kazumi](https://github.com/Predidit/Kazumi) | Material Design 组件与界面设计 |

## 许可证

采用 [GNU Affero General Public License v3.0](LICENSE)，是 [OronBox](https://github.com/zxor-org/OronBox) 的派生作品。详见 [NOTICE](NOTICE)。
