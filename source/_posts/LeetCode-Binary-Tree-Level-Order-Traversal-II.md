---
title: LeetCode Binary Tree Level Order Traversal II
date: 2019-05-21 11:56:01
categories:
- 工作
tags:
- LeetCode
- Java
- 算法
---
> Given a binary tree, return the bottom-up level order traversal of its nodes' values. (ie, from left to right, level by level from leaf to root).
> 
> For example:
> Given binary tree [3,9,20,null,null,15,7], return its bottom-up level order traversal as:
> [
>   [15,7],
>   [9,20],
>   [3]
> ]

```java
public List<List<Integer>> levelOrderBottom(TreeNode root) {
    List<List<Integer>> result = new ArrayList<>();
    if (root == null) {
        return result;
    }
    Stack<List<Integer>> stack = new Stack<>();
    Queue<TreeNode> queue = new LinkedList<>();
    queue.offer(root);
    while (!queue.isEmpty()) {
        int qLength = queue.size();
        List<Integer> itemList = new ArrayList<>();
        for (int i = 0; i < qLength; i++) {
            TreeNode node = queue.poll();
            itemList.add(node.val);
            if (node.left != null) {
                queue.offer(node.left);
            }
            if (node.right != null) {
                queue.offer(node.right);
            }
        }
        stack.push(itemList);
    }
    while (!stack.isEmpty()) {
        result.add(stack.pop());
    }
    return result;
}
```