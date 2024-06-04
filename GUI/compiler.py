import tkinter as tk
from tkinter import ttk, filedialog, messagebox
import os
import subprocess

def delete_txt_files():
    file_names = ["token_list.txt", "identifier_table.txt", "integer_table.txt", "real_table.txt", "output.txt"]
    for file_name in file_names:
        file_path = os.path.join(os.getcwd(), file_name)
        if os.path.exists(file_path):
            os.remove(file_path)

class ViewContentWindow:
    def __init__(self, file_name):
        # 打开文件并显示内容
        file_path = os.path.join(os.getcwd(), file_name)
        if os.path.exists(file_path):
            title = "标识符表"
            if file_name == "token_list.txt":
                title = "单词串"
            elif file_name == "integer_table.txt":
                title = "整型常数表"
            elif file_name == "real_table.txt":
                title = "实型常数表"
            else:
                title = "中间代码"
            self.window = tk.Toplevel()
            self.window.title(title)
            # 添加文本编辑器
            self.text_editor = tk.Text(self.window, wrap="word")
            self.text_editor.pack(expand=True, fill="both")
            with open(file_path, 'r') as file:
                content = file.read()
            self.text_editor.insert(tk.END, content)
            self.text_editor.config(state="disabled")
        else:
            if file_name == "output.txt":
                messagebox.showerror("错误", "请先进行语义分析！")
            else:
                messagebox.showerror("错误", "请先进行词法分析！")

class TextEditorWindow:
    def __init__(self):
        self.file_path = None
        self.create_widgets()
        self.line_numbers.pack_forget()
        self.text_editor.tag_configure("big", font=("宋体", 20, "bold"))  
        self.text_editor.tag_configure("normal", font=("宋体", 15))
        self.text_editor.insert(tk.END, "\n基于Flex+Bison的Fortran语言子集编译器\n\n", "big", "Made by：杨凯楠，杨天旺", "normal")
        self.text_editor.config(state="disabled")

    def create_widgets(self):
        self.window = tk.Tk()
        self.window.title("Fortran语言子集编译器")

        # 创建菜单
        menubar = tk.Menu(self.window)
        self.window.config(menu=menubar)

        file_menu = tk.Menu(menubar, tearoff=0)
        file_menu.add_command(label="打开文件", command=self.open_existing_program)
        file_menu.add_command(label="新建文件", command=self.create_new_program)
        file_menu.add_command(label="保存", command=self.save_program)
        menubar.add_cascade(label="文件", menu=file_menu)

        operation_menu = tk.Menu(menubar, tearoff=0)
        operation_menu.add_command(label="词法分析", command=self.analyze_lexical)
        operation_menu.add_command(label="语法分析", command=self.analyze_syntax)
        operation_menu.add_command(label="语义分析", command=self.generate_code)
        menubar.add_cascade(label="操作", menu=operation_menu)

        view_menu = tk.Menu(menubar, tearoff=0)
        view_menu.add_command(label="单词串", command=lambda: self.view_content("token_list.txt"))
        view_menu.add_command(label="标识符表", command=lambda: self.view_content("identifier_table.txt"))
        view_menu.add_command(label="整型常数表", command=lambda: self.view_content("integer_table.txt"))
        view_menu.add_command(label="实型常数表", command=lambda: self.view_content("real_table.txt"))
        view_menu.add_command(label="中间代码", command=lambda: self.view_content("output.txt"))
        menubar.add_cascade(label="查看", menu=view_menu)

        # 添加文本编辑器
        self.text_editor = tk.Text(self.window, wrap="word", padx=4, pady=4)
        self.text_editor.pack(side="right", expand=True, fill="both")
        self.line_numbers = tk.Text(self.window, width=2, padx=4, pady=4, wrap="word", state="disabled")
        self.line_numbers.pack(side="left", fill="y")
        
         # 同步滚动
        self.text_editor.config(yscrollcommand=self.scroll_text_editor_y)
        self.line_numbers.config(yscrollcommand=self.scroll_line_numbers_y)
        self.text_editor.bind("<Configure>", self.update_line_numbers)
        self.text_editor.bind("<Key>", self.update_line_numbers)

    def open_existing_program(self):
        file_path = filedialog.askopenfilename(filetypes=[("Text files", "*.txt")])
        if file_path:
            self.line_numbers.pack(side="left", fill="y")
            # 打开文件并读取内容
            with open(file_path, 'r') as file:
                program_text = file.read()
            self.file_path = file_path
            self.text_editor.config(state="normal")
            self.text_editor.delete('1.0', tk.END)
            self.text_editor.insert(tk.END, program_text)
            self.update_line_numbers(None)

    def create_new_program(self):
        self.line_numbers.pack(side="left", fill="y")
        self.update_line_numbers(None)
        self.file_path = None
        self.text_editor.config(state="normal")
        self.text_editor.delete('1.0', tk.END)

    def save_program(self):
        if self.file_path:
            delete_txt_files()
            program_text = self.text_editor.get('1.0', tk.END)
            with open(self.file_path, 'w') as file:
                file.write(program_text)
            messagebox.showinfo("操作", "源程序已保存")
        else:
            self.save_as_program()

    def save_as_program(self):
        program_text = self.text_editor.get('1.0', tk.END)
        file_path = filedialog.asksaveasfilename(defaultextension=".txt")
        if file_path:
            self.file_path = file_path
            with open(file_path, 'w') as file:
                file.write(program_text)
            messagebox.showinfo("操作", "源程序已保存")

    def analyze_lexical(self):
        if self.file_path:
            try:
                # 执行命令
                subprocess.run(["my_lexer.exe"], input=open(self.file_path).read(), text=True, check=True)
                messagebox.showinfo("操作", "词法分析成功")
            except Exception as e:
                messagebox.showerror("错误", f"词法分析失败: {e}")
        else:
            messagebox.showerror("错误", "请先打开文件")

    def analyze_syntax(self):
        if not os.path.exists("token_list.txt"):
            messagebox.showerror("错误", "请先进行词法分析")
            return
        if self.file_path:
            try:
                # 执行命令并捕获输出
                result = subprocess.run(["my_parser.exe"], input=open("token_list.txt").read(), text=True, capture_output=True, check=True)
                if result.stdout == "Pass!\n":
                    messagebox.showinfo("提示", "语法分析成功")
                else:
                    messagebox.showerror("错误", result.stdout)
            except subprocess.CalledProcessError as e:
                messagebox.showerror("错误", f"语法分析失败: {e}")
        else:
            messagebox.showerror("错误", "请先打开文件")

    def generate_code(self):
        if self.file_path:
            try:
                # 执行命令并捕获输出
                result = subprocess.run(["fortran_compiler.exe"], input=open(self.file_path).read(), text=True, capture_output=True, check=True)
                if result == "":
                    messagebox.showerror("错误", result.stderr)
                else:
                    messagebox.showinfo("提示","语义分析成功")
            except Exception as e:
                messagebox.showerror("错误", f"语义分析失败: {e}")
        else:
            messagebox.showerror("错误", "请先打开文件")

    def view_content(self, file_name):
            ViewContentWindow(file_name)

    def scroll_text_editor_y(self, *args):
        if len(args) == 2:
            self.line_numbers.yview_moveto(args[0])

    def scroll_line_numbers_y(self, *args):
        if len(args) == 2:
            self.text_editor.yview_moveto(args[0])


    def update_line_numbers(self, event):
        # 清除行号显示区域中的内容
        self.line_numbers.config(state="normal")
        self.line_numbers.delete('1.0', tk.END)

        # 计算文本编辑器中行号的数量
        lines = self.text_editor.get('1.0', 'end-1c').split('\n')
        line_count = len(lines)

        # 添加行号到行号显示区域
        for i in range(1, line_count + 1):
            self.line_numbers.insert(tk.END, f"{i}\n", "code")

        # 保持行号显示区域与文本编辑器的行数一致
        self.line_numbers.config(state="disabled")

# 创建文本编辑器窗口
delete_txt_files()
text_editor = TextEditorWindow()

# 运行主事件循环
text_editor.window.mainloop()
