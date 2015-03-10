extern int fork();
extern int wait();
extern void exit();

#include "user_lib.h"

char words[100];
int be_change = 0;

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

void main() 
{
   int s;
   s = semaGet(1);
   if(fork())
   {
	   while(1)
	   {
		   semaP(s);
		   if(be_change)
		   {
			   print(words);
			   be_change = 0;
		   }
		   semaV(s);
		}
   }
   else 
   {
	   while(1)
	   {
		   semaP(s);
		   be_change = 1;
		   write("Father will live one year after anther forever!\r\n\r\n");
		   semaV(s);
		   delay(15000);
	   }
	   exit(0);
   }
}

