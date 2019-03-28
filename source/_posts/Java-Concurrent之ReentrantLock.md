---
title: Java Concurrent之ReentrantLock
date: 2019-03-28 20:16:53
categories:
- 工作
tags:
- 源码
- Java
- 并发
---

上一篇讲解了AQS作为Java并发基石，提供了一些并发的基本操作，acquire，release等。本文将介绍AQS的经典实现-ReentrantLock.

先看下ReentrantLock的官方定义

> A reentrant mutual exclusion Lock with the same basic behavior and semantics as the implicit monitor lock accessed using synchronized methods and statements, but with extended capabilities.
> A ReentrantLock is owned by the thread last successfully locking, but not yet unlocking it. A thread invoking lock will return, successfully acquiring the lock, when the lock is not owned by another thread. The method will return immediately if the current thread already owns the lock. 

ReentrantLock具有与synchronized相同的语义，提供了更为丰富的功能，使用起来也更加灵活。一个ReentrantLock由线程持有，线程成功获取到了锁，并且还尚未解锁。如果线程已经成功获取了锁，会立即返回成功。

ReentrantLock定义了两种锁，公平所和非公平锁。当选择公平锁时，在争用下，锁有利于授予访问最长等待的线程，但是这种情况下，就不能保证访问顺序了。**锁的公平性并不能保证线程调度的公平性。** 因此，使用公平锁的许多线程之一可以连续获得锁多次，而其他活动线程没有执行，也没有获取锁。

ReentrantLock默认使用非公平锁

```java
/**
 * Creates an instance of {@code ReentrantLock}.
 * This is equivalent to using {@code ReentrantLock(false)}.
 */
public ReentrantLock() {
    sync = new NonfairSync();
}
```
还提供了一个构造函数，可以自主选择公平锁还是非公平锁

```java
/**
 * Creates an instance of {@code ReentrantLock} with the
 * given fairness policy.
 *
 * @param fair {@code true} if this lock should use a fair ordering policy
 */
public ReentrantLock(boolean fair) {
    sync = fair ? new FairSync() : new NonfairSync();
}
```
ReentrantLock定义了一个内部虚拟静态类**Sync**，该类继承自[AQS](https://wyhljn.github.io/2019/03/20/Java-Concurrent%E4%B9%8BAQS/)，然后公平锁和非公平锁又继承自Sync。

- #### 公平锁

```java
/**
 * Sync object for fair locks
 */
static final class FairSync extends Sync {
    private static final long serialVersionUID = -3000897897090466540L;
    
    // Lock方法调用了AQS的acquire
    final void lock() {
        acquire(1);
    }

    /**
     * Fair version of tryAcquire.  Don't grant access unless
     * recursive call or no waiters or is first.
     */
    protected final boolean tryAcquire(int acquires) {
        final Thread current = Thread.currentThread();
        int c = getState();
        // 第一次获取锁
        if (c == 0) {
            if (!hasQueuedPredecessors() &&
                compareAndSetState(0, acquires)) {
                setExclusiveOwnerThread(current);
                return true;
            }
        }
        else if (current == getExclusiveOwnerThread()) {
            int nextc = c + acquires;
            if (nextc < 0)
                throw new Error("Maximum lock count exceeded");
            setState(nextc);
            return true;
        }
        return false;
    }
}
```
从AQS那篇文章里可以得知，**acquire**方法会调用自定义的**tryAcquire**方法。公平锁实现了自定义的**tryAcquire**。
**acquire**会根据**tryAcquire**的返回值判断是否立即成功，**tryAcquire**返回true将获得锁。

<!-- more -->

看下**tryAcquire**的逻辑：
1. 判断state的值，等于0代表第一次获取锁。与非公平锁相比，这里会判断是否有线程在等待，如果没有的话，CAS设置state=1，并且设置锁被当前线程持有。
2. 如果state不是0，判断当前线程是不是锁的持有者，也就是说线程重入获取锁了。如果不是同一线程的话，直接就失败了，那么线程将进入等待队列（具体可参考AQS详解）。是锁的持有线程的话，将增加state的值，并返回成功。


```java
public final boolean hasQueuedPredecessors() {
    // The correctness of this depends on head being initialized
    // before tail and on head.next being accurate if the current
    // thread is first in queue.
    Node t = tail; // Read fields in reverse initialization order
    Node h = head;
    Node s;
    return h != t &&
        ((s = h.next) == null || s.thread != Thread.currentThread());
}
```
**hasQueuedPredecessors** 会从头节点开始判断，后面是否还有节点或者节点的线程持有者不是当前线程。那么就说明，后面还有等待的线程。

- #### 非公平锁

```java
/**
 * Sync object for non-fair locks
 */
static final class NonfairSync extends Sync {
    private static final long serialVersionUID = 7316153563782823691L;

    /**
     * Performs lock.  Try immediate barge, backing up to normal
     * acquire on failure.
     */
    final void lock() {
        if (compareAndSetState(0, 1))
            setExclusiveOwnerThread(Thread.currentThread());
        else
            acquire(1);
    }

    protected final boolean tryAcquire(int acquires) {
        return nonfairTryAcquire(acquires);
    }
}
```

非公平锁一上来就CAS获取资源，如果成功了，就标记线程持有者为自己。没拿到资源的逻辑就和公平锁一样了。

从上面可以看出，公平锁和非公平锁唯一的区别就是，非公平锁直接获取锁，成功就成功了。而公平锁需要判断是否有其它线程持有锁。

- #### 锁的释放

ReentrantLock的释放不区分公平锁还是非公平锁，都是调用的AQS的**release**方法，**release**会调用ReentrantLock的**tryRelease**。


```java
protected final boolean tryRelease(int releases) {
    int c = getState() - releases;
    if (Thread.currentThread() != getExclusiveOwnerThread())
        throw new IllegalMonitorStateException();
    boolean free = false;
    if (c == 0) {
        free = true;
        setExclusiveOwnerThread(null);
    }
    setState(c);
    return free;
}
```
方法传入了要释放的锁的个数。释放锁时会判断当前线程是不是锁的持有者，如果不是就别释放了，毕竟谁的锁谁来释放。如果都释放了，那么就将锁的线程持有者置空，然后就是设置剩下的state。

至此，ReentrantLock关于锁的源码就分析完了，这部分代码量不多，逻辑还是很简单的。

---

上一篇讲AQS的源码没有看Condition这部分，今天通过ReentrantLock缕一下这部分逻辑。

- ## Condition

**Condition**常用在生产者-消费者模型中。先看下*Doug Lea*给出的例子。


```java
class BoundedBuffer {
 final Lock lock = new ReentrantLock();
 final Condition notFull  = lock.newCondition(); 
 final Condition notEmpty = lock.newCondition(); 

 final Object[] items = new Object[100];
 int putptr, takeptr, count;

 public void put(Object x) throws InterruptedException {
   lock.lock();
   try {
     // 队列已满的情况下，一直等待，直到not full
     while (count == items.length)
       notFull.await();
     items[putptr] = x;
     if (++putptr == items.length) putptr = 0;
     ++count;
     // 队列已经不空了，唤醒等待的线程
     notEmpty.signal();
   } finally {
     lock.unlock();
   }
 }

 public Object take() throws InterruptedException {
   lock.lock();
   try {
     // 队列里没有元素了，等待，直到not empty
     while (count == 0)
       notEmpty.await();
     Object x = items[takeptr];
     if (++takeptr == items.length) takeptr = 0;
     --count;
     // 队列里不满了，发个通知
     notFull.signal();
     return x;
   } finally {
     lock.unlock();
   }
 }
}
```

可以看到，不管是put，还是take，操作之前都要先获得锁，操作之后释放锁。也就是在使用Condition之前都要获取锁，才能操作Condition。

ReentrantLock里提供了创建**Condition**的方法

```java
public Condition newCondition() {
    return sync.newCondition();
}

final ConditionObject newCondition() {
    return new ConditionObject();
}

```
**ConditionObject**定义在AQS里，它只有两个属性，一个**firstWaiter**，一个**lastWaiter**，分别保存条件队列的头和尾。下面按照阻塞-唤醒的顺序看下源码。

- ### await()

```java
// 方法定义表明是可中断的
public final void await() throws InterruptedException {
    if (Thread.interrupted())
        throw new InterruptedException();
    // 新建一个Condition类型的Node，加入队列的尾部
    Node node = addConditionWaiter();
    // 释放锁
    int savedState = fullyRelease(node);
    int interruptMode = 0;
    // 节点不在同步队列中
    while (!isOnSyncQueue(node)) {
        LockSupport.park(this);
        if ((interruptMode = checkInterruptWhileWaiting(node)) != 0)
            break;
    }
    if (acquireQueued(node, savedState) && interruptMode != THROW_IE)
        interruptMode = REINTERRUPT;
    if (node.nextWaiter != null) // clean up if cancelled
        unlinkCancelledWaiters();
    if (interruptMode != 0)
        reportInterruptAfterWait(interruptMode);
}
```
- #### addConditionWaiter

```java
private Node addConditionWaiter() {
    Node t = lastWaiter;
    // If lastWaiter is cancelled, clean out.
    // 状态不是Condition，就可以取消后面的节点么？
    if (t != null && t.waitStatus != Node.CONDITION) {
        unlinkCancelledWaiters();
        t = lastWaiter;
    }
    Node node = new Node(Thread.currentThread(), Node.CONDITION);
    if (t == null)
        firstWaiter = node;
    else
        t.nextWaiter = node;
    lastWaiter = node;
    return node;
}
```

从尾节点开始，如果尾节点状态不是**Condition**，遍历整个队列，将已取消的节点从队列移除。然后新建一个Condition状态的节点，lastWaiter指向它，加入队尾。

unlinkCancelledWaiters()会从头节点开始遍历，如果前面的节点状态不是**Condition**，就从队列里删除它后面的节点。

- #### fullyRelease

```java
final int fullyRelease(Node node) {
    boolean failed = true;
    try {
        int savedState = getState();
        if (release(savedState)) {
            failed = false;
            return savedState;
        } else {
            throw new IllegalMonitorStateException();
        }
    } finally {
        if (failed)
            node.waitStatus = Node.CANCELLED;
    }
}
```
**fullyRelease**会获取state的值，然后全部释放state，并返回之前的state值。

- #### isOnSyncQueue

```java
final boolean isOnSyncQueue(Node node) {
    if (node.waitStatus == Node.CONDITION || node.prev == null)
        return false;
    if (node.next != null) // If has successor, it must be on queue
        return true;
    /*
     * node.prev can be non-null, but not yet on queue because
     * the CAS to place it on queue can fail. So we have to
     * traverse from tail to make sure it actually made it.  It
     * will always be near the tail in calls to this method, and
     * unless the CAS failed (which is unlikely), it will be
     * there, so we hardly ever traverse much.
     */
    return findNodeFromTail(node);
}

private boolean findNodeFromTail(Node node) {
    Node t = tail;
    for (;;) {
        if (t == node)
            return true;
        if (t == null)
            return false;
        t = t.prev;
    }
}
```
判断当前节点是否在同步队列里。这块逻辑会自旋。
1. 如果waitStatus还是Node.CONDITION，那么节点还是在同步队列里（新增条件队列的节点状态是Node.CONDITION），后者前驱是null说明也没再同步队列里（Node.prev应该只用于同步队列）。
2. 如果node.next不为空，也就是有后继节点，证明在同步队列里（node.next应该也只用于同步队列）
3. 队列倒序从队尾向队头查找，找到相等的节点，说明在同步队列里。

如果**isOnSyncQueue**返回false，说明节点不在同步队列里，在条件队列里，那么线程将挂起，一直阻塞在这。（由LockSupport.park语义可以知道，线程被中断了，或者其他线程主动unpark才会唤醒当前线程。）从这块可以看出，如果想退出while循环的话，要么节点转移到了同步队列，要么线程被中断了。

- #### checkInterruptWhileWaiting
> 此方法由于判断，线程在挂起期间是否发生了中断。

```java
private int checkInterruptWhileWaiting(Node node) {
    return Thread.interrupted() ?
        (transferAfterCancelledWait(node) ? THROW_IE : REINTERRUPT) :
        0;
}

final boolean transferAfterCancelledWait(Node node) {
    if (compareAndSetWaitStatus(node, Node.CONDITION, 0)) {
        enq(node);
        return true;
    }
    /*
     * If we lost out to a signal(), then we can't proceed
     * until it finishes its enq().  Cancelling during an
     * incomplete transfer is both rare and transient, so just
     * spin.
     */
    while (!isOnSyncQueue(node))
        Thread.yield();
    return false;
}
```
线程挂起以后，会检查线程在这段时间是否发生了中断。

interruptMode | 含义
---|---
THROW_IE    | 在唤醒之前已经发生中断
REINTERRUPT | 在唤醒之后发生中断
0           | 说明在wait期间没有中断


1. 如果在这期间中断过，会CAS设置节点状态为0，设置成功，说明在唤醒之前已经发生中断，加入同步队列，并返回**THROW_IE**
2. 节点状态已经不是**Node.CONDITION**了，CAS设置失败，说明在await期间没有中断，而是唤醒之后发生了中断，返回**REINTERRUPT**
3. 如果线程没被中断过，返回0

跳出while循环以后，肯定是已经在同步队列里了，**acquireQueued**会在同步队列里获取锁，并返回中断状态。如果在这期间中断过，并且在唤醒之后发生过中断，将interruptMode设置为REINTERRUPT。最后会根据interruptMode来处理中断状态。

- ### signal()
> 将等待时间最长的线程从条件队列转移到同步队列

```java
public final void signal() {
    // 当前线程必须是锁的持有者才能唤醒
    if (!isHeldExclusively())
        throw new IllegalMonitorStateException();
    Node first = firstWaiter;
    if (first != null)
        doSignal(first);
}

private void doSignal(Node first) {
    do {
        // 将firstWaiter指向first节点的后一个，将first移除，
        // 如果后面没有节点了，将lastWaiter置为null
        if ( (firstWaiter = first.nextWaiter) == null)
            lastWaiter = null;
        // 将first和它后面节点的关系去掉
        first.nextWaiter = null;
    } while (!transferForSignal(first) &&
             (first = firstWaiter) != null);
}

// 将一个节点从条件队列转移到同步队列
// 返回true代表转移成功
final boolean transferForSignal(Node node) {
    /*
     * If cannot change waitStatus, the node has been cancelled.
     */
    // 如果节点状态已经不是Node.CONDITION，说明已经取消了，返回失败
    if (!compareAndSetWaitStatus(node, Node.CONDITION, 0))
        return false;

    /*
     * Splice onto queue and try to set waitStatus of predecessor to
     * indicate that thread is (probably) waiting. If cancelled or
     * attempt to set waitStatus fails, wake up to resync (in which
     * case the waitStatus can be transiently and harmlessly wrong).
     */
     // 将节点加入同步队列的队尾，返回前驱节点
    Node p = enq(node);
    int ws = p.waitStatus;
    // 如果前驱节点取消了，那么就唤醒这个节点的线程
    // 否则将前驱节点状态置为Node.SIGNAL，这时直接等待前驱节点唤醒自己，也就不用现在唤醒了
    if (ws > 0 || !compareAndSetWaitStatus(p, ws, Node.SIGNAL))
        LockSupport.unpark(node.thread);
    return true;
}
```
整体梳理以下signal的流程

1. signal从头节点开始遍历，如果节点已经取消，则转移到同步队列失败，继续尝试下一个节点
2. 如果节点未取消，将节点接入同步队列的队尾。如果前驱节点状态是取消，就唤醒当前节点的线程
3. 如果前驱节点不是取消状态，那么将其状态置为SIGNAL，结束唤醒操作


看完**await**和**signal**之后，整体总结一下

- await新建一个节点加入条件队列队尾，并调用park方法挂起线程
- signal将节点从条件队列转移到同步队列，如果前驱节点取消了，或者将前驱节点设置为SIGNAL失败，就唤醒当前节点的线程
- 挂起的线程被唤醒以后，会检查wait过程中是否中断过（是在唤醒之前还是在唤醒之后），然后处理中断状态