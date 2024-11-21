---
layout: post
title: "22.括号生成"
date: 2024-11-21
tags: "算法 数组 字符串 LeetCode"
category: 
---

"括号生成"是一道经典的回溯算法题目。要求生成所有有效的括号组合，其中 n 对括号需要满足以下条件：
- 括号必须正确匹配
- 生成的括号对数为 n
- 需要列出所有可能的合法括号组合

**示例 1：**
```
输入：n = 3
输出：["((()))","(()())","(())()","()(())","()()()"]
```
**示例 2：**
```
输入：n = 1
输出：["()"]
 ```

提示：
**1 <= n <= 8**

### 解题思路
本题使用回溯算法（Backtracking）解决，主要思路如下：
- 使用递归方法生成括号
- 在生成过程中维护左括号和右括号的数量
- 设置递归约束条件：
  1. 左括号数量小于 n 时可以添加左括号
  2. 右括号数量小于左括号数量时可以添加右括号
- 当生成的字符串长度为 2n 时，表示一个有效组合

### swift 代码实现

```swift
class Solution {
    func generateParenthesis(_ n: Int) -> [String] {
        // 存储结果的数组
        var result: [String] = []
        
        // 回溯函数，接收当前字符串、左括号和右括号的数量
        func backtrack(_ current: String, _ left: Int, _ right: Int) {
            // 如果字符串长度达到 2n，说明是一个有效的括号组合
            if current.count == 2 * n {
                result.append(current)
                return
            }
            
            // 添加左括号的条件：左括号数量小于 n
            if left < n {
                backtrack(current + "(", left + 1, right)
            }
            
            // 添加右括号的条件：右括号数量小于左括号数量
            if right < left {
                backtrack(current + ")", left, right + 1)
            }
        }
        
        // 开始回溯，初始字符串为空，左右括号数量都为 0
        backtrack("", 0, 0)
        
        return result
    }
}

// 测试代码
let solution = Solution()
let result = solution.generateParenthesis(3)
print(result)

```

**代码解释：**
1. `generateParenthesis` 是主函数，接收括号对数 n
2. `backtrack` 是递归回溯函数，包含三个参数：
   - `current`：当前生成的字符串
   - `left`：已使用的左括号数量
   - `right`：已使用的右括号数量
3. 递归约束条件：
   - 字符串长度等于 2n 时添加到结果数组
   - 左括号数量小于 n 时可以添加左括号
   - 右括号数量小于左括号数量时可以添加右括号
4. 初始调用 `backtrack` 时传入空字符串和 0 个左右括号

**空间复杂度 & 时间复杂度**
- **时间复杂度**：O(4^n / sqrt(n))，这是生成有效括号组合的复杂度
- **空间复杂度**：O(n)，主要用于递归调用栈和存储结果

这个解法通过回溯算法巧妙地生成所有合法的括号组合，控制了生成过程中的括号平衡性。

