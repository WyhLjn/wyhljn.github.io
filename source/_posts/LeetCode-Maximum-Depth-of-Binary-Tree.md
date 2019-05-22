---
title: LeetCode - Maximum Depth of Binary Tree
date: 2019-05-21 12:00:14
categories:
- 工作
tags:
- LeetCode
- Java
- 算法
---
> Given a binary tree, find its maximum depth.
> 
> The maximum depth is the number of nodes along the longest path from the root node down to the farthest leaf node.
> Note: A leaf is a node with no children.
> 
> Example:
> 
> Given binary tree [3,9,20,null,null,15,7],
> return its depth = 3.

```java
public int maxDepth(TreeNode root) {
    if (root == null) {
        return 0;
    }
    if (root.left == null && root.right == null) {
        return 1;
    }
    int lDepth = maxDepth(root.left);
    int rDepth = maxDepth(root.right);
    if (lDepth > rDepth) {
        return lDepth + 1;
    }
    else {
        return rDepth + 1;
    }
}
```