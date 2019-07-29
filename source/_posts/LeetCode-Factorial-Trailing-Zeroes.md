---
title: LeetCode - Factorial Trailing Zeroes
date: 2019-07-15 14:36:17
categories:
- 工作
tags:
- LeetCode
- Java
- 算法
---
> Given an integer n, return the number of trailing zeroes in n!.
> 
> Example 1:
> 
> Input: 3
> Output: 0
> Explanation: 3! = 6, no trailing zero.

> Example 2:
> 
> Input: 5
> Output: 1
> Explanation: 5! = 120, one trailing zero.


```java
public int trailingZeroes(int n) {
    int ret = 0;
    while (n > 0) {
        ret += n / 5;
        n /= 5;
    }
    return ret;
}
```