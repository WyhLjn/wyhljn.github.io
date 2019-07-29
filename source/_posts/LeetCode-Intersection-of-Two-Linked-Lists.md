---
title: LeetCode - Intersection of Two Linked Lists
date: 2019-07-10 17:21:08
categories:
- 工作
tags:
- LeetCode
- Java
- 算法
---
找到两个链表的交集的开始的节点，没有交集返回null

假设有A，B两个链表，A链表为[4, 1, 8, 4, 5]，
B链表为[5, 0, 1, 8, 4, 5]，则两个链表的交集的开始节点为8。


```java
public ListNode getIntersectionNode(ListNode headA, ListNode headB) {
    if (headA == null || headB == null) {
        return null;
    }
    ListNode a = headA, b = headB;
    while (a != b) {
        a = a == null ? headB : a.next;
        b = b == null ? headA : b.next;
    }
    return a;
}
```
