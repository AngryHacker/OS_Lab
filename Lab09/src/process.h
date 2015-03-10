#define Max_PCB 100
/*当前进程编号 */
int current_PCB = 0;
/*进程数量*/
int processNum = 1;
/* 新进程段基址 */
int current_Seg = 0x2000;
/* 进程状态 */
typedef enum PCB_Status{PCB_NEW,PCB_EXIT,PCB_RUNNING, PCB_READY,PCB_BLOCKED}PCB_Status;
/* 标志进程是否第一次执行 */
int tinyFlag,num = 0;
/* 是否为内核态 */
int kernal_mode;

extern void print();
extern void printInt();

typedef struct RegisterImage{
	int SS;
	int GS;
	int FS;
	int ES;
	int DS;
	int DI;
	int SI;
	int BP;
	int SP;
	int BX;
	int DX;
	int CX;
	int AX;
	int IP;
	int CS;
	int Flags;
}RegisterImage;

typedef struct PCB{
	RegisterImage regImg;/***registers will be saved in this struct automactically by timer interrupt***/
	/******/
	PCB_Status status;
	int ID;
	int FID;
}PCB;

/*进程表定义*/
PCB PCB_Queue[Max_PCB];
/* 当前进程的指针 */
PCB *runningPCB,*t_PCB,*sub_PCB;

/*获取当前进程指针*/
PCB* getCurrentPCB(){
	return &PCB_Queue[current_PCB];
}

/*保存当前进程控制块*/
void SavePCB(int ax,int bx, int cx, int dx, int sp, int bp, int si, int di, int ds ,int es,int fs,int gs, int ss,int ip, int cs,int fl)
{
	runningPCB = getCurrentPCB();

	/******************************/
	runningPCB->regImg.AX = ax;
	runningPCB->regImg.BX = bx;
	runningPCB->regImg.CX = cx;
	runningPCB->regImg.DX = dx;
	/******************************/
	runningPCB->regImg.DS = ds;
	runningPCB->regImg.ES = es;
	runningPCB->regImg.FS = fs;
	runningPCB->regImg.GS = gs;
	runningPCB->regImg.SS = ss;
	/******************************/
	runningPCB->regImg.IP = ip;
	runningPCB->regImg.CS = cs;
	runningPCB->regImg.Flags = fl;
	/******************************/
	runningPCB->regImg.DI = di;
	runningPCB->regImg.SI = si;
	runningPCB->regImg.SP = sp;
	runningPCB->regImg.BP = bp;
}

/*进程调度，进行进程轮转 */
void Schedule()
{
	/* 切换前进程转态为 PCB_READY */
	if(runningPCB->status == PCB_RUNNING)
		runningPCB->status = PCB_READY;

	/* printInt(current_PCB); */

	do
	{
		/* 下一个进程 */
		current_PCB = current_PCB+1;

		if(current_PCB >= processNum)
			current_PCB = 1;

	}while(PCB_Queue[current_PCB].status == PCB_BLOCKED || PCB_Queue[current_PCB].status == PCB_EXIT);

	/* 得到切换后的进程指针 */
	runningPCB = getCurrentPCB();

	/*进程状态为 PCB_NEW,则表示第一次执行，tinyFlag 置 1 */
	if(runningPCB->status == PCB_NEW)
		tinyFlag = 1;

	/* 切换后进程转态为 PCB_RUNNING*/
	runningPCB->status = PCB_RUNNING;

	return;
}


/*初始化进程控制块*/
void PCBInit(PCB *p, int processID, int seg)
{
	p->ID = processID;
	p->FID = 0;
	p->status = PCB_NEW;
	/******************************/
	p->regImg.GS = 0xb800;
	p->regImg.ES = seg;
	p->regImg.DS = seg;
	p->regImg.FS = seg;
	p->regImg.SS = seg;
	/******************************/
	p->regImg.DI = 0;
	p->regImg.SI = 0;
	p->regImg.BP = 0;
	p->regImg.SP = 0x10000 - 4;
	/******************************/
	p->regImg.BX = 0;
	p->regImg.AX = 0;
	p->regImg.CX = 0;
	p->regImg.DX = 0;
	/******************************/
	p->regImg.IP = 0x10000;
	p->regImg.CS = seg;
	p->regImg.Flags = 512;
}

/*创建新的进程*/
void createNewPCB()
{
	if(processNum > Max_PCB) return;

	PCBInit( &PCB_Queue[processNum] ,processNum, current_Seg);
	processNum++;
	current_Seg += 0x1000;
	/*print("creating PCB....\r\n");*/
}

/* 加载程序到内存，并创建进程 */
void runProcess(int pro,int seg,int off)
{
	if(pro == 1)
	{
		loadFile("PRS1    BIN",seg,off);
	}
	else if(pro == 2)
	{
		loadFile("PRS2    BIN",seg,off);
	}
	else if(pro == 3)
	{
		loadFile("PRS3    BIN",seg,off);
	}
	else if(pro == 4)
	{
		loadFile("PRS4    BIN",seg,off);
	}
	else if(pro == 5)
	{
		loadFile("USER    COM",seg,off);
	}
	createNewPCB();
}

/* 创建子进程 */
int do_fork()
{
	int sub_ID;
	print("\r\nkernal:forking\r\n");

	/* 创建子进程进程控制块 */
	sub_ID = createSubPCB();
	if(sub_ID == -1)
	{
		runningPCB->regImg.AX = -1;
		return -1;
	}

	sub_PCB = &PCB_Queue[sub_ID];
	runningPCB->regImg.AX = sub_ID;

	print("\r\n");

	/* 复制父进程堆栈给子进程 */
	stackCopy(sub_PCB->regImg.SS,runningPCB->regImg.SS,0x100);

	/* 重新启动进程 */
	PCB_Restore();
}

/* 创建子进程 PCB */
int createSubPCB()
{
	if(processNum > Max_PCB) return -1;

	t_PCB = &PCB_Queue[processNum];

	t_PCB->ID = processNum;
	t_PCB->status = PCB_READY;
	t_PCB->FID = current_PCB;
	/******************************/
	t_PCB->regImg.GS = 0xb800;
	t_PCB->regImg.ES = runningPCB->regImg.ES;
	t_PCB->regImg.DS = runningPCB->regImg.DS;
	t_PCB->regImg.FS = runningPCB->regImg.FS;
	t_PCB->regImg.SS = current_Seg;
	/******************************/
	t_PCB->regImg.DI = runningPCB->regImg.DI;
	t_PCB->regImg.SI = runningPCB->regImg.SI;
	t_PCB->regImg.BP = runningPCB->regImg.BP;
	t_PCB->regImg.SP = runningPCB->regImg.SP;
	/******************************/
	t_PCB->regImg.AX = 0;
	t_PCB->regImg.BX = runningPCB->regImg.BX;
	t_PCB->regImg.CX = runningPCB->regImg.CX;
	t_PCB->regImg.DX = runningPCB->regImg.DX;
	/******************************/
	t_PCB->regImg.IP = runningPCB->regImg.IP;
	t_PCB->regImg.CS = runningPCB->regImg.CS;
	t_PCB->regImg.Flags = runningPCB->regImg.Flags;

	processNum++;
	current_Seg += 0x1000;
	
	print("kernal:sub process created!\r\n");
	return processNum-1;
}

/* 进程等待 */
int do_wait()
{
	print("\r\nkernal:Waiting...\r\n\r\n");
	runningPCB->status = PCB_BLOCKED;
	/* 重新调度进程 */
	Schedule();
	/*重新加载运行的进程*/
	PCB_Restore();
}

void do_exit(int ss)
{
	print("\r\nkernal:exiting\r\n\r\n");
	PCB_Queue[current_PCB].status = PCB_EXIT;
	/* 父进程变成就绪态 */
	PCB_Queue[runningPCB->FID].status = PCB_READY;
	PCB_Queue[runningPCB->FID].regImg.AX = ss;
	current_Seg -= 0x1000;
	processNum --;
	if(processNum == 1) kernal_mode = 1;

	/* 进程退出后寻找下一个进程进行执行 */
	Schedule();
	PCB_Restore();
}

/* 清空进程控制块 */
void deleteAllPCB()
{
	processNum = 1;
	current_Seg = 0x2000;
	current_PCB = 0;
}
