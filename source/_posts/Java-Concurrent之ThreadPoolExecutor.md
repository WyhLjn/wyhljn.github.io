---
title: Java Concurrent之ThreadPoolExecutor
date: 2019-05-20 16:26:31
toc: true
categories:
- 工作
tags:
- 源码
- Java
- 并发
---
我们都知道，在当代的应用中，并发处理请求的场景越来越多。如果每次请求都新建一个线程，处理起来是比较方便，但是也会存在问题：系统创建线程的代价比较高，如果线程的执行时间又很短的话，那么操作系统会花费很大的代价去初始化线程、销毁线程，如此往复，浪费了系统资源不说，而且系统花费在处理请求上的时间不一定比花费在创建、销毁线程上的时间多。

因而Java中引入了线程池的概念。见名知意，它是一组可以处理请求的线程。线程池的好处也显而易见了。
- 可以降低资源消耗
- 提高响应速度
- 方便管理线程

> 本文源码基于Jdk1.8

下面进入正题，先从构造方法说起

#### 构造方法

线程池创建提供了四种构造方法

```java

public ThreadPoolExecutor(int corePoolSize,
                          int maximumPoolSize,
                          long keepAliveTime,
                          TimeUnit unit,
                          BlockingQueue<Runnable> workQueue) {
    this(corePoolSize, maximumPoolSize, keepAliveTime, unit, workQueue,
         Executors.defaultThreadFactory(), defaultHandler);
}

public ThreadPoolExecutor(int corePoolSize,
                          int maximumPoolSize,
                          long keepAliveTime,
                          TimeUnit unit,
                          BlockingQueue<Runnable> workQueue,
                          ThreadFactory threadFactory) {
    this(corePoolSize, maximumPoolSize, keepAliveTime, unit, workQueue,
         threadFactory, defaultHandler);
}

public ThreadPoolExecutor(int corePoolSize,
                          int maximumPoolSize,
                          long keepAliveTime,
                          TimeUnit unit,
                          BlockingQueue<Runnable> workQueue,
                          RejectedExecutionHandler handler) {
    this(corePoolSize, maximumPoolSize, keepAliveTime, unit, workQueue,
         Executors.defaultThreadFactory(), handler);
}

public ThreadPoolExecutor(int corePoolSize,
                          int maximumPoolSize,
                          long keepAliveTime,
                          TimeUnit unit,
                          BlockingQueue<Runnable> workQueue,
                          ThreadFactory threadFactory,
                          RejectedExecutionHandler handler) {
    if (corePoolSize < 0 ||
        maximumPoolSize <= 0 ||
        maximumPoolSize < corePoolSize ||
        keepAliveTime < 0)
        throw new IllegalArgumentException();
    if (workQueue == null || threadFactory == null || handler == null)
        throw new NullPointerException();
    this.acc = System.getSecurityManager() == null ?
            null :
            AccessController.getContext();
    this.corePoolSize = corePoolSize;
    this.maximumPoolSize = maximumPoolSize;
    this.workQueue = workQueue;
    this.keepAliveTime = unit.toNanos(keepAliveTime);
    this.threadFactory = threadFactory;
    this.handler = handler;
}

```

<!-- more -->

下面看下主要字段的含义

- corePoolSize ：核心线程池的大小。
1. 如果新提交一个任务，并且运行中的线程数小于corePoolSize，新建一个线程处理任务，即使其他线程处于空闲状态（idle）
2. 如果运行中的线程数大于等于corePoolSize，但是少于maximumPoolSize，只有当队列已满时才会新建线程
3. 如果corePoolSize与maximumPoolSize相等，则创建了一个固定大小的线程池。

- maximumPoolSize：最大线程池大小
- workQueue：等待队列，用于存储等待执行的任务
- keepAliveTime：空闲线程等待任务的时间。如果线程空闲了，并且线程池中的线程数大于corePoolSize，线程会等待直到超过这个时间
- TimeUnit：keepAliveTime的时间单位，有以下几种选择：
> 1. TimeUnit.NANOSECONDS
> 1. TimeUnit.MICROSECONDS
> 1. TimeUnit.MILLISECONDS
> 1. TimeUnit.SECONDS
> 1. TimeUnit.MINUTES
> 1. TimeUnit.HOURS
> 1. TimeUnit.DAYS
- threadFactory：用来创建新的线程，所有线程的创建都是通过threadFactory。
- handler：拒绝策略，如果等待队列满了并且没有空闲的线程，这时如果继续提交任务，就需要采取一种策略处理该任务。线程池提供了4种策略：
> 1. CallerRunsPolicy：用调用者的线程执行拒绝的任务，如果线程池关闭了，任务将被丢弃
> 2. AbortPolicy：直接抛出异常，这个是默认策略
> 3. DiscardPolicy：丢弃任务
> 4. DiscardOldestPolicy：丢弃最老的任务

#### 线程池的状态
线程池一共有5种状态，分别是：
1. RUNNING：可以接收新提交的任务，并且也能处理队列中的任务
2. SHUTDOWN：不接收新的任务，但是能够执行等待队列中的已经存在的任务
3. STOP：不再接受新任务，也不再执行队列中的任务，会中断正在处理任务的线程
4. TIDYING：所有任务都停止了，有效线程数为0，线程转入该状态并调用terminated() 方法进入TERMINATED 状态
5. TERMINATED：执行terminated()方法后进入该状态

下图为线程池各个状态的转换过程：
![](http://ww1.sinaimg.cn/mw690/ad274f89ly1g28ykhifq0j21ky0mejxg.jpg)

#### 几个类常量和位移操作

在分析源码之前，有必要先熟悉下这几个类变量


```java

// ctl的二进制是11100000000000000000000000000000，和running的值相等
private final AtomicInteger ctl = new AtomicInteger(ctlOf(RUNNING, 0));

// 定义一个基础的位移个数，这个数等于29，下面操作位移时会用到
private static final int COUNT_BITS = Integer.SIZE - 3;
// 1左移29位后减1，这个数二进制是00011111111111111111111111111111
private static final int CAPACITY   = (1 << COUNT_BITS) - 1;


// runState is stored in the high-order bits
// -1 的二进制是 11111111111111111111111111111111
// 11100000000000000000000000000000
private static final int RUNNING    = -1 << COUNT_BITS;
// 0
private static final int SHUTDOWN   =  0 << COUNT_BITS;
// 00100000000000000000000000000000
private static final int STOP       =  1 << COUNT_BITS;
// 01000000000000000000000000000000
private static final int TIDYING    =  2 << COUNT_BITS;
// 01100000000000000000000000000000
private static final int TERMINATED =  3 << COUNT_BITS;


// Packing and unpacking ctl
// ~CAPACITY = 11100000000000000000000000000000
// 取出高3位的值，返回线程池的状态
private static int runStateOf(int c)     { return c & ~CAPACITY; }
// 取出低29位的值，返回当前活动线程的数量
private static int workerCountOf(int c)  { return c & CAPACITY; }

private static int ctlOf(int rs, int wc) { return rs | wc; }


```
知道上面几个常量的二进制以后，下面进入正题，从源码分析线程池的执行过程

#### execute方法

> execute方法是线程池执行提交的任务的方法，线程池通过新建线程或者用已有的线程执行任务

```java
public void execute(Runnable command) {
    if (command == null)
        throw new NullPointerException();
    int c = ctl.get();
    // workerCountOf返回当前的活动线程数
    // 如果当前活动线程数少于corePoolSize
    if (workerCountOf(c) < corePoolSize) {
        // addWorker第二个参数表示限制线程数量，是根据corePoolSize还是maximumPoolSize
        // 如果为true，根据corePoolSize判断
        // 如果为false，根据maximumPoolSize判断
        if (addWorker(command, true))
            return;
        c = ctl.get();
    }
    // 如果当前线程是运行状态，并且成功将任务添加到等待队列
    if (isRunning(c) && workQueue.offer(command)) {
        int recheck = ctl.get();
        // 再次获取ctl的值，如果线程已经不是运行状态了，则从等待队列里移除，并调用拒绝策略
        if (! isRunning(recheck) && remove(command))
            reject(command);
        // 获取线程池中的活动线程数，如果没有活动的线程了，调用addWorker并传入null和false，从队列里取出第一个任务执行（参考runWorker方法）
        else if (workerCountOf(recheck) == 0)
            addWorker(null, false);
    }
    // 到这里有两种情况：
    // 1. 线程池已经不是运行状态
    // 2. 当前活动线程数超过corePoolSize并且队列已满
    else if (!addWorker(command, false))
        reject(command);
}
```
从以上代码可以知道execute方法的执行分以下步骤：
1. 如果当前活动线程数少于corePoolSize，会新创建一个线程来执行任务（具体逻辑在addWorker里，第二个参数为true代表和corePoolSize比较）；
2. 如果线程池正在运行中，活动线程数大于等于corePoolSize，则将任务添加到等待队列里（前提是队列未满）。
    1. 进入队列后继续检查线程池的状态，如果线程池不是运行状态了，从队列里移除任务，并调用拒绝策略；
    2. 如果线程池运行中的线程数为0，没有活动的线程了，调用addWorker并传入null和false，从队列里取出第一个任务执行。
3. 线程池的数量上限设置为maximumPoolSize，如果活动线程数小于maximumPoolSize，则新建线程执行任务，否则无法执行任务，并执行拒绝策略。

execute方法简单执行过程如下：
![](http://ww1.sinaimg.cn/mw690/ad274f89ly1g328j3gv0oj20tp0j8dgx.jpg)

#### addWorker方法
> addWorker是线程池真正执行任务的方法，通过返回值true或者false判断任务是否执行成功或者添加成功


```java
private boolean addWorker(Runnable firstTask, boolean core) {
    retry:
    for (;;) {
        int c = ctl.get();
        // 获得线程池的状态
        int rs = runStateOf(c);

        // Check if queue empty only if necessary.
        // 线程池状态大于等于SHUTDOWN，都不是运行状态
        // 接下来三个条件，只要有一个不满足就会返回false
        // 1.线程池已经停止
        // 2.提交的任务为空
        // 3.等待队列不为空
        // 可以推断：
        //  i. 如果线程池已经停止了，继续提交任务就会失败，那么线程池可以继续处理队列中已存在的任务；
        // ii. 未提交任务，队列中的任务已经空了，再调用addWorker也会失败
        if (rs >= SHUTDOWN &&
            ! (rs == SHUTDOWN &&
               firstTask == null &&
               ! workQueue.isEmpty()))
            return false;

        for (;;) {
            int wc = workerCountOf(c);
            // 判断活动线程是否超过线程数的上限，超过上限，则返回失败
            if (wc >= CAPACITY ||
                wc >= (core ? corePoolSize : maximumPoolSize))
                return false;
            // 未超过上限，活动线程数+1，如果成功，跳出循环
            if (compareAndIncrementWorkerCount(c))
                break retry;
            c = ctl.get();  // Re-read ctl
            // 如果线程池的状态发生变化了，重新进入addWorker方法执行
            if (runStateOf(c) != rs)
                continue retry;
            // else CAS failed due to workerCount change; retry inner loop
        }
    }

    boolean workerStarted = false;
    boolean workerAdded = false;
    Worker w = null;
    try {
        // 每个任务对应一个Worker对象，并且新建一个线程
        w = new Worker(firstTask);
        final Thread t = w.thread;
        if (t != null) {
            // 将任务添加到workers里需要获取锁
            final ReentrantLock mainLock = this.mainLock;
            mainLock.lock();
            try {
                // Recheck while holding lock.
                // Back out on ThreadFactory failure or if
                // shut down before lock acquired.
                int rs = runStateOf(ctl.get());

                // 只有满足下面条件，才会向workers里添加任务，添加成功，线程才会执行任务
                // 1. 线程池处于运行状态
                // 2.线程池不在运行中，但是添加的是空任务，也会添加成功，这块和execute执行过程，当没有活动线程，调用addWorker(null, false)对应，这种情况下会触发线程池继续执行队列中剩余的任务
                if (rs < SHUTDOWN ||
                    (rs == SHUTDOWN && firstTask == null)) {
                    if (t.isAlive()) // precheck that t is startable
                        throw new IllegalThreadStateException();
                    workers.add(w);
                    int s = workers.size();
                    if (s > largestPoolSize)
                        largestPoolSize = s;
                    workerAdded = true;
                }
            } finally {
                mainLock.unlock();
            }
            // worker任务添加成功，启动线程执行任务
            if (workerAdded) {
                t.start();
                workerStarted = true;
            }
        }
    } finally {
        if (! workerStarted)
            addWorkerFailed(w);
    }
    return workerStarted;
}
```
#### Worker任务
Worker类继承AQS，并实现了Runnable接口，则每个任务有了锁的特性，也能执行任务

##### worker类

```java
private final class Worker extends AbstractQueuedSynchronizer implements Runnable
{
    /**
     * This class will never be serialized, but we provide a
     * serialVersionUID to suppress a javac warning.
     */
    private static final long serialVersionUID = 6138294804551838833L;

    /** Thread this worker is running in.  Null if factory fails. */
    final Thread thread;
    /** Initial task to run.  Possibly null. */
    Runnable firstTask;
    /** Per-thread task counter */
    volatile long completedTasks;

    /**
     * Creates with given first task and thread from ThreadFactory.
     * @param firstTask the first task (null if none)
     */
    Worker(Runnable firstTask) {
        // 新增任务时，状态默认是-1
        setState(-1); // inhibit interrupts until runWorker
        this.firstTask = firstTask;
        // 每次新建一个线程
        this.thread = getThreadFactory().newThread(this);
    }

    /** Delegates main run loop to outer runWorker  */
    public void run() {
        runWorker(this);
    }

    // Lock methods
    //
    // The value 0 represents the unlocked state.
    // The value 1 represents the locked state.

    // state不等于0代表线程独占，被当前线程持有锁
    protected boolean isHeldExclusively() {
        return getState() != 0;
    }

    // 只有当state=0时，才能获取到锁，否则失败
    protected boolean tryAcquire(int unused) {
        if (compareAndSetState(0, 1)) {
            setExclusiveOwnerThread(Thread.currentThread());
            return true;
        }
        return false;
    }

    protected boolean tryRelease(int unused) {
        setExclusiveOwnerThread(null);
        setState(0);
        return true;
    }

    public void lock()        { acquire(1); }
    public boolean tryLock()  { return tryAcquire(1); }
    public void unlock()      { release(1); }
    public boolean isLocked() { return isHeldExclusively(); }

    void interruptIfStarted() {
        Thread t;
        if (getState() >= 0 && (t = thread) != null && !t.isInterrupted()) {
            try {
                t.interrupt();
            } catch (SecurityException ignore) {
            }
        }
    }
}

```
从Worker类里可以看出，每个任务的锁有三种状态：

- state = -1，是任务初始状态，新建时设置
- state = 0，当前任务没被任务线程持有
- state = 1，当前任务被某个线程持有

##### runWorker方法
该方法是线程池执行任务的真正方法，addWorker里调用t.start()，将会执行此方法

```java
final void runWorker(Worker w) {
    Thread wt = Thread.currentThread();
    // 从Worker里取出任务
    Runnable task = w.firstTask;
    w.firstTask = null;
    w.unlock(); // allow interrupts
    boolean completedAbruptly = true;
    try {
        // 如果task为空，从等待队列里取任务
        while (task != null || (task = getTask()) != null) {
            // 执行之前，先锁住任务
            w.lock();
            // If pool is stopping, ensure thread is interrupted;
            // if not, ensure thread is not interrupted.  This
            // requires a recheck in second case to deal with
            // shutdownNow race while clearing interrupt
            if ((runStateAtLeast(ctl.get(), STOP) ||
                 (Thread.interrupted() &&
                  runStateAtLeast(ctl.get(), STOP))) &&
                !wt.isInterrupted())
                wt.interrupt();
            try {
                beforeExecute(wt, task);
                Throwable thrown = null;
                try {
                    // 执行任务
                    task.run();
                } catch (RuntimeException x) {
                    thrown = x; throw x;
                } catch (Error x) {
                    thrown = x; throw x;
                } catch (Throwable x) {
                    thrown = x; throw new Error(x);
                } finally {
                    afterExecute(task, thrown);
                }
            } finally {
                task = null;
                w.completedTasks++;
                w.unlock();
            }
        }
        completedAbruptly = false;
    } finally {
        processWorkerExit(w, completedAbruptly);
    }
}

```
接着看getTask方法


```java
private Runnable getTask() {
    boolean timedOut = false; // Did the last poll() time out?

    for (;;) {
        int c = ctl.get();
        // 得到当前线程池状态
        int rs = runStateOf(c);

        // Check if queue empty only if necessary.
        // 如果线程池不是运行状态了，并且线程池正在STOP或者队列已经空了
        // 减少运行中的线程数量，并返回null
        if (rs >= SHUTDOWN && (rs >= STOP || workQueue.isEmpty())) {
            decrementWorkerCount();
            return null;
        }

        int wc = workerCountOf(c);

        // Are workers subject to culling?
        // allowCoreThreadTimeOut默认为false，说明核心线程不允许超时
        boolean timed = allowCoreThreadTimeOut || wc > corePoolSize;

        // 1. 如果有效线程数超过了允许的最大核心线程数，或者需要进行超时控制，有可能是因为上次获取任务时超时了
        // 2. 有效线程数大于1，或者队列是空的
        // 尝试减少有效线程数
        if ((wc > maximumPoolSize || (timed && timedOut))
            && (wc > 1 || workQueue.isEmpty())) {
            if (compareAndDecrementWorkerCount(c))
                return null;
            continue;
        }

        try {
            // 如果运行中的线程数超过了核心线程数，通过线程池设置的超时时间获取任务，超过时间则返回null
            // 否则通过take()获取，没有任务时会阻塞
            Runnable r = timed ?
                workQueue.poll(keepAliveTime, TimeUnit.NANOSECONDS) :
                workQueue.take();
            if (r != null)
                return r;
            // 取不到任务，说明已经超时了
            timedOut = true;
        } catch (InterruptedException retry) {
            // 如果获取任务时，发生了中断，将会继续循环取任务
            timedOut = false;
        }
    }
}
```
从上面可以看到，getTask()不止是取出了需要执行的任务，还会根据需要减少运行中线程的数量。

##### processWorkerExit方法

每个任务执行完成之后，都会调用这个方法

```java
private void processWorkerExit(Worker w, boolean completedAbruptly) {
    // 如果任务执行过程中发生了异常，需要减少线程数
    if (completedAbruptly) // If abrupt, then workerCount wasn't adjusted
        decrementWorkerCount();

    final ReentrantLock mainLock = this.mainLock;
    mainLock.lock();
    try {
        completedTaskCount += w.completedTasks;
        // 移除该任务
        workers.remove(w);
    } finally {
        mainLock.unlock();
    }

    // 判断是否需要进行关闭线程池的操作
    tryTerminate();

    int c = ctl.get();
    if (runStateLessThan(c, STOP)) {
        if (!completedAbruptly) {
            // 正常执行任务的情况下，allowCoreThreadTimeOut为true，保证至少保留一个核心线程
            int min = allowCoreThreadTimeOut ? 0 : corePoolSize;
            if (min == 0 && ! workQueue.isEmpty())
                min = 1;
            if (workerCountOf(c) >= min)
                return; // replacement not needed
        }
        // 如果worker是异常结束，通过addWorker继续执行
        addWorker(null, false);
    }
}
```
至此，整个工作线程的生命周期终结。线程池的执行通过创建worker任务来完成，Worker包装了需要执行的任务以及工作线程，并包含了对任务互斥状态的维护。每次任务的执行包含从队列里获取任务，或者执行worker自己的任务。

#### 线程池的关闭

##### tryTerminate方法

```
final void tryTerminate() {
    for (;;) {
        int c = ctl.get();
        // 判断线程池能否终止：
        // 1. 还在运行中，肯定不能终止
        // 2. 状态是TIDYING或者TERMINATED，所有任务已经关闭，已经没有工作的线程了
        // 3. SHUTDOWN时，并且队列中的任务还没执行完，是不能关闭的
        if (isRunning(c) ||
            runStateAtLeast(c, TIDYING) ||
            (runStateOf(c) == SHUTDOWN && ! workQueue.isEmpty()))
            return;
        
        // 还有运行中的工作线程，随机中断一个空闲的线程
        if (workerCountOf(c) != 0) { // Eligible to terminate
            interruptIdleWorkers(ONLY_ONE);
            return;
        }

        final ReentrantLock mainLock = this.mainLock;
        mainLock.lock();
        try {
            // 线程池状态置为TIDYING成功， 才会真正关闭线程池
            if (ctl.compareAndSet(c, ctlOf(TIDYING, 0))) {
                try {
                    terminated();
                } finally {
                    // 线程池状态置为TERMINATED，线程池已经关闭了
                    ctl.set(ctlOf(TERMINATED, 0));
                    termination.signalAll();
                }
                return;
            }
        } finally {
            mainLock.unlock();
        }
        // else retry on failed CAS
    }
}
```
总结以下，以下三种情况是不能关闭线程池的：
1. 线程池还在运行中
2. 线程池状态是TIDYING或者TERMINATED，说明线程池已经在终止的过程中了
3. 线程池状态是SHUTDOWN，但是队列中的任务还没执行完，也是不能关闭的

##### shutdown方法

```java
public void shutdown() {
    final ReentrantLock mainLock = this.mainLock;
    mainLock.lock();
    try {
        // 判断有没有权限操作
        checkShutdownAccess();
        // 状态切换到SHUTDOWN时
        advanceRunState(SHUTDOWN);
        // 中断空闲线程
        interruptIdleWorkers();
        onShutdown(); // hook for ScheduledThreadPoolExecutor
    } finally {
        mainLock.unlock();
    }
    // 尝试关闭线程池
    tryTerminate();
}
```


```java
public List<Runnable> shutdownNow() {
    List<Runnable> tasks;
    final ReentrantLock mainLock = this.mainLock;
    mainLock.lock();
    try {
        checkShutdownAccess();
        advanceRunState(STOP);
        interruptWorkers();
        tasks = drainQueue();
    } finally {
        mainLock.unlock();
    }
    tryTerminate();
    return tasks;
}
```

shutdownNow()方法与shutdown()方法逻辑差不多，区别在于:
1. 直接将线程池改为STOP
2. 中断所有工作线程，无论是否空闲
3. 移除原队列中的任务，将任务灌入新的队列，并返回


至此，线程池的主要流程执行和销毁大体上分析完了。