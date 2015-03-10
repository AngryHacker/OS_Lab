extern int fork();
extern int wait();
extern void exit();

#include "user_lib.h"

char str[80] = "129djwqhdsajd128dw9i39ie93i8494urjoiew98kdkd";
int LetterNr = 0;

void main() 
{
   int pid;
   char ch;
   print("In the user:before fork\r\n");
   pid = fork();
   print("In the user:after fork\r\n");
   print("The pid is:");printInt(pid);print("\r\n");
   if(pid == -1) exit(-1); 
   if(pid)
   {
	   print("In the user:before wait\r\n");
	   ch = wait();
	   print("In the user:after wait\r\n");
	   print("LetterNr=");
	   printInt(LetterNr);
	   print("\r\n");
	   exit(0);
   }
   else 
   {
	   print("In the user:sub process is running\r\n");
	   LetterNr = strlen(str);
	   print("In the user:before exit\r\n");
	   exit(0);
	   print("In the user:after exit\r\n");
   }
}

