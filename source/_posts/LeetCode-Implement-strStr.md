---
title: LeetCode - Implement strStr
date: 2019-04-09 18:03:47
categories:
- 工作
tags:
- LeetCode
- Java
- 算法
---

> Implement strStr().
> 
> Return the index of the first occurrence of needle in haystack, or -1 if needle is not part of haystack.
> 
> Example 1:
> 
> Input: haystack = "hello", needle = "ll"
> Output: 2
> Example 2:
> 
> Input: haystack = "aaaaa", needle = "bba"
> Output: -1

---

```java
public int strStr(String haystack, String needle) {
    if (null == haystack) return 0;
    if (null == needle || needle.length() == 0) return 0;
    if (needle.length() > haystack.length()) return -1;
    int m = haystack.length(), n = needle.length();
    for (int i = 0; i < m - n + 1; i++) {
        int j = 0;
        for (; j < n; j++) {
            if (haystack.charAt(i+j) != needle.charAt(j)) break;
        }
        if (j == n) return i;
    }
    return -1;
}

public static void main(String[] args) {
    String str = "bcdefgabcdabc";
    int index = new ImplementStrStr().strStr(str, "abc");
    // index:6
    System.out.println("index:" + index);
}
```
