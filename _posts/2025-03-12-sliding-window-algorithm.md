---
layout: post
title: "滑动窗口算法详解：从入门到精通"
date: 2025-04-15
tags: "算法 滑动窗口 双指针 字符串 数组 子数组 子串"
category: 算法
---

## 一、基本概念

### 1. 什么是滑动窗口算法？

滑动窗口算法是一种在线性时间内解决数组/字符串问题的技术，其核心思想是：
- 维护一个可变大小的"窗口"，窗口在数据结构上从左到右滑动
- 窗口内包含问题所需的部分或全部元素
- 通过调整窗口的左右边界，避免重复计算，降低时间复杂度

这就像在火车上透过窗户观景：
- 窗户（窗口）限定了你的视野范围
- 随着火车前进，窗口不断向前滑动
- 窗外的风景（数据）在不断变化
- 你只需关注窗口内的内容

### 2. 滑动窗口的类型

滑动窗口主要分为两种类型：

#### a) 固定大小的滑动窗口
- 窗口大小固定不变（如始终为k个元素）
- 窗口以固定步长向前滑动
- 适用于求解特定长度的子数组/子串问题

例如：计算数组中所有长度为k的连续子数组的最大和

#### b) 可变大小的滑动窗口
- 窗口大小可以动态调整
- 根据特定条件扩大或缩小窗口
- 适用于求解满足某些条件的最长/最短子数组/子串

例如：求解最长无重复字符的子串

### 3. 为什么需要学习滑动窗口算法？

1. **提高效率**
   - 将暴力解法的O(n²)或更高复杂度优化为O(n)
   - 避免重复计算，一次遍历即可解决问题
   - 空间复杂度通常为O(1)或O(k)，k为字符集大小

2. **解决实际问题**
   - 网络流量监控
   - 股票价格分析
   - 数据流处理
   - 字符串匹配

3. **面试高频题型**
   - 技术面试中的常见考点
   - 考察对高效算法的理解
   - 测试优化思维能力

## 二、滑动窗口的基本原理

### 1. 滑动窗口的工作流程

滑动窗口算法的基本流程如下：

1. **初始化窗口**：设置左右指针（通常初始值都为0）
2. **扩展窗口**：右指针向右移动，将新元素纳入窗口
3. **窗口处理**：根据窗口内的元素更新结果
4. **收缩窗口**：左指针向右移动，将元素移出窗口
5. **重复步骤2-4**：直到右指针到达数组/字符串的末尾

```swift
// 滑动窗口的基本框架
func slidingWindow(_ array: [Int]) -> Int {
    var left = 0
    var right = 0
    var result = 0
    
    while right < array.count {
        // 扩大窗口
        // 将array[right]添加到窗口中
        right += 1
        
        // 根据题目要求，判断窗口是否需要收缩
        while (窗口需要收缩) {
            // 将array[left]移出窗口
            left += 1
        }
        
        // 更新结果
        result = max(result, right - left)
    }
    
    return result
}
``` 

### 2. 滑动窗口的可视化

为了更好地理解滑动窗口，我们通过一个简单的例子来可视化这个过程：

假设我们需要找出数组 `[2, 3, 1, 2, 4, 3]` 中和至少为7的最短子数组长度。

```
步骤1：初始化窗口
[2, 3, 1, 2, 4, 3]
 ↑
left=right=0，窗口为空

步骤2：扩展窗口直到满足条件（和≥7）
[2, 3, 1, 2, 4, 3]
 ↑        ↑
left=0, right=3，窗口内元素：[2,3,1,2]，和为8≥7

步骤3：尝试收缩窗口，同时保持条件满足
[2, 3, 1, 2, 4, 3]
    ↑     ↑
left=1, right=3，窗口内元素：[3,1,2]，和为6<7，不满足条件

步骤4：继续扩展窗口
[2, 3, 1, 2, 4, 3]
    ↑        ↑
left=1, right=4，窗口内元素：[3,1,2,4]，和为10≥7

步骤5：再次尝试收缩窗口
[2, 3, 1, 2, 4, 3]
       ↑     ↑
left=2, right=4，窗口内元素：[1,2,4]，和为7≥7，满足条件

步骤6：继续收缩
[2, 3, 1, 2, 4, 3]
          ↑  ↑
left=3, right=4，窗口内元素：[2,4]，和为6<7，不满足条件

... 以此类推
```

通过这种方式，我们只需要遍历一次数组，就能找到满足条件的最短子数组，时间复杂度为O(n)。

### 3. 滑动窗口的常见实现方式

#### a) 使用哈希表跟踪窗口内的元素

当需要跟踪窗口内的元素频率或其他属性时，哈希表是一个很好的选择：

```swift
func slidingWindowWithHashMap(_ s: String) -> Int {
    var map = [Character: Int]() // 字符 -> 出现次数
    var left = 0
    var right = 0
    var result = 0
    
    let chars = Array(s)
    
    while right < chars.count {
        // 扩大窗口
        let rightChar = chars[right]
        map[rightChar, default: 0] += 1
        right += 1
        
        // 收缩窗口
        while (需要收缩的条件) {
            let leftChar = chars[left]
            map[leftChar, default: 0] -= 1
            if map[leftChar] == 0 {
                map.removeValue(forKey: leftChar)
            }
            left += 1
        }
        
        // 更新结果
        result = max(result, right - left)
    }
    
    return result
}
```

#### b) 使用计数器跟踪窗口状态

对于简单的问题，使用计数器可能更为高效：

```swift
func slidingWindowWithCounter(_ nums: [Int], _ k: Int) -> Int {
    var sum = 0
    var maxSum = Int.min
    var left = 0
    
    for right in 0..<nums.count {
        // 扩大窗口
        sum += nums[right]
        
        // 当窗口大小达到k时
        if right - left + 1 > k {
            // 收缩窗口
            sum -= nums[left]
            left += 1
        }
        
        // 窗口大小为k时更新结果
        if right - left + 1 == k {
            maxSum = max(maxSum, sum)
        }
    }
    
    return maxSum
}
```

## 三、滑动窗口算法的应用场景

### 1. 适合使用滑动窗口的问题类型

滑动窗口算法特别适合解决以下类型的问题：

#### a) 查找满足特定条件的子数组/子串
- 最长/最短的满足条件的子数组
- 所有满足条件的子数组
- 子数组的最大/最小和或乘积

#### b) 字符串处理问题
- 查找符合特定模式的子串
- 最长无重复字符子串
- 包含特定字符的最小子串

#### c) 数组处理问题
- 连续子数组的最大/最小和
- 定长子数组的最大/最小值
- 元素种类或频率相关的子数组

#### d) 数据流问题
- 移动平均值
- 最近k个数据的统计信息
- 数据流中的极值

### 2. 不适合使用滑动窗口的问题

并非所有线性结构问题都适合滑动窗口，以下情况通常不适用：

- 不要求连续子序列的问题
- 需要考虑元素顺序的问题（不仅是包含关系）
- 需要多次遍历的问题

例如，"最长递增子序列"问题就不适合使用滑动窗口，因为子序列不要求连续。 

## 四、经典滑动窗口问题详解

在这一部分，我们将从简单到中等难度，选取几个经典的滑动窗口问题，详细分析解题思路和代码实现。

### 1. 简单题目：最大连续子数组和（固定窗口）

**问题描述**：
给定一个整数数组和一个整数k，找出长度为k的连续子数组的最大和。

**示例**：
```
输入: [1, 3, -1, -3, 5, 3, 6, 7], k = 3
输出: 16
解释: 连续子数组 [3, 6, 7] 的和为16，是所有长度为3的连续子数组中的最大和
```

**解题思路**：
1. 使用固定大小的滑动窗口
2. 维护一个大小为k的窗口，计算窗口中元素的和
3. 随着窗口滑动，更新最大和

```swift
func maxSumSubarrayOfSizeK(_ nums: [Int], _ k: Int) -> Int {
    guard nums.count >= k else { return 0 }
    
    // 计算初始窗口的和
    var currentSum = 0
    for i in 0..<k {
        currentSum += nums[i]
    }
    
    var maxSum = currentSum
    
    // 滑动窗口，每次移除一个元素并添加一个新元素
    for i in k..<nums.count {
        // 添加新元素并移除窗口最左侧的元素
        currentSum = currentSum + nums[i] - nums[i - k]
        // 更新最大和
        maxSum = max(maxSum, currentSum)
    }
    
    return maxSum
}

// 测试代码
let result = maxSumSubarrayOfSizeK([1, 3, -1, -3, 5, 3, 6, 7], 3)
print("最大连续子数组和: \(result)") // 输出: 16
```

**复杂度分析**：
- 时间复杂度：O(n)，只需遍历一次数组
- 空间复杂度：O(1)，只使用了常量级额外空间

**图解执行过程**：
```
数组: [1, 3, -1, -3, 5, 3, 6, 7], k = 3

初始窗口 [1, 3, -1]，和为 3
移动窗口 [3, -1, -3]，和为 -1
移动窗口 [-1, -3, 5]，和为 1
移动窗口 [-3, 5, 3]，和为 5
移动窗口 [5, 3, 6]，和为 14
移动窗口 [3, 6, 7]，和为 16

最大和为 16
```

### 2. 中等题目：[无重复字符的最长子串](https://leetcode.cn/problems/wtcaE1/)

**问题描述**：
给定一个字符串，找出不含有重复字符的最长子串的长度。

**示例**：
```
输入: "abcabcbb"
输出: 3
解释: 最长无重复字符子串是 "abc"，长度为 3

输入: "bbbbb"
输出: 1
解释: 最长无重复字符子串是 "b"，长度为 1
```

**解题思路**：
1. 使用可变大小的滑动窗口
2. 使用哈希表记录窗口内的字符及其位置
3. 当遇到重复字符时，更新窗口左边界

```swift
func lengthOfLongestSubstring(_ s: String) -> Int {
    let chars = Array(s)
    var charIndexMap = [Character: Int]() // 字符 -> 索引
    var left = 0
    var maxLength = 0
    
    for right in 0..<chars.count {
        // 如果当前字符已在窗口内，更新左边界
        if let previousIndex = charIndexMap[chars[right]], previousIndex >= left {
            left = previousIndex + 1
        }
        
        // 更新字符的最新位置
        charIndexMap[chars[right]] = right
        
        // 更新最大长度
        maxLength = max(maxLength, right - left + 1)
    }
    
    return maxLength
}

// 测试代码
let result1 = lengthOfLongestSubstring("abcabcbb")
print("最长无重复字符子串长度: \(result1)") // 输出: 3

let result2 = lengthOfLongestSubstring("bbbbb")
print("最长无重复字符子串长度: \(result2)") // 输出: 1
```

**复杂度分析**：
- 时间复杂度：O(n)，其中n是字符串的长度
- 空间复杂度：O(min(m, n))，其中m是字符集的大小，n是字符串的长度

**图解执行过程**：
```
字符串: "abcabcbb"

步骤1: 窗口 [a]，maxLength = 1
步骤2: 窗口 [a, b]，maxLength = 2
步骤3: 窗口 [a, b, c]，maxLength = 3
步骤4: 遇到重复字符'a'，窗口变为 [b, c, a]，maxLength = 3
步骤5: 遇到重复字符'b'，窗口变为 [c, a, b]，maxLength = 3
步骤6: 遇到重复字符'c'，窗口变为 [a, b, c]，maxLength = 3
步骤7: 遇到重复字符'b'，窗口变为 [c, b]，maxLength = 3
步骤8: 遇到重复字符'b'，窗口变为 [b]，maxLength = 3

最终结果为 3
```

### 3. 中等题目：[最小覆盖子串](https://leetcode.cn/problems/M1oyTv/submissions/609633285/)

**问题描述**：
给你一个字符串S、一个字符串T，请在S中找出包含T所有字符的最小子串。

**示例**：
```
输入: S = "ADOBECODEBANC", T = "ABC"
输出: "BANC"
解释: 包含字符'A'、'B'和'C'的最小子串是"BANC"
```

**解题思路**：
1. 使用可变大小的滑动窗口
2. 使用两个哈希表分别记录目标字符串的字符频率和窗口内的字符频率
3. 当窗口包含所有目标字符时，尝试收缩窗口左边界，同时更新最小长度

```swift
func minWindow(_ s: String, _ t: String) -> String {
    // 处理边界情况
    if s.isEmpty || t.isEmpty || s.count < t.count {
        return ""
    }
    
    let sChars = Array(s)
    
    // 记录目标字符串中字符的出现次数
    var targetFreq = [Character: Int]()
    for char in t {
        targetFreq[char, default: 0] += 1
    }
    
    var windowFreq = [Character: Int]()
    var required = targetFreq.count // 需要满足的不同字符数量
    var formed = 0 // 已经满足的不同字符数量
    
    var left = 0
    var right = 0
    
    // 记录最小窗口的开始索引和长度
    var minLength = Int.max
    var resultStart = 0
    
    while right < sChars.count {
        // 扩大窗口
        let rightChar = sChars[right]
        windowFreq[rightChar, default: 0] += 1
        
        // 如果当前字符是目标字符，且窗口中的频率刚好满足目标频率
        if let targetCount = targetFreq[rightChar], windowFreq[rightChar] == targetCount {
            formed += 1
        }
        
        // 尝试收缩窗口
        while left <= right && formed == required {
            // 更新最小窗口
            let currentLength = right - left + 1
            if currentLength < minLength {
                minLength = currentLength
                resultStart = left
            }
            
            // 收缩窗口
            let leftChar = sChars[left]
            windowFreq[leftChar, default: 0] -= 1
            
            // 如果移除的字符导致目标字符不满足
            if let targetCount = targetFreq[leftChar], windowFreq[leftChar]! < targetCount {
                formed -= 1
            }
            
            left += 1
        }
        
        right += 1
    }
    
    // 如果没有找到满足条件的窗口
    if minLength == Int.max {
        return ""
    }
    
    // 提取结果子串
    return String(sChars[resultStart..<(resultStart + minLength)])
}

// 测试代码
let result = minWindow("ADOBECODEBANC", "ABC")
print("最小覆盖子串: \(result)") // 输出: "BANC"
```

**复杂度分析**：
- 时间复杂度：O(n)，其中n是字符串S的长度
- 空间复杂度：O(m)，其中m是字符集的大小

**执行过程说明**：
以输入S = "ADOBECODEBANC", T = "ABC"为例：

1. 初始化目标字符频率：{'A':1, 'B':1, 'C':1}
2. 初始窗口为空，右指针从0开始扩展窗口
3. 当窗口包含所有目标字符时（"ADOBEC"），formed=3，尝试收缩窗口
4. 收缩左边界，更新最小窗口
5. 继续扩展窗口，重复上述过程
6. 最终找到最小窗口"BANC"

### 4. 中等题目：找到所有字母异位词

**问题描述**：
给定一个字符串s和一个非空字符串p，找出s中所有是p的字母异位词的子串，返回这些子串的起始索引。
字母异位词指字母相同但排列不同的字符串。

**示例**：
```
输入: s = "cbaebabacd", p = "abc"
输出: [0, 6]
解释:
起始索引为0的子串是"cba"，它是"abc"的字母异位词。
起始索引为6的子串是"bac"，它是"abc"的字母异位词。
```

**解题思路**：
1. 使用固定大小的滑动窗口，窗口大小等于模式串p的长度
2. 使用哈希表记录p中字符的频率和窗口内字符的频率
3. 只有当两个频率表完全匹配时，当前窗口是p的字母异位词

```swift
func findAnagrams(_ s: String, _ p: String) -> [Int] {
    let sChars = Array(s)
    let pChars = Array(p)
    
    // 如果s的长度小于p的长度，不可能存在异位词
    if sChars.count < pChars.count {
        return []
    }
    
    // 记录p中每个字符的频率
    var pFreq = [Character: Int]()
    for char in pChars {
        pFreq[char, default: 0] += 1
    }
    
    // 记录窗口中每个字符的频率
    var windowFreq = [Character: Int]()
    var result = [Int]()
    
    // 固定大小的滑动窗口
    for right in 0..<sChars.count {
        // 将右指针字符加入窗口
        let rightChar = sChars[right]
        windowFreq[rightChar, default: 0] += 1
        
        // 当窗口大小超过p的长度时，移除左指针字符
        let left = right - pChars.count
        if left >= 0 {
            let leftChar = sChars[left]
            windowFreq[leftChar, default: 0] -= 1
            
            // 如果字符频率为0，从哈希表中移除
            if windowFreq[leftChar] == 0 {
                windowFreq.removeValue(forKey: leftChar)
            }
        }
        
        // 检查当前窗口是否是p的异位词
        if windowFreq == pFreq {
            result.append(right - pChars.count + 1)
        }
    }
    
    return result
}

// 测试代码
let result = findAnagrams("cbaebabacd", "abc")
print("字母异位词的起始索引: \(result)") // 输出: [0, 6]
```

**复杂度分析**：
- 时间复杂度：O(n)，其中n是字符串s的长度
- 空间复杂度：O(1)，因为字符集是固定的（最多26个小写字母）

**优化方案**：
为了避免每次比较两个哈希表，我们可以维护一个计数器，记录当前窗口中有多少字符的频率与目标频率匹配：

```swift
func findAnagramsOptimized(_ s: String, _ p: String) -> [Int] {
    let sChars = Array(s)
    let pChars = Array(p)
    
    if sChars.count < pChars.count {
        return []
    }
    
    var pFreq = [Character: Int]()
    var windowFreq = [Character: Int]()
    
    for char in pChars {
        pFreq[char, default: 0] += 1
    }
    
    var required = pFreq.count // 需要匹配的不同字符数量
    var formed = 0 // 已经匹配的不同字符数量
    var result = [Int]()
    
    for right in 0..<sChars.count {
        let rightChar = sChars[right]
        windowFreq[rightChar, default: 0] += 1
        
        // 如果当前字符在p中，并且频率匹配，formed加1
        if let targetCount = pFreq[rightChar], windowFreq[rightChar] == targetCount {
            formed += 1
        }
        
        // 移动左指针
        let left = right - pChars.count
        if left >= 0 {
            let leftChar = sChars[left]
            
            // 如果移除的字符会导致不再匹配，formed减1
            if let targetCount = pFreq[leftChar], windowFreq[leftChar] == targetCount {
                formed -= 1
            }
            
            windowFreq[leftChar, default: 0] -= 1
        }
        
        // 如果所有字符都匹配，添加起始索引
        if right >= pChars.count - 1 && formed == required {
            result.append(right - pChars.count + 1)
        }
    }
    
    return result
}
``` 

## 五、滑动窗口算法的实践建议

### 1. 识别滑动窗口问题的特征

要判断一个问题是否适合使用滑动窗口算法，可以寻找以下特征：

1. **连续性要求**：问题涉及连续子数组或子串
2. **最大/最小要求**：寻找满足某条件的最长/最短子数组
3. **约束条件**：子数组需要满足特定条件（和、元素频率等）
4. **线性扫描**：可以通过单次遍历解决问题

比如，当你看到类似"最长连续..."、"最短满足条件的子数组"、"包含所有字符的最小子串"等描述时，应该考虑滑动窗口算法。

### 2. 解题步骤模板

解决滑动窗口问题时，可以遵循以下步骤：

1. **确定滑动窗口类型**：固定大小或可变大小
2. **初始化窗口**：设置左右指针，初始化结果变量
3. **扩展窗口**：移动右指针，加入新元素
4. **满足条件时处理**：更新结果，考虑收缩窗口
5. **收缩窗口**：移动左指针，移除元素
6. **返回最终结果**

```swift
// 滑动窗口通用模板
func slidingWindowTemplate<T>(_ array: [T], _ condition: (T) -> Bool) -> Int {
    var left = 0
    var right = 0
    var result = 0
    
    while right < array.count {
        // 1. 扩展窗口，将array[right]加入窗口
        // 调整窗口状态
        
        right += 1
        
        // 2. 窗口满足条件时的处理
        while (满足收缩条件) {
            // 更新结果
            result = max/min(result, 当前值)
            
            // 3. 收缩窗口，将array[left]移出窗口
            // 调整窗口状态
            
            left += 1
        }
    }
    
    return result
}
```

### 3. 常见陷阱与解决方案

#### a) 窗口初始化

**陷阱**：忽略窗口的初始状态设置。
**解决方案**：确保正确初始化窗口变量和计数器。

```swift
// 错误示例
var left = 0, right = 0
// 没有初始化窗口的状态变量

// 正确示例
var left = 0, right = 0
var windowSum = 0 // 初始化窗口和
var windowFreq = [Character: Int]() // 初始化窗口频率表
```

#### b) 窗口边界更新

**陷阱**：窗口扩展和收缩的顺序错误。
**解决方案**：先处理窗口内的元素，再移动指针。

```swift
// 错误示例
right += 1
let rightChar = chars[right] // 可能导致数组越界

// 正确示例
let rightChar = chars[right]
// 处理rightChar
right += 1
```

#### c) 结果更新时机

**陷阱**：在错误的时机更新结果。
**解决方案**：根据问题要求，在适当的时机更新结果。

```swift
// 固定窗口大小的情况
if right - left + 1 == k {
    // 达到窗口大小时更新结果
    result = max(result, windowSum)
}

// 可变窗口大小的情况
while (窗口满足条件) {
    // 窗口满足条件时更新结果
    result = min(result, right - left)
    // 尝试收缩窗口
    left += 1
}
```

### 4. 性能优化技巧

#### a) 避免不必要的计算

某些情况下，我们可以在窗口滑动时增量更新结果，而不是每次重新计算：

```swift
// 低效方式
for right in 0..<array.count {
    var windowSum = 0
    for i in left...right {
        windowSum += array[i]
    }
    // 使用windowSum
}

// 高效方式
var windowSum = 0
for right in 0..<array.count {
    windowSum += array[right]
    if left > 0 {
        windowSum -= array[left - 1]
    }
    // 使用windowSum
}
```

#### b) 使用适当的数据结构

根据问题特点选择合适的数据结构：

- **哈希表**：跟踪元素频率
- **双端队列**：维护窗口内的最大/最小值
- **集合**：快速检查元素是否存在

#### c) 提前返回

对于特定场景，提前判断可以避免不必要的计算：

```swift
func minSubArrayLen(_ target: Int, _ nums: [Int]) -> Int {
    // 提前判断边界情况
    if nums.isEmpty { return 0 }
    
    // 计算数组总和，如果小于目标值，直接返回0
    let totalSum = nums.reduce(0, +)
    if totalSum < target { return 0 }
    
    // 如果单个元素就大于等于目标值，直接返回1
    if nums.contains(where: { $0 >= target }) { return 1 }
    
    // 剩余的滑动窗口逻辑
    // ...
}
```

## 六、总结与进阶

### 1. 滑动窗口算法的关键点

1. **双指针技巧**：使用左右指针定义窗口边界
2. **线性时间复杂度**：一般为O(n)，其中n为数组或字符串长度
3. **窗口状态管理**：高效地维护和更新窗口内的状态信息
4. **窗口调整策略**：根据问题要求动态调整窗口大小

### 2. 与其他算法的比较

| 算法 | 时间复杂度 | 空间复杂度 | 适用场景 |
|------|------------|------------|----------|
| 滑动窗口 | O(n) | O(1)或O(k) | 连续子数组/子串问题 |
| 双指针 | O(n) | O(1) | 两端操作、排序数组中的查找 |
| 前缀和 | O(n)预处理+O(1)查询 | O(n) | 区间和问题 |
| 动态规划 | 通常O(n²) | O(n)或O(n²) | 最优子结构问题 |

### 3. 滑动窗口的扩展应用

#### a) 多维滑动窗口

滑动窗口的概念可以扩展到二维矩阵中：

```swift
// 二维矩阵中的滑动窗口示例：计算大小为k×k的子矩阵的最大和
func maxSumSubmatrix(_ matrix: [[Int]], _ k: Int) -> Int {
    let rows = matrix.count
    let cols = matrix[0].count
    var maxSum = Int.min
    
    for left in 0..<cols {
        var rowSum = Array(repeating: 0, count: rows)
        
        for right in left..<cols {
            // 计算每行在left到right列之间的和
            for i in 0..<rows {
                rowSum[i] += matrix[i][right]
            }
            
            // 现在问题转化为一维数组中求大小为k的子数组最大和
            // 使用Kadane算法或一维滑动窗口
            let currentMaxSum = maxSubarraySum(rowSum, k)
            maxSum = max(maxSum, currentMaxSum)
        }
    }
    
    return maxSum
}
```

#### b) 滑动窗口与双指针结合

有些问题可能需要结合滑动窗口和其他双指针技巧：

```swift
// 三数之和问题的变种：找出和最接近target的三个数
func threeSumClosest(_ nums: [Int], _ target: Int) -> Int {
    let sortedNums = nums.sorted()
    var closestSum = sortedNums[0] + sortedNums[1] + sortedNums[2]
    
    for i in 0..<sortedNums.count - 2 {
        var left = i + 1
        var right = sortedNums.count - 1
        
        while left < right {
            let currentSum = sortedNums[i] + sortedNums[left] + sortedNums[right]
            
            if abs(currentSum - target) < abs(closestSum - target) {
                closestSum = currentSum
            }
            
            if currentSum < target {
                left += 1
            } else if currentSum > target {
                right -= 1
            } else {
                return target // 找到精确匹配
            }
        }
    }
    
    return closestSum
}
```

### 4. 进阶挑战题目

以下是一些进阶的滑动窗口问题，供读者练习：

#### a) [992. K个不同整数的子数组](https://leetcode.cn/problems/subarrays-with-k-different-integers/)

**问题描述**：
给定一个正整数数组 nums 和一个整数 k，返回 nums 中「好子数组」的数目。
如果 nums 的某个子数组中不同整数的个数恰好为 k，则称之为「好子数组」。

**示例**：
```
输入：nums = [1,2,1,2,3], k = 2
输出：7
解释：恰好由 2 个不同整数组成的子数组：[1,2], [2,1], [1,2], [2,3], [1,2,1], [2,1,2], [1,2,1,2]
```

**提示**：这个问题需要使用"恰好k个不同整数"转化为"最多k个不同整数"减去"最多k-1个不同整数"。

#### b) [76. 最小覆盖子串](https://leetcode.cn/problems/minimum-window-substring/)

**问题描述**：
给你一个字符串 s 、一个字符串 t 。返回 s 中涵盖 t 所有字符的最小子串。如果 s 中不存在涵盖 t 所有字符的子串，则返回空字符串 ""。

**提示**：本题已在上面详细解析过，读者可以尝试自己实现，并与标准解法比较。

#### c) [424. 替换后的最长重复字符](https://leetcode.cn/problems/longest-repeating-character-replacement/)

**问题描述**：
给你一个字符串 s 和一个整数 k 。你可以选择字符串中的任一字符，并将其更改为任何其他大写英文字符。该操作最多可执行 k 次。
在执行上述操作后，返回包含相同字母的最长子字符串的长度。

**示例**：
```
输入：s = "ABAB", k = 2
输出：4
解释：用两个'A'替换为两个'B',反之亦然，可以得到子串 "AAAA" 或 "BBBB"。
```

**挑战**：如何高效地维护窗口内的最大字符频率？

#### d) [438. 找到字符串中所有字母异位词](https://leetcode.cn/problems/find-all-anagrams-in-a-string/)

**问题描述**：
给定两个字符串 s 和 p，找到 s 中所有 p 的 异位词 的子串，返回这些子串的起始索引。不考虑答案输出的顺序。
异位词 指由相同字母重排列形成的字符串（包括相同的字符串）。

**提示**：本题已在上面详细解析过，读者可以尝试自己实现，并与标准解法比较。

#### e) [1004. 最大连续1的个数 III](https://leetcode.cn/problems/max-consecutive-ones-iii/)

**问题描述**：
给定一个二进制数组 nums 和一个整数 k，如果可以翻转最多 k 个 0 ，则返回 数组中连续 1 的最大个数。

**示例**：
```
输入：nums = [1,1,1,0,0,0,1,1,1,1,0], k = 2
输出：6
解释：[1,1,1,0,0,1,1,1,1,1,1] 翻转前面两个0即可得到最长的连续1。
```

**挑战**：如何在滑动窗口中高效跟踪翻转的0的数量？

## 七、实际面试中的应用

### 1. 面试官喜欢考察的滑动窗口变种

在面试中，面试官经常会变换题目条件或组合多个技巧来考察候选人的灵活应用能力：

1. **多条件滑动窗口**：窗口需要同时满足多个条件
2. **嵌套滑动窗口**：窗口内部再包含子窗口
3. **动态窗口大小**：窗口大小根据某些条件动态变化
4. **双向滑动窗口**：允许窗口两端同时扩展或收缩

### 2. 常见面试题变形

#### a) 带权重的滑动窗口

**问题示例**：给定一个权重数组和目标值，找出权重和等于目标值的最短子数组。

```swift
func shortestSubarrayWithSum(_ nums: [Int], _ target: Int) -> Int {
    var left = 0
    var sum = 0
    var minLength = Int.max
    
    for right in 0..<nums.count {
        sum += nums[right]
        
        while sum >= target {
            minLength = min(minLength, right - left + 1)
            sum -= nums[left]
            left += 1
        }
    }
    
    return minLength == Int.max ? 0 : minLength
}
```

#### b) 条件组合的滑动窗口

**问题示例**：找出同时包含特定数量的元素A和元素B的最短子数组。

```swift
func shortestSubarrayWithElements(_ nums: [Int], _ countA: Int, _ countB: Int) -> Int {
    var left = 0
    var currentA = 0
    var currentB = 0
    var minLength = Int.max
    
    for right in 0..<nums.count {
        // 更新窗口内元素计数
        if nums[right] == 1 {
            currentA += 1
        } else if nums[right] == 2 {
            currentB += 1
        }
        
        // 当窗口满足条件时尝试收缩
        while currentA >= countA && currentB >= countB {
            minLength = min(minLength, right - left + 1)
            
            // 更新左指针元素计数
            if nums[left] == 1 {
                currentA -= 1
            } else if nums[left] == 2 {
                currentB -= 1
            }
            
            left += 1
        }
    }
    
    return minLength == Int.max ? 0 : minLength
}
```

### 3. 面试技巧与解题策略

1. **了解问题类型**：快速识别问题是否适合滑动窗口
2. **从简单情况入手**：先考虑固定大小的窗口，再扩展到可变大小
3. **清晰表达思路**：向面试官解释滑动窗口的选择原因和具体实现步骤
4. **注意边界条件**：处理空数组、窗口大小超过数组长度等特殊情况
5. **考虑时间和空间效率**：说明算法的时间和空间复杂度
6. **测试示例**：用小型示例验证算法的正确性

### 4. 代码实现的完整性检查

在面试中实现滑动窗口算法时，需要确保以下几点：

- **变量初始化**：正确初始化左右指针和窗口状态变量
- **窗口扩展逻辑**：明确窗口如何扩展以及何时扩展
- **窗口收缩条件**：清晰定义何时收缩窗口及如何收缩
- **结果更新时机**：在适当的时机更新结果
- **边界条件处理**：处理特殊输入和边界情况
- **返回正确结果**：确保结果的格式和类型符合要求

## 八、总结

### 1. 滑动窗口算法的核心要点

1. **双指针技巧**：使用左右指针定义窗口边界
2. **线性时间复杂度**：只需遍历一次数组/字符串
3. **窗口状态管理**：高效地维护和更新窗口内的状态信息
4. **窗口调整策略**：根据问题要求动态调整窗口大小

### 2. 学习建议与进阶路径

1. **掌握基础模板**：理解并熟练应用滑动窗口的基本框架
2. **分类练习**：分别练习固定窗口和可变窗口的题目
3. **结合其他算法**：学习滑动窗口与哈希表、双指针等技巧的结合
4. **挑战复杂变种**：尝试解决多条件、多维度的滑动窗口问题
5. **归纳总结**：总结不同类型问题的共性和解题模式

### 3. 常见错误与避坑指南

1. **窗口边界错误**：注意指针移动的时机和顺序
2. **条件判断不清**：明确窗口扩展和收缩的条件
3. **状态更新遗漏**：确保窗口状态在扩展和收缩时都得到更新
4. **结果更新时机错误**：在合适的时机更新结果值
5. **特殊情况处理不当**：考虑空输入、单元素输入等边界情况

通过本文的学习，你应该能够掌握滑动窗口算法的核心思想和实现技巧，能够识别适合滑动窗口的问题，并能灵活应用这一强大工具解决各种实际问题。滑动窗口不仅是算法面试的热门题型，也是解决实际编程问题的有力武器。随着练习的深入，你将能够更加熟练地运用滑动窗口技巧，并将其与其他算法策略结合，解决更加复杂和多样化的问题。 