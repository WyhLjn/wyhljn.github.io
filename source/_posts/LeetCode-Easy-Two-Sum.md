---
title: LeetCode-Easy Two Sum
date: 2019-03-07 11:54:30
categories:
- 工作
tags:
- LeetCode
- Java
- 算法
---

> Given an array of integers, return indices of the two numbers such that they add up to a specific target.
> 
> You may assume that each input would have exactly one solution, and you may not use the same element twice.
> 
> Example:
> 
> Given nums = [2, 7, 11, 15], target = 9,
> 
> Because nums[0] + nums[1] = 2 + 7 = 9,
> return [0, 1].

---

<!-- more -->

```

public static int[] twoSum(int[] nums, int target) {
        Map<Integer, Integer> map = new HashMap<>();
        for (int i = 0 ; i < nums.length; i++) {
            int ret = target - nums[i];
            if (map.containsKey(ret)) {
                return new int[]{map.get(ret), i};
            }
            map.put(nums[i], i);
        }
        return new int[0];
    }

    public static void main(String[] args) {
        int[] nums = {1, 3, 5, 6, 9, 10};
        int target = 12;
        int[] result = twoSum(nums, target);
        // 1:4
        System.out.println(result[0] + ":" + result[1]);
    }

```
