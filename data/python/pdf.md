# PDF处理

pdf处理相关的包:
* reportlib
* pdfminer
* pdfkit


## pdf文本校验
检测PDF中是否包含异常文本
```python
from pdfminer.high_level import extract_text_to_fp
from io import BytesIO


class PdfTextValidator(object):
    """
    校验PDF文本内容，正常为True，异常为False

    >>> PdfTextValidator('./normal.pdf', ['Illegal Barcode Message']).validate()
    True

    >>> PdfTextValidator('./error.pdf', ['Illegal Barcode Message']).validate()
    False

    """
    def __init__(self, filename_or_content, error_words):
        self.filename = ''
        self.content = filename_or_content
        self.error_words = error_words
        if isinstance(filename_or_content, str):
            self.filename = filename_or_content
            with open(filename_or_content, 'rb') as f:
                self.content = f.read()

    def get_pdf_text(self):
        label_content = BytesIO(self.content)
        bio = BytesIO()
        extract_text_to_fp(label_content, bio)
        text = bio.getvalue().decode('utf-8')
        return text

    def validate(self):
        text = self.get_pdf_text()
        return all(map(lambda w: w not in text, self.error_words))


```



## 图片转换pdf
以下是一个对`reportlib.pdfgen`的封装，实现图片转换pdf功能
```python
from io import BytesIO
from PIL import Image
from reportlab.pdfgen import canvas, pdfimages


class Image2PDF(object):
    """ 图片转换PDF，不需要生成中间文件 """

    def content2content(self, content):
        """
        图片文件二进制流转换为pdf二进制流
        :param content: 图片文件二进制流
        :return: pdf二进制流
        """
        bio = BytesIO(content)
        img = Image.open(bio)
        return self.image2content(img)

    def image2content(self, image):
        """
        Image转pdf二进制流
        :param image: PIL Image对象
        :return: pdf二进制流
        """
        pdf_img = pdfimages.PDFImage(image, 0, 0)
        c = canvas.Canvas('', pagesize=(image.width, image.height))
        pdf_img.drawInlineImage(c)
        content = c.getpdfdata()
        return content

    def file2content(self, filename):
        """
        文件转pdf二进制流
        :param filename: 图片文件路径
        :return: pdf二进制流
        """
        img = Image.open(filename)
        return self.image2content(img)

    def file2file(self, filename, to=None):
        """
        图片文件转pdf文件
        :param filename: 图片文件路径
        :param to: 导出文件路径
        :return:
        """
        if to is None:
            file_path, postfix = filename.rsplit('.', maxsplit=1)
            to = f'{file_path}.pdf'
        content = self.file2content(filename)
        with open(to, 'wb') as f:
            f.write(content)

```