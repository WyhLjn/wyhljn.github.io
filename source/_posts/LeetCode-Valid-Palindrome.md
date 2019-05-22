---
title: LeetCode - Valid Palindrome
date: 2019-05-22 18:24:13
categories:
- 工作
tags:
- LeetCode
- Java
- 算法
---
> Given a string, determine if it is a palindrome, considering only alphanumeric characters and ignoring cases.
> 
> Note: For the purpose of this problem, we define empty string as valid palindrome.
> 
> Example 1:
> 
> Input: "A man, a plan, a canal: Panama"
> 
> Output: true
> 
> Example 2:
> 
> Input: "race a car"
> 
> Output: false

题解：这道题就是验证字符串是否是回文，忽略大消息，需要处理特殊字符。

```java
public boolean isPalindrome(String s) {
    if (s == null) {
        return false;
    }
    if (s == "") {
        return true;
    }
    s = s.replaceAll("[^a-zA-Z0-9]", "");
    s = s.toLowerCase();
    // 使用双指针
    for (int i = 0, j = s.length() - 1; i < j; i++, j--) {
        if (s.charAt(i) != s.charAt(j)) {
            return false;
        }
    }

    return true;
}

public static void main(String[] args) {
    String s = "A man, a plan, a canal: Panama";
    // is Palindrome:false
    System.out.println("is Palindrome:" + new ValidatePalindrome().isPalindrome(s));
}
```
