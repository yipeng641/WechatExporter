<div align="center">
  <img src="assets/wemory-icon.png" width="112" alt="Wemory 图标">
  <h1>Wemory</h1>
  <p>本地读取、浏览、备份与导出微信数据的 Windows 桌面工具</p>
  <p>
    <a href="https://wemory.bytefuse.cn/">产品官网</a> ·
    <a href="https://wemory.bytefuse.cn">下载最新版</a> ·
  </p>
</div>

![Wemory 聊天数据浏览界面](assets/wemory-home.png)

## Wemory 能做什么

Wemory 面向希望在自己的电脑上整理微信资料的用户。应用在本机读取和处理微信数据，帮助你集中浏览并按需导出：

- 聊天记录：浏览私聊、群聊和企业会话，导出为 HTML 或 PDF。
- 朋友圈：按时间浏览朋友圈内容，导出为 HTML 或 PDF。
- 通讯录：查看联系人，并将联系人和群成员导出为 XLSX。
- 公众号：批量采集、整理并导出公众号文章。

## 本地优先

微信数据的读取、解密和导出均在本机完成，内容不会上传。联网仅用于应用更新及下载必要组件；导出文件由你自行选择保存位置。

## 聊天记录导出

Wemory 会将微信会话按好友、群聊和企业会话分类，支持搜索、类型筛选和批量选择。你可以在导出前直接浏览消息内容，并按日期范围导出指定会话。

![Wemory 群聊记录浏览界面](assets/wemory-chat-list.png)

聊天记录支持文本、图片、视频、语音、表情、附件和折叠消息等常见类型。图片使用原图导出，未下载的视频也会显示封面，便于离线查看和归档


## 公众号采集和导出

![Wemory 公众号采集任务界面](assets/wemory-official-account.png)

## 通讯录的导出

![Wemory 通讯录界面](assets/wemory-contacts.png)

## 下载与安装

1. 前往 [Releases](https://wemory.bytefuse.cn/) 下载 
2. 在 Windows 10 或 Windows 11 x64 上运行安装程序。
3. 启动 Wemory，按照界面提示连接本机微信数据目录。

当前安装包尚未使用 Windows 代码签名证书签名，因此系统可能显示 Microsoft Defender SmartScreen 提示。


## 更新记录

### 2026.8.13

1. 修复公众号采集数据不完整的问题。
2. 优化聊天消息中的部分图标。
3. 支持聊天消息中的附件类型。
4. 支持聊天消息中的表情符号。
5. 支持聊天消息中的视频类型。
6. 修复语音消息无法打开的问题。
7. 修复聊天图片未使用原图导出的问题。
8. 支持折叠消息类型的显示。
9. 修复未下载的视频不显示封面的问题。
10. 导出联系人时包含对应标签。

## 系统要求

- Windows 10 / 11 x64
- 已在本机登录并产生数据的 Windows 微信客户端

## 说明

本仓库用于发布 Wemory 产品介绍、截图和安装包，不包含应用源代码。Wemory 不是微信官方产品，与腾讯或微信不存在隶属或合作关系。请仅处理你有权访问的数据，并遵守当地法律法规及相关服务条款。

问题反馈请使用本仓库的 [Issues](https://github.com/ftyszyx/wemory-wechat-backup/issues)。
