---
layout: post
title: "iOS 中的锁机制：概念、应用与性能对比"
date: 2025-04-28
tags: "iOS 多线程 锁 并发 线程安全"
category: iOS开发
---

## 引言

在 iOS 应用开发中，随着多线程编程的普及，锁机制成为保证线程安全、避免数据竞争的关键工具。当多个线程尝试同时访问共享资源时，如果不进行适当的同步控制，可能导致数据不一致、应用崩溃等问题。

本文将系统性地介绍 iOS 开发中常用的锁机制，从基本概念到具体实现，并通过性能对比帮助开发者选择适合自己场景的锁类型。

## 一、多线程与线程安全基本概念

在讨论锁机制之前，我们需要先理解几个基本概念：

### 1. 并发(Concurrency)与并行(Parallelism)

- **并发**：指程序的结构能够将多个独立的执行流（任务）组合起来。这些任务可能在单核处理器上通过时间片轮转交替执行。
- **并行**：指多个任务确实在同一时刻同时执行。这通常需要多核处理器支持。

### 2. 线程安全(Thread Safety)

指代码在多线程环境下能够正确地执行，不会因为多个线程的交替执行或并行执行而出现异常结果。

### 3. 临界区(Critical Section)

指访问共享资源的代码片段，这些代码必须以互斥的方式执行，确保同一时刻只有一个线程执行。

### 4. 死锁(Deadlock)

指两个或更多线程互相等待对方释放资源，导致所有线程永久阻塞的状态。

### 5. 锁的基本目的

锁的根本目的是保护共享资源，确保在同一时刻只有一个线程能够访问或修改这些资源。

## 二、iOS 中的锁机制分类

iOS/macOS 开发中可用的锁机制多种多样，它们在实现方式、性能特性和适用场景上各有不同。

### 1. 互斥锁 (Mutex)

互斥锁是最基本、使用最广泛的锁类型，它确保同一时刻只有一个线程能访问受保护的资源。互斥锁的核心特性：

- **独占访问**：一次只允许一个线程持有锁
- **阻塞等待**：其他尝试获取已被占用的锁的线程将被阻塞
- **顺序访问**：FIFO（先进先出）的公平性，避免线程饥饿
- **防止数据竞争**：确保共享资源的一致性和完整性

iOS/macOS 提供了多种互斥锁实现，从底层 C 语言接口到高级 Objective-C/Swift API。

#### a) pthread_mutex_t

来自 POSIX 线程库的低级别锁实现，提供了高效且可靠的互斥功能。这是 iOS/macOS 中大多数其他锁的基础实现。

```swift
// 完整示例：使用 pthread_mutex 保护银行账户余额
import Darwin.POSIX.pthread

class BankAccount {
    private var balance: Double
    private var mutex = pthread_mutex_t()
    
    init(initialBalance: Double) {
        self.balance = initialBalance
        pthread_mutex_init(&mutex, nil)
    }
    
    deinit {
        pthread_mutex_destroy(&mutex)
    }
    
    func deposit(amount: Double) {
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }
        
        balance += amount
        print("存款: \(amount), 当前余额: \(balance)")
    }
    
    func withdraw(amount: Double) -> Bool {
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }
        
        guard balance >= amount else {
            print("取款失败: 余额不足，当前余额: \(balance), 取款金额: \(amount)")
            return false
        }
        
        balance -= amount
        print("取款: \(amount), 当前余额: \(balance)")
        return true
    }
    
    func checkBalance() -> Double {
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }
        
        return balance
    }
}

// 使用示例：模拟多线程并发访问
func demonstrateMutexBankAccount() {
    let account = BankAccount(initialBalance: 1000)
    
    // 创建多个并发存款线程
    for i in 1...5 {
        DispatchQueue.global().async {
            account.deposit(Double(i * 100))
            Thread.sleep(forTimeInterval: 0.1)
        }
    }
    
    // 创建多个并发取款线程
    for i in 1...7 {
        DispatchQueue.global().async {
            _ = account.withdraw(Double(i * 150))
            Thread.sleep(forTimeInterval: 0.15)
        }
    }
    
    // 间隔查询余额
    DispatchQueue.global().async {
        for _ in 1...5 {
            Thread.sleep(forTimeInterval: 0.3)
            print("当前账户余额: \(account.checkBalance())")
        }
    }
}
```

pthread_mutex 提供以下主要特性：
- **类型灵活**：可配置为普通、递归、错误检查等类型
- **性能高效**：底层实现，开销较小
- **可靠性强**：POSIX 标准的一部分，经过长期验证
- **可用于 C/C++/Objective-C/Swift**：高度兼容性

#### b) NSLock

Foundation 框架提供的 Objective-C 风格的互斥锁，是对 pthread_mutex 的封装，提供了更面向对象的 API。

```swift
// 完整示例：线程安全的缓存实现
class ThreadSafeCache<Key: Hashable, Value> {
    private var cache: [Key: Value] = [:]
    private let lock = NSLock()
    
    func setValue(_ value: Value, forKey key: Key) {
        lock.lock()
        defer { lock.unlock() }
        
        cache[key] = value
        print("缓存键值对: [\(key): \(value)]")
    }
    
    func getValue(forKey key: Key) -> Value? {
        lock.lock()
        defer { lock.unlock() }
        
        return cache[key]
    }
    
    func removeValue(forKey key: Key) -> Value? {
        lock.lock()
        defer { lock.unlock() }
        
        let value = cache.removeValue(forKey: key)
        if value != nil {
            print("已删除键值对，键: \(key)")
        }
        return value
    }
    
    func removeAllValues() {
        lock.lock()
        defer { lock.unlock() }
        
        cache.removeAll()
        print("缓存已清空")
    }
    
    var count: Int {
        lock.lock()
        defer { lock.unlock() }
        
        return cache.count
    }
    
    var allKeys: [Key] {
        lock.lock()
        defer { lock.unlock() }
        
        return Array(cache.keys)
    }
}

// 使用示例：模拟多线程并发访问缓存
func demonstrateNSLockCache() {
    let cache = ThreadSafeCache<String, Int>()
    
    // 多个线程写入缓存
    for i in 1...5 {
        DispatchQueue.global().async {
            cache.setValue(i * 100, forKey: "key\(i)")
            Thread.sleep(forTimeInterval: 0.1)
        }
    }
    
    // 同时多个线程读取缓存
    for i in 1...5 {
        DispatchQueue.global().async {
            if let value = cache.getValue(forKey: "key\(i)") {
                print("读取缓存: key\(i) = \(value)")
            } else {
                print("缓存未命中: key\(i)")
            }
            Thread.sleep(forTimeInterval: 0.15)
        }
    }
    
    // 定期检查缓存状态
    DispatchQueue.global().async {
        for _ in 1...3 {
            Thread.sleep(forTimeInterval: 0.3)
            print("当前缓存条目数: \(cache.count), 键列表: \(cache.allKeys)")
        }
    }
    
    // 删除部分缓存
    DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
        cache.removeValue(forKey: "key1")
        cache.removeValue(forKey: "key3")
        print("当前缓存条目数: \(cache.count), 键列表: \(cache.allKeys)")
    }
}
```

NSLock 特性：
- **面向对象 API**：更符合 Objective-C/Swift 编程风格
- **自动内存管理**：无需手动初始化和销毁
- **尝试加锁方法**：提供 `try()` 方法，可在无法立即获取锁时返回而不阻塞
- **超时锁定**：支持 `lock(before:)` 方法，可设置超时时间

#### c) os_unfair_lock (iOS 10+)

这是 Apple 推荐的替代已废弃的 OSSpinLock 的选项，提供了更安全和高效的互斥锁实现。

```swift
// 完整示例：高性能计数器
import os.lock

class HighPerformanceCounter {
    private var count: Int = 0
    private var lock = os_unfair_lock_s()
    
    func increment() {
        os_unfair_lock_lock(&lock)
        count += 1
        os_unfair_lock_unlock(&lock)
    }
    
    func decrement() {
        os_unfair_lock_lock(&lock)
        count -= 1
        os_unfair_lock_unlock(&lock)
    }
    
    func getValue() -> Int {
        os_unfair_lock_lock(&lock)
        let value = count
        os_unfair_lock_unlock(&lock)
        return value
    }
}

// 使用示例：性能测试
func demonstrateUnfairLock() {
    let counter = HighPerformanceCounter()
    let iterationCount = 1_000_000
    
    // 测量大量递增操作的性能
    let start = Date()
    
    DispatchQueue.concurrentPerform(iterations: iterationCount) { _ in
        counter.increment()
    }
    
    let end = Date()
    let duration = end.timeIntervalSince(start)
    
    print("执行 \(iterationCount) 次递增操作用时: \(duration) 秒")
    print("最终计数: \(counter.getValue())")
}
```

os_unfair_lock 的特点：
- **高性能**：相比其他锁实现，具有更低的开销
- **避免优先级反转**：解决了 OSSpinLock 的优先级反转问题
- **轻量级**：占用内存小，适合频繁短期持有的场景
- **仅支持 iOS 10 及更高版本**

#### d) @synchronized (Objective-C)

虽然在 Swift 中不常用，但在 Objective-C 代码中，@synchronized 块是一种常见的互斥方式。

```objc
// Objective-C 示例
@implementation ThreadSafeObject

- (void)updateValue:(NSInteger)newValue {
    @synchronized (self) {
        _value = newValue;
        NSLog(@"值已更新为: %ld", (long)_value);
    }
}

- (NSInteger)currentValue {
    @synchronized (self) {
        return _value;
    }
}

@end
```

@synchronized 在 Swift 中的等效实现：

```swift
// Swift 中模拟 @synchronized
class ThreadSafeObject {
    private var value: Int = 0
    
    func updateValue(_ newValue: Int) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        value = newValue
        print("值已更新为: \(value)")
    }
    
    func currentValue() -> Int {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        return value
    }
}
```

#### e) 互斥锁使用场景对比

| 锁类型 | 优势 | 适用场景 | 性能 |
|-------|------|---------|------|
| pthread_mutex | 高度可配置，可靠性强 | 需要细粒度控制的场景，长时间持有锁 | 良好 |
| NSLock | 面向对象 API，易用性好 | 一般的 Swift/Objective-C 应用 | 良好 |
| os_unfair_lock | 性能最佳，内存占用小 | 高频短时锁定，对性能敏感的场景 | 优秀 |
| @synchronized | 语法简洁，自动处理锁生命周期 | Objective-C 代码中简单互斥需求 | 较低 |

#### f) 互斥锁最佳实践

1. **最小化锁的作用域**：只锁定真正需要保护的代码，减少锁持有时间
2. **使用 defer 释放锁**：确保在所有代码路径上都能正确释放锁
3. **避免在持有锁时执行耗时操作**：特别是 I/O 或网络操作
4. **根据性能需求选择合适的锁**：对性能敏感的代码使用 os_unfair_lock
5. **考虑锁竞争**：高竞争场景可能需要重新设计数据结构，减少共享
6. **避免嵌套锁**：防止死锁风险

#### g) 实际应用实例

互斥锁在 iOS 开发中的实际应用非常广泛：

1. **数据模型保护**：确保核心数据模型的线程安全
2. **配置管理**：保护应用配置的安全访问
3. **计数器和统计**：实现线程安全的计数和统计功能
4. **缓存系统**：保护内存缓存的一致性
5. **文件操作协调**：协调多线程环境下的文件读写

### 2. 递归锁 (Recursive Lock)

递归锁是一种特殊类型的互斥锁，允许同一个线程多次获取该锁而不会死锁。其核心特性：

- **同线程重入**：同一线程可以多次获取锁，但必须平衡解锁
- **计数机制**：内部维护获取次数计数，只有全部解锁后才释放资源
- **避免自锁死锁**：解决了同一线程内递归调用的锁问题
- **可预测性**：增强了复杂调用层次结构中的代码可预测性

递归锁在处理复杂调用关系、递归结构和层次化锁定需求时特别有用。

#### a) pthread_mutex_t (递归模式)

通过设置属性可以将标准的 pthread_mutex 配置为递归模式。

```swift
// 完整示例：带递归遍历功能的线程安全树结构
import Darwin.POSIX.pthread

// 简单树节点定义
class TreeNode {
    var value: String
    var children: [TreeNode]
    
    init(value: String, children: [TreeNode] = []) {
        self.value = value
        self.children = children
    }
}

// 线程安全的树管理器
class ThreadSafeTreeManager {
    private var rootNode: TreeNode?
    private var mutex = pthread_mutex_t()
    
    init() {
        // 初始化递归锁
        var attr = pthread_mutexattr_t()
        pthread_mutexattr_init(&attr)
        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE)
        pthread_mutex_init(&mutex, &attr)
        pthread_mutexattr_destroy(&attr)
    }
    
    deinit {
        pthread_mutex_destroy(&mutex)
    }
    
    // 设置根节点
    func setRoot(_ node: TreeNode) {
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }
        
        rootNode = node
    }
    
    // 查找节点 - 可能触发递归
    func findNode(withValue value: String) -> TreeNode? {
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }
        
        guard let root = rootNode else { return nil }
        return findNodeRecursive(value, in: root)
    }
    
    // 递归查找 - 在持有锁的情况下递归调用
    private func findNodeRecursive(_ value: String, in node: TreeNode) -> TreeNode? {
        // 注意：这里再次获取锁，如果不是递归锁会导致死锁！
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }
        
        // 检查当前节点
        if node.value == value {
            return node
        }
        
        // 递归检查子节点
        for child in node.children {
            if let found = findNodeRecursive(value, in: child) {
                return found
            }
        }
        
        return nil
    }
    
    // 添加子节点
    func addChild(_ child: TreeNode, toNodeWithValue parentValue: String) -> Bool {
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }
        
        guard let parent = findNodeRecursive(parentValue, in: rootNode!) else {
            return false
        }
        
        parent.children.append(child)
        return true
    }
    
    // 打印整个树 - 也是递归操作
    func printTree() {
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }
        
        guard let root = rootNode else {
            print("空树")
            return
        }
        
        printNodeRecursive(root, level: 0)
    }
    
    private func printNodeRecursive(_ node: TreeNode, level: Int) {
        // 再次获取锁
        pthread_mutex_lock(&mutex)
        defer { pthread_mutex_unlock(&mutex) }
        
        let indent = String(repeating: "  ", count: level)
        print("\(indent)- \(node.value)")
        
        for child in node.children {
            printNodeRecursive(child, level: level + 1)
        }
    }
}

// 使用示例
func demonstrateRecursiveMutex() {
    let treeManager = ThreadSafeTreeManager()
    
    // 创建一个简单的树结构
    let root = TreeNode(value: "Root")
    let child1 = TreeNode(value: "Child1")
    let child2 = TreeNode(value: "Child2")
    let grandChild1 = TreeNode(value: "GrandChild1")
    let grandChild2 = TreeNode(value: "GrandChild2")
    
    child1.children = [grandChild1]
    child2.children = [grandChild2]
    root.children = [child1, child2]
    
    treeManager.setRoot(root)
    
    // 在多线程环境下操作树
    DispatchQueue.global().async {
        treeManager.printTree()
    }
    
    DispatchQueue.global().async {
        if let node = treeManager.findNode(withValue: "Child1") {
            print("找到节点: \(node.value)")
        }
    }
    
    DispatchQueue.global().async {
        if treeManager.addChild(TreeNode(value: "NewChild"), toNodeWithValue: "Child2") {
            print("成功添加新节点")
            treeManager.printTree()
        }
    }
}
```

上面的例子展示了递归锁的关键应用场景：树遍历。如果使用普通互斥锁，在递归调用时会导致死锁，因为同一线程试图再次获取已经持有的锁。

#### b) NSRecursiveLock

Foundation 框架提供的递归锁实现，是对递归模式 pthread_mutex 的封装，提供更友好的 API。

```swift
// 完整示例：带缓存功能的表达式计算器
class RecursiveExpressionEvaluator {
    // 表达式类型
    enum Expression {
        case value(Int)
        case add(Expression, Expression)
        case multiply(Expression, Expression)
        case max(Expression, Expression)
    }
    
    private let lock = NSRecursiveLock()
    private var cache: [Expression: Int] = [:]
    
    // 递归计算表达式的值
    func evaluate(_ expression: Expression) -> Int {
        lock.lock()
        defer { lock.unlock() }
        
        // 检查缓存
        if let cachedResult = cache[expression] {
            print("缓存命中! 表达式结果: \(cachedResult)")
            return cachedResult
        }
        
        // 递归计算结果
        let result: Int
        switch expression {
        case .value(let value):
            result = value
            
        case .add(let left, let right):
            // 注意: 递归调用会再次获取锁
            result = evaluate(left) + evaluate(right)
            
        case .multiply(let left, let right):
            // 递归调用
            result = evaluate(left) * evaluate(right)
            
        case .max(let left, let right):
            // 递归调用
            result = max(evaluate(left), evaluate(right))
        }
        
        // 缓存结果
        cache[expression] = result
        print("计算表达式，结果: \(result)")
        return result
    }
    
    // 清除缓存
    func clearCache() {
        lock.lock()
        defer { lock.unlock() }
        
        cache.removeAll()
        print("缓存已清除")
    }
}

// 表达式的哈希和相等性实现 (省略具体实现)

// 使用示例
func demonstrateRecursiveLock() {
    let calculator = RecursiveExpressionEvaluator()
    
    // 创建表达式: (2 + 3) * max(4, 1+2)
    let expr1 = RecursiveExpressionEvaluator.Expression.add(
        .value(2), .value(3)
    )
    let expr2 = RecursiveExpressionEvaluator.Expression.max(
        .value(4), .add(.value(1), .value(2))
    )
    let expr3 = RecursiveExpressionEvaluator.Expression.multiply(expr1, expr2)
    
    // 多线程并发计算
    DispatchQueue.global().async {
        let result = calculator.evaluate(expr3)
        print("表达式结果: \(result)")
    }
    
    // 在不同线程中重用部分计算
    DispatchQueue.global().async {
        let partialResult = calculator.evaluate(expr1)
        print("部分表达式结果: \(partialResult)")
    }
    
    // 再次计算，验证缓存
    DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
        let result = calculator.evaluate(expr3)
        print("再次计算，表达式结果: \(result)")
    }
}
```

这个例子演示了递归锁在实现带缓存的表达式计算器中的应用，它允许在持有锁的情况下递归调用评估函数。

#### c) @synchronized 块的递归特性

在 Objective-C 中，@synchronized 块也具有递归特性：

```objc
// Objective-C 示例
@implementation RecursiveObject

- (void)recursiveOperation:(int)depth {
    @synchronized(self) {
        NSLog(@"深度: %d", depth);
        
        if (depth > 0) {
            // 递归调用，重复获取同一锁
            [self recursiveOperation:depth - 1];
        }
    }
}

@end
```

#### d) 递归锁 vs 普通互斥锁

| 特性 | 普通互斥锁 | 递归锁 |
|------|------------|--------|
| 同线程重入 | ❌ (会死锁) | ✅ |
| 递归调用支持 | ❌ | ✅ |
| 锁定计数 | 不跟踪 | 跟踪获取次数 |
| 性能 | 略高 | 略低(需要额外计数) |
| 适用场景 | 简单互斥 | 递归、嵌套调用 |

#### e) 递归锁的应用场景

递归锁特别适合以下场景:

1. **递归算法保护**：如树遍历、图搜索、分形计算等
2. **复杂对象图操作**：需要在持有锁的情况下导航对象关系
3. **嵌套锁需求**：API设计中可能需要在持有锁的情况下调用其他也会获取锁的方法
4. **框架/中间件开发**：当调用栈复杂且不可预测时
5. **代码重构安全网**：提供更大的灵活性，防止意外死锁

#### f) 递归锁的注意事项

尽管递归锁提供了便利，但也需注意：

1. **确保配对解锁**：每次lock()必须有对应的unlock()
2. **避免过度嵌套**：过深的递归调用仍可能导致栈溢出
3. **性能考量**：递归锁比普通互斥锁开销略大
4. **防止无限递归**：使用适当的终止条件
5. **设计替代方案**：在某些情况下，重构代码可能比使用递归锁更好

### 3. 读写锁 (Read-Write Lock)

读写锁是一种高级同步机制，它区分"读"和"写"两种操作，允许多个读者同时访问共享资源，但写入时必须独占访问。核心特性：

- **读者并发访问**：多个读者可以同时持有读锁
- **写者独占访问**：写者持有写锁时，排除所有其他读者和写者
- **读写互斥**：读者持有读锁时，写者必须等待
- **提高并发性能**：在读多写少的场景下显著提升性能

这种锁特别适合于读操作频繁而写操作较少的场景，比如配置数据、缓存系统、参考数据等。

#### a) pthread_rwlock_t

POSIX 线程库提供的读写锁实现，允许精细控制读写操作的同步。

```swift
// 完整示例：线程安全的配置管理器
import Darwin.POSIX.pthread

class ConfigurationManager {
    // 配置数据
    private var configurations: [String: Any] = [:]
    private var rwlock = pthread_rwlock_t()
    
    // 操作记录
    private var readCount = 0
    private var writeCount = 0
    
    init(defaultConfigs: [String: Any] = [:]) {
        // 初始化读写锁
        pthread_rwlock_init(&rwlock, nil)
        configurations = defaultConfigs
    }
    
    deinit {
        pthread_rwlock_destroy(&rwlock)
    }
    
    // 读取配置（允许并发）
    func getConfig(forKey key: String) -> Any? {
        pthread_rwlock_rdlock(&rwlock)
        defer { pthread_rwlock_unlock(&rwlock) }
        
        readCount += 1
        let value = configurations[key]
        print("读取配置[\(key)] = \(value ?? "nil"), 累计读取次数: \(readCount)")
        
        // 模拟读取耗时
        Thread.sleep(forTimeInterval: 0.01)
        
        return value
    }
    
    // 获取所有配置（读操作）
    func getAllConfigs() -> [String: Any] {
        pthread_rwlock_rdlock(&rwlock)
        defer { pthread_rwlock_unlock(&rwlock) }
        
        readCount += 1
        print("读取所有配置，累计读取次数: \(readCount)")
        
        // 模拟读取耗时
        Thread.sleep(forTimeInterval: 0.05)
        
        // 返回配置的副本
        return configurations
    }
    
    // 更新配置（写操作，独占）
    func updateConfig(value: Any, forKey key: String) {
        pthread_rwlock_wrlock(&rwlock)
        defer { pthread_rwlock_unlock(&rwlock) }
        
        writeCount += 1
        print("更新配置[\(key)] = \(value), 累计写入次数: \(writeCount)")
        
        // 模拟写入耗时
        Thread.sleep(forTimeInterval: 0.1)
        
        configurations[key] = value
    }
    
    // 批量更新配置（写操作，独占）
    func updateConfigs(with newConfigs: [String: Any]) {
        pthread_rwlock_wrlock(&rwlock)
        defer { pthread_rwlock_unlock(&rwlock) }
        
        writeCount += 1
        print("批量更新 \(newConfigs.count) 个配置项，累计写入次数: \(writeCount)")
        
        // 模拟写入耗时
        Thread.sleep(forTimeInterval: 0.2)
        
        for (key, value) in newConfigs {
            configurations[key] = value
        }
    }
    
    // 删除配置（写操作，独占）
    func removeConfig(forKey key: String) {
        pthread_rwlock_wrlock(&rwlock)
        defer { pthread_rwlock_unlock(&rwlock) }
        
        writeCount += 1
        print("删除配置[\(key)], 累计写入次数: \(writeCount)")
        
        // 模拟写入耗时
        Thread.sleep(forTimeInterval: 0.1)
        
        configurations.removeValue(forKey: key)
    }
}

// 使用示例：模拟读多写少的并发环境
func demonstrateReadWriteLock() {
    // 创建配置管理器
    let configManager = ConfigurationManager(defaultConfigs: [
        "timeout": 30,
        "maxRetries": 3,
        "apiEndpoint": "https://api.example.com"
    ])
    
    // 并发读取操作 (10个读线程)
    for i in 1...10 {
        DispatchQueue.global().async {
            for _ in 1...5 {
                if i % 3 == 0 {
                    let configs = configManager.getAllConfigs()
                    print("线程 \(i) 读取了 \(configs.count) 个配置项")
                } else {
                    let timeout = configManager.getConfig(forKey: "timeout")
                    print("线程 \(i) 读取超时配置: \(timeout ?? "nil")")
                }
                Thread.sleep(forTimeInterval: Double.random(in: 0.1...0.3))
            }
        }
    }
    
    // 少量写入操作 (2个写线程)
    for i in 1...2 {
        DispatchQueue.global().async {
            for j in 1...3 {
                switch j {
                case 1:
                    configManager.updateConfig(value: 45, forKey: "timeout")
                case 2:
                    configManager.updateConfigs(with: [
                        "maxRetries": 5,
                        "cacheEnabled": true
                    ])
                case 3:
                    configManager.removeConfig(forKey: "unused-key")
                default:
                    break
                }
                Thread.sleep(forTimeInterval: Double.random(in: 0.3...0.7))
            }
        }
    }
}
```

这个示例展示了读写锁在配置管理场景下的应用，体现了允许多个读取操作并发执行的优势。

#### b) 使用 GCD 的 dispatch_barrier 实现读写锁

GCD 提供了 barrier 操作，结合 concurrent queue 可以实现类似读写锁的功能，而且 API 更现代。

```swift
// 完整示例：高性能文章存储系统
class ArticleRepository {
    // 文章数据
    private var articles: [Int: Article] = [:]
    private let queue = DispatchQueue(label: "com.example.articleRepo", attributes: .concurrent)
    
    // 文章模型
    struct Article {
        let id: Int
        var title: String
        var content: String
        var tags: [String]
        var viewCount: Int
    }
    
    // 添加或更新文章 (写操作)
    func saveArticle(_ article: Article) {
        // 使用 barrier 确保独占访问
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            print("保存文章: \(article.title)")
            self.articles[article.id] = article
        }
    }
    
    // 批量保存文章 (写操作)
    func saveArticles(_ newArticles: [Article]) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            print("批量保存 \(newArticles.count) 篇文章")
            for article in newArticles {
                self.articles[article.id] = article
            }
        }
    }
    
    // 删除文章 (写操作)
    func deleteArticle(withId id: Int) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            if self.articles.removeValue(forKey: id) != nil {
                print("已删除文章 ID: \(id)")
            } else {
                print("未找到要删除的文章 ID: \(id)")
            }
        }
    }
    
    // 查找文章 (读操作)
    func getArticle(withId id: Int, completion: @escaping (Article?) -> Void) {
        // 普通异步操作，允许并发读取
        queue.async { [weak self] in
            guard let self = self else {
                completion(nil)
                return
            }
            
            let article = self.articles[id]
            if article != nil {
                print("读取文章: \(article!.title)")
            } else {
                print("未找到文章 ID: \(id)")
            }
            completion(article)
        }
    }
    
    // 搜索文章 (读操作)
    func searchArticles(withTag tag: String, completion: @escaping ([Article]) -> Void) {
        queue.async { [weak self] in
            guard let self = self else {
                completion([])
                return
            }
            
            let matchingArticles = self.articles.values.filter { $0.tags.contains(tag) }
            print("搜索标签 '\(tag)' 找到 \(matchingArticles.count) 篇文章")
            completion(matchingArticles)
        }
    }
    
    // 获取所有文章 (读操作)
    func getAllArticles(completion: @escaping ([Article]) -> Void) {
        queue.async { [weak self] in
            guard let self = self else {
                completion([])
                return
            }
            
            let allArticles = Array(self.articles.values)
            print("获取全部 \(allArticles.count) 篇文章")
            completion(allArticles)
        }
    }
    
    // 增加文章浏览次数 (需要读后写)
    func incrementViewCount(forArticleId id: Int, completion: @escaping (Bool) -> Void) {
        // 先读后写的操作，需要使用 barrier 确保一致性
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else {
                completion(false)
                return
            }
            
            guard var article = self.articles[id] else {
                print("无法增加阅读次数: 未找到文章 ID: \(id)")
                completion(false)
                return
            }
            
            article.viewCount += 1
            self.articles[id] = article
            print("文章 '\(article.title)' 阅读次数增加到 \(article.viewCount)")
            completion(true)
        }
    }
}

// 使用示例
func demonstrateDispatchBarrier() {
    let articleRepo = ArticleRepository()
    
    // 创建一些测试文章
    let articles = [
        ArticleRepository.Article(id: 1, title: "iOS 并发编程", content: "...", tags: ["iOS", "Swift", "Concurrency"], viewCount: 0),
        ArticleRepository.Article(id: 2, title: "SwiftUI 入门", content: "...", tags: ["iOS", "SwiftUI", "UI"], viewCount: 0),
        ArticleRepository.Article(id: 3, title: "Swift 并发新特性", content: "...", tags: ["Swift", "Concurrency", "Async/Await"], viewCount: 0)
    ]
    
    // 批量保存文章
    articleRepo.saveArticles(articles)
    
    // 模拟多用户并发阅读
    for _ in 1...20 {
        let randomId = Int.random(in: 1...3)
        DispatchQueue.global().async {
            articleRepo.getArticle(withId: randomId) { _ in }
        }
    }
    
    // 模拟搜索操作
    DispatchQueue.global().async {
        articleRepo.searchArticles(withTag: "Swift") { articles in
            for article in articles {
                print("- \(article.title)")
            }
        }
    }
    
    // 模拟记录阅读计数
    for _ in 1...10 {
        let randomId = Int.random(in: 1...3)
        DispatchQueue.global().async {
            articleRepo.incrementViewCount(forArticleId: randomId) { _ in }
        }
    }
    
    // 模拟内容更新
    DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
        let updatedArticle = ArticleRepository.Article(
            id: 2,
            title: "SwiftUI 入门 (更新版)",
            content: "更新的内容...",
            tags: ["iOS", "SwiftUI", "UI", "教程"],
            viewCount: 0
        )
        articleRepo.saveArticle(updatedArticle)
    }
    
    // 最后获取所有文章
    DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
        articleRepo.getAllArticles { allArticles in
            print("\n最终文章列表:")
            for article in allArticles {
                print("ID: \(article.id), 标题: \(article.title), 阅读次数: \(article.viewCount)")
            }
        }
    }
}
```

这个例子使用 GCD 的 barrier 实现了一个高性能的文章存储系统，适合读多写少的场景。

#### c) iOS 10+ os_unfair_lock 配合自定义实现读写锁

在某些情况下，你可能需要自定义读写锁的实现：

```swift
// 使用 os_unfair_lock 自定义实现读写锁
import os.lock

class CustomReadWriteLock {
    private var lock = os_unfair_lock_s()
    private var activeReaders: Int = 0
    private var pendingWriters: Int = 0
    private var isWriting: Bool = false
    
    // 获取读锁
    func lockForReading() {
        os_unfair_lock_lock(&lock)
        
        // 如果有写入者或等待的写入者，则需要等待
        while isWriting || pendingWriters > 0 {
            // 在实际实现中，这里需要使用条件变量
            // 这里简化为轮询
            os_unfair_lock_unlock(&lock)
            Thread.sleep(forTimeInterval: 0.001)
            os_unfair_lock_lock(&lock)
        }
        
        activeReaders += 1
        os_unfair_lock_unlock(&lock)
    }
    
    // 释放读锁
    func unlockForReading() {
        os_unfair_lock_lock(&lock)
        activeReaders -= 1
        os_unfair_lock_unlock(&lock)
    }
    
    // 获取写锁
    func lockForWriting() {
        os_unfair_lock_lock(&lock)
        
        pendingWriters += 1
        
        // 等待所有读者和其他写者
        while activeReaders > 0 || isWriting {
            // 在实际实现中，这里需要使用条件变量
            // 这里简化为轮询
            os_unfair_lock_unlock(&lock)
            Thread.sleep(forTimeInterval: 0.001)
            os_unfair_lock_lock(&lock)
        }
        
        pendingWriters -= 1
        isWriting = true
        os_unfair_lock_unlock(&lock)
    }
    
    // 释放写锁
    func unlockForWriting() {
        os_unfair_lock_lock(&lock)
        isWriting = false
        os_unfair_lock_unlock(&lock)
    }
}
```

> 注意：上面的自定义实现仅用于示例，实际生产环境应使用系统提供的读写锁或更成熟的实现。

#### d) 读写锁 vs 互斥锁性能对比

在大多数实际场景中，读写锁比互斥锁提供更好的并发性能，特别是在读操作频繁的情况下:

| 场景 | 互斥锁 | 读写锁 |
|-----|--------|-------|
| 全部是读操作 | 所有操作顺序执行 | 所有读操作并行执行 |
| 读操作为主，写操作少 | 所有操作顺序执行 | 读操作并行，只有写操作时才阻塞 |
| 全部是写操作 | 所有操作顺序执行 | 所有操作顺序执行，性能相当 |
| 写操作为主，读操作少 | 所有操作顺序执行 | 性能可能略低，因管理开销大 |

#### e) 读写锁的理想应用场景

读写锁最适合以下场景:

1. **内存缓存系统**：频繁的读取和不频繁的更新
2. **配置管理**：大多数时间都在读取配置，偶尔更新配置
3. **数据仓库**：读取频繁、更新不频繁的数据存储
4. **资源池管理**：资源状态频繁查询，状态改变较少
5. **观察者模式实现**：状态频繁被观察，但不经常变化

#### f) 读写锁的注意事项

使用读写锁时需注意：

1. **避免写者饥饿**：如果读操作太频繁，写操作可能长时间无法执行
2. **读锁不能升级为写锁**：如果已经持有读锁，不能直接升级为写锁（需要先释放读锁）
3. **性能开销**：读写锁内部逻辑比互斥锁复杂，管理开销略大
4. **可能导致死锁**：特别是尝试升级锁时
5. **写者公平性考虑**：某些实现可能会优先新请求的写者，导致等待的写者一直等待

### 4. 条件锁 (Condition Lock)

条件锁不仅提供互斥访问，还允许线程基于特定条件等待，直到其他线程改变了这个条件并发出信号。相比普通互斥锁，条件锁的最大优势在于：

- **避免忙等待**：线程可以休眠等待条件满足，而不是反复检查条件
- **精确的线程协作**：可以在特定条件满足时唤醒等待的线程
- **支持多线程通信模式**：特别适合于生产者-消费者、读者-写者等协作模式
- **资源节约**：与轮询相比，大大减少了CPU资源消耗

#### a) NSCondition

Foundation 框架提供的条件变量实现，结合了互斥锁和条件变量的功能。

```swift
// 示例代码：具有容量限制的线程安全队列
class BoundedQueue<T> {
    private var items: [T] = []
    private let condition = NSCondition()
    private let capacity: Int
    
    init(capacity: Int) {
        self.capacity = capacity
    }
    
    func enqueue(_ item: T) {
        condition.lock()
        defer { condition.unlock() }
        
        // 当队列已满时，等待消费者取出元素
        while items.count >= capacity {
            print("队列已满，生产者等待...")
            condition.wait()
        }
        
        items.append(item)
        print("生产者添加元素: \(item)")
        
        // 通知可能等待的消费者
        condition.signal()
    }
    
    func dequeue() -> T? {
        condition.lock()
        defer { condition.unlock() }
        
        // 当队列为空时，等待生产者添加元素
        while items.isEmpty {
            print("队列为空，消费者等待...")
            condition.wait()
        }
        
        let item = items.removeFirst()
        print("消费者取出元素: \(item)")
        
        // 通知可能等待的生产者
        condition.signal()
        
        return item
    }
}

// 使用示例
func demonstrateBoundedQueue() {
    let queue = BoundedQueue<Int>(capacity: 3)
    
    // 创建生产者线程
    DispatchQueue.global().async {
        for i in 1...10 {
            queue.enqueue(i)
            Thread.sleep(forTimeInterval: 0.2) // 模拟生产过程
        }
    }
    
    // 创建消费者线程
    DispatchQueue.global().async {
        for _ in 1...10 {
            _ = queue.dequeue()
            Thread.sleep(forTimeInterval: 0.5) // 模拟消费过程
        }
    }
}
```

这个示例中，`BoundedQueue` 实现了一个线程安全的有界队列：
- 当队列已满时，生产者线程会自动等待
- 当队列为空时，消费者线程会自动等待
- 条件锁保证了多线程环境下队列操作的安全性和高效性
- 无需使用轮询检查队列状态，节约CPU资源

NSCondition 的主要方法：
- `wait()`: 使当前线程等待，直到条件满足
- `wait(until:)`: 等待，直到条件满足或超时
- `signal()`: 唤醒一个等待的线程
- `broadcast()`: 唤醒所有等待的线程

#### b) NSConditionLock

一个更高级的条件锁，允许锁定和解锁基于特定条件值。每个 NSConditionLock 都维护一个整数条件值，线程可以等待特定的条件值。

```swift
// 示例代码：多阶段数据处理流水线
class DataProcessingPipeline {
    // 定义处理阶段
    enum Stage: Int {
        case notStarted = 0
        case dataLoaded = 1
        case dataProcessed = 2
        case analysisComplete = 3
        case finished = 4
    }
    
    private var data: [String] = []
    private var processedData: [Int] = []
    private var analysisResults: [String: Double] = [:]
    private let conditionLock = NSConditionLock(condition: Stage.notStarted.rawValue)
    
    // 阶段1：加载数据
    func loadData() {
        // 获取初始阶段的锁
        conditionLock.lock(whenCondition: Stage.notStarted.rawValue)
        print("开始加载数据...")
        
        // 模拟数据加载
        data = ["数据1", "数据2", "数据3", "数据4", "数据5"]
        Thread.sleep(forTimeInterval: 1)
        print("数据加载完成: \(data)")
        
        // 释放锁并将条件设置为下一阶段
        conditionLock.unlock(withCondition: Stage.dataLoaded.rawValue)
    }
    
    // 阶段2：处理数据
    func processData() {
        // 只有当数据已加载时才能获取锁
        conditionLock.lock(whenCondition: Stage.dataLoaded.rawValue)
        print("开始处理数据...")
        
        // 模拟数据处理
        processedData = data.map { $0.count * 10 }
        Thread.sleep(forTimeInterval: 1.5)
        print("数据处理完成: \(processedData)")
        
        // 释放锁并将条件设置为下一阶段
        conditionLock.unlock(withCondition: Stage.dataProcessed.rawValue)
    }
    
    // 阶段3：分析处理后的数据
    func analyzeData() {
        // 只有当数据已处理时才能获取锁
        conditionLock.lock(whenCondition: Stage.dataProcessed.rawValue)
        print("开始分析数据...")
        
        // 模拟数据分析
        for (i, value) in processedData.enumerated() {
            analysisResults["结果\(i)"] = Double(value) / 10.0
        }
        Thread.sleep(forTimeInterval: 1)
        print("数据分析完成: \(analysisResults)")
        
        // 释放锁并将条件设置为下一阶段
        conditionLock.unlock(withCondition: Stage.analysisComplete.rawValue)
    }
    
    // 阶段4：生成最终报告
    func generateReport() {
        // 只有当分析完成时才能获取锁
        conditionLock.lock(whenCondition: Stage.analysisComplete.rawValue)
        print("开始生成报告...")
        
        // 模拟报告生成
        var report = "数据处理报告:\n"
        for (key, value) in analysisResults {
            report += "- \(key): \(value)\n"
        }
        Thread.sleep(forTimeInterval: 0.8)
        print(report)
        
        // 释放锁并将条件设置为完成
        conditionLock.unlock(withCondition: Stage.finished.rawValue)
        print("整个流水线处理完成!")
    }
}

// 使用示例
func demonstrateProcessingPipeline() {
    let pipeline = DataProcessingPipeline()
    
    // 启动各个处理阶段
    DispatchQueue.global().async { pipeline.loadData() }
    DispatchQueue.global().async { pipeline.processData() }
    DispatchQueue.global().async { pipeline.analyzeData() }
    DispatchQueue.global().async { pipeline.generateReport() }
}
```

这个示例展示了 NSConditionLock 的强大之处：
- 实现了一个多阶段的数据处理流水线，每个阶段必须等待前一阶段完成
- 各个阶段可以在不同的线程上并发执行，但保持了严格的执行顺序
- 无需手动管理线程间的信号传递，条件锁自动处理了线程协调
- 代码结构清晰，每个处理阶段的依赖关系明确

#### c) NSCondition vs 其他锁的对比

| 功能特性 | 普通互斥锁(NSLock) | 条件锁(NSCondition) |
|---------|------------------|-------------------|
| 互斥访问 | ✓ | ✓ |
| 条件等待 | ✗ | ✓ |
| 线程协作 | 有限 | 丰富 |
| 避免忙等待 | ✗ | ✓ |
| 精确唤醒 | ✗ | ✓ |
| 适用场景 | 简单资源保护 | 生产者-消费者、多阶段处理 |

#### d) 实际应用场景

条件锁在iOS开发中有许多实际应用场景，例如：

1. **异步任务完成通知**：当耗时操作完成时，通知等待的线程继续执行
2. **资源池管理**：管理有限的资源，当资源可用时通知等待的线程
3. **数据缓冲区**：实现线程安全的缓冲区，用于线程间的数据传输
4. **工作队列**：实现任务分派系统，工作线程在任务到达时被唤醒
5. **状态同步**：在特定应用状态变化时协调多个线程的行为

条件锁相比简单的互斥锁，提供了更精细的线程控制和通信能力，能够高效地解决复杂的并发问题。

### 5. 自旋锁 (Spin Lock)

自旋锁在等待获取锁时会不断循环检查锁的状态，而不是让线程休眠。

> 注意：OS_SPINLOCK_DEPRECATED 自 iOS 10 起已废弃，不推荐使用原始的自旋锁，因为它可能导致优先级反转问题。

### 6. 无锁操作 (Lock-Free Operations)

一些操作可以通过原子性操作实现无锁同步。

#### a) OSAtomic 函数 (已弃用)

#### b) atomic 属性 (Objective-C)

#### c) Swift Atomics Package

Swift 5.3 后，Swift 团队推出了 Swift Atomics 包，提供低级别的原子操作。

```swift
// 示例代码 (需要导入 Swift Atomics 包)
import Atomics

class AtomicCounter {
    private var counter = ManagedAtomic<Int>(0)
    
    func increment() {
        counter.wrappingIncrement(ordering: .relaxed)
    }
    
    func getCount() -> Int {
        return counter.load(ordering: .relaxed)
    }
}
```

### 7. 信号量 (Semaphore)

信号量用于控制对资源的并发访问数量。

#### a) dispatch_semaphore_t (GCD)

```swift
// 示例代码
class ResourcePool {
    private let resources: [Resource]
    private let semaphore: DispatchSemaphore
    
    init(resources: [Resource]) {
        self.resources = resources
        // 创建一个计数等于资源数量的信号量
        self.semaphore = DispatchSemaphore(value: resources.count)
    }
    
    func useResource(completion: () -> Void) {
        // 等待一个资源变可用
        semaphore.wait()
        
        // 使用资源
        completion()
        
        // 释放资源
        semaphore.signal()
    }
}
```

## 三、锁的性能对比

各种锁机制在性能上有显著差异，选择合适的锁对应用性能有重要影响。以下是一个粗略的性能排序（从快到慢）：

1. **原子操作**：性能最高，但功能有限
2. **OSSpinLock**：性能很高，但有优先级反转问题（已弃用）
3. **unfair_lock**：iOS 10 引入，作为 OSSpinLock 的替代，性能接近
4. **dispatch_semaphore**：GCD 的信号量实现，性能较高
5. **pthread_mutex**：POSIX 互斥锁，性能良好
6. **NSLock**：基于 pthread_mutex 的 Objective-C 封装，性能轻微下降
7. **@synchronized**：便捷但性能较低，内部使用递归锁
8. **NSRecursiveLock**：递归锁，由于支持递归，性能略低

**实际性能测试示例**：

```swift
// 各类锁的性能测试代码
func performLockTest() {
    let iterations = 1_000_000
    var results: [String: TimeInterval] = [:]
    
    // 测试 pthread_mutex
    do {
        var mutex = pthread_mutex_t()
        pthread_mutex_init(&mutex, nil)
        
        let start = Date()
        for _ in 0..<iterations {
            pthread_mutex_lock(&mutex)
            pthread_mutex_unlock(&mutex)
        }
        results["pthread_mutex"] = Date().timeIntervalSince(start)
        
        pthread_mutex_destroy(&mutex)
    }
    
    // 测试 NSLock
    do {
        let lock = NSLock()
        
        let start = Date()
        for _ in 0..<iterations {
            lock.lock()
            lock.unlock()
        }
        results["NSLock"] = Date().timeIntervalSince(start)
    }
    
    // 测试 DispatchSemaphore
    do {
        let semaphore = DispatchSemaphore(value: 1)
        
        let start = Date()
        for _ in 0..<iterations {
            semaphore.wait()
            semaphore.signal()
        }
        results["DispatchSemaphore"] = Date().timeIntervalSince(start)
    }
    
    // 打印结果
    let sortedResults = results.sorted { $0.value < $1.value }
    for (name, time) in sortedResults {
        print("\(name): \(time) seconds")
    }
}
```

## 四、选择合适的锁

在选择锁时，需要考虑以下因素：

### 1. 使用场景

- **简单的互斥需求**：os_unfair_lock 或 NSLock
- **需要递归调用**：NSRecursiveLock
- **读多写少**：pthread_rwlock 或 dispatch_barrier
- **需要基于条件等待**：NSCondition 或 NSConditionLock
- **资源池管理**：DispatchSemaphore
- **简单的计数器或布尔标志**：原子操作

### 2. 性能要求

- 如果锁竞争频率高且锁持有时间短，考虑性能更高的选项如 unfair_lock
- 如果锁持有时间长，pthread_mutex 可能更合适，以避免浪费 CPU 时间

### 3. 代码复杂度

- NSLock 和其他 Foundation 类通常比 pthread 函数更易于使用
- GCD 的解决方案通常可以大大简化代码，特别是 serial queue 和 barrier

### 4. 平台支持和 API 稳定性

- 避免使用已废弃的 API，如 OSSpinLock
- 考虑跨平台需求，如果需要在 Linux 上运行，可能需要避免仅 Apple 平台支持的 API

## 五、锁相关最佳实践

### 1. 减少锁的粒度

尽量缩小锁保护的代码范围，只保护真正需要同步的部分。

```swift
// 不好的做法
func processData() {
    lock.lock()
    // 准备数据 - 可能不需要锁保护
    let data = prepareData()
    // 更新共享数据 - 需要锁保护
    updateSharedData(with: data)
    // 其他处理 - 可能不需要锁保护
    processResult()
    lock.unlock()
}

// 好的做法
func processData() {
    // 准备数据 - 不需要锁保护
    let data = prepareData()
    
    // 只在需要的地方使用锁
    lock.lock()
    updateSharedData(with: data)
    lock.unlock()
    
    // 其他处理 - 不需要锁保护
    processResult()
}
```

### 2. 避免死锁

- 按照一致的顺序获取多个锁
- 使用锁超时机制
- 使用锁层级来检测潜在的死锁风险

```swift
// 避免死锁的示例
class SafeTransfer {
    private let accountLock1 = NSLock()
    private let accountLock2 = NSLock()
    
    // 不好的做法 - 可能导致死锁
    func unsafeTransfer(amount: Double, fromAccount1: Bool) {
        if fromAccount1 {
            accountLock1.lock()
            accountLock2.lock()
        } else {
            accountLock2.lock()
            accountLock1.lock()
        }
        
        // 转账逻辑
        
        accountLock1.unlock()
        accountLock2.unlock()
    }
    
    // 好的做法 - 一致的锁定顺序
    func safeTransfer(amount: Double, fromAccount1: Bool) {
        // 总是先锁定编号较小的账户
        accountLock1.lock()
        accountLock2.lock()
        
        // 转账逻辑
        
        accountLock2.unlock()
        accountLock1.unlock()
    }
}
```

### 3. 考虑使用高级同步机制

在许多情况下，使用更高级的同步机制比直接使用锁更好：

- **DispatchQueue** 可以替代简单的互斥锁
- **Actors** (Swift 5.5+) 提供了安全的并发数据访问
- **AsyncSequence** 和其他新的并发 API

```swift
// 使用 DispatchQueue 代替锁
class ThreadSafeArray<T> {
    private var array: [T] = []
    private let queue = DispatchQueue(label: "com.example.array", attributes: .concurrent)
    
    func append(_ element: T) {
        queue.async(flags: .barrier) { [weak self] in
            self?.array.append(element)
        }
    }
    
    func element(at index: Int) -> T? {
        var result: T?
        queue.sync { [weak self] in
            guard let self = self, index < self.array.count else { return }
            result = self.array[index]
        }
        return result
    }
}

// 使用 Actor (Swift 5.5+)
actor ThreadSafeCollection<T> {
    private var items: [T] = []
    
    func add(_ item: T) {
        items.append(item)
    }
    
    func get(at index: Int) -> T? {
        guard index < items.count else { return nil }
        return items[index]
    }
}
```

### 4. 使用 defer 确保锁的释放

使用 `defer` 语句来确保锁在函数结束时总能被释放，避免因异常或提前返回导致的锁未释放问题。

```swift
func processWithLock() {
    lock.lock()
    defer { lock.unlock() }
    
    // 即使这里有异常或提前 return，锁也会被释放
    if someCondition {
        return
    }
    
    // 更多处理
}
```

## 六、现代 Swift 并发 (Swift 5.5+)

从 Swift 5.5 开始，Swift 语言引入了新的并发模型，许多情况下可以不再直接使用锁：

### 1. Actor 模型

Actor 提供了隔离状态的并发类型，保证其内部状态一次只能被一个任务访问。

```swift
actor BankAccount {
    private var balance: Double
    
    init(initialBalance: Double) {
        self.balance = initialBalance
    }
    
    func deposit(amount: Double) {
        balance += amount
    }
    
    func withdraw(amount: Double) throws -> Double {
        guard balance >= amount else {
            throw NSError(domain: "InsufficientFunds", code: 1, userInfo: nil)
        }
        balance -= amount
        return amount
    }
    
    func getBalance() -> Double {
        return balance
    }
}

// 使用
func transferMoney() async throws {
    let account = BankAccount(initialBalance: 1000)
    
    // 这些操作自动被序列化，无需手动锁定
    await account.deposit(amount: 200)
    let withdrawn = try await account.withdraw(amount: 500)
    let currentBalance = await account.getBalance()
    
    print("Withdrawn: \(withdrawn), Remaining: \(currentBalance)")
}
```

### 2. 结构化并发

Swift 的 async/await 模型和任务管理允许以更安全、更声明性的方式处理并发工作。

```swift
func processImages(urls: [URL]) async throws -> [UIImage] {
    // 并发处理所有图片，但结果仍能安全地合并
    return try await withThrowingTaskGroup(of: (Int, UIImage).self) { group in
        for (index, url) in urls.enumerated() {
            group.addTask {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard let image = UIImage(data: data) else {
                    throw NSError(domain: "ImageError", code: 1, userInfo: nil)
                }
                return (index, image)
            }
        }
        
        var images = [UIImage?](repeating: nil, count: urls.count)
        for try await (index, image) in group {
            images[index] = image
        }
        
        return images.compactMap { $0 }
    }
}
```

## 总结

锁机制是 iOS 并发编程的基本工具，选择合适的锁对于应用性能和正确性至关重要。在本文中，我们探讨了各种锁类型、它们的性能特性和适用场景。

对于 Swift 5.5+ 的开发者，优先考虑使用新的并发模型（如 Actor、async/await）来处理并发需求，这些工具往往能提供更好的安全性和可读性。但在某些特定场景下，或者与遗留代码交互时，仍需要了解和使用传统的锁机制。

无论采用哪种方式，理解并发问题的本质和安全处理共享资源的原则，永远是编写高质量并发代码的基础。 