import tkinter as tk
from tkinter import ttk, filedialog, messagebox

class TextEditorWindow:
    def __init__(self):
        self.file_path = None
        self.create_widgets()
        self.text_editor.config(state="disabled")

    def create_widgets(self):
        self.window = tk.Tk()
        self.window.title("文本编辑器")

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
        operation_menu.add_command(label="生成中间代码", command=self.generate_code)
        menubar.add_cascade(label="操作", menu=operation_menu)

        # 添加文本编辑器
        self.text_editor = tk.Text(self.window, wrap="word")
        self.text_editor.pack(expand=True, fill="both")

    def open_existing_program(self):
        file_path = filedialog.askopenfilename(filetypes=[("Text files", "*.txt")])
        if file_path:
            # 打开文件并读取内容
            with open(file_path, 'r') as file:
                program_text = file.read()
            self.file_path = file_path
            self.text_editor.config(state="normal")
            self.text_editor.delete('1.0', tk.END)
            self.text_editor.insert(tk.END, program_text)

    def create_new_program(self):
        self.file_path = None
        self.text_editor.config(state="normal")
        self.text_editor.delete('1.0', tk.END)

    def save_program(self):
        if self.file_path:
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
        messagebox.showinfo("操作", "词法分析")

    def analyze_syntax(self):
        messagebox.showinfo("操作", "语法分析")

    def generate_code(self):
        messagebox.showinfo("操作", "生成中间代码")

# 创建文本编辑器窗口
text_editor = TextEditorWindow()

# 运行主事件循环
text_editor.window.mainloop()
