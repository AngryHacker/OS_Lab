extern void printChar();
extern void getchar(); 
extern void cls();
extern void getdate(); 
extern void gettime();
extern void run();   

char in,ch1,ch2,ch3,ch4,p,input[100],output[100],t_char[100];
int i,yy,mm,dd,hh,mmm,ss,t;

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

	if(maxLen == 0)
	{
		return 0;
	}
	i = 0;
	getchar();
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
			getchar();
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
		getchar();
	}
	arr[i] = '\0';
	print("\n\r");
    return 1;
}

int strcmp(char* str1,char* str2)
{
	/*
	 * 比较两个字符串是否相等
	 */
	while(*str1 != '\0' && *str2 != '\0')
	{
		if(*str1 != *str2) return 0;
		str1++;str2++;
	}
	if(*str1 == '\0' && *str2 == '\0') 
		return 1;
	return 0;
}

void strcpy(char str1[],char str2[])
{
	/*
	 * 将字符串 str2 复制到 str1 中
	 */
	i = 0;
	while(str1[i] != '\0')
	{
		str2[i] = str1[i];
		i++;
	}
	str2[i] = '\0';
}

int strlen(char str[])
{
	/*
	 * 获取字符串的长度
	 */
	i = 0;
	while(str[i] != '\0')
	{
		i++;
	}
	return i;
}

void reverse(char str[],int len)
{
	/* 
	 * 将字符串反转
	 */
	for(i = 0;i < len;++i)
	{
		t_char[i] = str[len-i-1];
	}
	for(i = 0;i < len;++i)
	{
		str[i] = t_char[i];
	}
}

int substr(char str1[],char str2[],int st,int len)
{
	/*
	 * 将 str1 中从 st 开始 len 个字符放到 str2 中
	 */
	for(i = st;i < st+len;++i)
	{
		str2[i-st] = str1[i];
	}
	str2[st+len] = '\0';
}

void printInt(int ans)
{
	/*
	 * 打印一个整数到屏幕
	 */
	i = 0;
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
	print("                           Welcome to My OS\n\r\n");
	print("        date -- Get the date         time -- Get the time\n\r");
	print("        asc -- Get the ASCII of the char.like: asc A\n\r"); 
	print("        run -- run any number of program 1 2 3.like: run  21 or run 231231\n\r"); 
	print("        cls -- clear the screen      help -- get some help\n\n\r"); 

}

void asc(char ch)
{
	/* 显示字符 ch 的 ASCII 码 */
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
			p = input[j] - '0' + 10;
			run();
		}
	}
}

void help()
{
	print("\r\n        You can uses the commands:\n\n\r");
    print("        date -- Get the date         time -- Get the time\n\r");
	print("        asc -- Get the ASCII of the char.like: asc A\n\r"); 
	print("        run -- run any combination of 1 2 3.like: run  21 or run 231231\r\n"); 
	print("        cls -- clear the screen      help -- get some help\n\n"); 
}

cmain(){
	/* 
	 *视为主函数
	 */
	init();
	while(1)
	{
		print("\rroot#");
	    getline(input,10);
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
		else if(substr(input,t_char,0,3) && strcmp(t_char,"run"))
		{
			/* 
			 * 运行用户程序
			 */
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

