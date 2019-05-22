---
title: LeetCode - Pascal's Triangle
date: 2019-05-21 12:01:57
categories:
- 工作
tags:
- LeetCode
- Java
- 算法
---
![](http://ww1.sinaimg.cn/mw690/ad274f89ly1g38s2eeripj20zs0u6mzp.jpg)
给定一个非负数，转换成杨辉三角的数组。

```java
public List<List<Integer>> generate(int numRows) {
    List<List<Integer>> result = new ArrayList<>();
    if (numRows == 0) {
        return result;
    }
    for (int j = 0; j < numRows; j++) {
        List<Integer> rows = new ArrayList<>();
        rows.add(1);
        // 每行的首尾固定加1，中间元素满足杨辉三角的特性
        for (int i = 1; i < j; i++) {
            List<Integer> preRow = result.get(j - 1);
            int temp = preRow.get(i - 1) + preRow.get(i);
            rows.add(temp);
        }
        if (j != 0){
            rows.add(1);
        }
        result.add(rows);
    }
    return result;
}

public static void main(String[] args) {
    // Pascal's Triangle:[[1], [1, 1], [1, 2, 1], [1, 3, 3, 1], [1, 4, 6, 4, 1]]
    System.out.println("Pascal's Triangle:" + new PascalsTriangle().generate(5));
}
```