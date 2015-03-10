extern void printChar();
extern void printtest();
extern char getchar(); 
extern void cls();
extern void getdate(); 
extern void gettime();
extern void run();   
extern void to_OUCH();   
extern void upper();   
extern void lower();   
extern int  digital();   
extern char* convertToString();
extern void display();
extern void runProcess(int seg,int start,int num);
extern void delay();
extern void backspace();
extern void stackCopy();
extern void PCB_Restore();

#include "process.h"
#include "string.c"

char ch1,ch2,ch3,ch4,p,input[100],output[100],t_char[100];
int yy,mm,dd,hh,mmm,ss,t;

void print(char *p)
{
	/*
	 * 输出字符串 p
	 */
	while(*p != '\0')
	{
		printChar(*p);
		p++;
	}
}

int getline(char arr[],int maxLen)
{
	/*
	 * 读取用户输入的一行
	 */

	int i = 0;
	char in;
	if(maxLen == 0)
	{
		return 0;
	}
	in = getchar();
	while(in != '\n'&& in != '\r') 
	{
		/*
		 * 判断是不是回车键
		 */
		int k = in;
		if(k == 8)
		{
			/*
			 * 判断是不是退格键
			 */
			i--;
			backspace();
			in = getchar();
			continue;
		}
		printChar(in);
		arr[i++] = in;
		if(i == maxLen)
		{
			/*
			 * 是否达到允许输入的最大长度
			 */
			arr[i] = '\0';
			printChar('\n');
			return 0;
		}
		in = getchar();
	}
	arr[i] = '\0';
	print("\n\r");
    return 1;
}

void reverse(char str[],int len)
{
	/*
	 * 将字符串反转 被 21h 中 7 号功能调用
	 */
	int i;
	for(i = 0;i < len;++i)
	{
		t_char[i] = str[len-i-1];
	}
	for(i = 0;i < len;++i)
	{
		str[i] = t_char[i];
	}
}

int strlen(char str[])
{
	/*
	 * 获取字符串长度 被 21h 中 8 号功能调用
	 */
	int i = 0;
	while(str[i] != '\0')
	{
		i++;
	}
	return i;
}

void printInt(int ans)
{
	/*
	 * 打印一个整数到屏幕
	 */
	int i = 0;
	if(ans == 0) 
	{
		output[0] = '0';
		i++;
	}
	while(ans)
	{
		int t = ans%10;
		output[i++] = '0'+t;
		ans/=10;
	}
	reverse(output,i);
	output[i] = '\0';
	print(output);
}

void init()
{
	/* 初始化 */
	cls();
	print("                           Welcome to My OS 7.0\r\n");
	print("                             @ Develop by JC\n\r\n");
	print("        count   -- run the process of count letters fo lab 7\n\r"); 
	print("        go    -- create processes of 1 2 3 4, like go 13, go 2341\r\n"); 
	print("        run   -- run any number of program 1 2 3.like: run  21 or run 231231\n\r"); 
	print("        cls , help ,call , time and so on, please input help to ask detail \n\n\r"); 

}

void asc(char ch)
{
	/* 显示字符 ch 的 ASCII 码 */
	int i;
	i = ch;
	print("The ASCII of ");
	printChar(ch);
	print(" is :");
	printInt(i);
	print("\n\n");
}

int BCD_decode(int x)
{
	/*
	 * 把一个 BCD 编码转为 十进制数
	 */
	return x/16*10 + x%16;
}

void date()
{
	/*
	 * 获取当前日期并输出
	 */
	print("The date is: ");
	getdate();
	yy = BCD_decode(ch1)*100 + BCD_decode(ch2);
	if(yy == 0) print("0000");
	else if(yy >0 && yy < 10) print("000");
	else if(yy > 10 && yy < 100) print("00");
	else if(yy > 100 && yy < 1000) print("0");
	printInt(yy);
	printChar('/');
	mm = BCD_decode(ch3);
	if(mm == 0) print("00");
	else if(mm > 0 && mm < 10) printChar('0');
	printInt(mm);
	printChar('/');
	dd = BCD_decode(ch4);
	if(dd == 0) print("00");
	else if(dd > 0 && dd < 10) printChar('0');
	printInt(dd);
	print("\n\n");
}

void time()
{
	/*
	 * 获取当前时间并输出
	 */
	print("The time is: ");
	gettime();
	hh = BCD_decode(ch1);
	if(hh == 0) print("00");
	else if(hh >0 && hh < 10) printChar('0');
	printInt(hh);
	printChar(':');
	mmm = BCD_decode(ch2);
	if(mmm == 0) print("00");
	else if(mmm > 0 && mmm < 10) printChar('0');
	printInt(mmm);
	printChar(':');
	ss = BCD_decode(ch3);
	if(ss == 0) print("00");
	else if(ss > 0 && ss < 10) printChar('0');
	printInt(ss);
	print("\n\n");
}

void runPro()
{
	/* 运行用户选择的程序 */
	int j;
	for(j = 4;j < strlen(input);++j)
	{
		if(input[j] < '1' || input[j] > '3')
		{
			print("There is no such program!Please use the combination of 1,2,3!\n\n");
			return ;
		}
	}

	for(j = 4;j < strlen(input);++j)
	{
		if(input[j] == ' ') continue;
		else if(input[j] >= '1' && input[j] <= '3')
		{
			p = input[j] - '0' + 11;
			run();
		}
	}
}

void help()
{
	/*
	 * 输出帮助信息
	 */
	print("\r\n        You can uses the commands:\n\n\r");
	print("        count   -- run the process of count letters fo lab 7\n\r"); 
	print("        go      -- create processes of 1 2 3 4, like go 13, go 2341\r\n"); 
	print("        run     -- run any combination of 1 2 3.like: run  21 or run 231231\r\n"); 
	print("        call    -- The system will call BIOS 33h 34h 35h 36h at the same time\r\n"); 
	print("        asc     -- Get the ASCII of the char.like: asc A\n\r"); 
    print("        date    -- Get the date          time  -- Get the time\n\r");
	print("        cls     -- clear the screen      help  -- get some help\r\n"); 
}

int rand()
{
	/*
	 * 获取随机数
	 */
    int ss;
	gettime();
	ss = BCD_decode(ch3);
	return ss*ss%49 + ss*ss%23;
}

to_upper(char *p)
{
	/*
	 * 转化为大写形式 被 21h 中 1 号功能调用
	 */
	while(*p != '\0')
	{
		if(*p >= 'a' && *p <= 'z')
		{
			*p = *p - 32;
		}
		p++;
	}
}

to_lower(char *p)
{
	/*
	 * 转化为小写形式 被 21h 中 2 号功能调用
	 */
	while(*p != '\0')
	{
		if(*p >= 'A' && *p <= 'Z')
		{
			*p = *p + 32;
		}
		p++;
	}
}

int to_digit(char *p)
{
	/*
	 * 字符串转化为数字 被 21h 中 3 号功能调用
	 */
	int ans = 0;
	while(*p != '\0')
	{
		if(*p < '0' || *p > '9') *p = '0';
		ans = ans*10;
		ans = ans + *p - '0';
		p++;
	}
	return ans;
}

char* digit_to_str(int x)
{
	/*
	 * 数字转化为字符串 被 21h 中 4 号功能调用
	 */
	int i = 0,j;
	while(x)
	{
		int t = x%10;
		output[i++] = '0'+t;
		x/=10;
	}
	for(j = 0;j < i;++j)
	{
		t_char[j] = output[i-j-1];
	}
	for(j = 0;j < i;++j)
	{
		output[j] = t_char[j];
	}
	output[i] = '\0';
	return output;
}

int convertHexToDec(char *p)
{
	/*
	 * 十六进制转化为十进制 被 21h 中 6 号功能调用
	 */
	int ans = 0;
	while(*p != '\0')
	{
		int tt = 0;
		ans = ans*16;
		if(*p >= '0' && *p <= '9')
			tt = *p - '0';
		else if(*p >= 'A' && *p <= 'F')
			tt = *p - 'A' + 10;
		else if(*p >= 'a' && *p <= 'f')
			tt = *p - 'a' + 10;
		else tt = 0;
		ans += tt;
		p++;
	}
	return ans;
}



void processHandler()
{
	/*
	 * 创建用户所选的进程
	 */
	int j,t;
	if(strlen(input) > 7) print("Too many programs to ask! Please use less!");
	for(j = 3;j < strlen(input);++j)
	{
		if(input[j] < '1' || input[j] > '4')
		{
			print("There is no such program!Please use the combination of 1,2,3,4!\n\n");
			return ;
		}
	}

	for(j = 3;j < strlen(input);++j)
	{
		t = input[j] - '0';
		/*
		 * 创建进程，放在内存段 current_Seg,起始扇区为 7+t（第一面第0道），占用一个扇区
		 */
		runProcess(current_Seg,7+t,1);
	}
	/*
	 * 操作系统的进程控制块
	 */
	PCBInit(&PCB_Queue[0],1,0x1000);
	/*
	 * 内核态为 0，代表进入用户态
	 */
	kernal_mode = 0;
}

void count()
{
	/*
	 * 运行统计字母数的用户程序
	 */
	runProcess(current_Seg,11,1);
	runProcess(current_Seg,15,2);
	kernal_mode = 0;
}

cmain(){
	/* 
	 *视为主函数
	 */
	init();
	/*
	 * 进入内核态，并设置时钟
	 */
	kernal_mode = 1;
	startClock();
	while(1)
	{
		print("\rroot#");
	    getline(input,20);
	    if(strcmp(input,"date")) date();
	    else if(strcmp(input,"time")) time();
	    else if(substr(input,t_char,0,3) && strcmp(t_char,"asc"))
	    {
			/* 打印字符 ASCII 码 */
		    substr(input,t_char,4,1);
		    asc(t_char[0]);
	    }
		else if(strcmp(input,"cls"))
		{
			/*
			 * 清屏
			 */
			init();
		}
		else if(strcmp(input,"count"))
		{
			/*
			 * 统计字母
			 */
			cls();
			count();
			delay(1500);
			init();
		}
		else if(substr(input,t_char,0,2) && strcmp(t_char,"go"))
		{
			/*
			 * 进程演示
			 */
			cls();
			processHandler();
			delay(1500);
			deleteAllPCB();
			init();
		}
		else if(substr(input,t_char,0,3) && strcmp(t_char,"run"))
		{
			/* 
			 * 运行用户程序
			 */
			cls();
			runPro();
			init();
		}
		else if(strcmp(input,"help"))
		{
			/* 
			 * 打印帮助信息
			 */
			help();
		}
		else if(strcmp(input,"call"))
		{
			/*
			 * 调用 33 34 35 36 号 BIOS
			 */
			callBIOS();
			delay(25000);
			init();
		}
	    else
	    {
			/* 
			 * 错误指令
			 */
			print("Cat't find the Command: ");
		    print(input);
			print("\n\n");
	    }
	}
}

