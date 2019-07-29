---
title: LeetCode - Reverse Bits
date: 2019-07-17 18:46:47
categories:
- 工作
tags:
- LeetCode
- Java
- 算法
---
> Reverse bits of a given 32 bits unsigned integer.
> 
> Example 1:
> 
> Input: 00000010100101000001111010011100
>
> Output: 00111001011110000010100101000000
>
> Explanation: The input binary string 00000010100101000001111010011100 represents the unsigned integer 43261596, so return 964176192 which its binary representation is 00111001011110000010100101000000.
>
>
> Example 2:
> 
> Input: 11111111111111111111111111111101
>
> Output: 10111111111111111111111111111111
>
> Explanation: The input binary string 11111111111111111111111111111101 represents the unsigned integer 4294967293, so return 3221225471 which its binary representation is 10101111110010110010011101101001.


```java
public int reverseBits(int n) {
    int ret = 0;
    for (int i = 0; i < 32; i++, n >>= 1) {
        // n >>= 1，每次右移一位
        // n & 1，用来取最后一位
        // ret左移之后肯定是0，“或运算”保留原值
        ret = ret << 1 | (n & 1);
    }
    return ret;
}

```