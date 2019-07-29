---
title: LeetCode - Excel Sheet Column Number
date: 2019-07-15 14:35:59
categories:
- 工作
tags:
- LeetCode
- Java
- 算法
---
> Given a column title as appear in an Excel sheet, return its corresponding column number.
> 
> For example:
> 
>     A -> 1
>     B -> 2
>     C -> 3
>     ...
>     Z -> 26
>     AA -> 27
>     AB -> 28 
>     ...

> Example 1:
> 
> Input: "A"
> Output: 1

> Example 2:
> 
> Input: "AB"
> Output: 28

> Example 3:
> 
> Input: "ZY"
> Output: 701


```java
public int titleToNumber(String s) {
    int ret = 0;
    for (char c : s.toCharArray()) {
        ret = ret * 26 + (c - 'A' + 1);
    }
    return ret;
}
```