---
title: LeetCode - Remove Duplicates From Sorted List
date: 2019-05-06 18:51:04
categories:
- 工作
tags:
- LeetCode
- Java
- 算法
---
> Given a sorted linked list, delete all duplicates such that each element appear only once.
> 
> Example 1:
> 
> Input: 1->1->2
> Output: 1->2

> Example 2:
> 
> Input: 1->1->2->3->3
> Output: 1->2->3

---

```java
public ListNode deleteDuplicates(ListNode head) {
    if (null == head) {
        return head;
    }
    ListNode current = head;
    while (current != null && current.next != null) {
        if (current.val == current.next.val) {
            current.next = current.next.next;
        }
        else {
            current = current.next;
        }
    }
    return head;
}
```