---
layout: post
title: "LeetCode经典DFS题目详解"
date: 2025-02-20
tags: "算法 DFS LeetCode 题解"
category: 
---

## 一、岛屿数量（[LeetCode 200](https://leetcode.cn/problems/number-of-islands/)）

### 问题描述
给定一个由 '1'（陆地）和 '0'（水）组成的二维网格，计算岛屿的数量。岛屿总是被水包围，并且每座岛屿只能由水平方向和/或竖直方向上相邻的陆地连接形成。

### 思考过程
1. **问题分析**
   - 我们需要找到所有相连的陆地群
   - 每个陆地群就是一个岛屿
   - 陆地只能上下左右相连
   - 需要避免重复计算同一个岛屿

2. **解题思路**
   - 遍历整个网格，找到一个陆地（'1'）时：
     1. 这一定是一个新岛屿的起点（因为相连的陆地会被标记）
     2. 使用DFS找出所有相连的陆地
     3. 将找到的陆地标记为已访问
     4. 岛屿数量加1

3. **关键点**
   - 如何标记已访问的陆地？
     * 可以直接修改原数组，将访问过的'1'改为'0'
     * 这样可以省去额外的visited数组
   - 如何处理边界情况？
     * 检查数组边界
     * 检查当前位置是否是陆地

4. **代码设计**
   - 主函数：遍历网格，统计岛屿数量
   - DFS函数：标记当前岛屿的所有陆地
   - 使用方向数组来简化上下左右的遍历

### 代码实现
```swift
class Solution {
    func numIslands(_ grid: [[Character]]) -> Int {
        // 创建可变副本，因为我们需要修改网格来标记已访问的陆地
        var grid = grid
        var islandCount = 0
        
        // 遍历每个格子
        for i in 0..<grid.count {
            for j in 0..<grid[0].count {
                // 发现新的陆地，说明找到新岛屿
                if grid[i][j] == "1" {
                    dfs(&grid, i, j)  // 标记整个岛屿
                    islandCount += 1   // 岛屿计数加1
                }
            }
        }
        
        return islandCount
    }
    
    // DFS遍历并标记相连的陆地
    private func dfs(_ grid: inout [[Character]], _ i: Int, _ j: Int) {
        // 1. 边界检查：确保不会越界
        // 2. 水域检查：确保当前位置是陆地
        guard i >= 0 && i < grid.count &&
              j >= 0 && j < grid[0].count &&
              grid[i][j] == "1" else { return }
        
        // 标记当前陆地为已访问（通过将其变为水域）
        grid[i][j] = "0"
        
        // 递归访问上下左右四个方向
        dfs(&grid, i-1, j) // 上
        dfs(&grid, i+1, j) // 下
        dfs(&grid, i, j-1) // 左
        dfs(&grid, i, j+1) // 右
    }
}

// 使用示例
/*
输入:
[
  ["1","1","0","0","0"],
  ["1","1","0","0","0"],
  ["0","0","1","0","0"],
  ["0","0","0","1","1"]
]
输出: 3

解释:
11000  <- 岛屿1
11000
00100  <- 岛屿2
00011  <- 岛屿3
*/
```

### 执行过程分析
以下面的网格为例：
```
1 1 0 0 0
1 1 0 0 0
0 0 1 0 0
0 0 0 1 1
```

1. **第一个岛屿**
   ```
   第一步：发现(0,0)是陆地
   1 1 0 0 0    →    0 1 0 0 0    →    0 0 0 0 0
   1 1 0 0 0         1 1 0 0 0         0 0 0 0 0
   0 0 1 0 0         0 0 1 0 0         0 0 1 0 0
   0 0 0 1 1         0 0 0 1 1         0 0 0 1 1
   (标记(0,0))        (标记相邻陆地)     (第一个岛屿标记完成)
   ```

2. **第二个岛屿**
   ```
   发现(2,2)是陆地
   0 0 0 0 0
   0 0 0 0 0
   0 0 0 0 0    →    所有相连的'1'都被标记为'0'
   0 0 0 1 1
   ```

3. **第三个岛屿**
   ```
   发现(3,3)是陆地
   0 0 0 0 0
   0 0 0 0 0
   0 0 0 0 0
   0 0 0 0 0    →    完成所有岛屿的标记
   ```

### 复杂度分析
1. **时间复杂度**：O(M × N)
   - M和N是网格的行数和列数
   - 每个格子最多被访问一次
   - DFS的递归调用不会增加总的访问次数

2. **空间复杂度**：O(M × N)
   - 最坏情况下，整个网格都是陆地
   - 递归调用栈的深度可能达到M × N

### 优化思路
1. **内存优化**
   - 使用原地修改而不是额外的visited数组
   - 如果不能修改原数组，可以使用位运算来标记访问状态

2. **代码优化**
   - 可以使用方向数组来简化四个方向的遍历
   ```swift
   let directions = [(0,1), (0,-1), (1,0), (-1,0)]
   for (dx, dy) in directions {
       dfs(&grid, i+dx, j+dy)
   }
   ```

3. **特殊情况处理**
   - 空网格检查
   - 单行或单列网格的处理

### 相关题目推荐
1. 岛屿的最大面积（[LeetCode 695](https://leetcode.cn/problems/max-area-of-island/)）
2. 封闭岛屿的数目（[LeetCode 1254](https://leetcode.cn/problems/number-of-closed-islands/)）
3. 统计封闭岛屿的数目（[LeetCode 1020](https://leetcode.cn/problems/number-of-enclaves/)）

## 二、路径总和（[LeetCode 112](https://leetcode.cn/problems/path-sum/)）

### 问题描述
给定一个二叉树和一个目标和，判断该树中是否存在根节点到叶子节点的路径，这条路径上所有节点值相加等于目标和。

### 思考过程
1. **问题分析**
   - 需要找到一条从根到叶子的完整路径
   - 路径上所有节点的和等于目标值
   - 必须到达叶子节点（没有子节点的节点）
   - 可能存在负数值，所以不能提前剪枝

2. **解题思路**
   - 使用DFS遍历每条从根到叶的路径
   - 每访问一个节点，就从目标和中减去该节点的值
   - 到达叶子节点时，检查剩余值是否为0
   - 任意一条路径满足条件即可返回true

3. **关键点**
   - 如何判断叶子节点？
     * 左右子节点都为空的节点
   - 如何处理路径和？
     * 使用减法，避免额外空间存储路径
   - 特殊情况处理：
     * 空树的处理
     * 只有根节点的情况
     * 负数节点值的处理

4. **代码设计**
   - 使用递归实现DFS
   - 参数：当前节点和剩余目标和
   - 终止条件：到达叶子节点或空节点
   - 递归逻辑：检查左右子树是否存在满足条件的路径

### 代码实现
```swift
class TreeNode {
    var val: Int
    var left: TreeNode?
    var right: TreeNode?
    init(_ val: Int) {
        self.val = val
    }
}

class Solution {
    func hasPathSum(_ root: TreeNode?, _ targetSum: Int) -> Bool {
        // 处理空树情况
        guard let node = root else { return false }
        
        // 到达叶子节点，检查剩余值是否为0
        if node.left == nil && node.right == nil {
            return targetSum == node.val
        }
        
        // 计算剩余需要的和
        let remainingSum = targetSum - node.val
        
        // 递归检查左右子树是否存在满足条件的路径
        return hasPathSum(node.left, remainingSum) || 
               hasPathSum(node.right, remainingSum)
    }
}

// 使用示例
/*
      5
     / \
    4   8
   /   / \
  11  13  4
 /  \      \
7    2      1

targetSum = 22
路径：5->4->11->2 (和为22)
输出：true
*/
```

### 执行过程分析
以下面的二叉树为例，目标和为22：
```
      5
     / \
    4   8
   /   / \
  11  13  4
 /  \      \
7    2      1
```

1. **路径搜索过程**
   ```
   第一步：访问根节点5
   剩余目标和 = 22 - 5 = 17
   
   左子树路径：
   5 → 4 (17-4=13)
   → 11 (13-11=2)
   → 7 (2-7=-5) ❌
   → 2 (2-2=0) ✅
   
   右子树路径：
   5 → 8 (17-8=9)
   → 13 (9-13=-4) ❌
   → 4 (9-4=5)
   → 1 (5-1=4) ❌
   ```

2. **成功路径分析**
   ```
   路径：5 → 4 → 11 → 2
   计算过程：
   22 (初始目标)
   - 5 (根节点)
   - 4 (第二层)
   - 11 (第三层)
   - 2 (叶子节点)
   = 0 (满足条件)
   ```

### 复杂度分析
1. **时间复杂度**：O(N)
   - N是树中的节点数
   - 每个节点都需要访问一次
   - 没有重复访问的情况

2. **空间复杂度**：O(H)
   - H是树的高度
   - 递归调用栈的最大深度
   - 最坏情况下（树退化为链表）为O(N)

### 优化思路
1. **提前剪枝**（适用于特定情况）
   ```swift
   // 如果所有节点都是非负数，可以添加剪枝
   if remainingSum < 0 { return false }
   ```

2. **路径记录**（扩展功能）
   ```swift
   // 如果需要记录路径
   func hasPathSum(_ root: TreeNode?, _ targetSum: Int, _ path: [Int]) -> Bool {
       guard let node = root else { return false }
       let currentPath = path + [node.val]
       // ... 其余逻辑
   }
   ```

3. **迭代实现**（优化空间）
   ```swift
   // 使用栈代替递归
   struct NodeInfo {
       let node: TreeNode
       let remainingSum: Int
   }
   ```

### 常见错误
1. **忽略叶子节点判断**
   - 错误：只判断节点值等于剩余和
   - 正确：必须是叶子节点且值等于剩余和

2. **空节点处理**
   - 错误：返回remainingSum == 0
   - 正确：返回false（空节点不能构成有效路径）

3. **负数处理**
   - 错误：在remainingSum < 0时剪枝
   - 正确：考虑节点值可能为负数

### 相关题目推荐
1. 路径总和 II（[LeetCode 113](https://leetcode.cn/problems/path-sum-ii/)）
2. 路径总和 III（[LeetCode 437](https://leetcode.cn/problems/path-sum-iii/)）
3. 二叉树中的最大路径和（[LeetCode 124](https://leetcode.cn/problems/binary-tree-maximum-path-sum/)）

## 三、全排列（[LeetCode 46](https://leetcode.cn/problems/permutations/)）

### 问题描述
给定一个不含重复数字的数组，返回其所有可能的全排列。每个排列中，每个数字必须且只能使用一次。

### 思考过程
1. **问题分析**
   - 需要生成所有可能的排列组合
   - 数组中的每个数字都必须使用
   - 每个数字只能使用一次
   - 排列的长度等于原数组长度
   - 数字的相对顺序可以改变

2. **解题思路**
   - 使用回溯法（DFS的一种特殊形式）
   - 在每一层决策中：
     * 选择一个未使用的数字
     * 将其加入当前排列
     * 递归处理剩余数字
     * 回溯（撤销选择）
   - 当排列长度等于数组长度时，得到一个有效解

3. **关键点**
   - 如何标记已使用的数字？
     * 使用布尔数组记录使用状态
     * 或者直接修改原数组（不推荐）
   - 如何构建排列？
     * 使用数组存储当前路径
     * 当路径长度等于n时添加到结果
   - 如何实现回溯？
     * 递归返回时撤销当前选择
     * 确保状态能够恢复

4. **代码设计**
   - 主函数：初始化结果集和标记数组
   - 回溯函数：实现DFS搜索
   - 使用path数组记录当前排列
   - 使用used数组标记已使用的数字

### 代码实现
```swift
class Solution {
    func permute(_ nums: [Int]) -> [[Int]] {
        var result: [[Int]] = []
        var used = Array(repeating: false, count: nums.count)
        
        // 回溯函数
        func backtrack(_ path: [Int]) {
            // 找到一个完整排列
            if path.count == nums.count {
                result.append(path)
                return
            }
            
            // 尝试每个可用的数字
            for i in 0..<nums.count {
                // 跳过已使用的数字
                if used[i] { continue }
                
                // 1. 做选择
                used[i] = true
                // 2. 递归
                backtrack(path + [nums[i]])
                // 3. 撤销选择（回溯）
                used[i] = false
            }
        }
        
        // 开始回溯
        backtrack([])
        return result
    }
}
```

### 执行过程分析
以数组 `[1,2,3]` 为例：

1. **决策树分析**
```
                    []
        /           |           \
       1            2            3
    /     \      /     \      /     \
   12     13    21     23    31     32
    |      |     |      |     |      |
   123    132   213    231   312    321
```

2. **详细执行步骤**
```
第一层：选择第一个数字
[] → [1]     used=[true,false,false]
[] → [2]     used=[false,true,false]
[] → [3]     used=[false,false,true]

以[1]为例的第二层：
[1] → [1,2]  used=[true,true,false]
[1] → [1,3]  used=[true,false,true]

以[1,2]为例的第三层：
[1,2] → [1,2,3]  used=[true,true,true]
```

3. **回溯过程**
```
[1,2,3] 加入结果集
回溯，撤销3：[1,2]  used=[true,true,false]
回溯，撤销2：[1]    used=[true,false,false]
选择3：[1,3]        used=[true,false,true]
...以此类推
```

### 复杂度分析
1. **时间复杂度**：O(n!)
   - n个数字的全排列有n!种可能
   - 每种排列都需要O(n)的时间来构建
   - 总时间复杂度为O(n × n!)

2. **空间复杂度**：O(n)
   - used数组占用O(n)空间
   - 递归调用栈深度为O(n)
   - path数组占用O(n)空间
   - 不考虑存储结果的空间

### 优化思路
1. **空间优化**
   ```swift
   // 使用集合代替布尔数组
   func permute(_ nums: [Int]) -> [[Int]] {
       var result: [[Int]] = []
       
       func backtrack(_ path: [Int], _ remaining: Set<Int>) {
           if path.count == nums.count {
               result.append(path)
               return
           }
           
           for num in remaining {
               backtrack(path + [num], remaining.subtracting([num]))
           }
       }
       
       backtrack([], Set(nums))
       return result
   }
   ```

2. **性能优化**
   ```swift
   // 使用可变数组避免频繁的数组拷贝
   func permute(_ nums: [Int]) -> [[Int]] {
       var result: [[Int]] = []
       var path: [Int] = []
       var used = Array(repeating: false, count: nums.count)
       
       func backtrack() {
           if path.count == nums.count {
               result.append(path)
               return
           }
           
           for i in 0..<nums.count where !used[i] {
               path.append(nums[i])
               used[i] = true
               backtrack()
               path.removeLast()
               used[i] = false
           }
       }
       
       backtrack()
       return result
   }
   ```

### 常见错误
1. **忘记回溯**
   - 错误：没有重置used数组
   - 正确：每次递归返回时重置状态

2. **重复使用元素**
   - 错误：没有正确标记已使用元素
   - 正确：使用used数组严格控制

3. **提前终止**
   - 错误：路径长度不足就返回
   - 正确：只在路径长度等于n时才加入结果

### 相关题目推荐
1. 全排列 II（[LeetCode 47](https://leetcode.cn/problems/permutations-ii/)）
2. 下一个排列（[LeetCode 31](https://leetcode.cn/problems/next-permutation/)）
3. 字符串的排列（[LeetCode 567](https://leetcode.cn/problems/permutation-in-string/)）

## 四、单词搜索（[LeetCode 79](https://leetcode.cn/problems/word-search/)）

### 问题描述
给定一个二维网格和一个单词，找出该单词是否存在于网格中。单词必须按照字母顺序，通过相邻的单元格内的字母构成，其中"相邻"单元格是那些水平相邻或垂直相邻的单元格。同一个单元格内的字母不能被重复使用。

### 思考过程
1. **问题分析**
   - 需要在网格中找到连续的字母路径
   - 路径必须是相邻的（上下左右）
   - 每个格子只能使用一次
   - 路径的字母顺序必须匹配目标单词
   - 可以从任意位置开始搜索

2. **解题思路**
   - 遍历网格找到可能的起点（与单词第一个字母匹配的位置）
   - 从每个可能的起点开始DFS搜索
   - 在DFS过程中：
     * 验证当前字母是否匹配
     * 标记已访问的位置
     * 向四个方向继续搜索
     * 回溯时恢复标记

3. **关键点**
   - 如何标记已访问位置？
     * 可以修改原数组（将访问过的字符改为特殊字符）
     * 或使用额外的visited数组
   - 边界条件处理：
     * 数组边界检查
     * 字符匹配检查
     * 已访问检查
   - 何时返回结果：
     * 找到完整单词时返回true
     * 所有可能路径都无法匹配时返回false

4. **代码设计**
   - 主函数：遍历网格寻找起点
   - DFS函数：递归搜索匹配路径
   - 使用方向数组简化四个方向的遍历
   - 原地修改方式标记已访问位置

### 代码实现
```swift
class Solution {
    func exist(_ board: [[Character]], _ word: String) -> Bool {
        // 将字符串转换为字符数组，便于访问
        let word = Array(word)
        var board = board
        
        // 遍历网格每个位置作为起点
        for i in 0..<board.count {
            for j in 0..<board[0].count {
                // 从当前位置开始搜索
                if dfs(&board, i, j, word, 0) {
                    return true
                }
            }
        }
        return false
    }
    
    private func dfs(_ board: inout [[Character]], _ i: Int, _ j: Int, 
                    _ word: [Character], _ index: Int) -> Bool {
        // 找到完整单词
        if index == word.count {
            return true
        }
        
        // 边界检查和字符匹配检查
        guard i >= 0 && i < board.count &&
              j >= 0 && j < board[0].count &&
              board[i][j] == word[index] else {
            return false
        }
        
        // 标记当前字母为已访问（使用特殊字符）
        let temp = board[i][j]
        board[i][j] = "#"
        
        // 向四个方向搜索
        let found = dfs(&board, i+1, j, word, index+1) ||  // 下
                   dfs(&board, i-1, j, word, index+1) ||  // 上
                   dfs(&board, i, j+1, word, index+1) ||  // 右
                   dfs(&board, i, j-1, word, index+1)     // 左
        
        // 恢复字母（回溯）
        board[i][j] = temp
        return found
    }
}
```

### 执行过程分析
以下面的网格和单词"ABCCED"为例：
```
[
  ['A','B','C','E'],
  ['S','F','C','S'],
  ['A','D','E','E']
]
```

1. **搜索过程示例**
```
起点(0,0)='A'：
A # C E    A # C E    A # # E    A B C E
S F C S -> S F C S -> S F C S -> S F C S
A D E E    A D E E    A D E E    A D E E
(访问A)    (访问B)    (访问C)    (回溯)

路径跟踪：
A → B → C → C → E → D
(0,0)->(0,1)->(0,2)->(1,2)->(2,2)->(2,1)
```

2. **回溯过程**
```
每一步DFS：
1. 检查当前字母是否匹配
2. 标记为'#'
3. 尝试四个方向
4. 恢复原字母

例如在(0,0)位置：
- 标记：board[0][0] = '#'
- 递归搜索四个方向
- 恢复：board[0][0] = 'A'
```

### 复杂度分析
1. **时间复杂度**：O(N × M × 4^L)
   - N和M是网格的维度
   - L是单词的长度
   - 每个位置有4个方向可以探索
   - 最坏情况下需要探索所有可能的路径

2. **空间复杂度**：O(L)
   - L是单词的长度
   - 递归调用栈的最大深度
   - 不需要额外的visited数组（原地修改）

### 优化思路
1. **提前剪枝**
   ```swift
   // 在主函数中添加字符统计剪枝
   func exist(_ board: [[Character]], _ word: String) -> Bool {
       // 统计网格中的字符频率
       var charCount: [Character: Int] = [:]
       for row in board {
           for char in row {
               charCount[char, default: 0] += 1
           }
       }
       
       // 检查单词中的字符是否都能满足
       for char in word {
           guard let count = charCount[char], count > 0 else {
               return false
           }
           charCount[char] = count - 1
       }
       
       // 继续原来的搜索逻辑
       // ...
   }
   ```

2. **方向数组优化**
   ```swift
   // 使用方向数组简化代码
   let directions = [(1,0), (-1,0), (0,1), (0,-1)]
   
   // 在DFS中使用
   var found = false
   for (dx, dy) in directions {
       let newX = i + dx
       let newY = j + dy
       if !found {
           found = dfs(&board, newX, newY, word, index+1)
       }
   }
   ```

3. **visited数组版本**
   ```swift
   // 使用visited数组而不是修改原数组
   func exist(_ board: [[Character]], _ word: String) -> Bool {
       var visited = Array(repeating: Array(repeating: false, count: board[0].count), 
                          count: board.count)
       // ... DFS逻辑
   }
   ```

### 常见错误
1. **忘记回溯**
   - 错误：没有恢复修改过的字符
   - 正确：递归返回前恢复原字符

2. **方向处理**
   - 错误：漏掉某个方向或重复处理
   - 正确：使用方向数组确保完整性

3. **边界检查**
   - 错误：先检查字符匹配再检查边界
   - 正确：先检查边界再匹配字符

### 相关题目推荐
1. 单词搜索 II（[LeetCode 212](https://leetcode.cn/problems/word-search-ii/)）
2. 岛屿数量（[LeetCode 200](https://leetcode.cn/problems/number-of-islands/)）
3. 矩阵中的最长递增路径（[LeetCode 329](https://leetcode.cn/problems/longest-increasing-path-in-a-matrix/)）

## 五、被围绕的区域（[LeetCode 130](https://leetcode.cn/problems/surrounded-regions/)）

### 问题描述
给定一个二维矩阵，包含 'X' 和 'O'（字母 O）。找到所有被 'X' 围绕的区域，并将这些区域里所有的 'O' 用 'X' 填充。被围绕的区域是指不与边界相连的 'O' 区域。

### 思考过程
1. **问题分析**
   - 需要找到所有被'X'完全包围的'O'区域
   - 边界上的'O'及其相连的'O'不会被填充
   - 只有完全被'X'包围的'O'才需要变成'X'
   - 关键是识别哪些'O'是与边界相连的

2. **解题思路反转**
   - 不是直接找被围绕的区域
   - 而是找到所有不会被围绕的区域（与边界相连的'O'）
   - 步骤：
     1. 从边界的'O'开始DFS标记所有相连的'O'
     2. 剩下的'O'就是被围绕的区域
     3. 将未被标记的'O'变成'X'
     4. 恢复被标记的'O'

3. **关键点**
   - 为什么从边界开始？
     * 任何与边界相连的'O'都不会被围绕
     * 这样可以一次性标记所有"安全"的'O'
   - 如何标记已访问？
     * 可以使用特殊字符（如'#'）临时标记
     * 最后再恢复这些标记
   - 边界处理：
     * 需要遍历矩阵的四条边
     * 对每个边界上的'O'进行DFS

4. **代码设计**
   - 主函数：处理边界和转换
   - DFS函数：标记相连的'O'
   - 使用方向数组简化遍历
   - 分三个阶段：标记、转换、恢复

### 代码实现
```swift
class Solution {
    func solve(_ board: inout [[Character]]) {
        // 处理空矩阵或单行/列矩阵
        guard !board.isEmpty && !board[0].isEmpty else { return }
        
        let rows = board.count
        let cols = board[0].count
        
        // 第一阶段：标记与边界相连的'O'
        // 检查第一行和最后一行
        for j in 0..<cols {
            dfs(&board, 0, j)      // 第一行
            dfs(&board, rows-1, j) // 最后一行
        }
        
        // 检查第一列和最后一列
        for i in 0..<rows {
            dfs(&board, i, 0)      // 第一列
            dfs(&board, i, cols-1) // 最后列
        }
        
        // 第二阶段：处理整个矩阵
        for i in 0..<rows {
            for j in 0..<cols {
                if board[i][j] == "O" {
                    // 未标记的'O'是被围绕的，变成'X'
                    board[i][j] = "X"
                } else if board[i][j] == "#" {
                    // 恢复标记过的'O'
                    board[i][j] = "O"
                }
            }
        }
    }
    
    private func dfs(_ board: inout [[Character]], _ i: Int, _ j: Int) {
        // 边界检查和'O'检查
        guard i >= 0 && i < board.count &&
              j >= 0 && j < board[0].count &&
              board[i][j] == "O" else { return }
        
        // 标记当前'O'为已访问
        board[i][j] = "#"
        
        // 递归标记四个方向的相邻'O'
        dfs(&board, i+1, j) // 下
        dfs(&board, i-1, j) // 上
        dfs(&board, i, j+1) // 右
        dfs(&board, i, j-1) // 左
    }
}
```

### 执行过程分析
以下面的矩阵为例：
```
X X X X
X O O X
X X O X
X O X X
```

1. **边界检查和标记阶段**
```
第一步：检查边界上的'O'
X X X X    没有边界'O'，不需要标记
X O O X
X X O X
X O X X

第二步：所有未标记的'O'都是被围绕的
```

2. **转换阶段**
```
原始矩阵：    转换后：
X X X X      X X X X
X O O X  →   X X X X
X X O X      X X X X
X O X X      X O X X

说明：
- 除了(3,1)位置的'O'外，其他'O'都被围绕
- (3,1)的'O'与边界相连，所以保持不变
```

3. **特殊情况示例**
```
特殊情况1：边界相连
X O X    →    X O X
O X X         O X X
X X X         X X X
（边界'O'保持不变）

特殊情况2：连通区域
X O O    →    X O O
X O X         X O X
X X X         X X X
（与边界相连的'O'都保持不变）
```

### 复杂度分析
1. **时间复杂度**：O(M × N)
   - M和N是矩阵的维度
   - 每个格子最多被访问一次
   - DFS的递归调用不会增加总的访问次数

2. **空间复杂度**：O(M × N)
   - 最坏情况下的递归栈深度
   - 发生在整个矩阵都是'O'的情况

### 优化思路
1. **使用队列的BFS版本**
   ```swift
   func solve(_ board: inout [[Character]]) {
       let rows = board.count
       let cols = board[0].count
       var queue: [(Int, Int)] = []
       
       // 收集边界上的'O'
       for i in 0..<rows {
           if board[i][0] == "O" { queue.append((i, 0)) }
           if board[i][cols-1] == "O" { queue.append((i, cols-1)) }
       }
       // ... BFS处理
   }
   ```

2. **并查集解法**
   ```swift
   class UnionFind {
       private var parent: [Int]
       private var rank: [Int]
       
       init(_ size: Int) {
           parent = Array(0..<size)
           rank = Array(repeating: 0, count: size)
       }
       
       func find(_ x: Int) -> Int {
           if parent[x] != x {
               parent[x] = find(parent[x])
           }
           return parent[x]
       }
       
       func union(_ x: Int, _ y: Int) {
           let rootX = find(x)
           let rootY = find(y)
           if rootX != rootY {
               if rank[rootX] < rank[rootY] {
                   parent[rootX] = rootY
               } else if rank[rootX] > rank[rootY] {
                   parent[rootY] = rootX
               } else {
                   parent[rootY] = rootX
                   rank[rootX] += 1
               }
           }
       }
   }
   ```

3. **原地标记优化**
   ```swift
   // 使用位运算标记，避免使用额外字符
   func solve(_ board: inout [[Character]]) {
       // 使用ASCII值进行标记
       let MARKED = Character(UnicodeScalar("O").value + 128)
       // ... 其余逻辑
   }
   ```

### 常见错误
1. **方向处理不当**
   - 错误：遗漏某个方向的检查
   - 正确：使用方向数组确保四个方向都被检查

2. **边界处理不完整**
   - 错误：只检查部分边界
   - 正确：检查所有边界位置的'O'

3. **标记恢复问题**
   - 错误：忘记恢复临时标记
   - 正确：确保所有标记都被正确恢复

### 相关题目推荐
1. 岛屿数量（[LeetCode 200](https://leetcode.cn/problems/number-of-islands/)）
2. 封闭岛屿的数目（[LeetCode 1254](https://leetcode.cn/problems/number-of-closed-islands/)）
3. 飞地的数量（[LeetCode 1020](https://leetcode.cn/problems/number-of-enclaves/)）

## 总结

这五个经典的DFS问题展示了不同类型的DFS应用：

1. **岛屿数量**：展示了在网格中使用DFS进行连通区域标记
2. **路径总和**：展示了在树中使用DFS进行路径搜索
3. **全排列**：展示了使用DFS进行排列组合
4. **单词搜索**：展示了在网格中使用DFS进行路径查找
5. **被围绕的区域**：展示了使用DFS处理边界条件

### 解题技巧
1. 在网格类问题中，通常需要：
   - 检查边界条件
   - 标记已访问的位置
   - 向多个方向搜索

2. 在树类问题中，通常需要：
   - 处理空节点情况
   - 维护路径信息
   - 考虑回溯

3. 在排列组合问题中，通常需要：
   - 使用标记数组
   - 维护当前状态
   - 实现回溯逻辑

### 常见优化方法
1. 使用visited数组避免重复访问
2. 原地修改以节省空间
3. 提前剪枝优化搜索
4. 使用方向数组简化代码

### DFS的核心要素
1. **状态定义**：明确每个状态代表什么
2. **终止条件**：何时停止递归
3. **状态转移**：如何从当前状态到下一状态
4. **回溯处理**：如何撤销选择，返回上一状态
