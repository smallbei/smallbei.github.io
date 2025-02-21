---
layout: post
title: "LeetCode经典BFS题目详解"
date: 2025-02-21
tags: "算法 BFS LeetCode 题解"
category: 
---

## 引言

在学习完BFS的基本概念和实现方式后，最好的学习方法就是通过实际问题来加深理解。本文将详细讲解几个经典的BFS题目，这些题目代表了BFS在不同场景下的应用：

1. 树的层次遍历 - 最基础的BFS应用
2. 图的遍历和搜索 - 处理网格和矩阵问题
3. 状态转换问题 - 寻找最短路径
4. 多源BFS - 处理多个起点的情况

通过这些题目，我们将看到BFS如何巧妙地解决各种实际问题。

## 解题通用思路

在开始具体题目之前，我们先明确使用BFS解题的基本步骤：

1. **识别BFS适用场景**
   - 需要逐层遍历或搜索
   - 需要找到最短路径
   - 需要处理层次关系

2. **确定关键要素**
   - 起点：从哪里开始搜索
   - 终点：搜索的目标是什么
   - 状态转换：如何从一个状态到达另一个状态

3. **实现框架**
   - 初始化队列和访问标记
   - 处理当前层的节点
   - 生成下一层的节点
   - 记录必要的信息（层数、路径等）

## 经典题目解析

### 一、二叉树的层序遍历（[LeetCode 102](https://leetcode.cn/problems/binary-tree-level-order-traversal/)）

这是最基础的BFS应用，也是理解BFS层次性的最好例子。

#### 1. 题目分析
- **目标**：按层返回树中节点的值
- **特点**：
  * 需要区分不同层的节点
  * 需要保持从左到右的顺序
  * 需要将每层的结果分开存储

#### 2. 解题思路
1. 使用队列存储每层的节点
2. 在处理每一层之前，先记录该层的节点数量
3. 处理完当前层所有节点后，再处理下一层

#### 3. 代码实现
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
    func levelOrder(_ root: TreeNode?) -> [[Int]] {
        // 存储最终结果：每个子数组代表一层的节点值
        var result: [[Int]] = []
        
        // 处理空树的特殊情况
        guard let root = root else { return result }
        
        // 初始化队列，将根节点入队
        // 使用数组模拟队列，先进先出（FIFO）
        var queue: [TreeNode] = [root]
        
        // BFS主循环：当队列不为空时继续处理
        while !queue.isEmpty {
            // 记录当前层的节点数量
            // 这一步很关键，它帮助我们区分不同层的节点
            let size = queue.count
            
            // 存储当前层的所有节点值
            var currentLevel: [Int] = []
            
            // 处理当前层的所有节点
            // 通过size控制循环次数，确保一次只处理一层的节点
            for _ in 0..<size {
                // 取出队首节点
                let node = queue.removeFirst()
                // 将节点值加入当前层数组
                currentLevel.append(node.val)
                
                // 将下一层的节点加入队列
                // 注意顺序：先左后右，保证从左到右的遍历顺序
                if let left = node.left {
                    queue.append(left)
                }
                if let right = node.right {
                    queue.append(right)
                }
            }
            
            // 将当前层的结果加入最终结果数组
            result.append(currentLevel)
        }
        
        return result
    }
}
```
#### 4. 执行过程演示
以下面的二叉树为例：

```
     3
    / \
   9  20
     /  \
    15   7
```

执行过程：

```
第1层：
- 队列：[3]
- 输出：[[3]]

第2层：
- 队列：[9, 20]
- 输出：[[3], [9,20]]

第3层：
- 队列：[15, 7]
- 输出：[[3], [9,20], [15,7]]
```

#### 5. 复杂度分析
- 时间复杂度：O(n)，每个节点都需要访问一次
- 空间复杂度：O(w)，w是树的最大宽度

### 二、岛屿数量（[LeetCode 200](https://leetcode.cn/problems/number-of-islands/)）

这是BFS在网格问题中的典型应用。

#### 1. 题目分析
- **目标**：计算二维网格中岛屿的数量
- **特点**：
  * 需要处理上下左右四个方向
  * 需要标记已访问的位置
  * 一个岛屿可能包含多个相连的陆地

#### 2. 解题思路
1. 遍历整个网格
2. 当找到一个陆地时，使用BFS访问整个岛屿
3. 将访问过的陆地标记为已访问
4. 岛屿数量就是启动BFS的次数

#### 3. 代码实现
```swift
class Solution {
    func numIslands(_ grid: [[Character]]) -> Int {
        // 创建可变副本，因为我们需要修改网格来标记已访问的位置
        var grid = grid
        var count = 0  // 记录岛屿数量
        let rows = grid.count
        let cols = grid[0].count
        
        // 定义四个方向：右、下、左、上
        // 使用方向数组可以简化代码，避免写四次类似的逻辑
        let directions = [(0,1), (1,0), (0,-1), (-1,0)]
        
        // BFS函数：访问整个岛屿
        func bfs(_ row: Int, _ col: Int) {
            // 创建队列并将起始位置入队
            var queue = [(row, col)]
            // 将起始位置标记为已访问（将陆地改为水）
            grid[row][col] = "0"
            
            // BFS主循环
            while !queue.isEmpty {
                // 取出当前位置
                let (r, c) = queue.removeFirst()
                
                // 检查四个方向
                for (dr, dc) in directions {
                    let newRow = r + dr
                    let newCol = c + dc
                    
                    // 检查新位置是否有效且是陆地
                    // 1. 边界检查
                    // 2. 确保是陆地（'1'）
                    if newRow >= 0 && newRow < rows &&
                       newCol >= 0 && newCol < cols &&
                       grid[newRow][newCol] == "1" {
                        // 将新位置加入队列
                        queue.append((newRow, newCol))
                        // 标记为已访问
                        grid[newRow][newCol] = "0"
                    }
                }
            }
        }
        
        // 遍历整个网格
        for i in 0..<rows {
            for j in 0..<cols {
                // 当找到一个陆地时
                if grid[i][j] == "1" {
                    // 使用BFS访问整个岛屿
                    bfs(i, j)
                    // 岛屿数量加1
                    count += 1
                }
            }
        }
        
        return count
    }
}
```

#### 4. 执行过程演示
以下面的网格为例：
```
1 1 0
1 0 0
0 0 1
```

执行过程：
```
第一次BFS：
1 1 0    0 0 0
1 0 0 -> 0 0 0
0 0 1    0 0 1
找到第一个岛屿，count = 1

第二次BFS：
0 0 0    0 0 0
0 0 0 -> 0 0 0
0 0 1    0 0 0
找到第二个岛屿，count = 2
```

#### 5. 复杂度分析
- 时间复杂度：O(M × N)，M和N是网格的维度
- 空间复杂度：O(min(M,N))，队列的大小

### 三、单词接龙（[LeetCode 127](https://leetcode.cn/problems/word-ladder/)）

这是BFS在状态转换问题中的应用，也是一个典型的最短路径问题。

#### 1. 题目分析
- **目标**：找到从起始单词到目标单词的最短转换序列长度
- **特点**：
  * 每次只能改变一个字母
  * 转换后的单词必须在词典中
  * 需要找到最短路径

#### 2. 解题思路
1. 将每个单词看作图中的一个节点
2. 如果两个单词只差一个字母，则它们之间有一条边
3. 使用BFS找到从起始单词到目标单词的最短路径

#### 3. 代码实现
```swift
class Solution {
    func ladderLength(_ beginWord: String, _ endWord: String, _ wordList: [String]) -> Int {
        // 将词典转换为Set以提高查找效率
        var wordSet = Set(wordList)
        
        // 特殊情况：如果目标词不在词典中，无法完成转换
        if !wordSet.contains(endWord) { return 0 }
        
        // 初始化队列，访问集合和层数
        var queue: [String] = [beginWord]
        var visited = Set<String>()  // 记录已访问的单词
        var level = 1  // 记录转换步数（层数）
        
        // BFS主循环
        while !queue.isEmpty {
            // 获取当前层的单词数量
            let size = queue.count
            
            // 处理当前层的所有单词
            for _ in 0..<size {
                let currentWord = queue.removeFirst()
                
                // 如果找到目标单词，返回当前层数
                if currentWord == endWord { return level }
                
                // 尝试改变当前单词的每个位置
                var chars = Array(currentWord)
                for i in 0..<chars.count {
                    // 保存原始字符，以便后续恢复
                    let original = chars[i]
                    
                    // 尝试所有可能的字母
                    for c in "abcdefghijklmnopqrstuvwxyz" {
                        chars[i] = c
                        let newWord = String(chars)
                        
                        // 检查新单词是否有效：
                        // 1. 在词典中
                        // 2. 未被访问过
                        if wordSet.contains(newWord) && !visited.contains(newWord) {
                            queue.append(newWord)
                            visited.insert(newWord)
                        }
                    }
                    
                    // 恢复原始字符，准备改变下一个位置
                    chars[i] = original
                }
            }
            
            // 当前层处理完毕，层数加1
            level += 1
        }
        
        // 无法找到转换序列
        return 0
    }
}
```

#### 4. 执行过程演示
```
beginWord = "hit", endWord = "cog"
wordList = ["hot","dot","dog","lot","log","cog"]

执行过程：
第1层：hit
第2层：hot
第3层：dot, lot
第4层：dog, log
第5层：cog

返回：5（表示需要5步转换）
```

#### 5. 复杂度分析
- 时间复杂度：O(26 × N × L)，N是单词数量，L是单词长度
- 空间复杂度：O(N)，存储访问过的单词

### 四、腐烂的橘子（[LeetCode 994](https://leetcode.cn/problems/rotting-oranges/)）

这是一个多源BFS问题，需要从多个起点同时开始搜索。

#### 1. 题目分析
- **目标**：求所有橘子腐烂需要的最小分钟数
- **特点**：
  * 需要处理上下左右四个方向
  * 需要标记已腐烂的橘子
  * 需要统计新鲜橘子数量

#### 2. 解题思路
1. 首先找到所有初始腐烂的橘子
2. 使用BFS模拟腐烂过程：
   - 将所有腐烂的橘子加入队列
   - 每一轮（一分钟）处理当前队列中的所有橘子
   - 记录每轮感染的新橘子
3. 最后检查是否还有新鲜橘子

#### 3. 代码实现
```swift
class Solution {
    func orangesRotting(_ grid: [[Int]]) -> Int {
        let rows = grid.count
        let cols = grid[0].count
        var grid = grid  // 创建可变副本
        var queue: [(Int, Int)] = []  // 存储腐烂橘子的位置
        var freshCount = 0  // 记录新鲜橘子的数量
        var minutes = 0  // 记录腐烂时间
        
        // 第一步：遍历网格，找到所有腐烂的橘子和统计新鲜橘子
        for i in 0..<rows {
            for j in 0..<cols {
                if grid[i][j] == 2 {  // 腐烂的橘子
                    queue.append((i, j))
                } else if grid[i][j] == 1 {  // 新鲜橘子
                    freshCount += 1
                }
            }
        }
        
        // 特殊情况：如果没有新鲜橘子，直接返回0
        if freshCount == 0 { return 0 }
        
        // 定义四个方向
        let directions = [(1,0), (-1,0), (0,1), (0,-1)]
        
        // BFS主循环：当队列不为空且还有新鲜橘子时继续
        while !queue.isEmpty && freshCount > 0 {
            let size = queue.count  // 当前层（分钟）的腐烂橘子数量
            
            // 处理当前分钟的所有腐烂橘子
            for _ in 0..<size {
                let (x, y) = queue.removeFirst()
                
                // 检查四个方向的相邻橘子
                for (dx, dy) in directions {
                    let newX = x + dx
                    let newY = y + dy
                    
                    // 检查新位置是否有效且是新鲜橘子
                    if newX >= 0 && newX < rows &&
                       newY >= 0 && newY < cols &&
                       grid[newX][newY] == 1 {
                        // 使这个橘子腐烂
                        grid[newX][newY] = 2
                        queue.append((newX, newY))
                        freshCount -= 1  // 新鲜橘子数量减1
                    }
                }
            }
            
            minutes += 1  // 时间流逝1分钟
        }
        
        // 如果还有新鲜橘子，返回-1；否则返回所用的分钟数
        return freshCount == 0 ? minutes : -1
    }
}
```