---
layout: post
title: "单调栈详解：从入门到实践"
date: 2025-02-09
tags: "算法 栈 数据结构"
category: 
---

## 背景介绍

在计算机科学中，我们经常需要解决"找到数组中下一个更大/更小元素"、"寻找数组中的模式"等问题。传统的方法可能需要嵌套循环，时间复杂度达到O(n²)。单调栈的出现为这类问题提供了一个优雅且高效的解决方案。

## 基本概念

### 什么是单调栈？

单调栈是一种特殊的栈结构，其中的元素保持单调递增或单调递减的顺序。与普通栈相比，单调栈在插入新元素时会维护这种单调性，必要时会弹出栈顶元素。

### 单调栈的类型

1. **单调递增栈**
   - 从栈底到栈顶元素单调递增
   - 用于找下一个更小的元素

2. **单调递减栈**
   - 从栈底到栈顶元素单调递减
   - 用于找下一个更大的元素

## 特性分析

### 1. 数据特性
- 保持元素的单调性
- 自动移除不满足单调性的元素
- 栈内元素个数动态变化

### 2. 性能特性
- 时间复杂度：O(n)
- 空间复杂度：O(n)
- 每个元素最多入栈和出栈一次

### 3. 操作特性
- 入栈时维护单调性
- 出栈时保持数据完整性
- 支持快速查找特定模式

## 工作原理

### 单调递增栈的工作流程

```swift
// 示意图：处理序列 [3, 1, 4, 2]
// 步骤1: [3]
// 步骤2: [1]        // 3被弹出
// 步骤3: [1, 4]
// 步骤4: [1, 2]     // 4被弹出
```

### 单调递减栈的工作流程

```swift
// 示意图：处理序列 [3, 1, 4, 2]
// 步骤1: [3]
// 步骤2: [3, 1]
// 步骤3: [4]        // 3,1被弹出
// 步骤4: [4, 2]
```

## Swift 实现

### 基础实现

```swift
struct MonotonicStack<T: Comparable> {
    private var stack: [T] = []
    private let isIncreasing: Bool
    
    init(increasing: Bool = true) {
        self.isIncreasing = increasing
    }
    
    // 核心方法：维护单调性的入栈操作
    mutating func push(_ element: T) {
        while let top = stack.last,
              (isIncreasing && top > element) ||
              (!isIncreasing && top < element) {
            stack.removeLast()
        }
        stack.append(element)
    }
    
    // 辅助方法
    var isEmpty: Bool { stack.isEmpty }
    var peek: T? { stack.last }
    var elements: [T] { stack }
    
    mutating func pop() -> T? {
        stack.popLast()
    }
}
```

### 增强版实现

```swift
class EnhancedMonotonicStack<T: Comparable> {
    // 存储元素及其索引
    private var stack: [(element: T, index: Int)] = []
    private let isIncreasing: Bool
    
    init(increasing: Bool = true) {
        self.isIncreasing = increasing
    }
    
    func push(_ element: T, at index: Int) {
        while let last = stack.last,
              (isIncreasing && last.element > element) ||
              (!isIncreasing && last.element < element) {
            // 可以在这里处理被弹出的元素
            handlePoppedElement(last)
            stack.removeLast()
        }
        stack.append((element, index))
    }
    
    private func handlePoppedElement(_ element: (element: T, index: Int)) {
        // 这个方法是一个回调函数，可以在元素被弹出栈时进行自定义处理
        // 例如:
        // 1. 记录被弹出元素的下一个更大/更小元素
        // 2. 计算当前元素与被弹出元素的距离
        // 3. 统计被弹出元素在栈中停留的时间
        // 具体的处理逻辑需要根据实际业务场景来实现
    }
    
    // 其他辅助方法...
}
```

## 使用场景

### 1. 下一个更大元素
查找数组中每个元素的下一个更大元素。

```swift
func nextGreaterElements(_ nums: [Int]) -> [Int] {
    var result = Array(repeating: -1, count: nums.count)
    var stack: [(index: Int, value: Int)] = []
    
    for (i, num) in nums.enumerated() {
        while let last = stack.last, num > last.value {
            result[last.index] = num
            stack.removeLast()
        }
        stack.append((i, num))
    }
    
    return result
}

// 测试
let nums = [2, 1, 2, 4, 3]
print(nextGreaterElements(nums)) // [4, 2, 4, -1, -1]
```

### 2. 温度问题
查找每日温度后第一个更高温度的等待天数。

```swift
func dailyTemperatures(_ temperatures: [Int]) -> [Int] {
    var result = Array(repeating: 0, count: temperatures.count)
    var stack: [(index: Int, temp: Int)] = []
    
    for (i, temp) in temperatures.enumerated() {
        while let last = stack.last, temp > last.temp {
            let waitDays = i - last.index
            result[last.index] = waitDays
            stack.removeLast()
        }
        stack.append((i, temp))
    }
    
    return result
}

// 测试
let temps = [73, 74, 75, 71, 69, 72, 76, 73]
print(dailyTemperatures(temps)) // [1, 1, 4, 2, 1, 1, 0, 0]
```

### 3. 直方图最大矩形
计算直方图中最大的矩形面积。

```swift
func largestRectangleArea(_ heights: [Int]) -> Int {
    var maxArea = 0
    var stack: [(index: Int, height: Int)] = []
    
    for (i, height) in heights.enumerated() {
        var start = i
        
        while let last = stack.last, height < last.height {
            let width = i - last.index
            maxArea = max(maxArea, last.height * width)
            start = last.index
            stack.removeLast()
        }
        
        stack.append((start, height))
    }
    
    // 处理栈中剩余元素
    let totalWidth = heights.count
    while let last = stack.last {
        let width = totalWidth - last.index
        maxArea = max(maxArea, last.height * width)
        stack.removeLast()
    }
    
    return maxArea
}
```

## 优化技巧

### 1. 性能优化

```swift
// 预分配空间
var stack = ContiguousArray<Int>()
stack.reserveCapacity(expectedSize)

// 使用值类型
struct StackElement: Comparable {
    let index: Int
    let value: Int
    
    static func < (lhs: StackElement, rhs: StackElement) -> Bool {
        lhs.value < rhs.value
    }
}
```

### 2. 内存优化

```swift
// 使用元组减少内存占用
typealias StackElement = (index: Int, value: Int)

// 重用数组
class MonotonicStackOptimized {
    private var storage: [Int]
    private var count: Int = 0
    
    init(capacity: Int) {
        storage = Array(repeating: 0, count: capacity)
    }
}
```

### 3. 代码优化

```swift
// 使用泛型增加复用性
struct GenericMonotonicStack<T: Comparable> {
    private var stack: [T] = []
    private let comparator: (T, T) -> Bool
    
    init(comparator: @escaping (T, T) -> Bool) {
        self.comparator = comparator
    }
}
```

## 实践建议

1. **选择合适的单调性**
   - 根据问题需求选择递增或递减
   - 考虑是否需要处理相等元素

2. **处理边界情况**
   - 空栈的处理
   - 数组边界的处理
   - 重复元素的处理

3. **优化考虑**
   - 时间效率
   - 空间使用
   - 代码可维护性

## 总结

单调栈是一个强大而优雅的数据结构，它通过维护栈的单调性来高效解决特定类型的问题。关键要点：

1. 理解单调栈的核心特性
2. 掌握维护单调性的方法
3. 熟练运用在实际问题中
4. 注意优化和边界处理

通过本文的学习，你应该能够：
- 理解单调栈的工作原理
- 实现基本的单调栈结构
- 运用单调栈解决实际问题
- 优化单调栈的实现

## 参考资源

1. LeetCode相关题目
2. 数据结构与算法教程
3. Swift官方文档

希望这篇详细的教程能帮助你更好地理解和使用单调栈这一数据结构。 