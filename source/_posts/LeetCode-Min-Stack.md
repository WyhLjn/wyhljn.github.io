---
title: LeetCode - Min Stack
date: 2019-05-22 18:26:40
categories:
- 工作
tags:
- LeetCode
- Java
- 算法
---
> Design a stack that supports push, pop, top, and retrieving the minimum element in constant time.
> 
> push(x) -- Push element x onto stack.
> 
> pop() -- Removes the element on top of the stack.
> 
> top() -- Get the top element.
> 
> getMin() -- Retrieve the minimum element in the stack.
> 
> Example:
> 
> MinStack minStack = new MinStack();
> 
> minStack.push(-2);
> 
> minStack.push(0);
> 
> minStack.push(-3);
> 
> minStack.getMin();   --> Returns -3.
> 
> minStack.pop();
> 
> minStack.top();      --> Returns 0.
> 
> minStack.getMin();   --> Returns -2.

---

```java
class MinStack {

    /** initialize your data structure here. */
    Stack<Integer> stack;
    
    Stack<Integer> min;

    public MinStack() {
        stack = new Stack<>();
        min = new Stack<>();
    }

    public void push(int x) {
        stack.push(x);
        if (min.isEmpty() || x <= min.peek()) {
            min.push(x);
        }
    }

    public void pop() {
        if (stack.peek().equals(min.peek())) {
            stack.pop();
            min.pop();
        }
        else {
            stack.pop();
        }
    }

    public int top() {
        return stack.peek();
    }

    public int getMin() {
        return min.peek();
    }
}
```