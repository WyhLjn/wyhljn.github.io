---
title: LeetCode - Count Primes
date: 2019-07-26 18:44:22
categories:
- 工作
tags:
- LeetCode
- Java
- 算法
---
> Count the number of prime numbers less than a non-negative number, n.
> 
> Example:
> 
> Input: 10
> 
> Output: 4
> 
> Explanation: There are 4 prime numbers less than 10, they are 2, 3, 5, 7.

统计小于目标数的质数的个数

```java
public int countPrimes(int n) {
    boolean[] notPrime = new boolean[n];
    int count = 0;
    for (int i = 2; i < n; i++) {
        if (notPrime[i] == false) {
            count++;
            for (int j = 2; j * i < n; j++) {
                notPrime[j * i] = true;
            }
        }
    }
    return count;
}
```