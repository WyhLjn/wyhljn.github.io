---
title: LeetCode Valid Parentheses
date: 2019-03-19 18:54:04
categories:
- 工作
tags:
- LeetCode
- Java
- 算法
---

> Given a string containing just the characters '(', ')', '{', '}', '[' and ']', determine if the input string is valid.
> 
> An input string is valid if:
> 
> Open brackets must be closed by the same type of brackets.
> Open brackets must be closed in the correct order.
> Note that an empty string is also considered valid.
> 
> Example 1:
> 
> Input: "()"
> Output: true
> 
> Example 2:
> 
> Input: "()[]{}"
> Output: true
> 
> Example 3:
> 
> Input: "(]"
> Output: false
> 
> Example 4:
> 
> Input: "([)]"
> Output: false
> 
> Example 5:
> 
> Input: "{[]}"
> Output: true

---
<!-- more -->


```
public boolean isValid(String s) {
    if (null == s | "" == s || s.toCharArray().length == 1) return false;

    // 基于栈的结构，必须是反着的
    Map<Character, Character> mappings = new HashMap<>();
    mappings.put(')', '(');
    mappings.put('}', '{');
    mappings.put(']', '[');

    Stack<Character> stack = new Stack<>();

    for (int i = 0; i < s.length(); i++) {
        char c = s.charAt(i);
        if (mappings.containsKey(c)) {
            char topElement = stack.isEmpty() ? '#' : stack.pop();
            if (!mappings.get(c).equals(topElement)) {
                return false;
            }
        }
        else {
            stack.push(c);
        }
    }

    return stack.isEmpty();
}

public static void main(String[] args) {
    String testStr = "[({})]";
    // Valid Parentheses:true
    System.out.println("Valid Parentheses:" + new ValidParentheses().isValid(testStr));
}

```