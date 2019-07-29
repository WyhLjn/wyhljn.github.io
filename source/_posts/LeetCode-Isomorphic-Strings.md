---
title: LeetCode - Isomorphic Strings
date: 2019-07-26 18:44:34
categories:
- 工作
tags:
- LeetCode
- Java
- 算法
---
> Given two strings s and t, determine if they are isomorphic.
> 
> Two strings are isomorphic if the characters in s can be replaced to get t.
> 
> All occurrences of a character must be replaced with another character while preserving the order of characters. No two characters may map to the same character but a character may map to itself.
> 
> Example 1:
> 
> Input: s = "egg", t = "add"
> 
> Output: true
> 
> Example 2:
> 
> Input: s = "foo", t = "bar"
> 
> Output: false
> 
> Example 3:
> 
> Input: s = "paper", t = "title"
> 
> Output: true

判断两个字符串结构是否相同

```java
public boolean isIsomorphic(String s, String t) {
    Map m = new HashMap();
    for (Integer i = 0; i < s.length(); i++) {
        if (m.put(s.charAt(i), i) != m.put(t.charAt(i) + "", i)) {
            return false;
        }
    }
    return true;
}
```