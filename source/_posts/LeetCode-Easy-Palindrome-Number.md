---
title: LeetCode - Palindrome Number
date: 2019-03-14 19:59:15
categories:
- 工作
tags:
- LeetCode
- Java
- 算法
---

> Determine whether an integer is a palindrome. An integer is a palindrome when it reads the same backward as forward.
> 
> Example 1:
> 
> Input: 121
> Output: true
> Example 2:
> 
> Input: -121
> Output: false
> Explanation: From left to right, it reads -121. From right to left, it becomes 121-. Therefore it is not a palindrome.
> Example 3:
> 
> Input: 10
> Output: false
> Explanation: Reads 01 from right to left. Therefore it is not a palindrome.

---


```java
public boolean isPalindrome(int x) {
    // 负数，小数都不是回文
    if (x < 0 || (x % 10 == 0 && x != 0)) return false;
    int revertNumber = 0;
    // 找到数字的中间位置
    while (x > revertNumber) {
        revertNumber = revertNumber * 10 + x % 10;
        x /= 10;
    }
    return  x == revertNumber || x == revertNumber / 10;
}

public static void main(String[] args) {
    int originNumber = 123321;
    // 123321 isPalindrome:true
    System.out.println(originNumber + " isPalindrome:" + new PalindromeNumber().isPalindrome(originNumber));
}

```