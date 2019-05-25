# !Author :/guanbowen/

from tkinter import *
import pymysql

connect = pymysql.Connect(
    host='localhost',
    port=3306,
    user='root',
    passwd='1',
    db='zyl',
    charset='utf8'
)
cursor = connect.cursor()

# 初始化Tk()
myWindow = Tk()
myWindow.geometry("800x400")
# 设置标题
myWindow.title('WZT的小银行')
'''entry1 = Entry(myWindow)
entry2 = Entry(myWindow)
entry3 = Entry(myWindow)
entry4 = Entry(myWindow)'''

# 标签控件布局
Label(myWindow, text="欢迎登陆银行服务中心！").grid(row=0)

# Entry控件布局管理器

'''entry1.grid(row=0, column=1)
entry2.grid(row=1, column=1)
entry3.grid(row=2, column=1)
entry4.grid(row=3, column=1)'''


# 偿还贷款
# 接受输入数据
class REC:
    # 打开还款窗口
    def recev_Win(self):

        self.myWindow1 = Tk()
        myWindow2 = self.myWindow1
        myWindow2.geometry("800x400")
        # 设置标题
        myWindow2.title('还款系统')

        Label(myWindow2, text="贷款账户").grid(row=0)
        Label(myWindow2, text="还款账户").grid(row=1)
        Label(myWindow2, text="还款日期").grid(row=2)
        Label(myWindow2, text="还款金额").grid(row=3)

        self.entry1 = Entry(myWindow2)
        self.entry2 = Entry(myWindow2)
        self.entry3 = Entry(myWindow2)
        self.entry4 = Entry(myWindow2)

        self.entry1.grid(row=0, column=1)
        self.entry2.grid(row=1, column=1)
        self.entry3.grid(row=2, column=1)
        self.entry4.grid(row=3, column=1)

        Button(myWindow2, text='退出程序', command=myWindow2.quit).grid(row=6, column=0, sticky=W, padx=5, pady=5)
        Button(myWindow2, text='确认还款', command=self.recev_data).grid(row=6, column=1, sticky=W, padx=5, pady=5)
        myWindow2.mainloop()

        myWindow.quit()

    def recev_data(self):

        win = self.myWindow1
        loan_num = self.entry1.get()
        pay_num = self.entry2.get()
        pay_date = self.entry3.get()
        pay_amount = self.entry4.get()
        # 查询数据
        Label(win, text="100").grid(row=100)
        # print(loan_num,pay_num,pay_date)
        sql = 'call payback(%s,%s,@error,@leftmoney)' % (loan_num, pay_amount)
        print(sql)
        Label(win, text="1").grid(row=10)

        cursor.execute(sql)
        sql = 'select @error,@leftmoney'
        cursor.execute(sql)
        Label(win, text="2").grid(row=11)

        # 遍历数据（存放到元组中） 方式1
        row = cursor.fetchone()

        while row:
            if row[0] == 0:
                Label(win, text="还款成功！").grid(row=8)
                # print("还款成功！")
            elif row[0] == -4:
                Label(win, text="该账号款项已还清！").grid(row=8)
                # print("该账号款项已还清！")
            elif row[0] == -2:
                Label(win, text="还款额不能小于零！").grid(row=8)
                # print("还款额不能小于零！")
            elif row[0] == -3:
                Label(win, text="该贷款账户不存在！").grid(row=8)
                # print("该贷款账户不存在！")
            elif row[0] == -4:
                Label(win, text="违反主键约束！").grid(row=8)
            # print("违反主键约束！")
            elif row[0] == -5:
                Label(win, text="程序执行出错，请稍后再试... --error = 1").grid(row=8)
                # print("程序执行出错，请稍后再试... --error = 1")
            else:
                # 前景色，字体颜色
                Label(win, text="程序执行出错2，请稍后再试...--error = 2", bg='black', fg='redd').grid(row=8)
                # print("程序执行出错2，请稍后再试...--error = 2")
            row = cursor.fetchone()


# 选择转账
class TRA():
    # 打开转账窗口
    def Trans_Win(self):
        self.myWindow = Tk()
        myWindow3 = self.myWindow
        myWindow3.geometry("800x400")
        myWindow3.title('欢迎进入转账系统！！！')

        Label(myWindow3, text="转款账户").grid(row=0)
        Label(myWindow3, text="收款账户").grid(row=1)
        Label(myWindow3, text="转款金额").grid(row=2)

        self.entry1 = Entry(myWindow3)
        self.entry2 = Entry(myWindow3)
        self.entry3 = Entry(myWindow3)

        self.entry1.grid(row=0, column=1)
        self.entry2.grid(row=1, column=1)
        self.entry3.grid(row=2, column=1)

        Button(myWindow3, text='退出程序', command=myWindow3.quit).grid(row=6, column=0, sticky=W, padx=5, pady=5)
        Button(myWindow3, text='确认转账', command=self.Trans_account).grid(row=6, column=1, sticky=W, padx=5, pady=5)
        myWindow3.mainloop()
        myWindow.quit()

    def Trans_account(self):  # 转账
        win = self.myWindow
        account_x = self.entry1.get()
        account_y = self.entry2.get()
        ammount = self.entry3.get()

        sql = 'call PTransfer(\'%s\',\'%s\',%s,@error)'% (account_x, account_y,ammount)
        cursor.execute(sql)
        sql = 'select @error'
        cursor.execute(sql)

        # 遍历数据（存放到元组中） 方式1


        row1 = cursor.fetchone()
        while row1:
            if row1[0] == 0:
                Label(win, text="转账成功！").grid(row=8)
                # print("还款成功！")
            elif row1[0] == -1:
                Label(win, text="转款账户不存在！").grid(row=8)
                # print("该账号款项已还清！")
            elif row1[0] == -2:
                Label(win, text="收款账户不存在！").grid(row=8)
                # print("还款额不能小于零！")
            elif row1[0] == -3:
                Label(win, text="转账金额不能小于零！").grid(row=8)
                # print("该贷款账户不存在！")
            else:
                Label(win, text="系统执行出错，请稍后再试！").grid(row=8)
            row1 = cursor.fetchone()


Repay = REC()
Trans = TRA()
Button(myWindow, text='选择转账', command=Trans.Trans_Win).grid(row=4, column=2, sticky=W, padx=5, pady=5)
Button(myWindow, text='选择还款', command=Repay.recev_Win).grid(row=5, column=2, sticky=W, padx=5, pady=5)
# Quit按钮退出；Run按钮打印计算结果
Button(myWindow, text='退出程序', command=myWindow.quit).grid(row=6, column=2, sticky=W, padx=5, pady=5)
# 进入消息循环
myWindow.mainloop()

# conn.commit()
# conn.close()
