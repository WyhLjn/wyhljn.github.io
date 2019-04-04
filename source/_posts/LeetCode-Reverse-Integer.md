---
title: LeetCode - Reverse Integer
date: 2019-03-12 19:28:51
categories:
- 工作
tags:
- LeetCode
- Java
- 算法
---

> Given a 32-bit signed integer, reverse digits of an integer.
> 
> Example 1:
> 
> Input: 123
> Output: 321
> Example 2:
> 
> Input: -123
> Output: -321
> Example 3:
> 
> Input: 120
> Output: 21
> Note:
> Assume we are dealing with an environment which could only store integers within the 32-bit signed integer range: [−231,  231 − 1]. For the purpose of this problem, assume that your function returns 0 when the reversed integer overflows.

---

```java
public int reverse(int x) {
    int res = 0;
    while (x != 0) {
        if (Math.abs(res) > Integer.MAX_VALUE / 10) return 0;
        res = res * 10 + x % 10;
        x /= 10;
    }

    return res;
}

public static void main(String[] args) {
    int origin = 1534236;
    // reverse:6324351
    System.out.println("reverse:" + new ReverseInteger().reverse(origin));
}

```
