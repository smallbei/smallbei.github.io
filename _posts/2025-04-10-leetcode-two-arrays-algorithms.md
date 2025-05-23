---
layout: post
title: "LeetCode双数组问题详解：技巧与经典题目解析"
date: 2025-04-10
tags: "算法 LeetCode 数组 双指针 哈希表 排序"
category: 算法
---

## 一、引言

在LeetCode等算法练习平台中，涉及两个或多个数组的问题非常常见。这类问题不仅考察了对数组基本操作的掌握程度，更重要的是测试了算法思维、优化技巧以及对不同数据结构的灵活运用能力。从简单的查找交集、并集，到复杂的合并排序数组、寻找中位数等，双数组问题覆盖了多种经典的算法场景。

本文旨在系统性地梳理和讲解LeetCode中常见的双数组问题，主要内容包括：
- 双数组问题的常见类型分类
- 解决这些问题的核心算法技巧
- 精选经典题目进行深度解析
- 优化策略和常见陷阱
- 总结与进阶练习

通过本文的学习，希望能帮助你掌握处理双数组问题的通用方法，提高解题效率和代码质量。

## 二、双数组问题的常见类型

处理两个数组的问题时，通常可以根据问题的目标和约束条件将其分为几大类：

1.  **集合运算类**：
    *   求两个数组的交集（Intersection）
    *   求两个数组的并集（Union）
    *   求两个数组的差集（Difference）
    *   判断一个数组是否是另一个数组的子集

2.  **合并与排序类**：
    *   合并两个有序数组
    *   在两个有序数组中寻找第k小的元素
    *   寻找两个有序数组的中位数

3.  **查找与计数类**：
    *   在一个数组中查找另一个数组的元素
    *   统计满足特定条件的元素对（Pair）
    *   寻找两个数组中的共同元素或模式

4.  **比较与距离类**：
    *   计算两个数组之间的距离（如编辑距离的变种）
    *   比较两个数组的相似性
    *   寻找两个数组中最接近的元素对

理解问题的类型有助于我们快速选择合适的算法策略。例如，集合运算类问题通常适合使用哈希表，而合并与排序类问题则常用双指针或归并思想。

## 三、核心算法技巧

解决双数组问题时，以下几种算法技巧和数据结构最为常用：

### 1. 双指针 (Two Pointers)

双指针是处理数组问题，尤其是**有序数组**问题时的利器。通过维护两个（或多个）指针在数组中移动，可以在线性时间内完成查找、合并、比较等操作。

**典型应用场景**：
- **合并两个有序数组**：一个指针指向第一个数组，另一个指针指向第二个数组，比较指针所指元素大小，将较小者放入结果数组，并移动对应指针。
- **寻找两个有序数组的交集/并集**：类似合并，根据比较结果移动指针。
- **在两个数组中寻找满足特定条件的元素对**：例如，寻找和为target的两个数，一个指针从数组1的开头移动，一个指针从数组2的末尾移动（如果数组有序）。

**优势**：
- 时间复杂度通常为O(n + m)，其中n和m是两个数组的长度。
- 空间复杂度通常为O(1)或O(n + m)（如果需要存储结果）。

### 2. 哈希表 (Hash Table / Set / Dictionary)

哈希表提供了近乎O(1)时间的查找、插入和删除操作，非常适合处理**查找存在性、频率统计、去重**等问题。

**典型应用场景**：
- **求两个数组的交集/并集/差集**：将一个数组的元素存入哈希集合(Set)，然后遍历另一个数组，检查元素是否存在于集合中。
- **判断一个数组是否包含另一个数组的所有元素**：使用哈希表记录第一个数组的元素及其频率，然后遍历第二个数组进行核对。
- **寻找和为目标值的两个数**：遍历一个数组，对于每个元素`x`，在哈希表中查找`target - x`是否存在。

**优势**：
- 操作效率高，平均时间复杂度接近O(1)。
- 实现相对简单。

**劣势**：
- 需要额外的O(n)或O(m)空间复杂度来存储哈希表。
- 不保留元素顺序（除非使用特定类型的哈希表如LinkedHashMap）。

### 3. 排序 (Sorting)

预先对数组进行排序是许多双数组问题的有效预处理步骤，特别是当问题涉及到元素的相对顺序或大小比较时。

**典型应用场景**：
- **求两个数组的交集/并集 (排序后+双指针)**：排序后，可以使用双指针在线性时间内找到交集或并集。
- **寻找两个有序数组的中位数/第k小元素**：排序是基础。
- **寻找最接近的元素对**：排序后可以通过双指针或类似方法高效查找。

**优势**：
- 使后续使用双指针等技巧成为可能。
- 简化某些比较和查找逻辑。

**劣势**：
- 排序本身需要O(n log n + m log m)的时间复杂度。
- 如果原始顺序重要，排序会破坏顺序。

### 4. 二分查找 (Binary Search)

当其中一个或两个数组**有序**时，二分查找可以极大地提高查找效率，将线性查找的O(n)复杂度降低到O(log n)。

**典型应用场景**：
- **在一个有序数组中查找另一个数组的元素**：对第二个数组的每个元素，在第一个有序数组中进行二分查找。
- **寻找两个有序数组的第k小元素/中位数**：二分查找通常是这类问题的核心思想之一，通过二分查找缩小搜索范围。

**优势**：
- 查找效率极高。

**劣势**：
- 要求数组必须有序。

### 5. 栈/队列 (Stack/Queue)

虽然不如前几种方法常用，但在某些特定双数组问题中，栈或队列也能发挥作用。

**典型应用场景**：
- **模拟特定过程**：例如，比较两个表示操作序列的数组。
- **单调栈/队列优化**：在需要维护特定单调性的子问题中可能用到。

选择哪种技巧取决于具体问题：
- **数组是否有序？** -> 考虑排序、双指针、二分查找。
- **是否需要快速查找/去重？** -> 考虑哈希表。
- **是否关心元素顺序？** -> 哈希表可能不适用（除非特殊实现）。
- **空间复杂度是否有严格限制？** -> 优先考虑双指针（O(1)空间）。

通常，解决一个双数组问题可能需要组合使用多种技巧。

## 四、经典题目解析

接下来，我们将通过几个经典的LeetCode题目，深入理解如何应用上述技巧来解决双数组问题。

### 1. 两个数组的交集 (Intersection of Two Arrays)

这类问题有多个变种，我们来看两个最常见的：

#### a) [LeetCode 349. 两个数组的交集](https://leetcode.cn/problems/intersection-of-two-arrays/)

**问题描述**：
给定两个数组 `nums1` 和 `nums2`，返回它们的交集。输出结果中的每个元素一定是 **唯一** 的。我们可以不考虑输出结果的顺序。

**示例 1**：
```
输入：nums1 = [1,2,2,1], nums2 = [2,2]
输出：[2]
```

**示例 2**：
```
输入：nums1 = [4,9,5], nums2 = [9,4,9,8,4]
输出：[9,4] (顺序无所谓，[4,9] 也可以)
```

**思路分析**：
- 目标是找到两个数组共有的元素，并且结果需要去重。
- 这是典型的集合运算问题，使用哈希集合 (Set) 是最直观高效的方法。

**解题步骤 (哈希集合法)**：
1.  将第一个数组 `nums1` 的所有元素存入一个哈希集合 `set1` 中，利用集合的特性自动去重。
2.  创建一个空的哈希集合 `resultSet` 用于存储最终结果。
3.  遍历第二个数组 `nums2`。
4.  对于 `nums2` 中的每个元素，检查它是否存在于 `set1` 中。
5.  如果存在，则将该元素添加到 `resultSet` 中。由于 `resultSet` 也是集合，重复的交集元素也只会被存储一次。
6.  最后，将 `resultSet` 转换为数组并返回。

**代码实现 (Swift - 哈希集合)**：
```swift
class Solution {
    func intersection(_ nums1: [Int], _ nums2: [Int]) -> [Int] {
        // 将nums1转换为Set，自动去重并提供O(1)查找
        let set1 = Set(nums1)
        var resultSet = Set<Int>()
        
        // 遍历nums2
        for num in nums2 {
            // 如果nums2中的元素在set1中存在，则加入结果集
            if set1.contains(num) {
                resultSet.insert(num)
            }
        }
        
        // 将结果集转换为数组返回
        return Array(resultSet)
    }
}
```

**复杂度分析 (哈希集合法)**：
- 时间复杂度：O(n + m)，其中 n 和 m 分别是两个数组的长度。将 `nums1` 存入集合需要 O(n) 时间，遍历 `nums2` 并检查存在性需要 O(m) 时间（平均情况）。
- 空间复杂度：O(n) 或 O(m)，取决于哪个数组用于构建哈希集合。需要额外的空间存储哈希集合。

**另一种思路 (排序 + 双指针)**：
1.  对两个数组分别进行排序。
2.  使用两个指针 `p1` 和 `p2` 分别指向两个排序后数组的开头。
3.  比较 `sortedNums1[p1]` 和 `sortedNums2[p2]`：
    *   如果相等，说明找到了一个交集元素。将其加入结果列表（注意去重，如果结果列表最后一个元素与当前元素相同则跳过），然后同时移动 `p1` 和 `p2`。
    *   如果 `sortedNums1[p1] < sortedNums2[p2]`，移动 `p1`。
    *   如果 `sortedNums1[p1] > sortedNums2[p2]`，移动 `p2`。
4.  重复步骤 3 直到任意一个指针到达数组末尾。

**代码实现 (Swift - 排序 + 双指针)**：
```swift
class SolutionSort {
    func intersection(_ nums1: [Int], _ nums2: [Int]) -> [Int] {
        let sortedNums1 = nums1.sorted()
        let sortedNums2 = nums2.sorted()
        
        var p1 = 0
        var p2 = 0
        var result: [Int] = []
        
        while p1 < sortedNums1.count && p2 < sortedNums2.count {
            let num1 = sortedNums1[p1]
            let num2 = sortedNums2[p2]
            
            if num1 == num2 {
                // 找到交集元素，加入结果前去重
                if result.isEmpty || result.last! != num1 {
                    result.append(num1)
                }
                p1 += 1
                p2 += 1
            } else if num1 < num2 {
                p1 += 1
            } else { // num1 > num2
                p2 += 1
            }
        }
        
        return result
    }
}
```

**复杂度分析 (排序 + 双指针法)**：
- 时间复杂度：O(n log n + m log m)，主要来自排序。双指针遍历部分是 O(n + m)。
- 空间复杂度：O(log n + log m) 或 O(n + m)，取决于排序算法使用的空间。如果结果数组不算额外空间，可以认为是 O(log n + log m)。

**对比与选择**：
- **哈希集合法**：时间和空间复杂度都依赖于数组长度，实现简单，通常是首选。
- **排序+双指针法**：时间复杂度受排序影响，但空间复杂度较低（如果原地排序且不考虑结果数组）。当空间有限或数组已部分有序时可以考虑。

#### b) [LeetCode 350. 两个数组的交集 II](https://leetcode.cn/problems/intersection-of-two-arrays-ii/)

**问题描述**：
给定两个数组 `nums1` 和 `nums2`，返回它们的交集。输出结果中每个元素出现的次数，应与元素在两个数组中都出现的次数一致（取二者最小值）。可以不考虑输出结果的顺序。

**示例 1**：
```
输入：nums1 = [1,2,2,1], nums2 = [2,2]
输出：[2,2]
解释：数组1中有两个2，数组2中也有两个2，交集就是两个2。
```

**示例 2**：
```
输入：nums1 = [4,9,5], nums2 = [9,4,9,8,4]
输出：[4,9] 或 [9,4]
解释：数组1中有1个4和1个9。数组2中有2个4和2个9。交集中4出现min(1,2)=1次，9出现min(1,2)=1次。
```

**思路分析**：
- 与上一题不同，这次需要考虑元素的**出现次数**。
- 哈希表仍然是有效的工具，但需要存储元素的**频率**而不是仅仅存在性。

**解题步骤 (哈希映射法)**：
1.  选择一个较短的数组（为了优化空间），遍历它并使用哈希映射 (Dictionary) `freqMap` 记录每个元素及其出现的次数。
2.  创建一个空的结果数组 `result`。
3.  遍历另一个（较长的）数组。
4.  对于该数组中的每个元素 `num`：
    *   检查 `freqMap` 中是否存在 `num` 且其计数大于 0。
    *   如果存在，将 `num` 添加到 `result` 数组中，并将 `freqMap` 中 `num` 的计数减 1。
5.  返回 `result` 数组。

**代码实现 (Swift - 哈希映射)**：
```swift
class SolutionII {
    func intersect(_ nums1: [Int], _ nums2: [Int]) -> [Int] {
        // 优化：对较短的数组构建频率映射
        let (shorter, longer) = nums1.count < nums2.count ? (nums1, nums2) : (nums2, nums1)
        
        var freqMap = [Int: Int]()
        for num in shorter {
            freqMap[num, default: 0] += 1
        }
        
        var result = [Int]()
        for num in longer {
            // 如果在映射中找到，并且计数大于0
            if let count = freqMap[num], count > 0 {
                result.append(num)
                freqMap[num] = count - 1 // 计数减1
            }
        }
        
        return result
    }
}
```

**复杂度分析 (哈希映射法)**：
- 时间复杂度：O(n + m)，构建频率映射 O(n)，遍历另一个数组 O(m)。
- 空间复杂度：O(min(n, m))，用于存储较短数组的频率映射。

**另一种思路 (排序 + 双指针)**：
1.  对两个数组分别进行排序。
2.  使用两个指针 `p1` 和 `p2` 分别指向两个排序后数组的开头。
3.  比较 `sortedNums1[p1]` 和 `sortedNums2[p2]`：
    *   如果相等，说明找到了一个交集元素。将其加入结果列表，然后同时移动 `p1` 和 `p2`。
    *   如果 `sortedNums1[p1] < sortedNums2[p2]`，移动 `p1`。
    *   如果 `sortedNums1[p1] > sortedNums2[p2]`，移动 `p2`。
4.  重复步骤 3 直到任意一个指针到达数组末尾。

**代码实现 (Swift - 排序 + 双指针)**：
```swift
class SolutionIISort {
    func intersect(_ nums1: [Int], _ nums2: [Int]) -> [Int] {
        let sortedNums1 = nums1.sorted()
        let sortedNums2 = nums2.sorted()
        
        var p1 = 0
        var p2 = 0
        var result: [Int] = []
        
        while p1 < sortedNums1.count && p2 < sortedNums2.count {
            let num1 = sortedNums1[p1]
            let num2 = sortedNums2[p2]
            
            if num1 == num2 {
                result.append(num1) // 直接添加，因为要保留重复次数
                p1 += 1
                p2 += 1
            } else if num1 < num2 {
                p1 += 1
            } else { // num1 > num2
                p2 += 1
            }
        }
        
        return result
    }
}
```

**复杂度分析 (排序 + 双指针法)**：
- 时间复杂度：O(n log n + m log m)，主要来自排序。
- 空间复杂度：O(log n + log m) 或 O(n + m)，取决于排序算法。

**进阶思考**：
- **如果 `nums1` 的大小比 `nums2` 小很多，哪种方法更好？** 哈希映射法更好，因为它只需要 O(min(n, m)) 的空间，并且时间复杂度是线性的 O(n + m)，优于排序的 O(n log n + m log m)。
- **如果 `nums2` 的元素存储在磁盘上，内存是有限的，并且你不能一次加载所有元素到内存中，你该怎么办？**
    - 如果 `nums1` 可以完全加载到内存：使用哈希映射法。将 `nums1` 的频率存入内存中的哈希表。然后分块读取 `nums2`，对于每个块中的元素，查询哈希表并更新结果。
    - 如果 `nums1` 也很大，无法完全加载：可以使用外部排序（External Sort）对两个文件进行排序，然后使用类似双指针的方法，一次只加载文件的一小部分进行比较和合并，将结果写入输出文件。

### 2. 合并两个有序数组 (Merge Sorted Array)

#### [LeetCode 88. 合并两个有序数组](https://leetcode.cn/problems/merge-sorted-array/)

**问题描述**：
给你两个按 **非递减顺序** 排列的整数数组 `nums1` 和 `nums2`，另有两个整数 `m` 和 `n` ，分别表示 `nums1` 和 `nums2` 中的元素数目。

请你 **合并** `nums2` 到 `nums1` 中，使合并后的数组同样按 **非递减顺序** 排列。

**注意**：最终合并后的数组不应由函数返回，而是存储在数组 `nums1` 中。为了应对这种情况，`nums1` 的初始长度为 `m + n`，其中前 `m` 个元素表示应合并的元素，后 `n` 个元素为 `0` ，应忽略。`nums2` 的长度为 `n`。

**示例 1**：
```
输入：nums1 = [1,2,3,0,0,0], m = 3, nums2 = [2,5,6], n = 3
输出：[1,2,2,3,5,6]
解释：需要合并 [1,2,3] 和 [2,5,6] 。
合并结果是 [1,2,2,3,5,6] 。
```

**示例 2**：
```
输入：nums1 = [1], m = 1, nums2 = [], n = 0
输出：[1]
```

**示例 3**：
```
输入：nums1 = [0], m = 0, nums2 = [1], n = 1
输出：[1]
解释：需要合并的数组是 [] 和 [1] 。
合并结果是 [1] 。注意因为 nums1 空数组中的元素为 0 ，所以 nums1 有空间存放 nums2 中的元素。
```

**思路分析**：
- 目标是将两个有序数组合并成一个有序数组，并且结果需要 **原地** 存储在 `nums1` 中。
- 如果从前往后合并，将 `nums2` 的元素插入 `nums1` 的正确位置时，需要移动 `nums1` 中后续的元素，这会导致 O(m*n) 的时间复杂度。
- 关键在于利用 `nums1` 末尾的空闲空间。我们可以 **从后往前** 合并，将较大的元素直接放到 `nums1` 的末尾（即 `m + n - 1` 的位置），这样可以避免元素的移动。

**解题步骤 (从后往前双指针)**：
1.  初始化三个指针：
    *   `p1` 指向 `nums1` 中有效元素的末尾（索引 `m - 1`）。
    *   `p2` 指向 `nums2` 的末尾（索引 `n - 1`）。
    *   `p` 指向 `nums1` 数组的最终末尾（索引 `m + n - 1`）。
2.  当 `p1` 和 `p2` 都有效时（即 `p1 >= 0` 且 `p2 >= 0`），比较 `nums1[p1]` 和 `nums2[p2]`：
    *   如果 `nums1[p1] > nums2[p2]`，将 `nums1[p1]` 放到 `nums1[p]` 的位置，然后 `p1` 和 `p` 都向前移动一位 (`p1--`, `p--`)。
    *   否则（`nums1[p1] <= nums2[p2]`），将 `nums2[p2]` 放到 `nums1[p]` 的位置，然后 `p2` 和 `p` 都向前移动一位 (`p2--`, `p--`)。
3.  循环结束后，可能其中一个数组的指针已经到达开头 (`p1 < 0` 或 `p2 < 0`)，而另一个数组还有剩余元素。
4.  如果 `p2` 仍然有效（`p2 >= 0`），说明 `nums2` 中还有剩余元素未合并（这些元素都比 `nums1` 中所有剩余元素小或 `nums1` 已处理完）。将 `nums2` 中剩余的元素依次拷贝到 `nums1` 的 `p` 位置即可（同时移动 `p2` 和 `p`）。
5.  如果 `p1` 仍然有效，不需要额外操作，因为它们已经在 `nums1` 的正确位置了。

**代码实现 (Swift - 从后往前双指针)**：
```swift
class SolutionMerge {
    func merge(_ nums1: inout [Int], _ m: Int, _ n: Int, _ nums2: [Int]) {
        // p1 指向 nums1 有效元素的末尾
        var p1 = m - 1 
        // p2 指向 nums2 的末尾
        var p2 = n - 1 
        // p 指向 nums1 的最终末尾
        var p = m + n - 1
        
        // 当两个数组都还有元素时，从后往前比较并放置
        while p1 >= 0 && p2 >= 0 {
            if nums1[p1] > nums2[p2] {
                nums1[p] = nums1[p1]
                p1 -= 1
            } else {
                nums1[p] = nums2[p2]
                p2 -= 1
            }
            p -= 1
        }
        
        // 如果 nums2 中还有剩余元素，将其拷贝到 nums1 的前面
        // (如果 nums1 有剩余，它们已经在正确位置了)
        while p2 >= 0 {
            nums1[p] = nums2[p2] 
            p2 -= 1
            p -= 1
        }
    }
}
```

**复杂度分析**：
- 时间复杂度：O(m + n)，因为两个指针 `p1` 和 `p2` 总共移动了 m + n 次。
- 空间复杂度：O(1)，因为我们是原地修改 `nums1`，没有使用额外的存储空间。

**关键点**：
- 从后往前合并是避免元素移动、实现 O(1) 空间复杂度的关键。
- 处理好循环结束后的边界情况（即某个数组还有剩余元素）。

### 3. 寻找两个正序数组的中位数 (Median of Two Sorted Arrays)

#### [LeetCode 4. 寻找两个正序数组的中位数](https://leetcode.cn/problems/median-of-two-sorted-arrays/)

**问题描述**：
给定两个大小分别为 `m` 和 `n` 的正序（从小到大）数组 `nums1` 和 `nums2`。

请你找出并返回这两个正序数组的 **中位数** 。

算法的时间复杂度应该为 O(log (m+n))。

**中位数定义**：
- 如果合并后的数组长度 `(m + n)` 是奇数，中位数是排序后位于中间的那个数。
- 如果合并后的数组长度 `(m + n)` 是偶数，中位数是排序后中间两个数的平均值。

**示例 1**：
```
输入：nums1 = [1,3], nums2 = [2]
输出：2.00000
解释：合并数组 = [1,2,3] ，中位数 2
```

**示例 2**：
```
输入：nums1 = [1,2], nums2 = [3,4]
输出：2.50000
解释：合并数组 = [1,2,3,4] ，中位数 (2 + 3) / 2 = 2.5
```

**思路分析**：
- **暴力解法**：最直观的方法是将两个数组合并成一个大的有序数组，然后直接找到中位数。合并可以使用类似上一题的双指针方法，时间复杂度 O(m + n)，空间复杂度 O(m + n)。但这不满足题目要求的 O(log (m+n)) 时间复杂度。
- **寻找第k小元素**：中位数问题可以转化为寻找合并后数组中第 `k` 小的元素。如果总长度 `totalLength = m + n`：
    - 若 `totalLength` 为奇数，中位数是第 `(totalLength / 2) + 1` 小的元素。
    - 若 `totalLength` 为偶数，中位数是第 `totalLength / 2` 小和第 `(totalLength / 2) + 1` 小两个元素的平均值。
- **二分查找优化**：寻找第 `k` 小元素的问题可以使用二分查找的思想来优化。我们不直接合并数组，而是通过比较两个数组中的特定元素来不断缩小查找范围。

**解题步骤 (二分查找寻找第k小元素)**：
核心思想是：要在两个有序数组 `A` 和 `B` 中找到第 `k` 小的元素，我们可以比较 `A[k/2 - 1]` 和 `B[k/2 - 1]` 这两个元素（如果索引存在）。
1.  假设 `A[k/2 - 1] < B[k/2 - 1]`。这意味着 `A` 数组的前 `k/2` 个元素（即 `A[0]` 到 `A[k/2 - 1]`）都不可能是合并后数组的第 `k` 小元素（它们最多是第 `k-1` 小）。因为即使 `B` 数组的前 `k/2 - 1` 个元素都比 `A[k/2 - 1]` 小，加上 `A[k/2 - 1]` 本身，也只有 `(k/2 - 1) + 1 = k/2` 个元素小于 `B[k/2 - 1]`，再加上 `B` 的前 `k/2 - 1` 个元素，总共是 `k/2 + (k/2 - 1) = k - 1` 个元素。所以 `A` 的前 `k/2` 个元素可以被安全地排除。
2.  排除 `A` 的前 `k/2` 个元素后，问题转化为在 `A` 的剩余部分和整个 `B` 数组中寻找第 `k - k/2` 小的元素。
3.  如果 `A[k/2 - 1] >= B[k/2 - 1]`，则可以排除 `B` 的前 `k/2` 个元素，问题转化为在整个 `A` 和 `B` 的剩余部分中寻找第 `k - k/2` 小的元素。
4.  通过迭代或递归地执行这个过程，每次排除大约 `k/2` 个元素，直到 `k` 变为 1（此时返回两个数组当前起始元素的较小值），或者某个数组被完全排除（此时在另一个数组中直接找第 `k` 小元素）。
5.  需要处理边界情况：当 `k/2 - 1` 超出某个数组的边界时，比较的"分割点"需要相应调整。

**代码实现 (Swift - 二分查找找第k小 - 迭代优化)**：
```swift
class SolutionMedian {
    func findMedianSortedArrays(_ nums1: [Int], _ nums2: [Int]) -> Double {
        let m = nums1.count
        let n = nums2.count
        let totalLength = m + n

        // 寻找第 k 小的元素 (k 从 1 开始计数) - 迭代版本
        func findKthElement(_ k: Int, _ nums1: [Int], _ nums2: [Int]) -> Int {
            var index1 = 0 // nums1 的起始索引
            var index2 = 0 // nums2 的起始索引
            var currentK = k // 还需要找第 currentK 小

            while true {
                // 边界情况：一个数组已经完全被排除
                if index1 == nums1.count {
                    return nums2[index2 + currentK - 1]
                }
                if index2 == nums2.count {
                    return nums1[index1 + currentK - 1]
                }
                // 边界情况：k 减小到 1
                if currentK == 1 {
                    return min(nums1[index1], nums2[index2])
                }

                // 正常情况：计算要比较的两个元素的索引
                let halfK = currentK / 2
                // 计算实际比较的索引，防止越界
                // newIndex 是相对于原数组的索引
                let newIndex1 = min(index1 + halfK, nums1.count) - 1
                let newIndex2 = min(index2 + halfK, nums2.count) - 1
                let pivot1 = nums1[newIndex1]
                let pivot2 = nums2[newIndex2]

                // 比较 pivot1 和 pivot2，排除不可能包含第 k 小元素的部分
                if pivot1 <= pivot2 {
                    // nums1 的 [index1...newIndex1] 部分可以排除
                    // 计算排除的元素个数
                    let excludedCount = newIndex1 - index1 + 1
                    // 更新 k 和 nums1 的起始索引
                    currentK -= excludedCount
                    index1 = newIndex1 + 1
                } else {
                    // nums2 的 [index2...newIndex2] 部分可以排除
                    // 计算排除的元素个数
                    let excludedCount = newIndex2 - index2 + 1
                    // 更新 k 和 nums2 的起始索引
                    currentK -= excludedCount
                    index2 = newIndex2 + 1
                }
            }
        }

        // 根据总长度的奇偶性计算中位数
        if totalLength % 2 == 1 {
            // 奇数长度，中位数是第 (totalLength / 2) + 1 小的元素
            let midIndex = totalLength / 2
            return Double(findKthElement(midIndex + 1, nums1, nums2))
        } else {
            // 偶数长度，中位数是第 totalLength / 2 和第 (totalLength / 2) + 1 小元素的平均值
            let midIndex1 = totalLength / 2 // 第 totalLength / 2 小 (k 从 1 开始)
            let midIndex2 = totalLength / 2 + 1 // 第 totalLength / 2 + 1 小
            let element1 = findKthElement(midIndex1, nums1, nums2)
            let element2 = findKthElement(midIndex2, nums1, nums2)
            return Double(element1 + element2) / 2.0
        }
    }
}
```

**复杂度分析**：
- 时间复杂度：O(log (m + n))。每次循环（或递归），我们都将 `k` 的值减半（大约 `k/2`），因此总的时间复杂度是对数级别的。
- 空间复杂度：O(1)（对于迭代版本），或者 O(log (m + n))（对于递归版本，来自递归调用的栈空间）。

**另一种思路 (划分数组)**：
还有一种更精妙的二分查找方法，它不是直接找第 `k` 小元素，而是试图找到一个合适的"分割线"，将两个数组划分成左右两部分，使得：
1.  左半部分所有元素 <= 右半部分所有元素
2.  左半部分的元素个数等于（或接近等于）右半部分的元素个数。

这个分割线的位置可以通过在较短的数组上进行二分查找来确定。找到分割线后，中位数就可以由分割线两侧的元素（最多四个）确定。

这种方法实现细节更复杂，但也能达到 O(log (min(m, n))) 的时间复杂度。

**思路更简单的版本 (O(m+n) 时间复杂度)**：

虽然不符合题目的 O(log(m+n)) 时间复杂度要求，但最容易理解的方法是先将两个数组合并成一个大的有序数组，然后直接找到中位数。

```swift
class SolutionMedianSimple {
    func findMedianSortedArrays(_ nums1: [Int], _ nums2: [Int]) -> Double {
        // 1. 合并两个数组
        let merged = (nums1 + nums2).sorted()
        let count = merged.count

        // 2. 根据总长度奇偶性找中位数
        if count % 2 == 1 {
            // 总长度为奇数，中位数是中间那个数
            return Double(merged[count / 2])
        } else {
            // 总长度为偶数，中位数是中间两个数的平均值
            let mid1 = merged[count / 2 - 1]
            let mid2 = merged[count / 2]
            return Double(mid1 + mid2) / 2.0
        }
    }
}
```

**复杂度分析 (合并后查找)**：
- 时间复杂度：O((m+n) log(m+n))，主要来自排序 `sorted()`。如果使用双指针合并（类似 LeetCode 88 但创建新数组），合并时间是 O(m+n)，则总时间也是 O(m+n)。
- 空间复杂度：O(m+n)，需要额外空间存储合并后的数组。

这个版本代码简洁，易于理解，但在性能上无法满足 LeetCode 第 4 题的要求，适合作为理解问题的起点。

## 五、优化策略与常见陷阱

在解决双数组问题时，除了掌握核心技巧，还需要注意一些优化策略和避免常见的陷阱。

### 1. 优化策略

- **利用有序性**：如果输入数组有序或可以排序，优先考虑双指针和二分查找，通常能获得更好的时间复杂度。
- **空间换时间**：当内存允许时，使用哈希表可以大大简化查找、去重和频率统计的操作，将时间复杂度降至线性。
- **预处理**：排序、构建频率表或前缀和数组等预处理步骤有时能为后续计算带来便利。
- **选择较短数组**：在使用哈希表或某些比较策略时，优先处理较短的数组通常能优化空间使用或减少比较次数。
- **从后往前**：在需要原地修改且数组末尾有空间时（如合并有序数组），从后往前操作可以避免元素移动，降低复杂度。
- **降维思想**：某些二维或多维数组问题可以通过固定某些维度，将其转化为一维数组问题来解决（如寻找子矩阵和）。

### 2. 常见陷阱

- **边界条件**：
    - 空数组：确保算法能正确处理一个或两个输入数组为空的情况。
    - 指针越界：在使用双指针或索引访问时，务必检查指针是否超出数组范围。
    - 单元素数组：测试算法在只有一个元素的数组上的表现。
- **整数溢出**：在计算和或进行大量算术运算时，注意潜在的整数溢出问题，可能需要使用更大范围的数据类型（如 `Int64`）。
- **重复元素处理**：
    - 求交集时是否需要去重？（LeetCode 349 vs 350）
    - 使用双指针时，如何跳过重复元素以避免结果重复？
- **原地修改**：如果题目要求原地修改数组（如 LeetCode 88），确保没有使用过多的额外空间，并正确地在原始数组上操作。
- **浮点数精度**：在计算平均值（如中位数）时，使用浮点数类型 (`Double`或`Float`) 并注意精度问题。
- **复杂度要求**：注意题目对时间或空间复杂度的特定要求，选择合适的算法（如中位数问题的 O(log(m+n)) 要求）。

## 六、总结与进阶

双数组问题是算法面试和竞赛中的常客，它们千变万化，但核心的解决思路往往围绕着**双指针、哈希表、排序和二分查找**这几种基本技巧的组合与变形。

**核心要点回顾**：
- **理解问题本质**：是集合运算、合并排序、查找计数还是其他类型？
- **分析数组特性**：是否有序？元素是否重复？数值范围？
- **选择合适工具**：根据问题特性和复杂度要求选用双指针、哈希表、排序或二分查找。
- **关注边界与细节**：仔细处理空数组、指针越界、重复元素等情况。
- **时空权衡**：根据内存限制和时间要求，在不同算法间做取舍。

**进阶方向**：
- **多维数组**：将双数组技巧扩展到二维甚至更高维度。
- **滑动窗口**：结合双指针和窗口思想解决子数组/子串问题。
- **前缀和/差分数组**：用于快速计算区间和或进行区间修改。
- **更复杂的数据结构**：如Trie树（处理字符串数组）、线段树/树状数组（处理动态查询）。

### 练习题推荐

为了巩固所学知识，建议尝试以下 LeetCode 题目：(没怎么做😂)

- **简单**:
    - [26. 删除有序数组中的重复项](https://leetcode.cn/problems/remove-duplicates-from-sorted-array/) (单数组，但用到双指针思想)
    - [27. 移除元素](https://leetcode.cn/problems/remove-element/) (单数组，双指针)
    - [167. 两数之和 II - 输入有序数组](https://leetcode.cn/problems/two-sum-ii-input-array-is-sorted/)
    - [283. 移动零](https://leetcode.cn/problems/move-zeroes/) (单数组，双指针)
- **中等**:
    - [1. 两数之和](https://leetcode.cn/problems/two-sum/) (哈希表)
    - [15. 三数之和](https://leetcode.cn/problems/3sum/) (排序 + 双指针)
    - [18. 四数之和](https://leetcode.cn/problems/4sum/) (排序 + 双指针扩展)
    - [56. 合并区间](https://leetcode.cn/problems/merge-intervals/) (排序)
    - [75. 颜色分类](https://leetcode.cn/problems/sort-colors/) (单数组，三指针)
    - [209. 长度最小的子数组](https://leetcode.cn/problems/minimum-size-subarray-sum/) (滑动窗口)
    - [977. 有序数组的平方](https://leetcode.cn/problems/squares-of-a-sorted-array/) (双指针)
- **困难**:
    - [42. 接雨水](https://leetcode.cn/problems/trapping-rain-water/) (单数组，双指针或单调栈)
    - [239. 滑动窗口最大值](https://leetcode.cn/problems/sliding-window-maximum/) (单调队列)
    - [315. 计算右侧小于当前元素的个数](https://leetcode.cn/problems/count-of-smaller-numbers-after-self/) (归并排序或树状数组/线段树)