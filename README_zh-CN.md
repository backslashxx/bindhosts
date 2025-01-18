[English](https://github.com/bindhosts/bindhosts/blob/master/README.md) | **简体中文**

# bindhosts

适用于APatch、KernelSU 和 Magisk 的 Systemless hosts

完全无依赖，可自我更新。

## 特点

- 支持 WebUI 和 action 按钮 `action.sh`
- 可与 Adaway 共存
- 通过 Manager mount、bind mount 和 OverlayFS 实现的 Systemless hosts
- 所用重定向方法：ZN-hostsredirect、hosts_file_redirect、open_redirect

## 支持的 Root 管理器

- [APatch](https://github.com/bmax121/APatch) 
- [KernelSU](https://github.com/tiann/KernelSU)
- [Magisk](https://github.com/topjohnwu/Magisk)  <sup>([没有WebUI](https://github.com/topjohnwu/Magisk/issues/8609#event-15568590949)👀)</sup>

### 同时支持以下第三方模块管理器

- [KsuWebUI](https://github.com/5ec1cff/KsuWebUIStandalone)   <sup>🌐</sup>
- [MMRL](https://github.com/DerGoogler/MMRL)   <sup>▶ 🌐</sup>

## 另请参阅

- [使用手册](Documentation/usage_zh-CN.md)
- [隐藏指南](Documentation/hiding_zh-CN.md)
- [运行模式](Documentation/modes_zh-CN.md)

## 链接

- 点击 [此处](https://github.com/bindhosts/bindhosts/releases) 下载bindhosts
- 点击 [此处](Documentation/sources.md) 查看更多信息(开放源代码许可)
- 点击 [此处](Documentation/localize.md) 参与bindhosts的本地化引导

## 帮助与支持

如果遇到问题请在 [这里](https://github.com/bindhosts/bindhosts/issues) 提交你的 issues

我们始终欢迎你们来提交 [请求](https://github.com/bindhosts/bindhosts/pulls)
