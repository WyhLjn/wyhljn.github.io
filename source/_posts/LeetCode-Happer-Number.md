---
title: LeetCode - Happer Number
date: 2019-07-23 17:25:15
categories:
- 工作
tags:
- LeetCode
- Java
- 算法
---
> Write an algorithm to determine if a number is "happy".
> 
> A happy number is a number defined by the following process: Starting with any positive integer, replace the number by the sum of the squares of its digits, and repeat the process until the number equals 1 (where it will stay), or it loops endlessly in a cycle which does not include 1. Those numbers for which this process ends in 1 are happy numbers.
> 
> Example: 
> 
> Input: 19
> 
> Output: true
> 
> Explanation: 
>
> 1² + 9² = 82
>
> 8² + 2² = 68
>
> 6² + 8² = 100
>
> 1² + 0² + 0² = 1

题解：一个数满足多次平方和之后等于1


```java
public boolean isHappy(int n) {
    HashSet<Integer> hashSet = new HashSet<>();
    while (!hashSet.contains(n)) {
        hashSet.add(n);
        int temp = 0;
        while (n > 0) {
            temp += Math.pow(n % 10, 2);
            n /= 10;
        }
        n = temp;
    }

    return n == 1;
}
```