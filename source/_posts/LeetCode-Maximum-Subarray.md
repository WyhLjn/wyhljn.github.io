---
title: LeetCode - Maximum Subarray
date: 2019-04-17 18:51:21
categories:
- 工作
tags:
- LeetCode
- Java
- 算法

---

> Given an integer array nums, find the contiguous subarray (containing at least one number) which has the largest sum and return its sum.
> 
> Example:
> 
> Input: [-2,1,-3,4,-1,2,1,-5,4],
> Output: 6
> Explanation: [4,-1,2,1] has the largest sum = 6.


```java

public int maxSubArray(int[] nums) {
    if (null == nums || nums.length == 0) {
        return 0;
    }
    int ret = Integer.MIN_VALUE, temp_sum = 0;
    for (int num : nums) {
        temp_sum = Math.max(num + temp_sum, num);
        ret = Math.max(ret, temp_sum);
    }
    return ret;
}

public static void main(String[] args) {
    int[] nums = {-2, 1, -3, 4, -1, 2, 1, -5, 4};
    // 6
    System.out.println(new MaximumSubarray().maxSubArray(nums));
}

```