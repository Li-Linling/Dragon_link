#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================================
;  Dragon Link - 米哈游游戏自动化挂机脚本
;  适用游戏：原神 / 崩坏：星穹铁道 / 绝区零
;  运行环境：AutoHotkey v2.0 + Windows 10/11
;  必须：以管理员身份运行
; ============================================================

; ============================================================
;  🔧 使用前必读
; ============================================================
;
;  本脚本需要配合第三方辅助工具使用（BetterGI / March7th Assistant / 一条龙）。
;
;  所有 toolPath（工具路径）、toolTitle（工具窗口标题）、
;  gameTitle（游戏窗口特征）、clickSequence（点击坐标），
;  都需要根据你自己电脑的实际情况修改。
;
;  👉 如何获取这些信息？请使用 AutoHotkey 自带的 Window Spy 工具。
;     获取方法：系统托盘 AHK 图标右键 → Window Spy
;
;  👉 toolPath 获取方法：
;     打开任务管理器 → 找到目标工具进程 → 右键 → 打开文件所在位置
;
;  ⚠️ 重要：脚本运行原神时会自动关闭 Snipaste。
;     如果你的电脑上还有其他会占用 F 键或截图快捷键的软件，
;     也建议在脚本运行期间手动关闭，避免冲突。
;
; ============================================================

; ============================================================
;  🧩 用户配置区（请根据自己电脑修改）
; ============================================================

; ---------- 邮件配置（可选，不需要邮件通知可以留空） ----------
smtpServer := "smtp.qq.com"
smtpPort := 465
senderEmail := "你的QQ邮箱@qq.com"          ; ← 改成你的QQ邮箱
senderPass := "你的QQ邮箱授权码"            ; ← 改成你的SMTP授权码，不是QQ密码
receiverEmail := "接收通知的邮箱@qq.com"     ; ← 改成接收通知的邮箱

; ---------- 需要关闭的软件（运行原神时自动关闭，结束后恢复） ----------
; Snipaste 会占用快捷键，导致脚本无法正常运行。
; 格式：进程名.exe
; 如有其他软件冲突，按同样格式添加即可。
snipastePath := "C:\Program Files\Snipaste\Snipaste.exe"  ; ← 改成你电脑上的实际路径

; ---------- 米哈游启动器根目录（用于自动提取游戏图标） ----------
launcherRootPath := "D:\miHoYo\miHoYo Launcher"  ; ← 改成你自己的米哈游启动器路径

; ---------- 全局阈值 ----------
minRuntimeSeconds := 120     ; 单游戏运行低于此秒数视为异常 → 汇总邮件
warnAfterHours    := 2       ; 单游戏运行超过此小时数 → 立刻发预警邮件（不打断）

; ---------- 游戏配置 ----------
; ⚠️ 以下所有内容都需要根据你自己电脑修改！
;
; toolPath      : 辅助工具的完整路径。
;                 获取方法：任务管理器 → 右键进程 → 打开文件所在位置
;
; toolTitle     : 辅助工具启动后的窗口标题。
;                 获取方法：Window Spy → 查看 “Window Title” 一栏。
;                 不需要填完整标题，填核心部分即可（如 “BetterGI”）。
;
; gameTitle     : 游戏窗口特征，推荐使用 “ahk_exe 进程名.exe” 格式。
;                 获取方法：Window Spy → 查看 “ahk_exe” 一栏。
;
; gameProcess   : 游戏进程名，用于强制结束游戏。
;
; clickSequence : 屏幕坐标点击序列，格式 “C:x,y”。
;                 获取方法：Window Spy → 查看 “Screen” 坐标。
;
games := [
    {
        name: "绝区零",
        iconFile: "nap_cn.ico",
        iconPath: "",
        toolPath: "D:\miHoYo\ZZZ\OneDragon-Launcher.exe",   ; ← 改成你的路径
        toolTitle: "绝区零 一条龙",                          ; ← 改成 Window Spy 获取的标题
        gameTitle: "ahk_exe ZenlessZoneZero.exe",           ; ← 改成 Window Spy 获取的进程名
        gameProcess: "ZenlessZoneZero.exe",
        clickSequence: ["C:2500,1550"],                     ; ← 改成你的屏幕坐标
        preClickWait: 10000,
        postClickWait: 5000,
        timeoutHours: 3
    },
    {
        name: "星铁",
        iconFile: "hkrpg_cn.ico",
        iconPath: "",
        toolPath: "D:\miHoYo\SR\March7th Launcher.exe",     ; ← 改成你的路径
        toolTitle: "March7th Assistant",                    ; ← 改成 Window Spy 获取的标题
        gameTitle: "ahk_exe StarRail.exe",                  ; ← 改成 Window Spy 获取的进程名
        gameProcess: "StarRail.exe",
        clickSequence: ["C:1415,1375"],                     ; ← 改成你的屏幕坐标
        preClickWait: 10000,
        postClickWait: 5000,
        timeoutHours: 3
    },
    {
        name: "原神",
        iconFile: "hk4e_cn.ico",
        iconPath: "",
        toolPath: "D:\miHoYo\GI\BetterGI.exe",              ; ← 改成你的路径
        toolTitle: "BetterGI",                               ; ← 改成 Window Spy 获取的标题
        gameTitle: "ahk_exe YuanShen.exe",                  ; ← 改成 Window Spy 获取的进程名
        gameProcess: "YuanShen.exe",
        clickSequence: ["C:1350,990", "C:1770,750"],        ; ← 改成你的屏幕坐标
        preClickWait: 10000,
        postClickWait: 5000,
        timeoutHours: 3
    }
]

; ---------- GitHub Hosts 自动更新（默认关闭，有风险，请自行决定是否开启） ----------
; 数据来源：
;   主源：HelloGitHub 提供的 hosts（https://raw.hellogithub.com/hosts）
;   备用：GitHub520 项目（https://github.com/521xueweihan/GitHub520）
; 说明：hosts 内容由第三方维护，本项目仅调用下载，不对其内容负责。
;       如不需要，可将 enableAutoUpdateHosts 设为 false。
hostsUrl := "https://raw.hellogithub.com/hosts"
hostsFilePath := A_WinDir . "\System32\drivers\etc\hosts"
hostsBackupPath := A_WinDir . "\System32\drivers\etc\hosts.bak"
hostsTempPath := A_Temp . "\hellogithub_hosts_new.txt"
hostsUpdateMinSize := 100
enableAutoUpdateHosts := false      ; ← 改为 true 可开启
autoUpdateOnStartup := false
autoUpdateIntervalHours := 24

; ============================================================
;  全局状态
; ============================================================
isRunning := false
cancelRequested := false
abortAll := false
userAborted := false
runReport := ""
hasAbnormal := false
snipasteWasRunning := false
hostsUpdateRunning := false
hostsLastUpdate := ""
pendingHostsUpdate := false
selectedFlags := ""
cardStates := []

; ============================================================
;  初始化
; ============================================================
CoordMode "Mouse", "Screen"
CoordMode "Pixel", "Screen"

if !A_IsAdmin {
    MsgBox("请以管理员身份运行此脚本，否则无法强制结束游戏进程。`n（右键脚本 → 以管理员身份运行）", "提示", "Icon! T5")
    ExitApp
}

if enableAutoUpdateHosts {
    if autoUpdateOnStartup
        SetTimer(AutoUpdateHostsTimer, -5000)
    if autoUpdateIntervalHours > 0
        SetTimer(AutoUpdateHostsTimer, autoUpdateIntervalHours * 60 * 60 * 1000)
}

F7::StartProcess()
F8::HandleF8()

; ============================================================
;  游戏内热键映射
; ============================================================
#HotIf WinActive("原神")
XButton1::Send "e"
XButton2::Send "t"

#HotIf WinActive("崩坏：星穹铁道")
XButton1::Send "e"
XButton2::Send "r"

#HotIf WinActive("绝区零")
XButton1::Send "e"
XButton2::Send "r"

#HotIf

; ============================================================
;  启动器 ico 目录定位
; ============================================================
FindLauncherIcoDir() {
    global launcherRootPath
    if !DirExist(launcherRootPath)
        return ""

    bestVersion := ""
    bestPath := ""

    Loop Files, launcherRootPath . "\*", "D" {
        versionName := A_LoopFileName
        if !RegExMatch(versionName, "^\d+(\.\d+)+$")
            continue
        icoDir := A_LoopFileFullPath . "\ico"
        if !DirExist(icoDir)
            continue
        if (bestVersion = "" || CompareVersion(versionName, bestVersion) > 0) {
            bestVersion := versionName
            bestPath := icoDir
        }
    }
    return bestPath
}

CompareVersion(v1, v2) {
    p1 := StrSplit(v1, ".")
    p2 := StrSplit(v2, ".")
    n := Max(p1.Length, p2.Length)
    Loop n {
        a := A_Index <= p1.Length ? Integer(p1[A_Index]) : 0
        b := A_Index <= p2.Length ? Integer(p2[A_Index]) : 0
        if (a > b)
            return 1
        if (a < b)
            return -1
    }
    return 0
}

ResolveIconPath(game) {
    if (game.HasProp("iconPath") && game.iconPath != "" && FileExist(game.iconPath))
        return game.iconPath
    if (game.HasProp("iconFile") && game.iconFile != "") {
        icoDir := FindLauncherIcoDir()
        if (icoDir != "") {
            candidate := icoDir . "\" . game.iconFile
            if FileExist(candidate)
                return candidate
        }
    }
    return ""
}

; ============================================================
;  图片预处理
; ============================================================
PrepareImage(srcPath, dstPath, w, h) {
    if FileExist(dstPath) {
        try {
            if FileGetTime(dstPath, "M") >= FileGetTime(srcPath, "M")
                return true
        }
    }
    pid := DllCall("GetCurrentProcessId")
    psFile := A_Temp . "\ahk_prep_" . pid . ".ps1"
    try FileDelete(psFile)

    psScript :=
    (
        "Add-Type -AssemblyName System.Drawing`r`n" .
        "`$icon = New-Object System.Drawing.Icon('" . srcPath . "', 256, 256)`r`n" .
        "`$srcBmp = `$icon.ToBitmap()`r`n" .
        "`$dst = New-Object System.Drawing.Bitmap(" . w . ", " . h . ")`r`n" .
        "`$g = [System.Drawing.Graphics]::FromImage(`$dst)`r`n" .
        "`$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic`r`n" .
        "`$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality`r`n" .
        "`$g.DrawImage(`$srcBmp, 0, 0, " . w . ", " . h . ")`r`n" .
        "`$dst.Save('" . dstPath . "', [System.Drawing.Imaging.ImageFormat]::Png)`r`n" .
        "`$g.Dispose(); `$dst.Dispose(); `$srcBmp.Dispose(); `$icon.Dispose()"
    )
    FileAppend(psScript, psFile, "UTF-8")
    exitCode := RunWait('powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' . psFile . '"', , "Hide")
    try FileDelete(psFile)
    return (exitCode = 0 && FileExist(dstPath))
}

; ============================================================
;  通用工具
; ============================================================
LogLine(text) {
    global runReport
    runReport .= text . "`n"
}

FormatTimeMS(ms) {
    totalSec := ms // 1000
    h := totalSec // 3600
    m := Mod(totalSec // 60, 60)
    s := Mod(totalSec, 60)
    return Format("{:02}:{:02}:{:02}", h, m, s)
}

ShowToolTip(text, durationMs) {
    MonitorGetWorkArea(, &left, &top, &right, &bottom)
    x := right - 500 - 20
    y := bottom - 100 - 20
    if (x < left)
        x := left + 10
    ToolTip(text, x, y)
    if durationMs > 0
        SetTimer(() => ToolTip(), -durationMs)
}

ShowReportGUI(reportText) {
    reportUI := Gui("+AlwaysOnTop -MinimizeBox", "自动化运行最终报告")
    reportUI.SetFont("s10", "Microsoft YaHei")
    reportUI.Add("Text", "w480 Center cBlue", "🎉 本轮自动化流程已彻底结束！")
    reportUI.Add("Edit", "w480 h260 ReadOnly Multi", reportText)
    btnClose := reportUI.Add("Button", "w120 x190 y+15 Default", "确认并关闭")
    btnClose.OnEvent("Click", (*) => reportUI.Destroy())
    reportUI.Show("AutoSize Center")
}

; ============================================================
;  需要关闭的软件控制
; ============================================================
CloseSnipaste() {
    global snipasteWasRunning
    snipasteWasRunning := false
    if ProcessExist("snipaste.exe") {
        snipasteWasRunning := true
        try RunWait("taskkill /f /im snipaste.exe /t", , "Hide")
        catch
            try ProcessClose("snipaste.exe")
        Sleep 500
        return true
    }
    return false
}

RestoreSnipaste() {
    global snipasteWasRunning, snipastePath
    if snipasteWasRunning {
        if !ProcessExist("snipaste.exe")
            try Run('"' . snipastePath . '"')
        snipasteWasRunning := false
    }
}

; ============================================================
;  游戏选择界面回调
; ============================================================
ToggleCardState(index, controls, *) {
    global cardStates
    cardStates[index] := !cardStates[index]
    if cardStates[index] {
        controls.barGreen.Visible := true
        controls.barGray.Visible := false
        controls.nameGreen.Visible := true
        controls.nameGray.Visible := false
    } else {
        controls.barGreen.Visible := false
        controls.barGray.Visible := true
        controls.nameGreen.Visible := false
        controls.nameGray.Visible := true
    }
}

OnSelectOK(selectGui, *) {
    global selectedFlags, cardStates
    flags := ""
    for state in cardStates
        flags .= state ? "1" : "0"
    selectedFlags := flags
    selectGui.Destroy()
}

OnSelectCancel(selectGui, *) {
    global selectedFlags
    selectedFlags := ""
    selectGui.Destroy()
}

; ============================================================
;  Hosts 更新逻辑
; ============================================================
HandleF8() {
    global isRunning
    if isRunning
        EmergencyCleanup()
    else
        UpdateHosts(true)
}

AutoUpdateHostsTimer() {
    global isRunning, pendingHostsUpdate
    if isRunning {
        pendingHostsUpdate := true
        return
    }
    UpdateHosts(false)
}

UpdateHosts(showResult := true) {
    global hostsUrl, hostsFilePath, hostsBackupPath, hostsTempPath, hostsUpdateMinSize
    global hostsUpdateRunning, hostsLastUpdate

    if hostsUpdateRunning
        return
    hostsUpdateRunning := true
    success := false
    message := ""

    try {
        if FileExist(hostsTempPath)
            FileDelete(hostsTempPath)

        curlPath := A_WinDir . "\System32\curl.exe"
        if !FileExist(curlPath)
            throw Error("未找到 curl.exe")

        opts := "--ssl-no-revoke -s --connect-timeout 15 --max-time 60 --retry 3 --retry-delay 2"
        curlCmd := '"' . curlPath . '" -L ' . opts . ' -o "' . hostsTempPath . '" "' . hostsUrl . '"'
        exitCode := RunWait(curlCmd, , "Hide")

        if (exitCode != 0) {
            mirrorUrl := "https://raw.githubusercontent.com/521xueweihan/GitHub520/main/hosts"
            curlCmd := '"' . curlPath . '" -L ' . opts . ' -o "' . hostsTempPath . '" "' . mirrorUrl . '"'
            exitCode := RunWait(curlCmd, , "Hide")
        }

        if (exitCode != 0)
            throw Error("curl 下载失败，退出码: " . exitCode)
        if !FileExist(hostsTempPath)
            throw Error("下载文件不存在")
        if FileGetSize(hostsTempPath) < hostsUpdateMinSize
            throw Error("下载文件过小，可能下载失败")
        if FileExist(hostsFilePath)
            FileCopy(hostsFilePath, hostsBackupPath, 1)
        else
            throw Error("系统 hosts 文件不存在")

        FileCopy(hostsTempPath, hostsFilePath, 1)
        try RunWait("ipconfig /flushdns", , "Hide")
        if FileExist(hostsTempPath)
            FileDelete(hostsTempPath)

        hostsLastUpdate := A_Now
        success := true
        message := "✅ GitHub Hosts 已更新"
    } catch as err {
        message := "❌ GitHub Hosts 更新失败: " . err.Message
    }

    hostsUpdateRunning := false

    if showResult {
        if success
            ShowToolTip(message . "`n备份: " . hostsBackupPath, 3000)
        else
            MsgBox(message, "Hosts 更新", "Icon! T5")
    } else {
        if !success
            ShowToolTip(message, 3000)
    }
}

; ============================================================
;  核心流程
; ============================================================
StartProcess() {
    global isRunning, cancelRequested, abortAll, userAborted, runReport, hasAbnormal
    global games, pendingHostsUpdate, selectedFlags, cardStates

    if isRunning {
        MsgBox("已有流程正在运行，请勿重复启动", "提示", "Icon! T3")
        return
    }

    ; ---------- 游戏选择界面 ----------
    selectedFlags := ""
    cardStates := []
    for game in games
        cardStates.Push(true)

    selectGui := Gui("+AlwaysOnTop -MinimizeBox", "选择执行游戏")
    selectGui.SetFont("s12 Bold", "Microsoft YaHei")
    selectGui.Add("Text", "w600 Center cBlue", "点击游戏卡片切换选中状态  ·  按回车开始执行")
    selectGui.SetFont("s10", "Microsoft YaHei")

    startX := 30, startY := 70, colWidth := 200, cardW := 180, cardH := 180

    for index, game in games {
        cardX := startX + (index - 1) * colWidth
        iconPath := ResolveIconPath(game)

        ok := false
        cachePath := A_Temp . "\AHK_Card_" . index . "_" . cardW . "x" . cardH . ".png"
        if (iconPath != "" && FileExist(iconPath))
            ok := PrepareImage(iconPath, cachePath, cardW, cardH)

        if ok
            cardPic := selectGui.Add("Picture", "x" . cardX . " y" . startY . " w" . cardW . " h" . cardH . " +0x100", cachePath)
        else
            cardPic := selectGui.Add("Text", "x" . cardX . " y" . startY . " w" . cardW . " h" . cardH . " +0x100 +0x200 Center Border", game.name)

        barGreen := selectGui.Add("Text", "x" . cardX . " y" . (startY + cardH + 10) . " w" . cardW . " h4 Background0x4CAF50", "")
        barGray := selectGui.Add("Text", "x" . cardX . " y" . (startY + cardH + 10) . " w" . cardW . " h4 Background0xC8C8C8", "")
        barGray.Visible := false

        selectGui.SetFont("s10 Bold", "Microsoft YaHei")
        nameGreen := selectGui.Add("Text", "x" . cardX . " y" . (startY + cardH + 20) . " w" . cardW . " Center cGreen", game.name)
        selectGui.SetFont("s10", "Microsoft YaHei")
        nameGray := selectGui.Add("Text", "x" . cardX . " y" . (startY + cardH + 20) . " w" . cardW . " Center cGray", game.name)
        nameGray.Visible := false

        controls := { barGreen: barGreen, barGray: barGray, nameGreen: nameGreen, nameGray: nameGray }
        cardPic.OnEvent("Click", ToggleCardState.Bind(index, controls))
    }

    totalWidth := startX * 2 + colWidth * (games.Length - 1) + cardW
    btnY := startY + cardH + 60
    btnW := 150, btnGap := 20
    btnTotalWidth := btnW * 2 + btnGap
    btnX := (totalWidth - btnTotalWidth) // 2

    btnOK := selectGui.Add("Button", "x" . btnX . " y" . btnY . " w" . btnW . " h38 Default", "开始执行（回车）")
    btnCancel := selectGui.Add("Button", "x" . (btnX + btnW + btnGap) . " y" . btnY . " w" . btnW . " h38", "取消（Esc）")
    btnOK.OnEvent("Click", OnSelectOK.Bind(selectGui))
    btnCancel.OnEvent("Click", OnSelectCancel.Bind(selectGui))
    selectGui.OnEvent("Escape", OnSelectCancel.Bind(selectGui))

    selectGui.Show("AutoSize Center")
    WinWaitClose("ahk_id " . selectGui.Hwnd)

    if selectedFlags = ""
        return

    ; ---------- 状态重置 ----------
    skipFlags := StrSplit(selectedFlags)
    isRunning := true
    cancelRequested := false
    abortAll := false
    userAborted := false
    hasAbnormal := false

    scriptStartTime := A_TickCount
    runReport := "====== 自动化运行日志 ======`n"
    runReport .= "开始时间: " . A_YYYY . "-" . A_MM . "-" . A_DD . " " . A_Hour . ":" . A_Min . ":" . A_Sec . "`n------------------------------`n"

    ; ---------- 主循环 ----------
    Loop games.Length {
        index := A_Index
        game := games[index]
        if skipFlags[index] = "1" {
            if !ProcessGame(game) || abortAll
                break
        } else {
            LogLine("⏭️ [" . game.name . "] 状态: 已跳过")
            ShowToolTip("跳过 " . game.name, 2000)
        }
        Sleep 2000
    }

    ; ---------- 汇总 ----------
    totalDuration := FormatTimeMS(A_TickCount - scriptStartTime)
    LogLine("------------------------------")
    if userAborted
        LogLine("🛑 流程状态: 用户主动中止")
    else if hasAbnormal
        LogLine("⚠️ 流程状态: 存在异常")
    else
        LogLine("✅ 流程状态: 正常结束")
    LogLine("⏱️ 脚本总运行时长: " . totalDuration)
    LogLine("==========================")

    isRunning := false
    ShowReportGUI(runReport)

    ; ---------- 汇总邮件 ----------
    if userAborted {
        ShowToolTip("用户主动中止，本次不发送邮件。", 3000)
    } else if hasAbnormal {
        SendEmailReport(runReport)
    } else {
        ShowToolTip("流程正常结束，无需发送邮件。", 3000)
    }

    ; ---------- 挂机期间 hosts 更新补发 ----------
    if pendingHostsUpdate {
        pendingHostsUpdate := false
        UpdateHosts(false)
    }
}

EmergencyCleanup() {
    global isRunning, cancelRequested, abortAll, userAborted
    if !isRunning
        return
    userAborted := true
    abortAll := true
    cancelRequested := true
    ShowToolTip("紧急停止，正在清理所有进程...", 3000)
    CleanupAllGames()
    isRunning := false
    RestoreSnipaste()
}

CleanupAllGames() {
    global games
    for game in games {
        try ProcessClose(game.gameProcess)
        if WinExist(game.toolTitle) {
            pid := WinGetPID(game.toolTitle)
            WinClose(game.toolTitle)
            Sleep 1000
            if pid
                try ProcessClose(pid)
        } else {
            toolExe := RegExReplace(game.toolPath, ".*\\")
            try
                ProcessClose(toolExe)
            catch
                try RunWait("taskkill /f /im " . toolExe, , "Hide")
        }
    }
}

; ============================================================
;  单个游戏流程
; ============================================================
ProcessGame(game) {
    global cancelRequested, abortAll, runReport, hasAbnormal
    global minRuntimeSeconds, warnAfterHours

    if game.name = "原神"
        CloseSnipaste()

    ; ---------- 1. 启动工具 ----------
    try {
        Run(game.toolPath)
    } catch as err {
        if game.name = "原神"
            RestoreSnipaste()
        LogLine("❌ [" . game.name . "] 致命错误 | 环节: 启动辅助工具 | 原因: " . err.Message)
        hasAbnormal := true
        return true
    }

    ; ---------- 2. 等待工具窗口 ----------
    toolHwnd := WaitWindow(game.toolTitle, 90)
    if !toolHwnd {
        if game.name = "原神"
            RestoreSnipaste()
        try ProcessClose(RegExReplace(game.toolPath, ".*\\"))
        LogLine("❌ [" . game.name . "] 异常结束 | 环节: 等待工具窗口 | 原因: 未找到窗口")
        hasAbnormal := true
        return true
    }

    ; ---------- 3. 点击前等待 ----------
    if game.HasProp("preClickWait") and game.preClickWait > 0 {
        ShowToolTip(game.name . " 工具已加载，等待 " . (game.preClickWait/1000) . " 秒后点击...", game.preClickWait)
        loop game.preClickWait // 1000 {
            if cancelRequested or abortAll {
                CleanupGame(game, toolHwnd)
                return false
            }
            Sleep 1000
        }
    }

    ; ---------- 4. 点击序列 ----------
    for action in game.clickSequence {
        if SubStr(action, 1, 2) = "C:" {
            coords := StrSplit(SubStr(action, 3), ",")
            if coords.Length = 2 {
                WinActivate(toolHwnd)
                WinWaitActive(toolHwnd, , 2)
                Click(Integer(coords[1]), Integer(coords[2]))
            }
        }
        Sleep 500
    }

    ; ---------- 5. 点击后等待 ----------
    if game.HasProp("postClickWait") and game.postClickWait > 0 {
        ShowToolTip(game.name . " 点击完成，等待 " . (game.postClickWait/1000) . " 秒加载...", game.postClickWait)
        loop game.postClickWait // 1000 {
            if cancelRequested or abortAll {
                CleanupGame(game, toolHwnd)
                return false
            }
            Sleep 1000
        }
    }

    ; ---------- 6. 等待游戏窗口 ----------
    ShowToolTip("等待 " . game.name . " 游戏窗口出现 (限时 10 秒)...", 0)
    gameHwnd := WaitWindow(game.gameTitle, 10)
    if !gameHwnd {
        if game.name = "原神"
            RestoreSnipaste()
        SafeCloseTool(toolHwnd, game.toolPath)
        LogLine("⚠️ [" . game.name . "] 异常结束 | 环节: 等待游戏窗口 | 原因: 10 秒内游戏未响应")
        hasAbnormal := true
        return true
    }

    ; ---------- 7. 挂机监控 ----------
    gameStartTime := A_TickCount
    warnMs := warnAfterHours * 60 * 60 * 1000
    timeoutMs := game.timeoutHours * 60 * 60 * 1000
    warnEmailSent := false
    timeoutNotified := false
    isMonday := (A_WDay = 2)   ; 1=周日, 2=周一, ..., 7=周六
    ShowToolTip("正在运行 " . game.name . "，监控中...", 0)

    while WinExist("ahk_id " . gameHwnd) {
        if cancelRequested or abortAll {
            CleanupGame(game, toolHwnd)
            return false
        }

        elapsed := A_TickCount - gameStartTime

        ; ---- 2 小时预警邮件（不打断） ----
        if (!warnEmailSent && elapsed > warnMs) {
            warnEmailSent := true
            LogLine("⏰ [" . game.name . "] 已运行超过 " . warnAfterHours . " 小时，发送预警邮件")
            SendWarningEmail(game.name, warnAfterHours)
            ShowToolTip(game.name . " 已运行超过 " . warnAfterHours . " 小时，已发提醒", 5000)
        }

        ; ---- 3 小时超时动作 ----
        if (elapsed > timeoutMs) {
            if isMonday {
                if !timeoutNotified {
                    timeoutNotified := true
                    LogLine("⚠️ [" . game.name . "] 已运行超过 " . game.timeoutHours . " 小时，今天周一继续挂机（不关闭）")
                    ShowToolTip(game.name . " 超 " . game.timeoutHours . " 小时，周一继续", 5000)
                }
            } else {
                hasAbnormal := true
                gameDurationStr := FormatTimeMS(elapsed)
                LogLine("❌ [" . game.name . "] 已运行超过 " . game.timeoutHours . " 小时，非周一强制关闭 | 已运行: " . gameDurationStr)
                ShowToolTip(game.name . " 超时，强制关闭", 3000)
                CleanupGame(game, toolHwnd)
                if game.name = "原神"
                    RestoreSnipaste()
                return true
            }
        }
        Sleep 1000
    }

    ; ---------- 8. 游戏自然结束，检查运行时长 ----------
    gameDurationMs := A_TickCount - gameStartTime
    gameDurationStr := FormatTimeMS(gameDurationMs)

    if (gameDurationMs < minRuntimeSeconds * 1000) {
        LogLine("❌ [" . game.name . "] 流程过短 | 仅运行 " . gameDurationStr . "（< " . minRuntimeSeconds . " 秒，疑似启动失败或崩溃）")
        hasAbnormal := true
    } else {
        LogLine("▶️ [" . game.name . "] 正常挂机完毕 | 耗时: " . gameDurationStr)
    }

    ; ---------- 9. 收尾 ----------
    loop 10 {
        if cancelRequested or abortAll {
            CleanupGame(game, toolHwnd)
            return false
        }
        ShowToolTip(game.name . " 游戏已关闭，等待 " . (10 - A_Index + 1) . " 秒后关闭工具...", 1000)
        Sleep 1000
    }

    ShowToolTip("正在关闭 " . game.name . " 工具...", 2000)
    SafeCloseTool(toolHwnd, game.toolPath)

    if game.name = "原神"
        RestoreSnipaste()

    return true
}

SafeCloseTool(toolHwnd, toolPath) {
    global cancelRequested, abortAll
    if cancelRequested or abortAll
        return
    toolExe := RegExReplace(toolPath, ".*\\")

    if WinExist("ahk_id " . toolHwnd) {
        WinClose(toolHwnd)
        loop 3 {
            if !WinExist("ahk_id " . toolHwnd)
                break
            Sleep 1000
        }
        if WinExist("ahk_id " . toolHwnd) {
            WinKill(toolHwnd)
            Sleep 500
        }
    }
    try ProcessClose(toolExe)
}

CleanupGame(game, toolHwnd) {
    try ProcessClose(game.gameProcess)
    SafeCloseTool(toolHwnd, game.toolPath)
    if game.name = "原神"
        RestoreSnipaste()
}

WaitWindow(title, timeoutSec) {
    global cancelRequested, abortAll
    endTime := A_TickCount + timeoutSec * 1000
    while A_TickCount < endTime {
        if cancelRequested or abortAll
            return 0
        hwnd := WinExist(title)
        if hwnd
            return hwnd
        Sleep 500
    }
    return 0
}

; ============================================================
;  邮件模块
; ============================================================
BuildCDO() {
    global smtpServer, smtpPort, senderEmail, senderPass, receiverEmail
    cdo := ComObject("CDO.Message")
    cdo.BodyPart.Charset := "utf-8"
    cdo.From := senderEmail
    cdo.To := receiverEmail

    schemas := "http://schemas.microsoft.com/cdo/configuration/"
    fields := cdo.Configuration.Fields
    fields.Item[schemas . "sendusing"] := 2
    fields.Item[schemas . "smtpserver"] := smtpServer
    fields.Item[schemas . "smtpserverport"] := smtpPort
    fields.Item[schemas . "smtpauthenticate"] := 1
    fields.Item[schemas . "sendusername"] := senderEmail
    fields.Item[schemas . "sendpassword"] := senderPass
    fields.Item[schemas . "smtpusessl"] := true
    fields.Update()
    return cdo
}

; 汇总异常报告
SendEmailReport(reportContent) {
    global senderPass

    if (senderPass = "YOUR_AUTH_CODE" || senderPass = "" || senderPass = "你的QQ邮箱授权码") {
        ShowToolTip("⚠️ 邮件模块未配置，跳过发送邮件。", 3000)
        return
    }

    ShowToolTip("正在通过 SMTP 推送报告至邮箱...", 0)
    try {
        cdo := BuildCDO()
        cdo.Subject := "【AutoHotkey】挂机流水线异常报告"
        cdo.TextBody := reportContent
        cdo.Send()
        ShowToolTip("✅ 邮件通知已成功推送！", 3000)
    } catch as err {
        ShowToolTip("❌ 邮件发送异常: " . err.Message, 5000)
    }
}

; 单游戏运行过长的预警提醒（不打断，不影响汇总）
SendWarningEmail(gameName, hours) {
    global senderPass

    if (senderPass = "YOUR_AUTH_CODE" || senderPass = "" || senderPass = "你的QQ邮箱授权码")
        return

    try {
        cdo := BuildCDO()
        cdo.Subject := "【AutoHotkey】挂机超时预警 - " . gameName
        cdo.TextBody := "游戏 [" . gameName . "] 已运行超过 " . hours . " 小时，请留意是否卡住。`n`n"
                      . "当前时间: " . A_YYYY . "-" . A_MM . "-" . A_DD . " " . A_Hour . ":" . A_Min . ":" . A_Sec . "`n"
                      . "周一：超 3 小时会继续挂机；其他日期：超 3 小时将强制关闭进入下一个流程。"
        cdo.Send()
    } catch as err {
        LogLine("⚠️ 预警邮件发送失败: " . err.Message)
    }
}
