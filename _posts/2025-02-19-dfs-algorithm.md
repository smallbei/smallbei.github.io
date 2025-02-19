---
layout: post
title: "深度优先搜索(DFS)详解：从入门到精通"
date: 2025-02-19
tags: "算法 DFS 搜索 数据结构"
category: 
---

## 一、DFS基本概念

### 1. 什么是DFS？

深度优先搜索（Depth-First Search，简称DFS）是一种用于遍历或搜索树/图的算法。它的特点是：
- 沿着一条路径一直走到底
- 当无法继续前进时才回溯
- 确保访问到所有的节点

想象你在走迷宫：
- 每到一个分岔路口，你总是先选择一条路一直走
- 走到死胡同时，才返回到最近的分岔路口，选择另一条路
- 这就是DFS的基本思想

### 2. DFS的核心特征

1. **递归性**
   - 问题可以分解为子问题
   - 子问题的解决方式与原问题相同
   - 有明确的终止条件

2. **回溯性**
   - 当前路径不通时，返回上一步
   - 尝试其他可能的选择
   - 记录和恢复状态

3. **完整性**
   - 保证访问所有可能的路径
   - 不会重复访问节点
   - 一定能找到解（如果存在）

## 二、DFS的实现方式

### 1. 递归实现

```swift
// 二叉树的DFS遍历
class TreeNode {
    var val: Int
    var left: TreeNode?
    var right: TreeNode?
    
    init(_ val: Int) {
        self.val = val
    }
}

func dfs(_ root: TreeNode?) {
    // 1. 终止条件
    guard let node = root else { return }
    
    // 2. 处理当前节点
    print(node.val)
    
    // 3. 递归处理子节点
    dfs(node.left)
    dfs(node.right)
}

// 使用示例
let root = TreeNode(1)
root.left = TreeNode(2)
root.right = TreeNode(3)
dfs(root) // 输出: 1 2 3
```

### 2. 栈实现

```swift
// 使用栈实现DFS
func dfsWithStack(_ root: TreeNode?) {
    // 1. 处理空树
    guard let root = root else { return }
    
    // 2. 创建栈并将根节点入栈
    var stack: [TreeNode] = [root]
    
    // 3. 当栈不为空时循环
    while !stack.isEmpty {
        // 4. 弹出栈顶节点并访问
        let node = stack.removeLast()
        print(node.val)
        
        // 5. 将子节点入栈（注意顺序：先右后左，这样出栈时就是先左后右）
        if let right = node.right {
            stack.append(right)
        }
        if let left = node.left {
            stack.append(left)
        }
    }
}
```

## 三、实际应用示例

### 1. 二叉树路径和问题

问题描述：
给定一个二叉树和一个目标和，判断是否存在从根节点到叶子节点的路径，使得路径上所有节点值的和等于目标和。

```swift
class Solution {
    func hasPathSum(_ root: TreeNode?, _ targetSum: Int) -> Bool {
        // 1. 处理空节点
        guard let node = root else { return false }
        
        // 2. 如果是叶子节点，检查和是否相等
        if node.left == nil && node.right == nil {
            return targetSum == node.val
        }
        
        // 3. 递归检查左右子树
        let remainingSum = targetSum - node.val
        return hasPathSum(node.left, remainingSum) || 
               hasPathSum(node.right, remainingSum)
    }
}

// 使用示例
/*
     10
    /  \
   5    15
  / \     \
 3   7     18

目标和：18
路径：10 -> 5 -> 3 (和为18，返回true)
*/
```

### 2. 岛屿数量问题

问题描述：
给定一个由 '1'（陆地）和 '0'（水）组成的二维网格，计算岛屿的数量。一个岛被水包围，并且它是通过水平方向或垂直方向上相邻的陆地连接而成的。

```swift
class Solution {
    func numIslands(_ grid: [[Character]]) -> Int {
        var grid = grid // 创建可变副本
        var count = 0
        
        // 遍历每个格子
        for i in 0..<grid.count {
            for j in 0..<grid[0].count {
                if grid[i][j] == "1" {
                    dfs(&grid, i, j)
                    count += 1
                }
            }
        }
        
        return count
    }
    
    // DFS遍历并标记已访问的陆地
    private func dfs(_ grid: inout [[Character]], _ i: Int, _ j: Int) {
        // 1. 边界检查
        guard i >= 0 && i < grid.count && 
              j >= 0 && j < grid[0].count && 
              grid[i][j] == "1" else { return }
        
        // 2. 标记已访问
        grid[i][j] = "0"
        
        // 3. 访问上下左右四个方向
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
11000
11000  <- 一个岛屿
00100  <- 一个岛屿
00011  <- 一个岛屿
*/
```

### 3. 全排列问题

问题描述：
给定一个没有重复数字的序列，返回其所有可能的全排列。

```swift
class Solution {
    func permute(_ nums: [Int]) -> [[Int]] {
        var result: [[Int]] = []
        var used = Array(repeating: false, count: nums.count)
        
        func backtrack(_ path: [Int]) {
            // 1. 找到一个排列
            if path.count == nums.count {
                result.append(path)
                return
            }
            
            // 2. 尝试每个数字
            for i in 0..<nums.count {
                // 跳过已使用的数字
                if used[i] { continue }
                
                // 标记使用
                used[i] = true
                // 将当前数字加入路径
                backtrack(path + [nums[i]])
                // 回溯，取消标记
                used[i] = false
            }
        }
        
        backtrack([])
        return result
    }
}

// 使用示例
let nums = [1, 2, 3]
let solution = Solution()
let result = solution.permute(nums)
print(result) // [[1,2,3], [1,3,2], [2,1,3], [2,3,1], [3,1,2], [3,2,1]]
```

## 四、DFS的优化技巧

### 1. 剪枝优化

```swift
// 带剪枝的DFS示例
func dfsWithPruning(_ node: TreeNode?, _ target: Int, _ currentSum: Int) -> Bool {
    guard let node = node else { return false }
    
    // 剪枝：如果当前和已经超过目标值，无需继续
    let newSum = currentSum + node.val
    if newSum > target { return false }
    
    // 其他逻辑...
    return dfsWithPruning(node.left, target, newSum) ||
           dfsWithPruning(node.right, target, newSum)
}
```

### 2. 记忆化搜索

```swift
// 使用记忆化优化DFS
class Solution {
    var memo: [String: Bool] = [:] // 记忆化存储
    
    func canReach(_ s: String, _ target: String) -> Bool {
        // 1. 检查记忆化存储
        let key = s + "-" + target
        if let result = memo[key] {
            return result
        }
        
        // 2. 计算结果
        let result = /* DFS逻辑 */
        
        // 3. 存储结果
        memo[key] = result
        return result
    }
}
```

### 3. 状态压缩

```swift
// 使用位运算进行状态压缩
func dfsWithBitMask(_ pos: Int, _ visited: Int, _ n: Int) -> Int {
    // 使用整数的位表示访问状态
    if pos == n { return 1 }
    
    var count = 0
    for i in 0..<n {
        // 检查第i位是否被访问
        if (visited & (1 << i)) == 0 {
            // 将第i位标记为已访问
            count += dfsWithBitMask(pos + 1, visited | (1 << i), n)
        }
    }
    return count
}
```

## 五、常见问题和解决方案

### 1. 处理环

```swift
// 处理图中的环
func dfsWithCycleDetection(_ graph: [[Int]], _ node: Int, _ visited: inout Set<Int>) -> Bool {
    // 1. 标记当前节点为访问中
    visited.insert(node)
    
    // 2. 访问相邻节点
    for next in graph[node] {
        // 如果发现已访问的节点，说明有环
        if visited.contains(next) {
            return true
        }
        // 继续DFS
        if dfsWithCycleDetection(graph, next, &visited) {
            return true
        }
    }
    
    // 3. 回溯时移除标记
    visited.remove(node)
    return false
}
```

### 2. 避免重复访问

```swift
// 使用visited数组避免重复访问
func dfsWithVisited(_ grid: [[Int]], _ i: Int, _ j: Int, _ visited: inout Set<String>) {
    // 1. 创建位置标识
    let pos = "\(i),\(j)"
    
    // 2. 检查是否访问过
    if visited.contains(pos) { return }
    
    // 3. 标记为已访问
    visited.insert(pos)
    
    // 4. 继续DFS
    // ...
}
```

### 3. 处理无限递归

```swift
// 添加深度限制
func dfsWithDepthLimit(_ node: TreeNode?, _ depth: Int, _ limit: Int) -> Bool {
    // 1. 超过深度限制，返回
    if depth > limit { return false }
    
    // 2. 常规DFS逻辑
    guard let node = node else { return true }
    
    return dfsWithDepthLimit(node.left, depth + 1, limit) &&
           dfsWithDepthLimit(node.right, depth + 1, limit)
}
```

## 六、性能分析

### 1. 时间复杂度
- 树的DFS：O(n)，n为节点数
- 图的DFS：O(V + E)，V为顶点数，E为边数
- 全排列：O(n!)，n为数字个数

### 2. 空间复杂度
- 递归调用栈：O(h)，h为树的高度
- visited数组：O(V)，V为顶点数
- 解的存储：取决于具体问题

## 七、实战技巧

### 1. 写DFS的步骤
1. 确定递归参数和返回值
2. 确定终止条件
3. 确定单层递归逻辑
4. 考虑状态重置（回溯）

### 2. 调试技巧
1. 打印递归栈
2. 可视化搜索路径
3. 使用小规模测试用例

### 3. 代码模板

```swift
// DFS代码模板
func dfs(_ param: Type) -> ReturnType {
    // 1. 终止条件
    if 满足特定条件 {
        return 特定值
    }
    
    // 2. 标记当前状态
    标记
    
    // 3. 处理当前逻辑并递归
    for 每个可能的选择 {
        if 可以选择 {
            选择这个选项
            dfs(新的参数)
            撤销选择 // 回溯
        }
    }
    
    // 4. 恢复状态
    取消标记
}
```

## 八、总结

### 1. DFS的适用场景
- 树/图的遍历和搜索
- 排列组合问题
- 路径查找问题
- 连通性问题

### 2. DFS的优缺点
优点：
- 实现简单
- 空间效率高
- 适合搜索深层次结构

缺点：
- 可能栈溢出
- 不一定找到最短路径
- 时间复杂度可能较高

### 3. 实践建议
1. 先画图理解问题
2. 确定状态和选择
3. 考虑优化方案
4. 注意边界情况

## 九、练习题推荐

1. LeetCode 经典DFS题目：
   - #200 岛屿数量
   - #112 路径总和
   - #46 全排列
   - #79 单词搜索
   - #130 被围绕的区域

2. 进阶练习：
   - #301 删除无效的括号
   - #332 重新安排行程
   - #679 24点游戏