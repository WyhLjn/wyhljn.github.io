---
title: LeetCode - Pascal's Triangle II
date: 2019-05-21 12:02:32
categories:
- 工作
tags:
- LeetCode
- Java
- 算法
---
![](http://ww1.sinaimg.cn/mw690/ad274f89ly1g38s9fv7jej20zg0p0go3.jpg)

题解：返回杨辉三角特定行的元素。

```java
public List<Integer> getRow(int rowIndex) {
        if (rowIndex < 0) {
        return new ArrayList<>();
    }
    List<Integer> result = new ArrayList<>();
    result.add(1);
    for (int k = 1; k <= rowIndex; k++) {
        // 开头结尾的元素需要重写，倒序防止覆盖
        for (int i = k - 1; i >= 1; i--) {
            result.set(i, result.get(i) + result.get(i - 1));
        }
        result.add(1);
    }
    return result;
}

public static void main(String[] args) {
    int rowIndex = 3;
    // [1,3,3,1]
    System.out.println(new PascalsTriangleTwo().getRow(rowIndex));
}
```
