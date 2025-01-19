# bindhosts 工作模式
- 这些是目前已定义的工作模式，支持自动检测或手动切换
- 你可以通过访问 [开发者选项](https://github.com/bindhosts/bindhosts/issues/10#issue-2703531116) 切换工作模式。

#### 术语表
 - magic mount - 主要用于Magisk的挂载方式
 - susfs - [susfs4ksu](https://gitlab.com/simonpunk/susfs4ksu) 的缩写，一种修补内核的进阶隐藏Root框架

---

## mode=0
### 默认模式
 - **APatch** 
   - OverlayFS / magic mount
   - magic mount 兼容 Adaway，OverlayFS 不兼容 Adaway
   - 隐藏: 使用 [ZygiskNext](https://github.com/Dr-TSNG/ZygiskNext) 并开启遵循排除列表
 - **Magisk** 
   - magic mount  
   - 兼容 Adaway  
   - 隐藏: 排除列表 / [Shamiko](https://github.com/LSPosed/LSPosed.github.io/releases) / [Zygisk Assistant](https://github.com/snake-4/Zygisk-Assistant)  
 - **KernelSU** 
   - OverlayFS + path_umount, (magic mount? soon?)
   - 与 Adaway 不兼容  
   - 隐藏: umount 模块 (对于非GKI设备，请将path_umount backport到内核中)

---

## mode=1
### ksu_susfs_bind
- susfs assisted mount --bind
- 仅 KernelSU 可用  
- 需要被susfs修补过的内核以及对应的用户空间工具  
- 兼容 Adaway  
- 隐藏: **最佳，因为 SuSFS 处理卸载/取消挂载**

---

## mode=2
### plain bindhosts
- mount --bind
- **兼容性最好**
- 实际上在所有的管理器均能工作，但并未真正可用
- 会泄露bind mount, 泄露全局修改的 hosts 文件  
- 当 APatch 处于 OverlayFS (默认模式) 时选择，因为其提供更好的兼容性。
- 兼容 Adaway
- 隐藏: 基本上没有隐藏, 需要辅助手段

---

## mode=3
### apatch_hfr, hosts_file_redirect
- 内核中对 /system/etc/hosts 进行重定向 (uid 0)
- 仅 APatch 可用，需要 hosts_file_redirect KPM  
  - [hosts_file_redirect](https://github.com/AndroidPatch/kpm/blob/main/src/hosts_file_redirect/)  
  - [操作指引](https://github.com/bindhosts/bindhosts/issues/3)
- 似乎在所有设置下不起作用，需要碰运气
- 与 Adaway 不兼容  
- 隐藏: **对 APatch 而言最佳, 由于其压根没有挂载**

---

## mode=4
### zn_hostsredirect
- 通过 zygisk 注入 netd
- 作者 aviraxp **推荐** 使用 - ```"Injection is much better than mount in this usecase"(在这种情况下，注入比挂载要好得多)```
- 应该能在所有管理器上工作  
- 需要:  
  - [ZN-hostsredirect](https://github.com/aviraxp/ZN-hostsredirect)  
  - [ZygiskNext](https://github.com/Dr-TSNG/ZygiskNext)  
- 与 Adaway 不兼容  
- 隐藏: 不错的方法，因为其压根不进行挂载, 只是依赖于其他模块

---

## mode=5
### ksu_susfs_open_redirect
- 内核中对 /system/etc/hosts 进行重定向 (uid 低于2000)
- 仅 KernelSU 可用
- 仅能通过**手动切换**的方式启用  
- 需要被susfs修补过的内核以及对应的用户空间工具  
- 作者 simonpunk **不推荐** 使用 - ```"openredirect will take more CPU cycle as well.."(openredirect 也会消耗更多的CPU资源…)```
- 需要 SuSFS 1.5.1 及更高版本  
- 兼容 Adaway 
- 隐藏: 不错的方法，但可能会浪费更多CPU资源

---

## mode=6
### ksu_source_mod
- KernelSU try_umount 协助的 mount --bind
- 需要修改源: 参阅[此处](https://github.com/tiann/KernelSU/commit/2b2b0733d7c57324b742c017c302fc2c411fe0eb)  
- 支持 KernelSU NEXT 12183+，另请参阅[此处](https://github.com/rifsxd/KernelSU-Next/commit/9f30b48e559fb5ddfd088c933af147714841d673)
- **警告**: 与 SuSFS 冲突，如果你能使用 SuSFS 实现则不需要该模式
- 兼容 Adaway
- 隐藏: 不错的方法，但你可能只需要 susfs 实现。

---

## mode=7
### generic_overlay
- 通用的 overlayfs rw 挂载
- 应该能在所有管理器上工作 
- 仅能**手动切换** ，由于在检测中 **极其恼火地高** 的易感性
- 泄露 overlayfs 挂载 (和 /data/adb 上级目录), 泄露全局修改的 hosts 文件
- 可能不会在 APatch bind_mount / MKSU 上工作，若用户有原生 f2fs /data 字符折叠支持
- 兼容 Adaway
- 隐藏: 基本上没有隐藏, 需要辅助手段

---

## mode=8
### ksu_susfs_overlay
- susfs 协助的 overlayfs rw 挂载
- 仅 KernelSU 可用  
- 需要被susfs修补过的内核以及对应的用户空间工具  
- 可能不会在 APatch bind_mount / MKSU 上工作，若用户有原生 f2fs /data 字符折叠支持
- 兼容 Adaway
- 隐藏: 不错的办法，但是 ksu_susfs_bind 更简单

---

