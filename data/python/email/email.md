# email

文档: [链接](https://docs.python.org/zh-cn/3/library/email.html)

<b>电子邮件的基本概念：</b>
* MUA: Mail User Agent——邮件用户代理
* MTA: Mail Transfer Agent——邮件传输代理
* MDA: Mail Delivery Agent——邮件投递代理

<b>传输过程</b>
> 发件人->MUA->MTA->若干个MTA->MDA<-MUA<-收件人

由此可知，要编写程序来发送和接受邮件，本质上就是：
* 编写MUA邮件发送到MTA
* 编写MUA从MDA上收邮件

<b>发邮件时:</b> MUA和MTA使用的协议就是SMTP：Simple Mail Transfer Protocol，后面的MTA到另一个MTA也是用SMTP协议。		
<b>收邮件时:</b> MUA和MDA使用的协议有两种：POP：Post Office Protocol，目前版本是3，俗称POP3；IMAP：Internet Message Access Protocol，目前版本是4，优点是不但能取邮件，还可以直接操作MDA上存储的邮件，比如从收件箱移到垃圾箱，等等。    	

构造一个邮件对象就是一个Message对象，如果构造一个MIMEText对象，就表示一个文本邮件对象，如果构造一个MIMEImage对象，就表示一个作为附件的图片，要把多个对象组合起来，就用MIMEMultipart对象，而MIMEBase可以表示任何对象。它们的继承关系如下：
```
Message
+- MIMEBase
   +- MIMEMultipart
   +- MIMENonMultipart
      +- MIMEMessage
      +- MIMEText
      +- MIMEImage
```

## 发送邮件
```python
from email.mime.text import MIMEText
from email.header import Header
from email.utils import parseaddr, formataddr
from email.mime.base import MIMEBase
from email.mime.multipart import MIMEMultipart
from email import encoders

import smtplib

def _format_addr(s):
    # 格式化用户地址
    name, addr = parseaddr(s)
    return formataddr((Header(name, 'utf-8').encode(), addr))

def send(from_addr, password, to_addr, smtp_server):
    msg = MIMEMultipart()
    # alternative表示若无法查看html格式可降级为plain格式
    # msg = MIMEMultipart('alternative')  
    msg['From'] = _format_addr('发送者XXX <%s>' % from_addr)
    msg['To'] = _format_addr('接收者XXX <%s>' % to_addr)
    msg['Subject'] = Header('测试信件', 'utf-8').encode()

    # plain = MIMEText('this is a test', 'plain', 'utf-8')
    # msg.attach(plain)
    html = MIMEText('<html><body><h1>Hello</h1><p color="red">this is a test</p><img src="cid:0" /></body></html>', 'html', 'utf-8')
    msg.attach(html)

    # 添加附件就是加上一个MIMEBase，从本地读取文件
    with open('test.jpg', 'rb') as f:
        mime = MIMEBase('image', 'jpg', filename='test.jpg')
        # 必要的头信息
        mime.add_header('Content-Disposition', 'attachment', filename='test.jpg')
        mime.add_header('Content-ID', '<0>')
        mime.add_header('X-Attachment-ID', '0')
        # 读取附件内容
        mime.set_payload(f.read())
        # 使用Base64编码
        encoders.encode_base64(mime)
        msg.attach(mime)

    server = smtplib.SMTP_SSL(smtp_server, 465)
    server.set_debuglevel(1)
    server.login(from_addr, password)
    server.sendmail(from_addr, [to_addr], msg.as_string())
    server.quit()

if __name__ == '__main__':
    from_addr = input('From:')
    password = input('Password:')
    to_addr = input('To:')
    smtp_server = 'smtp.'+from_addr.split('@')[-1]
    send(from_addr, password, to_addr, smtp_server)
```

## 接收邮件
```python
from email.parser import Parser
from email.header import decode_header
from email.utils import parseaddr

import poplib

def decode_str(s):
    value, charset = decode_header(s)[0]
    if charset:
        value = value.decode(charset)
    return value

def guess_charset(msg):
    charset = msg.get_charset()
    if charset is None:
        content_type = msg.get('Content-Type', '').lower()
        pos = content_type.find('charset=')
        if pos >= 0:
            charset = content_type[pos+8:].strip()
    return charset

def print_info(msg, indent=0):
    if indent == 0:
        for header in ['From', 'To', 'Subject']:
            value = msg.get(header, '')
            if value:
                if header == 'Subject':
                    value = decode_str(value)
                else:
                    hdr, addr = parseaddr(value)
                    name = decode_str(hdr)
                    value = u'%s <%s>' % (name, addr)
            print('%s%s: %s' % ('  '*indent, header, value))
    if(msg.is_multipart()):
        parts = msg.get_payload()
        for n, part in enumerate(parts):
            print('%spart %s' % ('  '*indent, n))
            print('%s---------------' % ('  '*indent))
            print_info(part, indent+1)
    else:
        content_type = msg.get_content_type()
        if content_type == 'text/plain' or content_type == 'text/html':
            content = msg.get_payload(decode=True)
            charset = guess_charset(msg)
            if charset:
                content = content.decode(charset)
            print('%sText:%s' % ('  '*indent, content+'...'))
        else:
            print('%sAttachment: %s' % ('  '*indent, content_type))
            


def receive(email, password, pop3_server):
    server = poplib.POP3_SSL(pop3_server)
    server.set_debuglevel(1)
    print(server.getwelcome().decode('utf8'))

    # 身份认证
    server.user(email)
    server.pass_(password)

    # 返回信息
    print('信件数量: %s 占用空间: %s' % server.stat())
    resp, mails, octets = server.list()

    # 获取最新一封邮件，索引号从1开始
    index = len(mails)
    resp, lines, octets = server.retr(index)

    msg_content = b'\n'.join(lines).decode('utf8')
    msg = Parser().parsestr(msg_content)
    # 打印email信息
    print_info(msg) 

    server.quit()
    

if __name__ == '__main__':
    email = input('Email:')
    password = input('Password:')
    pop3_server = 'pop3.' + email.split('@')[-1]
    receive(email, password, pop3_server)
```

## IMAP4接收邮件
利用imaplib库实现，获取方式与poplib类似，接口信息查看 https://docs.python.org/3/library/imaplib.html

链接
https://www.liaoxuefeng.com/wiki/0014316089557264a6b348958f449949df42a6d3a2e542c000/001432005226355aadb8d4b2f3f42f6b1d6f2c5bd8d5263000 

