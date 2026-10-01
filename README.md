# FlowGuard 流量管家（iPhone）

一个在 iPhone 上使用的「月度流量监控 + 额度提醒」App：设置每月套餐流量（如 120GB）和账期起始日，App 自动估算已用流量，在 50% / 80% / 90% / 100% 等节点给你发通知，并根据当前日均用量预测账期结束时会不会超量。

## 它能做什么 / 不能做什么

- 能：估算每月蜂窝流量已用量、计算剩余流量、阈值通知提醒、超量预测、手动校准。
- 不能：**无法自动断网**（苹果不向任何第三方 App 开放蜂窝数据开关），收到提醒后需要你在控制中心手动关闭；也无法直接读取运营商的实时套餐余量。

> 因此建议：除了本 App，再开通运营商免费的「流量阈值短信提醒」作为双保险；想真正自动断网，可联系运营商开通「达量限速 / 流量封顶」服务。

---

# 安装总览（全程免费，只需一台 Windows 电脑和 iPhone）

整个过程分三步：

1. **云端编译**：把源码上传到 GitHub，云端的 Mac 自动帮你编译出 App 安装包（.ipa）。
2. **安装 AltStore**：在 Windows 上安装 AltStore，它用你自己的 Apple ID 给 App 免费签名。
3. **侧载安装**：用 AltStore 把编译好的 .ipa 装进 iPhone。

预计耗时：首次约 30～40 分钟。装好后日常使用零成本。

---

# 第一步：云端编译（GitHub Actions）

## 1.1 注册 GitHub 账号

1. 打开 https://github.com/signup ，按提示用邮箱注册一个账号（免费）。
2. 注册后登录 GitHub。

## 1.2 安装 GitHub Desktop

1. 打开 https://desktop.github.com/ 下载并安装 GitHub Desktop。
2. 首次打开时用刚注册的 GitHub 账号登录（点 “Sign in to GitHub.com”，浏览器里授权即可）。

## 1.3 准备本地文件

1. 把交付给你的 `FlowGuard.zip` 解压，得到一个 **FlowGuard 文件夹**（里面能看到 `project.yml`、`FlowGuard`、`.github` 等内容）。
2. 建议把该文件夹放到一个固定位置，例如 `C:\Users\你的用户名\Documents\FlowGuard`。
3. 记住这个路径，后面要用。

## 1.4 把文件夹发布为 GitHub 仓库

1. 在 GitHub Desktop 左上角点 **File（文件）→ Add Local Repository（添加本地仓库）**。
2. 点 **Choose...（选择）**，选中第 1.3 步的 FlowGuard 文件夹，点 “Add Repository”。
3. 此时会提示 *This directory does not appear to be a Git Repository*，点击蓝色的 **create a repository** 链接。
4. 在弹出窗口中：
   - Name（名称）保持 `FlowGuard`；
   - Git Ignore 和 License 保持 None；
   - 点 **Create Repository**。
5. 接着点右上角的 **Publish repository（发布仓库）**：
   - **建议取消勾选 “Keep this code private（将代码设为私有）”**，即发布为公开仓库——公开仓库的云端编译完全免费且不限次数（代码只是这个小 App，不含任何隐私）。
   - 点 **Publish Repository**，等待上传完成。

## 1.5 等待云端编译

1. 上传完成后，用浏览器打开你的仓库页面：`https://github.com/你的用户名/FlowGuard`。
2. 点顶部的 **Actions（操作）** 标签，会看到一个名为 *Build FlowGuard IPA* 的任务正在运行（黄色圆点）。
3. 等待约 5～10 分钟，圆点变成 **绿色对勾** 即编译成功。
   - 如果是红色叉号，请看文末「常见问题」，或把该页面的报错截图发回来，我来帮你修。

## 1.6 下载编译好的 ipa

1. 在 Actions 页面点最上面那次构建记录（绿色对勾那条）。
2. 拉到页面最底部 **Artifacts（产物）** 区域，点击 **FlowGuard-unsigned-ipa** 下载（下载需要你已登录 GitHub）。
3. 下载到的是一个 zip 压缩包，解压后得到 **FlowGuard-unsigned.ipa**，这就是 App 安装包，先放着，第三步用。
4. 建议把这个 ipa 拖入 **iCloud Drive**（第二步会装 iCloud for Windows），方便手机上的“文件”App 直接找到它。

---

# 第二步：在 Windows 上安装 AltStore

## 2.1 安装 iTunes（必须是 Apple 官网版）

> AltStore 不兼容微软应用商店版的 iTunes，请务必安装 Apple 官网版本。

1. 用浏览器打开：https://www.apple.com/itunes/download/win64 ，下载并安装 iTunes（64 位）。
2. 打开 iTunes，用你的 **Apple ID 登录**（就是 iPhone 上用的那个 Apple ID）。
3. 菜单栏选 **账户 → 授权此电脑**。

## 2.2 安装 iCloud for Windows

1. 打开 https://support.apple.com/zh-cn/HT208443 ，按页面指引下载安装 iCloud for Windows。
2. 安装后用同一个 Apple ID 登录，勾选 **iCloud Drive（iCloud 云盘）** 并应用。这样 Windows 资源管理器里会出现 iCloud Drive 文件夹，第三步用来传 ipa。

## 2.3 让电脑通过 WiFi 识别 iPhone

1. 用数据线把 iPhone 连接到电脑，手机上弹出“是否信任此电脑”时点**信任**并输入锁屏密码。
2. 在 iTunes 左上角点手机图标进入设备页面。
3. 在“摘要”里勾选 **通过 Wi-Fi 与此 iPhone 同步**，点右下角“应用”。
4. 之后可以拔掉数据线，只要手机和电脑连同一个 WiFi 即可。

## 2.4 安装 AltServer

1. 打开 https://altstore.io/ ，点 **Download AltServer for Windows**，下载并安装。
2. 安装后运行 AltServer，它会常驻在屏幕右下角的**任务栏托盘区**（一个菱形小图标，可能需要点托盘的“∧”才能看到）。

## 2.5 把 AltStore 装到 iPhone

1. 建议先用数据线把手机连上电脑（首次安装用数据线最稳）。
2. 右键点托盘区的 **AltServer 图标 → Install AltStore（安装 AltStore）→ 选择你的 iPhone**。
3. 按提示输入 **Apple ID 邮箱和密码**。
   - 如果你的 Apple ID 开启了双重认证（基本都开了）而密码报错：去 https://appleid.apple.com 登录，进入 **登录和安全 → App 专用密码**，生成一个专用密码，把它填到 AltStore 的密码框（账号仍填你的 Apple ID 邮箱）。
   - 该账号密码只用于向苹果申请一个免费的本地开发证书，AltStore 是开源软件，不会保存或上传你的密码。
4. 等待几秒，手机桌面上会出现 **AltStore** 这个 App。

## 2.6 在手机上信任开发者证书

1. 打开 iPhone **设置 → 通用 → VPN与设备管理**。
2. 在“开发者 App”下点你的 **Apple ID**，再点**信任**。
3. 现在可以打开 AltStore 了。

---

# 第三步：用 AltStore 安装流量管家

1. 确保电脑上 **AltServer 正在运行**、手机与电脑在同一 WiFi（首次安装建议插着数据线）。
2. 确认第一步下载的 **FlowGuard-unsigned.ipa** 已放到手机“文件”App 能找到的位置（最简单：放入 iCloud Drive，手机“文件”→ iCloud 云盘里即可看到）。
3. 在手机上打开 **AltStore**，进入 **My Apps（我的 App）** 标签。
4. 点左上角的 **“+”**，在弹出的文件列表里选择 **FlowGuard-unsigned.ipa**。
5. AltStore 会调用电脑上的 AltServer 完成签名并自动安装，稍等片刻。
6. 安装完成后回到桌面，就能看到 **流量管家** App 了。首次打开时允许它发送通知。

---

# App 首次使用设置（重要）

1. 打开 App，进入底部 **设置** 标签：
   - **每月套餐流量**：填写你的套餐总量，例如 `120`（GB）。
   - **每月账期起始日**：选择运营商每月重新计流量的日期（可在运营商 App 或扣费短信里查到，常见为 1 日）。
   - **流量提醒阈值**：打开你需要的提醒（建议 80%、90%、100% 都开）。
   - 点 **请求通知权限**，允许通知。
2. 打开 iPhone **设置 → 通用 → 后台 App 刷新**：确认总开关打开，并允许“流量管家”后台刷新（否则 App 在后台无法及时采样和提醒）。
3. 由于 App 从安装时刻才开始计数，**强烈建议先做一次校准**：
   - 在运营商 App（中国移动 / 中国联通 / 中国电信）查到“本期已用流量”；
   - 在流量管家 设置 → **手动校准已用流量**，填入该数值。
   - 之后 App 会以这个真实值为基线继续估算。建议每月再校准 1～2 次。

## 收到 100% 提醒后怎么断网

从屏幕右上角下拉控制中心（带 Home 键的机型从底部上划）→ 长按左上角网络区域 → 点按绿色蜂窝数据图标使其变灰，即手动断网。

---

# 关于 7 天续签（务必了解）

- 免费 Apple ID 签名的 App，证书**有效期为 7 天**。到期后 App 会闪退或提示“不再可用”，这是苹果对免费账号的统一限制，不是 App 出问题。
- **自动续签**：当电脑上的 AltServer 开着、手机与电脑在同一 WiFi 时，AltStore 会在后台自动续签。
- **手动续签**：打开 AltStore → My Apps → 点 **Refresh All / 刷新**（需 AltServer 运行）。
- 建议每周在电脑旁时打开一次 AltStore 让它刷新；续签不会丢失 App 内的任何数据。
- iPhone 若重启过，也建议打开一次 AltStore 刷新。

> 若以后不想每周续签，可开通 688 元/年的 Apple 开发者账号并改用 TestFlight 安装，届时找我调整发布配置即可。

---

# 常见问题（FAQ）

**Q：Actions 构建失败（红色叉号）怎么办？**
A：点进失败的记录，再点 build 任务展开日志，看最前面的红色报错；常见原因是文件没传完整（`.github` 隐藏文件夹没上传）。把报错页面截图发我，我改好配置后你重新发布即可。

**Q：AltStore 提示找不到 AltServer？**
A：确认数据线连接正常、iTunes 能识别到手机、电脑和手机在同一网络；Windows 防火墙若弹窗请勾选“专用网络”并允许访问。

**Q：安装时提示 App ID / 签名次数限制？**
A：免费 Apple ID 最多同时侧载 3 个 App，且每天签名次数有限；删掉不用的侧载 App，或隔天再试。

**Q：App 里已用流量显示 0 或偏小？**
A：App 从安装时刻才开始统计，属于正常现象；按上面的步骤做一次“手动校准”即可。

**Q：收不到流量提醒通知？**
A：依次检查：① 设置里已允许通知；② 后台 App 刷新已打开；③ 手机未处于“低电量模式”（该模式会暂停后台刷新）；④ 把 App 打开一次让它采样。后台通知时机由 iOS 决定，长时间不打开 App 时提醒可能延迟到下次打开才发出。

**Q：以后想更新 App 怎么办？**
A：我给你新文件后，替换本地 FlowGuard 文件夹内容，GitHub Desktop 会自动识别改动，点 Commit → Push/Publish，Actions 会重新编译，下载新 ipa 后在 AltStore 里重新安装即可（数据会保留）。

---

# 免责声明

本 App 的流量数据基于系统网络接口计数器估算，仅供参考，**不作为计费依据**，最终流量与费用以运营商账单为准。App 为个人自用工具，通过免费开发者证书侧载安装，请遵守 Apple 相关使用条款。
