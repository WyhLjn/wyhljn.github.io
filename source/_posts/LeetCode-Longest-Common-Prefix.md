---
title: LeetCode - Longest Common Prefix
date: 2019-03-18 19:06:44
categories:
- 工作
tags:
- LeetCode
- Java
- 算法
---

> Write a function to find the longest common prefix string amongst an array of strings.
> 
> If there is no common prefix, return an empty string "".
> 
> Example 1:
> 
> Input: ["flower","flow","flight"]
> Output: "fl"
> 
> Example 2:
> 
> Input: ["dog","racecar","car"]
> Output: ""
> Explanation: There is no common prefix among the input strings.
> 
> Note:
> 
> All given inputs are in lowercase letters a-z.

---

<!-- more -->

```
public String longestCommonPrefix(String[] strs) {

    if (null == strs || strs.length == 0) return "";
    if (strs.length == 1) return strs[0];

    // 找到长度最小字符串，减少循环次数
    int minLength = strs[0].length();
    for (int i = 1; i < strs.length; i++) {
        minLength = Math.min(strs[i].length(), minLength);
    }
    if (minLength == 0) return "";
    int end = 1;
    for (; end <= minLength ; end++) {
        for (String str : strs) {
            // 每次循环和strs[0]比较
            String temp = strs[0].substring(0, end);
            if (!str.substring(0, end).equals(temp))
                return strs[0].substring(0, end - 1);
        }
    }

    return strs[0].substring(0, end - 1);
}

public static void main(String[] args) {
    String[] strs = {"felle", "felleasdgasdg", "felleasdg"};
    // longest common prefix:felle
    System.out.println("longest common prefix:" + new LongestCommonPrefix().longestCommonPrefix(strs));
}

```