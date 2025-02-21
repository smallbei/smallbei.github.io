---
layout: post
title: "广度优先搜索(BFS)详解：从入门到精通"
date: 2025-02-21
tags: "算法 BFS 搜索 数据结构"
category: 
---

## 一、BFS基本概念

### 1. 什么是BFS？

广度优先搜索（Breadth-First Search，简称BFS）是一种用于遍历或搜索树/图的算法。它的特点是：
- 从起点开始，逐层遍历
- 先访问离起点近的节点，再访问离起点远的节点
- 保证找到的路径是最短路径

想象你在一个游乐园里找朋友：
- 你先在当前位置环顾四周
- 然后向外扩展一圈，检查附近的区域
- 如此扩展下去，直到找到朋友
- 这就是BFS的基本思想

### 2. BFS中的核心数据结构：队列

队列（Queue）是BFS算法的核心数据结构，它具有以下特点：
- **先进先出（FIFO）**：最先加入队列的元素最先被处理
- **有序性**：保证了节点访问的顺序性，符合"逐层遍历"的需求
- **层次性**：通过队列可以方便地划分和处理每一层的节点

为什么BFS需要使用队列？
1. **保持顺序**：队列确保我们按照距离起点的远近顺序处理节点
2. **层次管理**：队列帮助我们追踪当前正在处理的层级
3. **状态记录**：队列存储了待处理的节点，避免重复访问

### 3. BFS的核心特征

1. **层次性**
   - 按层级顺序访问节点
   - 同一层的节点被一起处理
   - 确保距离起点相同的节点被同时访问

2. **最短路径**
   - 总是先找到最短路径
   - 适合解决最短距离问题
   - 路径长度等于层级深度

3. **完整性**
   - 保证访问所有可达节点
   - 不会遗漏任何可能的路径
   - 适合寻找所有可能解

### 4. BFS的优化方向：双向BFS

双向BFS是一种重要的优化技术，它的基本思想是：
- **同时从起点和终点开始搜索**
- **当两个搜索相遇时，就找到了最短路径**

为什么双向BFS能提高效率？
1. **搜索空间缩小**
   - 单向BFS：搜索空间呈指数增长，\(O(b^d)\)
   - 双向BFS：两端搜索空间各为\(O(b^{d/2})\)
   - 总体效果：\(O(b^{d/2} + b^{d/2}) << O(b^d)\)

2. **实际应用场景**
   - 起点和终点都已知
   - 搜索空间对称
   - 分支因子（每个节点的平均子节点数）较大

举例说明：
```
单向BFS：
第1层：1个节点
第2层：3个节点
第3层：9个节点
第4层：27个节点
总计：40个节点

双向BFS：
从起点：
第1层：1个节点
第2层：3个节点
从终点：
第1层：1个节点
第2层：3个节点
总计：8个节点
```

## 二、BFS的实现方式

### 1. 队列实现

```swift
// 二叉树的BFS遍历
class TreeNode {
    var val: Int
    var left: TreeNode?
    var right: TreeNode?
    
    init(_ val: Int) {
        self.val = val
    }
}

func bfs(_ root: TreeNode?) {
    // 1. 处理空树
    guard let root = root else { return }
    
    // 2. 创建队列并将根节点入队
    var queue: [TreeNode] = [root]
    
    // 3. 当队列不为空时循环
    while !queue.isEmpty {
        // 4. 获取当前层的节点数
        let size = queue.count
        
        // 5. 处理当前层的所有节点
        for _ in 0..<size {
            let node = queue.removeFirst()
            print(node.val)
            
            // 6. 将子节点加入队列
            if let left = node.left {
                queue.append(left)
            }
            if let right = node.right {
                queue.append(right)
            }
        }
    }
}

// 使用示例
let root = TreeNode(1)
root.left = TreeNode(2)
root.right = TreeNode(3)
bfs(root) // 输出: 1 2 3
```

### 2. 双向队列（Deque）实现

#### 什么是双向队列？
双向队列（Double-ended queue，简称Deque）是一种特殊的队列，它具有以下特点：
- 可以在队列的两端进行插入和删除操作
- 结合了栈（LIFO）和队列（FIFO）的特性
- 比普通队列更灵活，但实现也更复杂

为什么需要双向队列？
1. **性能优化**
   - 普通队列在头部删除元素的时间复杂度为O(n)
   - 双向队列可以在常数时间O(1)完成两端的操作
   - 适合需要频繁在两端操作的场景

2. **特殊场景处理**
   - 滑动窗口问题
   - 回文字符串判断
   - 需要同时支持FIFO和LIFO操作的场景

#### 双向队列的实现
```swift
// 双向队列的基本实现
class Deque<T> {
    // 使用数组作为底层存储
    private var array: [T] = []
    
    // 判断队列是否为空
    var isEmpty: Bool { array.isEmpty }
    
    // 获取队列大小
    var count: Int { array.count }
    
    // 查看队首元素
    var first: T? { array.first }
    
    // 查看队尾元素
    var last: T? { array.last }
    
    // 在队首添加元素 - O(1)
    func addFirst(_ element: T) {
        array.insert(element, at: 0)
    }
    
    // 在队尾添加元素 - O(1)
    func addLast(_ element: T) {
        array.append(element)
    }
    
    // 从队首移除元素 - O(1)
    func removeFirst() -> T? {
        guard !isEmpty else { return nil }
        return array.removeFirst()
    }
    
    // 从队尾移除元素 - O(1)
    func removeLast() -> T? {
        guard !isEmpty else { return nil }
        return array.removeLast()
    }
}

// 使用双向队列进行BFS遍历
func bfsWithDeque(_ root: TreeNode?) {
    guard let root = root else { return }
    
    let deque = Deque<TreeNode>()
    deque.addLast(root) // 将根节点加入队尾
    
    while !deque.isEmpty {
        // 获取当前层的节点数
        let levelSize = deque.count
        
        // 处理当前层的所有节点
        for _ in 0..<levelSize {
            // 从队首取出节点
            guard let node = deque.removeFirst() else { continue }
            print(node.val)
            
            // 将子节点加入队尾
            if let left = node.left {
                deque.addLast(left)
            }
            if let right = node.right {
                deque.addLast(right)
            }
        }
    }
}
```

#### 双向队列在BFS中的应用场景

1. **二叉树层次遍历优化**

问题描述：
给定一个二叉树，返回其按层序遍历得到的节点值。即逐层地，从左到右访问所有节点。

为什么使用双向队列？
- 普通数组在头部删除元素需要O(n)时间
- 双向队列在头部删除元素只需O(1)时间
- 对于大规模二叉树，性能提升明显

解题思路：
1. 使用双向队列存储每层节点
2. 每次处理一层时，记录当前层的节点数
3. 从队首取出节点处理，从队尾添加子节点
4. 重复这个过程直到队列为空

```swift
// 使用双向队列优化层次遍历
func levelOrderWithDeque(_ root: TreeNode?) -> [[Int]] {
    var result: [[Int]] = []
    guard let root = root else { return result }
    
    let deque = Deque<TreeNode>()
    deque.addLast(root)
    
    while !deque.isEmpty {
        let levelSize = deque.count
        var currentLevel: [Int] = []
        
        for _ in 0..<levelSize {
            if let node = deque.removeFirst() {
                currentLevel.append(node.val)
                
                // 从左到右添加子节点
                if let left = node.left {
                    deque.addLast(left)
                }
                if let right = node.right {
                    deque.addLast(right)
                }
            }
        }
        
        result.append(currentLevel)
    }
    
    return result
}
```

2. **滑动窗口最大值**

问题描述：
给定一个数组 nums 和一个大小为 k 的滑动窗口，这个窗口从数组的最左侧移动到最右侧，每次只能看到窗口内的 k 个数字。滑动窗口每次向右移动一位，求每个窗口中的最大值。

例如：
```
输入: nums = [1,3,-1,-3,5,3,6,7], k = 3
输出: [3,3,5,5,6,7]
解释:
  滑动窗口的位置                最大值
---------------               -----
[1  3  -1] -3  5  3  6  7      3
 1 [3  -1  -3] 5  3  6  7      3
 1  3 [-1  -3  5] 3  6  7      5
 1  3  -1 [-3  5  3] 6  7      5
 1  3  -1  -3 [5  3  6] 7      6
 1  3  -1  -3  5 [3  6  7]     7
```

为什么使用双向队列？
- 需要在O(1)时间内获取窗口最大值
- 需要高效地维护一个单调递减序列
- 双向队列可以同时支持队首队尾的操作

解题思路：
1. 使用双向队列存储元素下标
2. 保持队列中的元素单调递减
3. 移除窗口外的元素（从队首）
4. 移除小于当前元素的值（从队尾）
5. 队首元素即为当前窗口最大值

```swift
// 使用双向队列解决滑动窗口最大值问题
func maxSlidingWindow(_ nums: [Int], _ k: Int) -> [Int] {
    var result: [Int] = []
    let deque = Deque<Int>() // 存储索引
    
    for i in 0..<nums.count {
        // 移除窗口外的元素
        while !deque.isEmpty && deque.first! < i - k + 1 {
            _ = deque.removeFirst()
        }
        
        // 移除所有小于当前元素的值
        while !deque.isEmpty && nums[deque.last!] < nums[i] {
            _ = deque.removeLast()
        }
        
        // 添加当前元素
        deque.addLast(i)
        
        // 当窗口形成后，记录最大值
        if i >= k - 1 {
            result.append(nums[deque.first!])
        }
    }
    
    return result
}
```

3. **回文字符串判断**

问题描述：
给定一个字符串，判断它是否是回文串。只考虑字母和数字字符，忽略大小写。

例如：
```
输入: "A man, a plan, a canal: Panama"
输出: true
解释: "amanaplanacanalpanama" 是回文串

输入: "race a car"
输出: false
解释: "raceacar" 不是回文串
```

为什么使用双向队列？
- 需要同时从字符串的两端进行比较
- 双向队列可以高效地进行首尾操作
- 避免了创建新的字符串副本

解题思路：
1. 将有效字符（字母和数字）依次加入双向队列
2. 同时从队列两端取出字符进行比较
3. 如果所有字符都匹配，则是回文串
4. 如果出现不匹配，则不是回文串

```swift
// 使用双向队列判断回文字符串
func isPalindrome(_ s: String) -> Bool {
    let deque = Deque<Character>()
    
    // 将字符加入双向队列
    for char in s.lowercased() where char.isLetter || char.isNumber {
        deque.addLast(char)
    }
    
    // 从两端比较字符
    while deque.count > 1 {
        if deque.removeFirst() != deque.removeLast() {
            return false
        }
    }
    
    return true
}

// 使用示例
let s1 = "A man, a plan, a canal: Panama"
print(isPalindrome(s1)) // 输出: true

let s2 = "race a car"
print(isPalindrome(s2)) // 输出: false
```

通过这些实际应用场景，我们可以看到双向队列在不同类型的问题中的优势：
1. 在层次遍历中提供了更高效的节点访问
2. 在滑动窗口问题中维护了单调序列
3. 在回文串判断中简化了首尾比较操作

## 三、实际应用示例

### 1. 二叉树的层序遍历

问题描述：
给定一个二叉树，返回其按层序遍历得到的节点值。即逐层地，从左到右访问所有节点。

```swift
class Solution {
    func levelOrder(_ root: TreeNode?) -> [[Int]] {
        var result: [[Int]] = []
        guard let root = root else { return result }
        
        var queue: [TreeNode] = [root]
        
        while !queue.isEmpty {
            let size = queue.count
            var currentLevel: [Int] = []
            
            for _ in 0..<size {
                let node = queue.removeFirst()
                currentLevel.append(node.val)
                
                if let left = node.left {
                    queue.append(left)
                }
                if let right = node.right {
                    queue.append(right)
                }
            }
            
            result.append(currentLevel)
        }
        
        return result
    }
}

// 使用示例
/*
     3
    / \
   9  20
     /  \
    15   7

输出: [
  [3],
  [9,20],
  [15,7]
]
*/
```

### 2. 最短路径问题

问题描述：
在一个二维网格中，1表示陆地，0表示水域。找到从起点到终点的最短路径长度。只能上下左右移动。

```swift
class Solution {
    func shortestPath(_ grid: [[Int]], _ start: (Int, Int), _ end: (Int, Int)) -> Int {
        let rows = grid.count
        let cols = grid[0].count
        let directions = [(0,1), (1,0), (0,-1), (-1,0)]
        
        var queue: [(Int, Int)] = [start]
        var visited = Set<String>()
        var steps = 0
        
        // 将坐标转换为唯一标识符
        func getKey(_ pos: (Int, Int)) -> String {
            return "\(pos.0),\(pos.1)"
        }
        
        // 标记起点为已访问
        visited.insert(getKey(start))
        
        while !queue.isEmpty {
            let size = queue.count
            
            for _ in 0..<size {
                let current = queue.removeFirst()
                
                // 到达终点
                if current == end {
                    return steps
                }
                
                // 尝试四个方向
                for (dx, dy) in directions {
                    let newX = current.0 + dx
                    let newY = current.1 + dy
                    let newPos = (newX, newY)
                    let key = getKey(newPos)
                    
                    // 检查边界和是否可行
                    if newX >= 0 && newX < rows &&
                       newY >= 0 && newY < cols &&
                       grid[newX][newY] == 1 &&
                       !visited.contains(key) {
                        queue.append(newPos)
                        visited.insert(key)
                    }
                }
            }
            
            steps += 1
        }
        
        return -1 // 无法到达终点
    }
}

// 使用示例
let grid = [
    [1,1,0,0],
    [1,1,0,0],
    [1,1,1,1],
    [0,0,0,1]
]
let solution = Solution()
let result = solution.shortestPath(grid, (0,0), (3,3))
print("最短路径长度：\(result)") // 输出：6
```

### 3. 单词接龙问题

问题描述：
给定两个单词（起始单词和结束单词）和一个字典，找出从起始单词到结束单词的最短转换序列的长度。每次转换只能改变一个字母。

```swift
class Solution {
    func ladderLength(_ beginWord: String, _ endWord: String, _ wordList: [String]) -> Int {
        // 将wordList转换为Set以提高查找效率
        var wordSet = Set(wordList)
        
        // 如果结束单词不在字典中，无法完成转换
        if !wordSet.contains(endWord) {
            return 0
        }
        
        // 创建队列并将起始单词入队
        var queue: [String] = [beginWord]
        var visited = Set<String>()
        var level = 1
        
        while !queue.isEmpty {
            let size = queue.count
            
            for _ in 0..<size {
                let currentWord = queue.removeFirst()
                
                // 找到结束单词
                if currentWord == endWord {
                    return level
                }
                
                // 尝试改变每个位置的字母
                var wordArray = Array(currentWord)
                for i in 0..<wordArray.count {
                    let originalChar = wordArray[i]
                    
                    // 尝试所有可能的字母
                    for c in "abcdefghijklmnopqrstuvwxyz" {
                        wordArray[i] = c
                        let newWord = String(wordArray)
                        
                        // 如果新单词在字典中且未访问过
                        if wordSet.contains(newWord) && !visited.contains(newWord) {
                            queue.append(newWord)
                            visited.insert(newWord)
                        }
                    }
                    
                    // 恢复原始字母
                    wordArray[i] = originalChar
                }
            }
            
            level += 1
        }
        
        return 0 // 无法完成转换
    }
}

// 使用示例
let beginWord = "hit"
let endWord = "cog"
let wordList = ["hot","dot","dog","lot","log","cog"]
let solution = Solution()
print("最短转换序列长度：\(solution.ladderLength(beginWord, endWord, wordList))") // 输出：5
// 转换序列：hit -> hot -> dot -> dog -> cog
```

## 四、BFS的优化技巧

### 1. 双向BFS

双向BFS的实现需要考虑以下几个关键点：

1. **两个搜索集合的管理**
   - 分别维护起点集合和终点集合
   - 选择较小的集合进行扩展（优化策略）
   - 检测两个集合是否相交

2. **访问状态的记录**
   - 记录每个节点的访问状态
   - 避免重复访问
   - 检测是否找到路径

```swift
// 双向BFS基础模板
func bidirectionalBFS(_ start: String, _ end: String, _ wordSet: Set<String>) -> Int {
    // 1. 特殊情况处理
    guard wordSet.contains(end) else { return 0 }
    
    // 2. 初始化两端的搜索集合
    var beginSet: Set<String> = [start]
    var endSet: Set<String> = [end]
    var visited: Set<String> = []
    var level = 1
    
    // 3. 当两端都还有节点时继续搜索
    while !beginSet.isEmpty && !endSet.isEmpty {
        // 4. 优化：选择较小的集合进行扩展
        if beginSet.count > endSet.count {
            let temp = beginSet
            beginSet = endSet
            endSet = temp
        }
        
        // 5. 扩展选定的集合
        var nextLevel: Set<String> = []
        for word in beginSet {
            // 6. 生成所有可能的下一步状态
            let nextStates = getNextStates(word)
            
            for nextWord in nextStates {
                // 7. 如果另一端已经访问过这个状态，说明找到了最短路径
                if endSet.contains(nextWord) {
                    return level + 1
                }
                
                // 8. 否则，如果这是一个有效且未访问的状态，加入下一层
                if wordSet.contains(nextWord) && !visited.contains(nextWord) {
                    nextLevel.insert(nextWord)
                    visited.insert(nextWord)
                }
            }
        }
        
        // 9. 更新搜索集合和层数
        beginSet = nextLevel
        level += 1
    }
    
    return 0 // 未找到路径
}

// 辅助函数：生成下一步可能的状态
func getNextStates(_ word: String) -> [String] {
    var result: [String] = []
    var chars = Array(word)
    
    for i in 0..<chars.count {
        let original = chars[i]
        for c in "abcdefghijklmnopqrstuvwxyz" {
            chars[i] = c
            result.append(String(chars))
        }
        chars[i] = original
    }
    
    return result
}
```

### 2. 状态压缩

```swift
// 使用位运算进行状态压缩
func bfsWithBitMask(_ start: Int, _ target: Int, _ n: Int) -> Int {
    var queue: [Int] = [start]
    var visited = Set<Int>()
    var level = 0
    
    while !queue.isEmpty {
        let size = queue.count
        
        for _ in 0..<size {
            let current = queue.removeFirst()
            
            if current == target {
                return level
            }
            
            // 使用位运算生成下一状态
            for i in 0..<n {
                let next = current ^ (1 << i)
                if !visited.contains(next) {
                    queue.append(next)
                    visited.insert(next)
                }
            }
        }
        
        level += 1
    }
    
    return -1
}
```

### 3. 记忆化搜索

```swift
// 带记忆化的BFS
func bfsWithMemo(_ start: String, _ target: String, _ dict: Set<String>) -> Int {
    var memo: [String: Int] = [:]
    var queue: [(String, Int)] = [(start, 0)]
    
    while !queue.isEmpty {
        let (current, steps) = queue.removeFirst()
        
        // 检查记忆化存储
        if let cached = memo[current] {
            if cached <= steps {
                continue
            }
        }
        
        // 更新记忆化存储
        memo[current] = steps
        
        // 生成下一步可能的状态
        // ...
    }
    
    return memo[target] ?? -1
}
```

## 五、常见问题和解决方案

### 1. 处理环

```swift
// 处理图中的环
func bfsWithCycleDetection(_ graph: [[Int]], _ start: Int) -> [Int] {
    var queue: [Int] = [start]
    var visited = Set<Int>()
    var parent: [Int: Int] = [:]
    
    visited.insert(start)
    
    while !queue.isEmpty {
        let current = queue.removeFirst()
        
        for next in graph[current] {
            if visited.contains(next) {
                // 检测到环
                if parent[current] != next {
                    // 找到一个非父子关系的已访问节点
                    return reconstructCycle(current, next, parent)
                }
            } else {
                visited.insert(next)
                parent[next] = current
                queue.append(next)
            }
        }
    }
    
    return []
}
```

### 2. 多源BFS

```swift
// 多源BFS示例
func multiSourceBFS(_ grid: [[Int]], _ sources: [(Int, Int)]) -> [[Int]] {
    var result = Array(repeating: Array(repeating: Int.max, count: grid[0].count), 
                      count: grid.count)
    var queue = sources
    
    // 初始化源点距离
    for (x, y) in sources {
        result[x][y] = 0
    }
    
    let directions = [(0,1), (1,0), (0,-1), (-1,0)]
    var distance = 0
    
    while !queue.isEmpty {
        distance += 1
        let size = queue.count
        
        for _ in 0..<size {
            let (x, y) = queue.removeFirst()
            
            for (dx, dy) in directions {
                let newX = x + dx
                let newY = y + dy
                
                if newX >= 0 && newX < grid.count &&
                   newY >= 0 && newY < grid[0].count &&
                   result[newX][newY] == Int.max {
                    result[newX][newY] = distance
                    queue.append((newX, newY))
                }
            }
        }
    }
    
    return result
}
```

### 3. 带权BFS

```swift
// 带权BFS（使用优先队列）
struct PriorityQueue<T> {
    private var elements: [(T, Int)]
    private let comparator: (Int, Int) -> Bool
    
    init(comparator: @escaping (Int, Int) -> Bool) {
        self.elements = []
        self.comparator = comparator
    }
    
    mutating func enqueue(_ element: T, priority: Int) {
        elements.append((element, priority))
        siftUp(from: elements.count - 1)
    }
    
    mutating func dequeue() -> (T, Int)? {
        guard !elements.isEmpty else { return nil }
        
        elements.swapAt(0, elements.count - 1)
        let result = elements.removeLast()
        if !elements.isEmpty {
            siftDown(from: 0)
        }
        return result
    }
    
    private mutating func siftUp(from index: Int) {
        var child = index
        var parent = (child - 1) / 2
        
        while child > 0 && comparator(elements[child].1, elements[parent].1) {
            elements.swapAt(child, parent)
            child = parent
            parent = (child - 1) / 2
        }
    }
    
    private mutating func siftDown(from index: Int) {
        var parent = index
        
        while true {
            var candidate = parent
            let leftChild = 2 * parent + 1
            let rightChild = 2 * parent + 2
            
            if leftChild < elements.count && 
               comparator(elements[leftChild].1, elements[candidate].1) {
                candidate = leftChild
            }
            
            if rightChild < elements.count && 
               comparator(elements[rightChild].1, elements[candidate].1) {
                candidate = rightChild
            }
            
            if candidate == parent {
                return
            }
            
            elements.swapAt(parent, candidate)
            parent = candidate
        }
    }
}
```

## 六、性能分析

### 1. 时间复杂度
- 树的BFS：O(n)，n为节点数
- 图的BFS：O(V + E)，V为顶点数，E为边数
- 带权BFS：O((V + E) * log V)

### 2. 空间复杂度
- 队列存储：O(w)，w为最宽层的节点数
- 访问标记：O(V)，V为顶点数
- 双向BFS：O(2^(d/2))，d为最短路径长度

## 七、实战技巧

### 1. 写BFS的步骤
1. 创建队列和访问标记集合
2. 将起点加入队列
3. 循环处理队列中的节点
4. 记录层次信息（如果需要）

### 2. 调试技巧
1. 打印队列状态
2. 可视化搜索过程
3. 使用小规模测试用例

### 3. 代码模板

```swift
// BFS代码模板
func bfs(_ start: State) -> Result {
    // 1. 初始化数据结构
    var queue: [State] = [start]
    var visited = Set<State>()
    var level = 0
    
    // 2. 标记起点
    visited.insert(start)
    
    // 3. BFS主循环
    while !queue.isEmpty {
        let size = queue.count
        
        // 处理当前层
        for _ in 0..<size {
            let current = queue.removeFirst()
            
            // 检查是否到达目标
            if isTarget(current) {
                return buildResult(current, level)
            }
            
            // 生成下一层状态
            for next in getNextStates(current) {
                if !visited.contains(next) {
                    queue.append(next)
                    visited.insert(next)
                }
            }
        }
        
        level += 1
    }
    
    return defaultResult
}
```

## 八、总结

### 1. BFS的适用场景
- 最短路径问题
- 层序遍历
- 连通性问题
- 状态转换问题

### 2. BFS的优缺点
优点：
- 保证找到最短路径
- 适合处理层次性问题
- 不会栈溢出

缺点：
- 空间消耗大
- 不适合深度优先的场景
- 实现相对复杂

### 3. 实践建议
1. 选择合适的数据结构
2. 注意边界条件处理
3. 考虑优化方案
4. 处理好访问标记

## 九、练习题推荐

1. LeetCode 经典BFS题目：
   - #102 二叉树的层序遍历
   - #127 单词接龙
   - #200 岛屿数量
   - #207 课程表
   - #994 腐烂的橘子

2. 进阶练习：
   - #126 单词接龙 II
   - #317 离建筑物最近的距离
   - #815 公交路线
   - #1293 网格中的最短路径