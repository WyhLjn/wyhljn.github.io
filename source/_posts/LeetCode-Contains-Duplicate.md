---
title: LeetCode - Contains Duplicate
date: 2019-07-29 16:45:07
categories:
- 工作
tags:
- LeetCode
- Java
- 算法
---
> Given an array of integers, find if the array contains any duplicates.
> 
> Your function should return true if any value appears at least twice in the array, and it should return false if every element is distinct.
> 
> Example 1:
> 
> Input: [1,2,3,1]
> 
> Output: true
> 
> Example 2:
> 
> Input: [1,2,3,4]
> 
> Output: false
> 
> Example 3:
> 
> Input: [1,1,1,3,3,4,3,2,4,2]
> 
> Output: true


```java
public boolean containsDuplicate(int[] nums) {
    if (nums == null || nums.length == 1) {
        return false;
    }
    Set<Integer> set = new HashSet<>(nums.length);
    for (int i = 0; i < nums.length; i++) {
        if (!set.add(nums[i])) {
            return true;
        }
    }
    return false;
}
```