---
title: LeetCode - Balanced Binary Tree
date: 2019-05-21 11:58:24
categories:
- 工作
tags:
- LeetCode
- Java
- 算法
---
> Given a binary tree, determine if it is height-balanced.
> 
> For this problem, a height-balanced binary tree is defined as:
> 
> a binary tree in which the depth of the two subtrees of every node never differ by more than 1.
> 
> Example 1:
> 
> Given the following tree [3,9,20,null,null,15,7], return true.
> 
> Example 2:
> 
> Given the following tree [1,2,2,3,3,null,null,4,4], return false.

题目意思是：给定一个二叉树，判断其是否是高度平衡的，也就是每个节点的左右子树高度差不超过1。

```java
public boolean isBalanced(TreeNode root) {
    return getHeight(root) != -1;
}

private int getHeight(TreeNode node) {
    if (node == null) {
        return 0;
    }
    int lh = getHeight(node.left);
    int rh = getHeight(node.right);
    if (lh == -1 || rh == -1 || Math.abs(lh - rh) > 1) {
        return -1;
    }
    return Math.max(lh, rh) + 1;
}
```