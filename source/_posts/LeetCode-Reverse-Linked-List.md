---
title: LeetCode - Reverse Linked List
date: 2019-07-26 18:44:44
categories:
- 工作
tags:
- LeetCode
- Java
- 算法
---
> Reverse a singly linked list.
> 
> Example:
> 
> Input: 1->2->3->4->5->NULL
> 
> Output: 5->4->3->2->1->NULL

反转单向链表

```java
public ListNode reverseList(ListNode head) {
    ListNode newHead = null;
    while (head != null) {
        ListNode next = head.next;
        head.next = newHead;
        newHead = head;
        head = next;
    }
    return newHead;
}
```