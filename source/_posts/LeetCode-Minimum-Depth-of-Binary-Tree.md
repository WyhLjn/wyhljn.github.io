---
title: LeetCode - Minimum Depth of Binary Tree
date: 2019-05-21 11:53:18
categories:
- 工作
tags:
- LeetCode
- Java
- 算法
---
> Given a binary tree, find its minimum depth.
> 
> The minimum depth is the number of nodes along the shortest path from the root node down to the nearest leaf node.
> 
> Note: A leaf is a node with no children.
> 
> Example:
> 
> Given binary tree [3,9,20,null,null,15,7], return its minimum depth = 2.

题目意思是：给定一个二叉树，找出二叉树的最少深度，也就是从根节点到叶子节点的最短距离。

```java
public int minDepth(TreeNode root) {
    if (null == root) {
        return 0;
    }
    if (root.left == null) {
        return minDepth(root.right) + 1;
    }
    if (root.right == null) {
        return minDepth(root.left) + 1;
    }
    return Math.min(minDepth(root.left), minDepth(root.right)) + 1;
}
```