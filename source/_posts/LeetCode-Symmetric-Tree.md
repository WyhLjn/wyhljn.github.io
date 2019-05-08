---
title: LeetCode - Symmetric Tree
date: 2019-05-08 18:45:17
categories:
- 工作
tags:
- LeetCode
- Java
- 算法
---
> Given a binary tree, check whether it is a mirror of itself (ie, symmetric around its center).
> 
> For example, this binary tree [1,2,2,3,4,4,3] is symmetric,
> 
> But the following [1,2,2,null,3,null,3] is not
>  
> 
> Note:
> Bonus points if you could solve it both recursively and iteratively.

---

```java
public boolean isSymmetric(TreeNode root) {
    if (null == root) {
        return true;
    }
    return isMirror(root.left, root.right);
}

public boolean isMirror(TreeNode left, TreeNode right) {
    if (null == left && null == right) {
        return true;
    }
    if (null != left && null != right && left.val == right.val) {
        return isMirror(left.left, right.right) && isMirror(left.right, right.left);
    }
    return false;
}
```