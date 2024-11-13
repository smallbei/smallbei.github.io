---
layout: post
title: "【LeetCode】14.最长公共前缀"
date: 2024-11-13
tags: "算法 数组 字符串 LeetCode"
category: 
---

在这篇文章中，我们将探讨如何使用 Swift 解决 LeetCode 上的经典问题——最长公共前缀。这个问题要求我们找出一个字符串数组中所有字符串共有的最长前缀。如果不存在公共前缀，则返回空字符串。这个问题在实际开发中非常常见，尤其是在处理字符串比较和文本处理时。

## 题目描述

给定一个字符串数组 `strs`，找出所有字符串中的最长公共前缀。

如果不存在公共前缀，返回空字符串 `""`。

**示例 1:**

```
输入: strs = ["flower","flow","flight"]
输出: "fl"
```

**示例 2:**

```
输入: strs = ["dog","racecar","car"]
输出: ""
解释: 输入不存在公共前缀。
```

## 算法实现

我们将使用 Swift 语言来实现这个问题的解决方案。我们的算法将通过比较字符串数组中的每个字符串，逐步找出最长的公共前缀。

```swift
// 定义函数 longestCommonPrefix，接受一个字符串数组 strs 并返回一个字符串
func longestCommonPrefix(_ strs: [String]) -> String {
    // 如果数组为空，直接返回空字符串
    if strs.count == 0 {
        return ""
    }
    
    // 假设数组的第一个字符串是公共前缀
    var prefix = strs[0]
    
    // 从数组的第二个元素开始遍历
    for i in 1..<strs.count {
        // 使用 commonPrefix 函数更新公共前缀
        prefix = commonPrefix(prefix, strs[i])
        // 如果公共前缀为空，直接返回空字符串，因为不可能有公共前缀了
        if prefix.isEmpty {
            break
        }
    }
    // 返回最终的公共前缀
    return prefix
}

// 定义函数 commonPrefix，接受两个字符串 str1 和 str2，并返回它们的公共前缀
func commonPrefix(_ str1: String, _ str2: String) -> String {
    // 初始化索引 i 为 0
    var i = 0
    
    // 使用 while 循环比较两个字符串的字符，直到到达任一字符串的末尾
    while i < str1.count && i < str2.count {
        // 获取两个字符串当前索引下的字符
        let index1 = str1.index(str1.startIndex, offsetBy: i)
        let index2 = str2.index(str2.startIndex, offsetBy: i)
        
        // 如果当前位置的字符不相等，则跳出循环
        if str1[index1] != str2[index2] {
            break
        }
        // 如果相等，索引 i 加 1，继续比较下一个字符
        i += 1
    }
    // 返回 str1 从开始到索引 i（不包括 i）的子串，即两个字符串的公共前缀
    return String(str1.prefix(i))
}

// 示例
print(longestCommonPrefix(["flower","flow","flight"])) // 输出: "fl"
print(longestCommonPrefix(["dog","racecar","car"]))   // 输出: ""
```

## 代码解释

`longestCommonPrefix` 函数首先检查输入数组是否为空，如果为空，则直接返回空字符串。它初始化 `prefix` 为数组的第一个字符串，并遍历数组中的其余字符串。对于每个字符串，它调用 `commonPrefix` 函数来更新 `prefix`。如果在任何时候 `prefix` 变为空字符串，循环将终止，因为这意味着没有公共前缀。

`commonPrefix` 函数比较两个字符串 `str1` 和 `str2`，直到它们不再匹配。它使用 `while` 循环和 `if` 语句来检查两个字符串在相同位置的字符是否相同。如果找到不匹配的字符，循环将终止，函数返回 `str1` 的前 `i` 个字符作为公共前缀。

## 时间复杂度和空间复杂度

**时间复杂度：** O(n * k)，其中 `n` 是字符串数组的长度，`k` 是数组中最短字符串的平均长度。这是因为我们需要在最坏的情况下比较数组中每个字符串的每个字符。

**空间复杂度：** O(1)，我们只需要一个固定大小的变量来存储公共前缀，因此空间复杂度是常数级别的。

