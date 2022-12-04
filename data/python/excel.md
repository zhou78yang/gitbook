# Excel处理

> python excel资源: http://www.python-excel.org/

* openpyxl: 用于读写xlsx的包
* xlsxwriter: 写xlsx文件的包
* xlrd: 读xls文件的包
* xlwt: 写xls文件的包
* xlutils: xlrd和xlwt的高级封装，提供一些常用处理方法

## 文档Usage

### openpyxl
文档地址： https://openpyxl.readthedocs.io/en/stable/ 			

写文件
```python
>>> from openpyxl import Workbook
>>> from openpyxl.utils import get_column_letter
>>>
>>> wb = Workbook()
>>>
>>> dest_filename = 'empty_book.xlsx'
>>>
>>> ws1 = wb.active
>>> ws1.title = "range names"
>>>
>>> for row in range(1, 40):
...     ws1.append(range(600))
>>>
>>> ws2 = wb.create_sheet(title="Pi")
>>>
>>> ws2['F5'] = 3.14
>>>
>>> ws3 = wb.create_sheet(title="Data")
>>> for row in range(10, 20):
...     for col in range(27, 54):
...         _ = ws3.cell(column=col, row=row, value="{0}".format(get_column_letter(col)))
>>> print(ws3['AA10'].value)
AA
>>> wb.save(filename = dest_filename)
```	

读文件
```python
>>> from openpyxl import load_workbook
>>> wb = load_workbook(filename = 'empty_book.xlsx')
>>> sheet_ranges = wb['range names']
>>> print(sheet_ranges['D18'].value)
3
```

文件写入BytesIO
```python
>>> from io import BytesIO
>>> bio = BytesIO
>>> wb.save(bio)
```


### xlsxwriter
> 由于xls受到65535行的限制，一般情况下系统导出优先选用xlsxwriter


### xlutils
文档地址: https://xlutils.readthedocs.io/en/latest/index.html 			

##### xlutils.copy： 将一个`xlrd.Book`对象转换为`xlwt.Workbook`对象
相关文档: 
```python
>>> from os.path import join
>>> from xlrd import open_workbook
>>> rb = open_workbook(join(test_files,'testall.xls'), formatting_info=True, on_demand=True)

# 修改和保存
>>> from xlutils.copy import copy
>>> wb = copy(rb)
>>> wb.get_sheet(0).write(0,0,'changed!')
>>> wb.save(join(temp_dir.path,'output.xls'))

```

##### xlutils.styles: 处理`xlrd`中样式的工具 				
相关文档: https://xlutils.readthedocs.io/en/latest/styles.html
```python
# 读取文件，注意formatting_info=True
>>> import os
>>> from xlrd import open_workbook
>>> book = open_workbook(os.path.join(test_files,'testall.xls'), formatting_info=True)

# 加载Styles对象
>>> from xlutils.styles import Styles
>>> s = Styles(book)

# 获取单元格样式，直接将单元格作为索引传入
>>> sheet = book.sheet_by_name('Sheet1')
>>> s[sheet.cell(0,0)]
<xlutils.styles.NamedStyle ...>

# 获取XF对象，存的index，属于rdbook的内容
>>> A1_xf = A1_style.xf
>>> A1_xf
<xlrd.formatting.XF ...>
```
> [!Warning]
> 这并不适用于通过`xlwt`写入到新sheet中拷贝样式styles的操作，相关功能推荐使用`xlutils.save`和`xlutils.filter`


## 案例

### 保持单元格格式不变修改文字内容
**相关package: xlwt**

> xlwt中的`xlwt.Worksheet.Worksheet.write`方法会重置单元格属性

```python
def write_cell(sheet, row, col, label):
    # sheet.write后会重置单元格格式，此处直接修改原始数据保持原格式不变
    xf_idx = sheet.row(row)._Row__cells[col].xf_idx
    sheet.write(row, col, label)
    sheet.row(row)._Row__cells[col].xf_idx = xf_idx

```

### 将一个sheet复制成多个相同的sheet
**相关package: xlutils, xlrd**

业务场景：提供一个excel模板文件，要求生成多个相同的sheet
```python
# 参照`xlutils.filter.XLRDReader.__call__`源码
def copy(rdbook: xlrd.Book, sheet_copy=1):
    writer = XLWTWriter()
    writer.start()

    writer.workbook(rdbook, 'unknown.xls')
    for n in range(sheet_copy):
        for sheet_x in range(rdbook.nsheets):
            sheet = rdbook.sheet_by_index(sheet_x)
            writer.sheet(sheet, '{}_{}'.format(sheet.name, n))
            for row_x in range(sheet.nrows):
                writer.row(row_x, row_x)
                for col_x in range(sheet.row_len(row_x)):
                    writer.cell(row_x, col_x, row_x, col_x)
            if rdbook.on_demand:
                rdbook.unload_sheet(sheet_x)
    writer.finish()

    return writer.output[0][1]

```


### 导出方法封装（xlwt）
```python
import io
import xlwt
import doctest


class XlsExporter(object):
    """
    数据导出到Excel，依赖xlwt，导出文件行数限制65535
    >>> xe = XlsExporter()
    >>> data = [
    ... [1, 'a', '2020-01-01'],
    ... [2, 'b', '2020-01-02'],
    ... ]
    >>> xe.add_sheet(data, sheetname='sheet', headers=('col1', 'col2', 'col3'))

    字典数据导出
    >>> from collections import OrderedDict
    >>> data_dict = [
    ... {'a': 1, 'b': '2020-01-01'},
    ... {'a': 2, 'b': '2020-01-02'},
    ... ]
    >>> header_map = OrderedDict([('a', 'col1'), ('b', 'col2')])
    >>> xe.add_sheet_by_dict(data=data_dict, header_map=header_map, sheetname='sheet2')

    >>> xe.to_file('./test.xls')    # 直接保存本地文件
    >>> bio = xe.to_bio()           # 保存到BytesIO对象
    """
    def __init__(self):
        self.wb = xlwt.Workbook(encoding='utf-8')

    def add_sheet(self, data, headers=None, sheetname='sheet', cell_overwrite_ok=False):
        """ 源数据为列表/元组格式 """
        sheet = self.wb.add_sheet(sheetname=sheetname, cell_overwrite_ok=cell_overwrite_ok)
        first_row = 0
        if headers:
            for c, header in enumerate(headers):
                sheet.write(0, c, header)
            first_row = 1

        for r, line in enumerate(data, first_row):
            for c, item in enumerate(line):
                sheet.write(r, c, item)

    def add_sheet_by_dict(self, data, header_map, sheetname='sheet', cell_overwrite_ok=False):
        """ 源数据为字典格式 """
        fields, headers = zip(*header_map.items())
        data_list = list()
        for item in data:
            data_list.append([item.get(f, None) for f in fields])
        self.add_sheet(data_list, headers=headers, sheetname=sheetname, cell_overwrite_ok=cell_overwrite_ok)

    def to_bio(self):
        bio = io.BytesIO()
        self.wb.save(bio)
        bio.seek(0)
        return bio

    def to_file(self, filename):
        self.wb.save(filename)

```


### 复制部分区域
```python
def rc2pos(row, col):
    """
        行列转换成具体的位置
        >>> '{}{}'.format(*rc2pos(1, 1))
        'A1'
        >>> '{}{}'.format(*rc2pos(2, 26))
        'Z2'
        >>> '{}{}'.format(*rc2pos(100, 26+1))
        'AA100'
        >>> '{}{}'.format(*rc2pos(1, 12345))
        'RFU1'
        >>> '{}{}'.format(*rc2pos(2, 26*26+26))
        'ZZ2'
    """
    base = 26
    rest = col
    row_result = list()

    while rest > 0:
        rest, mod = divmod(rest-1, base)
        row_result.append(chr(mod+1 + 64).upper())
    return ''.join(row_result[::-1]), str(row)


def copy_sheet_range(ws1, ws2, r0, c0, r1, c1, r_delta=0, c_delta=0):
    """
    复制区域

    """
    # 合并单元格
    for mc in ws1.merged_cells.ranges:
        if not (r0 <= mc.min_row <= mc.max_row <= r1 and c0 <= mc.min_col <= mc.max_col <= c1):
            # 不在此范围内的单元格跳过
            continue
        pos_list = [
            *rc2pos(mc.min_row + r_delta, mc.min_col + c_delta),
            *rc2pos(mc.max_row + r_delta, mc.max_col + c_delta),
        ]
        merge = '{}{}:{}{}'.format(*pos_list)
        ws2.merge_cells(merge)

    for r in range(r0, r1 + 1):
        ws2.row_dimensions[r+r_delta].height = ws1.row_dimensions[r].height

        for c in range(c0, c1 + 1):
            src_c, src_r = rc2pos(r, c)
            dst_c, dst_r = rc2pos(r + r_delta, c + c_delta)
            dst = '{}{}'.format(dst_c, dst_r)

            if r == r0:
                ws2.column_dimensions[dst_c].width = ws1.column_dimensions[src_c].width

            try:
                cell1 = ws1['{}{}'.format(src_c, src_r)]  # 获取data单元格数据

                if not isinstance(cell1, MergedCell):
                    # 非合并的单元格写值
                    ws2[dst].value = cell1.value  # 赋值到ws2单元格

                if cell1.has_style:  # 拷贝格式
                    ws2[dst].font = copy(cell1.font)
                    ws2[dst].border = copy(cell1.border)
                    ws2[dst].fill = copy(cell1.fill)
                    ws2[dst].number_format = copy(cell1.number_format)
                    ws2[dst].protection = copy(cell1.protection)
                    ws2[dst].alignment = copy(cell1.alignment)
            except AttributeError as e:
                print("cell(%s) is %s" % (dst, e))
                continue

```