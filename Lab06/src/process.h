#define Max_PCB 8
/*当前进程编号 */
int current_PCB = 0;
/*进程数量*/
int processNum = 1;
/* 新进程段基址 */
int current_Seg = 0x2000;
/* 进程状态 */
typedef enum PCB_Status{PCB_READY,PCB_EXIT,PCB_RUNNING, PCB_BLOCKING}PCB_Status;
/* 标志进程是否第一次执行 */
int tinyFlag;
/* 是否为内核态 */
int kernal_mode;

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
}PCB;

/*进程表定义*/
PCB PCB_Queue[Max_PCB];
/* 当前进程的指针 */
PCB *runningPCB;

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
	/* 切换前进程转态为 PCB_BLOCKING */
	runningPCB->status = PCB_BLOCKING;

	/* 下一个进程 */
	current_PCB = current_PCB+1;

	if(current_PCB == processNum)
		current_PCB = 1;

	/* 得到切换后的进程指针 */
	runningPCB = getCurrentPCB();

	/*进程状态为 PCB_READY,则表示第一次执行，tinyFlag 置 1 */
	if(runningPCB->status == PCB_READY)
		tinyFlag = 1;

	/* 切换后进程转态为 PCB_RUNNING*/
	runningPCB->status = PCB_RUNNING;

	return;
}

/*初始化进程控制块*/
void PCBInit(PCB *p, int processID, int seg)
{
	p->ID = processID;
	p->status = PCB_READY;
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
	p->regImg.SP = 0x100 - 4;
	/******************************/
	p->regImg.BX = 0;
	p->regImg.AX = 0;
	p->regImg.CX = 0;
	p->regImg.DX = 0;
	/******************************/
	p->regImg.IP = 0x100;
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
}

/* 清空进程控制块 */
void deleteAllPCB()
{
	processNum = 1;
	current_Seg = 0x2000;
	current_PCB = 0;
}
