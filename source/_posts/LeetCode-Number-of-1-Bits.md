---
title: LeetCode - Number of 1 Bits
date: 2019-07-17 18:50:32
categories:
- 工作
tags:
- LeetCode
- Java
- 算法
---
> Write a function that takes an unsigned integer and return the number of '1' bits it has (also known as the Hamming weight).
> 
>  
> 
> Example 1:
> 
> Input: 00000000000000000000000000001011
>
> Output: 3
>
> Explanation: The input binary string 00000000000000000000000000001011 has a total of three '1' bits.
>
>
> Example 2:
> 
> Input: 00000000000000000000000010000000
>
> Output: 1
>
> Explanation: The input binary string 00000000000000000000000010000000 has a total of one '1' bit.
>
>
> Example 3:
> 
> Input: 11111111111111111111111111111101
>
> Output: 31
>
> Explanation: The input binary string 11111111111111111111111111111101 has a total of thirty one '1' bits


```java
public int hammingWeight(int n) {
    int num = 0;
    int baseNum = 1;
    for (int i = 0; i < 32; i++, n >>= 1) {
        if ((baseNum & n) == 1) {
            num ++;
        }
    }
    return num;
}

public static void main(String[] args) {
    int n = 11;
    // number of 1 bits:3
    System.out.println("number of 1 bits:" + new NumberOfOneBits().hammingWeight(n));
}
```