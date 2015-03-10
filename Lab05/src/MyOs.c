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
extern int convertHexToDec();
extern void reverse();
extern int strlen();
extern void display();
extern void Int33();
extern void Int34();
extern void Int35();
extern void Int36();


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
	int i = 0;
	while(str1[i] != '\0')
	{
		str2[i] = str1[i];
		i++;
	}
	str2[i] = '\0';
}



int substr(char str1[],char str2[],int st,int len)
{
	/*
	 * 将 str1 中从 st 开始 len 个字符放到 str2 中
	 */
	int i;
	for(i = st;i < st+len;++i)
	{
		str2[i-st] = str1[i];
	}
	str2[st+len] = '\0';
}

int isDigit(char *p)
{
	/*
	 * 判断字符串是不是纯数字
	 */
	while(*p != '\0')
	{
		if(*p < '0' || *p > '9') return 0;
		p++;
	}
	return 1;
}

int isHex(char *p)
{
	/*
	 * 判断字符串是不是表示十六进制
	 */
	while(*p != '\0')
	{
		if((*p < '0' || *p > '9') && (*p < 'a' || *p > 'f') && (*p < 'A' || *p > 'F')) return 0;
		p++;
	}
	return 1;
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
	print("                           Welcome to My OS 5.0\r\n");
	print("                             @ Develop by JC\n\r\n");
	print("        date -- Get the date         time -- Get the time\n\r");
	print("        int21   -- To test the all function in 21h\r\n"); 
	print("        asc  -- Get the ASCII of the char.like: asc A\n\r"); 
	print("        run  -- run any number of program 1 2 3.like: run  21 or run 231231\n\r"); 
	print("        call -- call the int 33h, int 34h, int 35h, int 36h at the same time\n\r"); 
	print("        others: cls , help , int33 , int34 , int35 , int36 \n\n\r"); 

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
			p = input[j] - '0' + 7;
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
	print("        asc     -- Get the ASCII of the char.like: asc A\n\r"); 
	print("        run     -- run any combination of 1 2 3.like: run  21 or run 231231\r\n"); 
	print("        call    -- The system will call BIOS 33h 34h 35h 36h at the same time\r\n"); 
	print("        int21   -- To test the all function in 21h\r\n"); 
    print("        date    -- Get the date          time  -- Get the time\n\r");
	print("        cls     -- clear the screen      help  -- get some help\r\n"); 
	print("        int33   -- call int33h           int34 -- call int34h\r\n"); 
	print("        int35   -- call int35h           int36 -- call int36h\r\n"); 

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

int to_deci(char *p)
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

void to_reverse(char str[],int len)
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

int get_strlen(char str[])
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

void call21h()
{
	/*
	 * 对21h 中的功能号进行测试
	 */
	while(1)
	{
		cls();
		print("\r\n         Now, you can run some commands to test the 21h:\n\n\r");
		print("        1.ouch  -- to ouch          2.upper -- change the letter to upper\n\r");
		print("        3.lower         -- change the letter to lower\n\r"); 
		print("        4.to_digit      -- change the string to digit\r\n"); 
		print("        5.to_string     -- change the digit to string\r\n"); 
		print("        6.display_where -- you can assign where to display\r\n");
		print("        7.to_deci      -- change the Hex to a decimal digit\r\n"); 
		print("        8.reverse      -- to reverse your string\r\n"); 
		print("        9.strlen      --  get the length of your string\r\n"); 
		print("        10.quit          -- just to quit\r\n\r\n"); 
		print("Please input your choice:"); 
		getline(input,20);
	    if(strcmp(input,"1") || strcmp(input,"ouch"))
		{
			/*
			 * 测试 0 号功能
			 */
			to_OUCH();
		}
	    else if(strcmp(input,"2") || strcmp(input,"upper"))
		{
			/*
			 * 测试 1 号功能
			 */
			while(1)
			{
				print("\r\nPlease input a sentence or quit to back:");
				getline(input,30);
				if(strcmp(input,"quit")) break;
				upper(input);
				print("\r\nThe upper case is:");
				print(input);
				print("\r\n");
			}
		}
	    else if(strcmp(input,"3") || strcmp(input,"lower"))
		{
			/*
			 * 测试 2 号功能
			 */
		    while(1)
			{
				print("\r\nPlease input a sentence or quit to back:");
				getline(input,30);
				if(strcmp(input,"quit")) break;
				lower(input);
				print("\r\nThe lower case is:");
				print(input);
				print("\r\n");
			}
		}
	    else if(strcmp(input,"4") || strcmp(input,"to_digit"))
		{
			/*
			 * 测试 3 号功能
			 */
			print("\r\nDo you want to continue? Y | N :");
			getline(input,2);
			while(1)
			{
				int t1,t2,t3;
				t1 = 0;t2 = 0;
				if(strcmp(input,"n") || strcmp(input,"N")) break;
				print("\r\nPlease input the first digit:");
				getline(input,4);
				if(isDigit(input))
				{
				    t1 = digital(input);
				}
				else 
				{
					print("\r\nInvalid digit!We assume it is 12\n\r");
					t1 = 12;
				}
				print("\r\nPlease input the second digit:");
				getline(input,4);
				if(isDigit(input))
				{
					t2 = digital(input);
				}
				else 
				{
					print("\r\nInvalid digit!We assume it is 21\n\r");
					t2 = 21;
				}
				print("\r\nThe sum of the them is:");
				t3 = t1 + t2;
				printInt(t3);
				print("\r\n");
				print("\r\nDo you want to continue? Y | N :");
				getline(input,2);
			}
		}
	    else if(strcmp(input,"5") || strcmp(input,"to_string"))
		{
			/*
			 * 测试 4 号功能
			 */
			print("\r\nDo you want to continue? Y | N: ");
			getline(input,2);
			while(1)
			{
				char *cht;
				int tt = rand();
				if(strcmp(input,"n") || strcmp(input,"N")) break;
				cht = convertToString(tt);
				print("\r\nI am a string: ");
				print(cht);
				print("\r\n");
				print("\r\nDo you want to continue? Y | N: ");
				getline(input,2);
			}
		}
	    else if(strcmp(input,"6") || strcmp(input,"display_where"))
		{
			/*
			 * 测试 5 号功能
			 */
			int row,col;
			print("\r\nPlease input the row:");
			getline(input,3);
			if(isDigit(input))
			{
				row = digital(input);
			}
			else 
			{
				print("\r\nInvalid digit!We assume it is 12\n\r");
			    row = 12;
			}
			print("\r\nPlease input column:");
			getline(input,3);
			if(isDigit(input))
			{
				col = digital(input);
			}
			else 
			{
				print("\r\nInvalid digit!We assume it is 40\n\r");
			    col = 40;
			}
			print("\r\nPlease input the string:");
			getline(input,30);
			display(row,col,input);
		}
		else if(strcmp(input,"7") || strcmp(input,"to_dec"))
		{
			/*
			 * 测试 6 号功能
			 */
			print("\r\nDo you want to continue? Y | N :");
			getline(input,2);
			while(1)
			{
				int t1;
				t1 = 0;
				if(strcmp(input,"n") || strcmp(input,"N")) break;
				print("\r\nPlease input the hex digit:");
				getline(input,3);
				if(isHex(input))
				{
				    t1 = convertHexToDec(input);
				}
				else 
				{
					print("\r\nInvalid Hex!We assume it is 12\n\r");
					t1 = 12;
				}
				print("\r\nThe decimal form is:");
				printInt(t1);
				print("\r\n");
				print("\r\nDo you want to continue? Y | N :");
				getline(input,2);
			}
		}
		else if(strcmp(input,"8") || strcmp(input,"reverse"))
		{
			/*
			 * 测试 7 号功能
			 */
			print("\r\nDo you want to continue? Y | N :");
			getline(input,2);
			while(1)
			{
				if(strcmp(input,"n") || strcmp(input,"N")) break;
				print("\r\nPlease input the your string:");
				getline(input,30);
				reverse(input,strlen(input));
				print("\r\nThe string after reverse is:");
				print(input);
				print("\r\n");
				print("\r\nDo you want to continue? Y | N :");
				getline(input,2);
			}
		}
		else if(strcmp(input,"9") || strcmp(input,"strlen"))
		{
			/*
			 * 测试 8 号功能
			 */
			print("\r\nDo you want to continue? Y | N :");
			getline(input,2);
			while(1)
			{
				int t;
				if(strcmp(input,"n") || strcmp(input,"N")) break;
				print("\r\nPlease input the your string:");
				getline(input,30);
				t = strlen(input);
				print("\r\nThe length of the string is:");
				printInt(t);
				print("\r\n");
				print("\r\nDo you want to continue? Y | N :");
				getline(input,2);
			}
		}
	    else if(strcmp(input,"10") || strcmp(input,"quit"))
		{
			/*
			 * 退出
			 */
			break;
		}
	}
}


cmain(){
	/* 
	 *视为主函数
	 */
	init();
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
		else if(strcmp(input,"int21") || strcmp(input,"Int21") || strcmp(input,"int 21"))
		{
			/*
			 * 测试 21 号中断
			 */
			call21h();
			init();
		}
		else if(strcmp(input,"call"))
		{
			/*
			 * 调用 33 34 35 36 号 BIOS
			 */
			callBIOS();
			init();
		}
		else if(strcmp(input,"int33") || strcmp(input,"Int33") || strcmp(input,"int 33"))
		{
			/*
			 * 调用 33 号中断
			 */
			Int33();
			init();
		}
		else if(strcmp(input,"int34") || strcmp(input,"Int34") || strcmp(input,"int 34"))
		{
			/*
			 * 调用 34 号中断
			 */
			Int34();
			init();
		}
		else if(strcmp(input,"int35") || strcmp(input,"Int35") || strcmp(input,"int 35"))
		{
			/*
			 * 调用 35 号中断
			 */
			Int35();
			init();
		}
		else if(strcmp(input,"int36") || strcmp(input,"Int36") || strcmp(input,"int 36"))
		{
			/*
			 * 调用 36 号中断
			 */
			Int36();
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

