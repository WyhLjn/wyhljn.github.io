---
title: LeetCode-Easy Merge Two Sorted Lists
date: 2019-03-22 19:10:14
categories:
- 工作
tags:
- LeetCode
- Java
- 算法
---

> Merge two sorted linked lists and return it as a new list. The new list should be made by splicing together the nodes of the first two lists.
> 
> Example:
> 
> Input: 1->2->4, 1->3->4
> Output: 1->1->2->3->4->4

---

```java
public ListNode mergeTwoLists(ListNode l1, ListNode l2) {
    ListNode newList = new ListNode(-1);
    // 不会丢失头结点
    ListNode cur = newList;
    while (l1 != null && l2 != null) {
        if (l1.val < l2.val) {
            cur.next = l1;
            l1 = l1.next;
        }
        else {
            cur.next = l2;
            l2 = l2.next;
        }

        cur = cur.next;
    }

    cur.next = (l1 == null) ? l2 : l1;

    return newList.next;
}
```