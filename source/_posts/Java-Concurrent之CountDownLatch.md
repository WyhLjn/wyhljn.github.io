---
title: Java Concurrent之CountDownLatch
date: 2019-05-24 15:06:09
toc: true
categories:
- 工作
tags:
- 源码
- Java
- 并发
---
CountDownLatch是一款同步器，实现了只有当其他线程完成一组操作之后，当前的线程才能继续运行。latch是门栓的意思，count down是倒计时的意思，从字面意思也可以看出，倒计时到了某个值以后，门就打开了。

CountDownLatch初始化时设置了一个count值，当count值达到0之前，门是关闭状态的，await方法会一直阻塞，每次调用countDown方法，count会减一，直到count为0，门被打开了，这时阻塞的线程会被释放，继续执行。但是需要注意的是，count是不能重置的，也就是倒计时只能触发一次，如果需要支持重置计数器，可以用CyclicBarrier来实现。

下面从源码层面分析CountDownLatch是如何实现类似的功能的。
> 本文源码基于Jdk1.8

CountDownLatch包含一个内部类Sync，继承了AQS，这点和ReentrantLock很像。

#### 内部类Sync

```java
private static final class Sync extends AbstractQueuedSynchronizer {
    private static final long serialVersionUID = 4982264981922014374L;

    // 初始化时设定了AQS状态值state
    Sync(int count) {
        setState(count);
    }

    int getCount() {
        return getState();
    }

    // count计数器清零了，成功获得资源，这块用来判断当前线程是否需要加入阻塞队列等待
    protected int tryAcquireShared(int acquires) {
        return (getState() == 0) ? 1 : -1;
    }

    // 释放持有的资源
    protected boolean tryReleaseShared(int releases) {
        // Decrement count; signal when transition to zero
        for (;;) {
            int c = getState();
            if (c == 0)
                return false;
            int nextc = c-1;
            // state=0时返回true，即只有当前是倒数第一个线程调用时才会返回true
            if (compareAndSetState(c, nextc))
                return nextc == 0;
        }
    }
}
```

#### await方法

```java
// state=0之前，线程会一直阻塞。发生以下几种情况线程会唤醒
// 1. count等于0
// 2. 其他线程中断了当前线程
public void await() throws InterruptedException {
    sync.acquireSharedInterruptibly(1);
}

public final void acquireSharedInterruptibly(int arg)
        throws InterruptedException {
    if (Thread.interrupted())
        throw new InterruptedException();
    if (tryAcquireShared(arg) < 0)
        doAcquireSharedInterruptibly(arg);
}

private void doAcquireSharedInterruptibly(int arg)
    throws InterruptedException {
    // 新建一个空节点，成为头节点，当前节点追加到头节点之后，并返回这个节点
    final Node node = addWaiter(Node.SHARED);
    boolean failed = true;
    try {
        for (;;) {
            // 前继节点即为空节点
            final Node p = node.predecessor();
            if (p == head) {
                int r = tryAcquireShared(arg);
                // 当计数器清零之后，才会退出死循环
                if (r >= 0) {
                    setHeadAndPropagate(node, r);
                    p.next = null; // help GC
                    failed = false;
                    return;
                }
            }
            // 如果当前线程的节点不是第二节点，有可能禁止线程被处理器调度
            // 因为头节点是空节点，在这里会将头节点状态置为SIGNAL，这样在release时，才能释放后继节点
            if (shouldParkAfterFailedAcquire(p, node) &&
                parkAndCheckInterrupt())
                throw new InterruptedException();
        }
    } finally {
        if (failed)
            cancelAcquire(node);
    }
}
```
await方法调用了内部类Sync的acquireSharedInterruptibly方法，该方法属于AQS的公有方法。在AQS源码分析一篇里没有分析这个方法，现在在这看下这个方法。

acquireSharedInterruptibly和acquireShared是共享模式下的一对方法。一个不可被中断，一个忽略中断。
1.  如果线程被中断过，直接抛出异常，CountDownLatch捕捉到异常以后，当前线程会唤醒，参与线程调度，代码将继续执行。
1.  接着调用内部类的tryAcquireShared方法，如果计数器大于0，返回-1，则继续执行doAcquireSharedInterruptibly，由该方法可知，只有tryAcquireShared >= 0，也就是只有当计数器清零之后，才会退出死循环
2.  新建可共享的节点，将包含此线程的节点加入阻塞队列，判断tryAcquireShared的返回值，如果当前线程刚好是第二个节点，并且此时计数器归零，则会传播唤醒阻塞队列中等待的线程。否则有可能阻止当前线程被处理器调度


#### countDown方法

```java
public void countDown() {
    sync.releaseShared(1);
}

public final boolean releaseShared(int arg) {
    if (tryReleaseShared(arg)) {
        doReleaseShared();
        return true;
    }
    return false;
}
```
countDown每次释放一个资源，从Sync重写的tryReleaseShared方法得知，只有当前计数器count=1，也就是倒数第一个线程调用时才会返回true。然后唤醒阻塞队列中的第一个线程。

最后总结一下CountDownLatch的特性：

- CountDownLatch具有AQS的特性，在计数器归零之前，所有线程（一般只是当前线程）在阻塞队列中等待，处于Park状态，处理器不会调度这些线程
- count归零以后，唤醒阻塞队列中等待的线程