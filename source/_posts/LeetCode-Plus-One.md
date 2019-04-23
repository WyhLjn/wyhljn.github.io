---
title: LeetCode - Plus One
date: 2019-04-23 18:22:40
categories:
- 工作
tags:
- LeetCode
- Java
- 算法
---
> Given a non-empty array of digits representing a non-negative integer, plus one to the integer.
> 
> The digits are stored such that the most significant digit is at the head of the list, and each element in the array contain a single digit.
> 
> You may assume the integer does not contain any leading zero, except the number 0 itself.
> 
> Example 1:
> 
> Input: [1,2,3]
> Output: [1,2,4]
> Explanation: The array represents the integer 123.
> 
> Example 2:
> 
> Input: [4,3,2,1]
> Output: [4,3,2,2]
> Explanation: The array represents the integer 4321.


```java
public int[] plusOne(int[] digits) {
    if (null == digits) return new int[]{};
    for (int i = digits.length - 1; i >=0 ; i--) {
        if (digits[i] == 9) {
            digits[i] = 0;
            continue;
        }
        else {
            digits[i] += 1;
            break;
        }
    }
    if (digits[0] == 0) {
        int[] ret = new int[digits.length + 1];
        ret[0] = 1;
        return ret;
    }
    else {
        return digits;
    }
}

public static void main(String[] args) {
    int[] digits = {1, 0, 9, 9};
    int[] ret = new PlusOne().plusOne(digits);
    // 1100
    for (int i = 0; i < ret.length; i++) {
        System.out.println(ret[i] + "");
    }
}

```
