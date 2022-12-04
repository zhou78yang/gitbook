# 邮件

## yagmail -- Yet Another GMAIL/SMTP client
yagmail是一个简单易用的SMTP客户端

文档: https://github.com/kootenpv/yagmail

异步版本 aioyagmail: https://github.com/kootenpv/aioyagmail

### 使用
```python
import yagmail
# 保存用户信息，需要额外安装keyring包
yagmail.register('your_name@example.com', '<your_password>')

# 客户端对象，host默认为smtp.gmail.com
yag = yagmail.SMTP('your_name@example.com', host='smtp.example.com')

# 发送邮件
yag.send('to@example.com', 'title', 'body')

# 发送附件1
yag.send(to=recipients,
         subject=email_subject,
         contents=contents,
         attachments=['path/to/attachment1.png', 'path/to/attachment2.pdf', 'path/to/attachment3.zip']
)

# 发送附件2
with open('path/to/attachment', 'rb') as f:
    yag.send(to=recipients,
             subject=email_subject,
             contents=contents,
             attachments=f
             )
```


## stmplib
smtplib是标准库提供的一个`SMTP`客户端，可以借此实现用SMTP协议发送邮件。

文档： https://docs.python.org/zh-cn/3/library/smtplib.html


## poplib
poplib是标准库提供的一个`POP3`客户端，用于接收POP3协议邮件。

文档： https://docs.python.org/zh-cn/3/library/poplib.html


## 其他类库
* `imaplib`: IMAP4协议客户端 [链接](https://docs.python.org/zh-cn/3/library/imaplib.html)
* `nntplib`: NNTP协议客户端 [链接](https://docs.python.org/zh-cn/3/library/nntplib.html)
* `mailbox`: 含对`email.Message`操作的封装 [链接](https://docs.python.org/zh-cn/3/library/mailbox.html)
* `smtpd`: STMP服务器 [链接](https://docs.python.org/zh-cn/3/library/smtpd.html)
