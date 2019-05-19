# GerritJarvis

GerritJarvis 是一个由 Swift 语言（5.0）编写的 Mac App，主要用于 [Gerrit Code Review](https://www.gerritcodereview.com/) 的事件通知。

## 痛点

在使用 Gerrit 进行 Code Review 时，经常会出现不及时看 Review，不知道有人 Vote/Comment 以及回复了 Comment，不知道自己的 Commit 已经 Conflict，需要自己不断地手动打开 Gerrit，查看状态。

为了解决这种低效率的情况，需要有一个在相关事件发生变化时能够主动通知的机制，GerritJarvis 为了解决这个问题而生。为什么叫 Jarvis 呢？名字源于 Iron Man 中 Tony Stark 的人工智能助理 Jarvis，希望这个 App 能像 Jarvis 一样，能够帮使用者处理好使用 Gerrit 进行 Code Review 过程中的各种事件。

## 特点

- 能够主动通知新 Review/Score/Comment、Merge Conflict、Commit Merged 等多种事件
- 轻量级页面，在状态栏显示图标和新消息个数，点击后弹出列表页，访问方便
- 支持配置一些通知策略，支持一键清除红点
- UI 重新设计，参考 IM 风格，使用更现代的排版和图标

## 安装与使用

### 安装

解压 zip 包，将 GerritJarvis.app 拷贝到系统 Applications 目录，右键点击 GerritJarvis.app，选择打开（不要使用双击打开），会弹框询问是否信任，点击信任即可。打开后会在状态栏看到 GerritJarvis 的图标。

### 使用

使用 GerritJarvis 时需要配置对应的 Gerrit 账号和密码。**请注意密码不是 Gerrit 的登录密码，而是 HTTP 密码，需要专门生成！**，具体方式为打开 Gerrit 网页，点击头像，到 Setting -> HTTP Pasword，如果没有 HTTP Password，点击 Generate Password 生成密码，如果已经有了，拷贝此密码即可。

如果 GerritJarvis 还未设置账号密码，列表页中会出现 Go To Preferences 的按钮，点击按钮到 Preference，选择 Account 的 Tab，将 Gerrit 的用户名和 HTTP Password 填到输入框中，点击 Save 进行保存。

关于 Review 列表：

* Review 列表按照更新时间从新到旧进行排序，自己提交的 Outgoing Review 在顶部，默认不显示自己给自己 -2 的 Review（还没准备好给别人看），可以在设置中勾选“显示自己提的 Review 中被自己 -2 的 Review”进行配置
* 点击 Cell 跳转到 Review 对应的网页，右上角显示 Score（-2、-1、0、+1、+2）的情况
* 红点的显示逻辑是：
  * 对于我提的 Review，最新的消息不是由我操作或者出现了 Merge Conflict 时显示红点
  * 对于别人提的 Review，最新的消息不是由我操作时显示红点（不管是有新的 Patch 还是 Comments，都会显示红点）
* 只有我提的 Review 才会显示新 Comments 的数量
* Review 列表使用定时刷新的方式，列表刷新频率支持 1，3，5，10，30 分钟

关于通知：

* 默认只通知我提的 Review 的事件，包括：
  * 某个 Reviewer 进行了评论和打分
  * Merge Conflict（可以在设置中关掉）
  * Merged
* 如果想知道别人给我提的 Review 的事件，需要在设置中进行配置：
  * 勾选“通知新的 Incoming Review”，当别人给我提 Reivew 且我还没看过时（Review 的消息中最新的消息不是由我操作的）会收到通知

## TODO

- [ ] Merge Trigger，合并时可以触发指定的 Bash/Python 脚本
- [ ] 显示 Waiting Time，超过等待阈值后进行通知
- [ ] 支持黑名单/白名单
- [ ] 支持 Scheme，可以通过 Alfred 快速跳转到某个 Review

## 👨🏻‍💻 作者

Joe Shang, shangchuanren@gmail.com

## 👮🏻 许可证

GerritJarvis 使用 MIT License，更多请查看 LICENSE 文件。

### 图片版权说明

GerritJarvis 主要使用了两套图片：

* 用户头像的 47 张图片来自于 [flaticon](https://www.flaticon.com/)，由 [freepik](https://www.freepik.com/) 制作 [Animal Pack](https://www.flaticon.com/packs/animals-3)
* 其他非用户头像的图片，像设置、刷新等来自于 [iconfont](https://www.iconfont.cn) 的 [Ant Design 官方图标库](https://www.iconfont.cn/collections/detail?spm=a313x.7781069.1998910419.d9df05512&cid=9402)

