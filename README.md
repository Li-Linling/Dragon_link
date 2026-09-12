# Dragon Link

一个基于 AutoHotkey v2.0 的米哈游游戏自动化挂机脚本，支持《原神》《崩坏：星穹铁道》《绝区零》。

## ✨ 功能

- **鼠标侧键映射**：游戏内 XButton1 / XButton2 映射到键盘按键
- **一键自动化**：按 `F7` 呼出游戏选择界面，自动启动工具、点击、等待游戏、挂机监控
- **异常邮件通知**：运行过短或超时自动发送邮件报告（可选）
- **紧急停止**：按 `F8` 终止所有流程并清理进程
- **可选 Hosts 更新**：内置 GitHub Hosts 自动更新（默认关闭）

## 📋 环境要求

- Windows 10 / 11
- [AutoHotkey v2.0](https://www.autohotkey.com/)
- **必须以管理员身份运行**
- 第三方辅助工具（自行下载并配置路径）：
  - 绝区零：一条龙
  - 星穹铁道：March7th Assistant
  - 原神：BetterGI

## 🚀 使用前配置

脚本中所有路径、窗口标题、点击坐标都需要根据你的电脑修改。关键配置说明如下：

### toolPath — 工具路径

辅助工具的完整路径。

**获取方法**：打开任务管理器 → 找到目标工具进程 → 右键 → **打开文件所在位置**

### toolTitle — 工具窗口标题

辅助工具启动后的窗口标题。

**获取方法**：使用 AHK 自带的 Window Spy 工具（系统托盘 AHK 图标右键 → Window Spy），查看 “Window Title” 一栏。填核心部分即可，如 `BetterGI`。

### gameTitle — 游戏窗口特征

推荐格式：`ahk_exe 进程名.exe`

**获取方法**：Window Spy 中查看 “ahk_exe” 一栏。

### clickSequence — 屏幕坐标

格式：`C:x,y`

**获取方法**：Window Spy 中查看 “Screen” 坐标。

### 需要关闭的软件

脚本运行原神时会自动关闭 Snipaste。如果你电脑上还有其他会占用 F 键或截图快捷键的软件，也建议在脚本运行期间手动关闭，或在脚本中按同样格式添加。

## 🔨 如何编译

如果你想将 `.ahk` 编译成 `.exe`：

1. 安装 [AutoHotkey v2.0](https://www.autohotkey.com/)
2. 下载 [Ahk2Exe](https://github.com/AutoHotkey/Ahk2Exe) 或使用 AHK 安装包自带的编译器
3. 右键 `main.ahk` → **Compile Script (Ahk2Exe)**
4. 编译产物默认在脚本同目录

注意：杀毒软件可能会误报 AHK 编译的程序，这是常见现象。

## ⚠️ 免责声明

- 本脚本仅供个人学习与交流使用
- 使用第三方工具或修改 hosts 可能存在账号风险，请自行评估
- 请勿在脚本中填写真实密码或邮箱授权码

## 📄 开源协议

[MIT License](LICENSE)