# 隐藏指南

## APatch
 由于以下原因，在APatch隐藏是一件颇有挑战性的事情:
  1. 其使用 OverlayFS 但缺少自己内置的取消挂载的方法
  2. bind mount 并未被广泛应用

 建议: 
   - 迁移到 bind mount 并使用 [ZygiskNext](https://github.com/Dr-TSNG/ZygiskNext) 的遵守排除列表
   - 使用 hosts_file_redirect kpm
      - [使用教程](https://github.com/bindhosts/bindhosts/issues/3)
      - [点击下载](https://github.com/AndroidPatch/kpm/releases)
   - 若 hosts_file_redirect 失败, 请安装 [ZN-hostsredirect](https://github.com/aviraxp/ZN-hostsredirect/releases)

## KernelSU
 在 KernelSU 上隐藏应该能正常工作, 只要:
  1. 你的内核有 path_umount (GKI, backported)
  2. 不存在冲突模块 (即 Magical Overlayfs)

 建议:
  - 若为非gki内核且内核不包含 path_umount，请咨询内核开发者 [backport 该功能特性](https://github.com/tiann/KernelSU/pull/1464)
  - 若你坚持使用 Magical OverlayFS, [请使用该fork](https://github.com/backslashxx/magic_overlayfs), 该fork遵循 skip_mount
  - 还有一个替代方案, 只需安装 [ZN-hostsredirect](https://github.com/aviraxp/ZN-hostsredirect/releases)

## Magisk
 在 Magisk (和其分支) 应该也能正常工作。
 - 添加想要隐藏root的app至排除列表内。
 - (可选) 你也可以安装 [Shamiko](https://github.com/LSPosed/LSPosed.github.io/releases/)

# FAQ
 - 为什么需要隐藏root?
   - 一些root检测手段会检测hosts文件是否被修改。
 - 我该如何检查该检测点?
   - 阅读 [如何检查检测点](https://github.com/bindhosts/bindhosts/issues/4)
 - 我该如何迁移 APatch 至 bind mount?
   - [在此处](https://github.com/bmax121/APatch/actions) 下载自动构建版本

## 术语表
 - bind mount - magic mount 在 APatch 中的术语，挂载办法主要源自 Magisk。
