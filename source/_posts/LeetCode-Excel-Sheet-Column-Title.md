---
title: LeetCode - Excel Sheet Column Title
date: 2019-07-12 18:52:16
categories:
- 工作
tags:
- LeetCode
- Java
- 算法
---
> Given a positive integer, return its corresponding column title as appear in an Excel sheet.
> 
> For example:
> 
>     1 -> A
>     2 -> B
>     3 -> C
>     ...
>     26 -> Z
>     27 -> AA
>     28 -> AB 
>     ...

> Example 1:
> 
> Input: 1
> Output: "A"

> Example 2:
> 
> Input: 28
> Output: "AB"

> Example 3:
> 
> Input: 701
> Output: "ZY"

输入数字返回数字在Excel代表的表头名称

```java
public String convertToTitle(int n) {
    if (n <= 0) {
        return "";
    }
    StringBuilder result = new StringBuilder();
    while (n > 0) {
        n --;
        result.insert(0, (char)('A' + n % 26));
        n /= 26;
    }
    return result.toString();
}
```