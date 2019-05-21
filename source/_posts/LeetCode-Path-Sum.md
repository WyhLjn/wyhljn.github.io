---
title: LeetCode Path Sum
date: 2019-05-21 12:01:15
categories:
- 工作
tags:
- LeetCode
- Java
- 算法
---
> Given a binary tree and a sum, determine if the tree has a root-to-leaf path such that adding up all the values along the path equals the given sum.
> 
> Note: A leaf is a node with no children.
> 
> Example:
> 
> Given the below binary tree and sum = 22, return true, as there exist a root-to-leaf path 5->4->11->2 which sum is 22.

题目意思是：给定一个二叉树和一个值，判断从根节点到叶子节点的路径，满足有一条路径上的节点加起来等于该值。

```java
public boolean hasPathSum(TreeNode root, int sum) {
    if (null == root) {
        return false;
    }
    if (root.left == null && root.right == null && sum - root.val == 0) {
        return true;
    }
    return hasPathSum(root.left, sum - root.val) || hasPathSum(root.right, sum - root.val);
}
```