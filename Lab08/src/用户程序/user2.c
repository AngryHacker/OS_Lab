extern int fork();
extern int wait();
extern void exit();

#include "user_lib.h"

char words[100];
int be_change = 0,fruit_disk;

void write(char *p)
{
	int i = 0;
	while(*p != '\0')
	{
		words[i++] = *p;
		p++;
	}
	return;
}

void putfruit()
{
	int t;
	t = rand()%10;
	fruit_disk = t;
}

void main() 
{
   int s1,s2;
   s1 = semaGet(0);
   s2 = semaGet(0);
   if(fork())
   {
	   while(1)
	   {
		   semaP(s1);
		   semaP(s2);
		   if(be_change)
		   {
			   print(words);
			   be_change = 0;
		   }
		   print("Father enjoy the fruit ");printInt(fruit_disk);print("\r\n\r\n");
		   fruit_disk = 0;
		}
   }
   else 
   {
	   if(fork())
	   {
		   while(1)
		   {
			   be_change = 1;
			   write("Father will live one year after anther forever!\r\n");
			   semaV(s1);
			   delay(21000);
		   }
	   }
	   else 
	   {
		   while(1)
		   {
			   putfruit();
			   semaV(s2);
			   delay(21000);
		   }
	   }
   }
}

