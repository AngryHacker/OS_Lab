#define NrSemaphore 10
#define Nr_PCB 10

typedef struct SemaphoreType
{
	int count;
	int blocked_PCB[Nr_PCB];
	int used,front,tail;
}SemaphoreType;

SemaphoreType semaphoreQueue[NrSemaphore];

int semaGet(int value)
{
	int i = 0;
	/* 找到第一个未使用的信号量 */
	while(semaphoreQueue[i].used == 1 && i < NrSemaphore)
	{
		i++;
	}
	/* 检测合法性 */
	if(i < NrSemaphore)
	{
		/*初始操作*/
		semaphoreQueue[i].used = 1;
		semaphoreQueue[i].count = value;
		semaphoreQueue[i].front = 0;
		semaphoreQueue[i].tail = 0;
		/*print("kernal:semGet ");printInt(i);print("  ");printInt(semaphoreQueue[i].count);print("\r\n");*/
		PCB_Queue[current_PCB].regImg.AX = i;
		PCB_Restore();
		return i;
	}
	else 
	{
		/* 非法情况 */
		PCB_Queue[current_PCB].regImg.AX = -1;
		PCB_Restore();
		return -1;
	}
}

int semaFree(int s)
{
	/* 释放信号量 */
	semaphoreQueue[s].used = 0;
}


/* 把进程加入对应信号量的阻塞队列 */
void semaBlock(int s)
{
	/*print("kernal:the process ");printInt(current_PCB);print(" be blocked by P in s ");printInt(s);print("\r\n");*/
	PCB_Queue[current_PCB].status = PCB_BLOCKED;
	if((semaphoreQueue[s].tail + 1)%Nr_PCB == semaphoreQueue[s].front)
	{
		/* 阻塞队列满 */
		print("kernal:too much blocked process\r\n");
		return;
	}
	/* 进程号放到队尾 */
	semaphoreQueue[s].blocked_PCB[semaphoreQueue[s].tail] = current_PCB;
	/* 队尾指针移动 */
	semaphoreQueue[s].tail = (semaphoreQueue[s].tail + 1)%Nr_PCB;
}

/* 从阻塞队列唤醒一个进程 */
void semaWakeUp(int s)
{
	int t;
	if(semaphoreQueue[s].tail == semaphoreQueue[s].front)
	{
		/* 队空 */
		print("No blocked process to wake up!\r\n");
		return ;
	}
	/* 队头进程变为就绪态 */
	t = semaphoreQueue[s].blocked_PCB[semaphoreQueue[s].front];
	/*print("kernal:the process ");printInt(t);print(" be wake up by V in s ");printInt(s);print("\r\n");*/
	PCB_Queue[t].status = PCB_READY;
	/* 队头指针移动 */
	semaphoreQueue[s].front = (semaphoreQueue[s].front + 1)%Nr_PCB;
	return;
}

/* P 操作 */
void semaP(int s)
{
	semaphoreQueue[s].count--;
	if(semaphoreQueue[s].count < 0)
	{
		/* count 小于 0 要阻塞 */
		semaBlock(s);
		schedule();
	}
	PCB_Restore();
}

/* V 操作 */
void semaV(int s)
{
	semaphoreQueue[s].count++;
	if(semaphoreQueue[s].count <= 0)
	{
		/* count 小于等于 0 要唤醒一个阻塞进程 */
		semaWakeUp(s);
		schedule();
	}
	PCB_Restore();
}

