---
title: LeetCode - Two Sum II
date: 2019-07-12 18:41:32
categories:
- 工作
tags:
- LeetCode
- Java
- 算法
---
> Given an array of integers that is already sorted in ascending order, find two numbers such that they add up to a specific target number.
> 
> The function twoSum should return indices of the two numbers such that they add up to the target, where index1 must be less than index2.
> 
> Note:
> 
> Your returned answers (both index1 and index2) are not zero-based.
> You may assume that each input would have exactly one solution and you may not use the same element twice.
> 
> Example:
> 
> Input: numbers = [2,7,11,15], target = 9
> Output: [1,2]
> Explanation: The sum of 2 and 7 is 9. Therefore index1 = 1, index2 = 2.

题解：题目意思是给定一个排序的数组，如果数组中存在两个数的和等于给定的数，返回它们的索引，并且保证第一个数小于第二个数


```java
public int[] twoSum(int[] numbers, int target) {
    int start = 0, end = numbers.length - 1;
    while (start < end) {
        if (numbers[start] + numbers[end] == target) {
            break;
        }
        if (numbers[start] + numbers[end] < target) {
            start ++;
        }
        else {
            end --;
        }
    }
    return new int[]{start + 1, end + 1};
}

```