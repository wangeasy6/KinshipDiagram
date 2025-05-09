from opencc import OpenCC   # pip install opencc-python-reimplemented
import sys
import os

def convert_file(input_path, output_path=None):
    """
    将文件中的简体中文转换为繁体中文
    :param input_path: 输入文件路径
    :param output_path: 输出文件路径（默认在源文件后加 "_traditional"）
    """
    # 初始化转换器（简体转繁体）
    cc = OpenCC('s2t')

    # 生成默认输出路径
    if not output_path:
        base, ext = os.path.splitext(input_path)
        output_path = f"{base}_zh-TW{ext}"

    try:
        # 读取文件（UTF-8编码）
        with open(input_path, 'r', encoding='utf-8') as f_in:
            content = f_in.read()

        # 转换文本
        traditional_content = cc.convert(content)

        # 写入新文件
        with open(output_path, 'w', encoding='utf-8') as f_out:
            f_out.write(traditional_content)
        print(f"转换成功！输出文件：{output_path}")

    except Exception as e:
        print(f"错误：{str(e)}")

if __name__ == '__main__':
    # if len(sys.argv) < 2:
    #     print("请将文件拖放到此脚本上，或通过命令行提供文件路径。")
    #     sys.exit(1)

    # input_file = sys.argv[1]
    convert_file("user_manual_zh-CN.md", "user_manual_zh-TW.md")