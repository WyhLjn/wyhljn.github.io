---
title: Java Concurrent之AQS
date: 2019-03-20 18:56:42
categories:
- 工作
tags:
- 源码
- Java
- 并发
---

Java里的AQS是许多同步器的基石，例如ReentrantLock，Semaphore。AQS提供了一个框架，依赖FIFO先进先出的等待队列实现阻塞锁和同步并发器。

AQS定义了两种资源共享方式：Exclusive独占和Shared共享，默认是独占式。当以独占模式获取时，其他线程则不能获取到锁，共享模式下则可能成功。当共享模式获取成功时，下一个等待线程（如果存在）也必须确定它是否也可以获取。 在不同模式下等待的线程共享相同的FIFO队列。 通常，实现子类只支持这些模式之一，但是两者都可以在ReadWriteLock中发挥作用 。 仅支持独占或仅共享模式的子类不需要定义支持未使用模式的方法。

子类想实现同步的功能，需要实现以下这几个方法

-  tryAcquire
-  tryRelease
-  tryAcquireShared
-  tryReleaseShared
-  isHeldExclusively

### AQS内部类Node

Node定义了两个常量，分别标识独占式和共享式
> static final Node SHARED = new Node();
>
> static final Node EXCLUSIVE = null;

还约定了线程等待队列的5种状态
1. 默认状态0.
2. SIGNAL = -1，代表后继节点需要被唤醒。当其前继节点的线程释放了同步锁或被取消，将会通知该后继节点的线程执行，也就是当前节点释放锁了，后继节点就会马上执行
3. CANCELLED = 1，当前节点因为超时或者中断取消了。取消状态的线程永远不会再阻塞。
4. CONDITION = -2，标识当前节点处于等待队列中。经过transfer之后，会转为同步队列。
5. PROPAGATE = -3，表明下一个acquireShared应该无条件传播。

<!-- more -->

### 源码分析

- #### acquire

```java
public final void acquire(int arg) {
    if (!tryAcquire(arg) &&
        acquireQueued(addWaiter(Node.EXCLUSIVE), arg))
        selfInterrupt();
}

```
该方法用户独占模式。
首先调用重写的tryAcquire，如果成功直接返回。
否则addWaiter，新建Node节点，将此节点接入队尾。
进入acquireQueued方法，该节点会一直获取资源，返回节点的中断状态。

- #### tryAcquire

```java
protected boolean tryAcquire(int arg) {
    throw new UnsupportedOperationException();
}
```
此方法用于子类实现具体的获取资源的逻辑，并且以独占方式获取。如果state满足条件，将会返回成功。

- #### addWaiter

```java
private Node addWaiter(Node mode) {
    // 新建一个节点
    Node node = new Node(Thread.currentThread(), mode);
    // Try the fast path of enq; backup to full enq on failure
    Node pred = tail;
    if (pred != null) {
        node.prev = pred;
        // 如果存在尾节点，CAS将此节点接入队尾，并且返回该节点
        if (compareAndSetTail(pred, node)) {
            pred.next = node;
            return node;
        }
    }
    enq(node);
    return node;
}
```
可以看到，如果当前队列存在尾节点的话，直接通过CAS安全方式加入队尾，并返回该节点。如果没有队尾，转入***enq***调用。

- #### enq

```java
private Node enq(final Node node) {
    // 无限循环直到插入成功才返回该节点
    for (;;) {
        Node t = tail;
        // 如果队列为空，新建一个空节点，将head设置为这个节点，并将尾节点也指向它
        if (t == null) { // Must initialize
            if (compareAndSetHead(new Node()))
                tail = head;
        } else {
            // 如果队列非空，将此节点放到队尾
            node.prev = t;
            if (compareAndSetTail(t, node)) {
                t.next = node;
                return t;
            }
        }
    }
}
```
通过CAS自旋一直重试，直到将此节点插入队尾，然后返回它。

- #### acquireQueued

```java
final boolean acquireQueued(final Node node, int arg) {
    boolean failed = true;
    try {
        boolean interrupted = false;
        for (;;) {
            // 如果前继节点是头节点，并且成功获取资源，那么将此节点设置成头节点，返回过程中的中断状态
            final Node p = node.predecessor();
            if (p == head && tryAcquire(arg)) {
                setHead(node);
                p.next = null; // help GC
                failed = false;
                return interrupted;
            }
            // 如果资源获取失败，判断节点是否需要park，阻塞当前线程
            if (shouldParkAfterFailedAcquire(p, node) && parkAndCheckInterrupt())
                interrupted = true;
        }
    } finally {
        if (failed)
            cancelAcquire(node);
    }
}
```
从这块逻辑可以看出来，只有当前节点是第二个节点，才能去获取资源。如果既不是第二个节点，也没有成功获取到资源，就需要判断当前线程是否需要阻塞，并且将当前线程阻塞，禁用线程调度。如果不能park，将会继续死循环。直到满足第一个条件，才会退出这个方法。

- #### shouldParkAfterFailedAcquire

```java
private static boolean shouldParkAfterFailedAcquire(Node pred, Node node) {
    int ws = pred.waitStatus;
    if (ws == Node.SIGNAL)
        /*
         * This node has already set status asking a release
         * to signal it, so it can safely park.
         */
        return true;
    if (ws > 0) {
        /*
         * Predecessor was cancelled. Skip over predecessors and
         * indicate retry.
         */
        do {
            node.prev = pred = pred.prev;
        } while (pred.waitStatus > 0);
        pred.next = node;
    } else {
        /*
         * waitStatus must be 0 or PROPAGATE.  Indicate that we
         * need a signal, but don't park yet.  Caller will need to
         * retry to make sure it cannot acquire before parking.
         */
        compareAndSetWaitStatus(pred, ws, Node.SIGNAL);
    }
    return false;
}
```
判断当前节点能否park的条件只有一个，那就是前置节点的状态必须是SIGNAL。
> 1. 如果是的话，那么当前节点就可以高枕无忧，等待被唤醒，可以安心的休息了。
> 2. 如果前置节点状态为取消（只有CANCELLED状态才大于0），会从后往前一直寻找节点，直到找到第一个非CANCELLED状态的节点，并将此节点设为设为后继节点
> 3. 如果前置节点非取消状态，通过CAS将前置节点设为SIGNAL。

从这可以推断，如果前置节点状态是SIGNAL，当前节点立马就可以park，如果不是的话，起码还要经过二次循环调用，将前置节点设为SIGNAL（CAS成功的情况下），下次循环时才可以park。那么最差的情况将会循环三次。

- #### parkAndCheckInterrupt

```java
private final boolean parkAndCheckInterrupt() {
    LockSupport.park(this);
    return Thread.interrupted();
}

public static void park(Object blocker) {
    Thread t = Thread.currentThread();
    setBlocker(t, blocker);
    UNSAFE.park(false, 0L);
    setBlocker(t, null);
}
```
前面判断出可以park的时候，会调用这个方法。当前线程将不会参与线程调度。除非发生以下两种情况：

> 1. 其它线程调用了此线程的unpark方法
> 2. 其它线程中断了当前线程

下面再总体梳理以下acquire的流程。

- 首先调用自定义的tryAcquire获取资源，如果失败直接返回false。
- 成功的话新建一个Node节点，标记为独占节点，并加入等待队列的尾部。
- 队列中的节点进入自旋状态，如果当前节点是第二节点，并且得到资源，当前节点升级为头节点，返回中断状态。否则如果前驱节点是SIGNAL状态，线程放弃调度，直到被中断或者唤醒。

---

看完了acquire的逻辑，下面看下release的流程。

- #### release

```java
public final boolean release(int arg) {
    if (tryRelease(arg)) {
        Node h = head;
        if (h != null && h.waitStatus != 0)
            unparkSuccessor(h);
        return true;
    }
    return false;
}
```
先调用自定义同步器重写的*tryRelease*方法，如果成功的话，唤醒后继节点。

```java
private void unparkSuccessor(Node node) {
    /*
     * If status is negative (i.e., possibly needing signal) try
     * to clear in anticipation of signalling.  It is OK if this
     * fails or if status is changed by waiting thread.
     */
    // 非取消状态的节点，状态置为初始状态0
    int ws = node.waitStatus;
    if (ws < 0)
        compareAndSetWaitStatus(node, ws, 0);

    /*
     * Thread to unpark is held in successor, which is normally
     * just the next node.  But if cancelled or apparently null,
     * traverse backwards from tail to find the actual
     * non-cancelled successor.
     */
    Node s = node.next;
    // 后继节点为空或者已取消，从后往前遍历，找到最前面的正常状态的节点，唤醒节点的线程
    if (s == null || s.waitStatus > 0) {
        s = null;
        for (Node t = tail; t != null && t != node; t = t.prev)
            if (t.waitStatus <= 0)
                s = t;
    }
    if (s != null)
        LockSupport.unpark(s.thread);
}
```
release的过程还是比较简单的，头节点改为初始状态，如果头节点的后继节点为空或者已取消，从后往前遍历，找到第一个正常状态的节点，唤醒它的线程。

---
接下来看下共享式是如何获取资源的
- #### acquireShared

```java
public final void acquireShared(int arg) {
    if (tryAcquireShared(arg) < 0)
        doAcquireShared(arg);
}
```
这里调用同步器自定义实现的tryAcquireShared，大于0即成功立即返回，0代表成功，但是没有资源了，负数代表失败。失败的话，进入doAcquireShared。

- #### doAcquireShared

```java
private void doAcquireShared(int arg) {
    // 新建一个节点接入等待队列
    final Node node = addWaiter(Node.SHARED);
    boolean failed = true;
    try {
        boolean interrupted = false;
        for (;;) {
            final Node p = node.predecessor();
            // 如果前置节点是头节点的话
            if (p == head) {
                // 尝试获取资源，成功的话，继续传播唤醒后继节点
                int r = tryAcquireShared(arg);
                if (r >= 0) {
                    setHeadAndPropagate(node, r);
                    p.next = null; // help GC
                    if (interrupted)
                        selfInterrupt();
                    failed = false;
                    return;
                }
            }
            // 判断当前节点是否park并且阻塞线程
            if (shouldParkAfterFailedAcquire(p, node) &&
                parkAndCheckInterrupt())
                interrupted = true;
        }
    } finally {
        if (failed)
            cancelAcquire(node);
    }
}
```
新加入的节点如果是第二节点，再次尝试获取资源，如果成功了，此节点成为头节点，并唤醒后继节点，因为是共享模式嘛。如果当前节点不是第二节点，就需要判断当前节点能否park，这块逻辑和独占模式情况下是一样的。

- #### setHeadAndPropagate

```java
private void setHeadAndPropagate(Node node, int propagate) {
    Node h = head; // Record old head for check below
    // 当前节点设为头节点
    setHead(node);
    /*
     * Try to signal next queued node if:
     *   Propagation was indicated by caller,
     *     or was recorded (as h.waitStatus either before
     *     or after setHead) by a previous operation
     *     (note: this uses sign-check of waitStatus because
     *      PROPAGATE status may transition to SIGNAL.)
     * and
     *   The next node is waiting in shared mode,
     *     or we don't know, because it appears null
     *
     * The conservatism in both of these checks may cause
     * unnecessary wake-ups, but only when there are multiple
     * racing acquires/releases, so most need signals now or soon
     * anyway.
     */
    if (propagate > 0 || h == null || h.waitStatus < 0 ||
        (h = head) == null || h.waitStatus < 0) {
        Node s = node.next;
        if (s == null || s.isShared())
            doReleaseShared();
    }
}
```
如果还有剩余量，头节点是正常状态，新加入的节点的后继节点为空或者是共享模式的，则继续唤醒后继节点

- #### doReleaseShared

```java
private void doReleaseShared() {
    /*
     * Ensure that a release propagates, even if there are other
     * in-progress acquires/releases.  This proceeds in the usual
     * way of trying to unparkSuccessor of head if it needs
     * signal. But if it does not, status is set to PROPAGATE to
     * ensure that upon release, propagation continues.
     * Additionally, we must loop in case a new node is added
     * while we are doing this. Also, unlike other uses of
     * unparkSuccessor, we need to know if CAS to reset status
     * fails, if so rechecking.
     */
    for (;;) {
        Node h = head;
        if (h != null && h != tail) {
            int ws = h.waitStatus;
            if (ws == Node.SIGNAL) {
                // 如果头节点（也就是当前节点）是SIGNAL状态，重置头节点状态，并唤醒后继节点
                if (!compareAndSetWaitStatus(h, Node.SIGNAL, 0))
                    continue;            // loop to recheck cases
                unparkSuccessor(h);
            }
            // 如果头节点是默认状态，将其置为PROPAGATE
            else if (ws == 0 &&
                     !compareAndSetWaitStatus(h, 0, Node.PROPAGATE))
                continue;                // loop on failed CAS
        }
        if (h == head)                   // loop if head changed
            break;
    }
}
```
因为是共享模式，获取到资源以后，需要继续唤醒后继节点。接下来是共享模式释放的过程。

- #### releaseShared

```java
public final boolean releaseShared(int arg) {
    // 尝试释放资源，返回true或者false
    if (tryReleaseShared(arg)) {
        doReleaseShared();
        return true;
    }
    return false;
}
```
释放失败的话，进入上面的doReleaseShared方法。

至此忽略中断状态的独占和共享模式都讲完了，至于不可中断获取资源的方法，过程也比较类似，只是在线程被中断的时候，抛出InterruptedException异常。