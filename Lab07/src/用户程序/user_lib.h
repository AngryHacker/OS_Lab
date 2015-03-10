extern void cls();
extern char getchar();
extern void delay(int t);
extern void printchar();
extern void backspace();

char input[100],output[100],t_char[100];

void reverse(char str[],int len)
{
	/*
	 * 将字符串反转 
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
	 * 获取字符串长度
	 */
	int i = 0;
	while(str[i] != '\0')
	{
		i++;
	}
	return i;
}

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
