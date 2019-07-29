---
title: LeetCode - Remove Linked List Elements
date: 2019-07-23 17:25:26
categories:
- 工作
tags:
- LeetCode
- Java
- 算法
---
> Remove all elements from a linked list of integers that have value val.
> 
> Example:
> 
> Input:  1->2->6->3->4->5->6, val = 6
> 
> Output: 1->2->3->4->5


```java
public ListNode removeElements(ListNode head, int val) {
    ListNode newHead = new ListNode(-1);
    newHead.next = head;
    ListNode pre = newHead;
    while (pre.next != null) {
        if (pre.next.val == val) {
            pre.next = pre.next.next;
        }
        else {
            pre = pre.next;
        }
    }
    return newHead.next;
}
```