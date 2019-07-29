---
title: LeetCode - House Robber
date: 2019-07-23 17:24:42
categories:
- 工作
tags:
- LeetCode
- Java
- 算法
---
> You are a professional robber planning to rob houses along a street. Each house has a certain amount of money stashed, the only constraint stopping you from robbing each of them is that adjacent houses have security system connected and it will automatically contact the police if two adjacent houses were broken into on the same night.
> 
> Given a list of non-negative integers representing the amount of money of each house, determine the maximum amount of money you can rob tonight without alerting the police.
> 
> Example 1:
> 
> 
> Input: [1,2,3,1]
> 
> Output: 4
> 
> Explanation: Rob house 1 (money = 1) and then rob house 3 (money = 3).
>              Total amount you can rob = 1 + 3 = 4.
>              
> Example 2:
> 
> 
> Input: [2,7,9,3,1]
> 
> Output: 12
> Explanation: Rob house 1 (money = 2), rob house 3 (money = 9) and rob house 5 (money = 1).
>              Total amount you can rob = 2 + 9 + 1 = 12.
> 

题解：求相互不相邻的数的和的最大值


```java
public int rob(int[] nums) {
    int pre = 0, cur = 0;
    for (int num : nums) {
        int temp = Math.max(pre + num, cur);
        pre = cur;
        cur = temp;
    }
    return cur;
}

public static void main(String[] args) {
    int[] nums = new int[]{2, 7, 9, 3, 1, 5};
    // maximum amount is :16
    System.out.println("maximum amount is :" + new HouseRobber().rob(nums));
}
```
