---
layout: post
title: "iOS GCD 线程管理详解：从原理到实践"
date: 2025-04-28 10:00:00 +0800
tags: [iOS, Swift, GCD, 多线程, 性能优化]
categories: [iOS开发]
---

# iOS GCD 线程管理详解：从原理到实践

## 引言

在 iOS 开发中，为了提供流畅的用户体验，我们经常需要处理耗时操作，如网络请求、文件读写和复杂计算。这些操作如果在主线程执行，会导致 UI 卡顿。因此，合理的线程管理成为了高质量 iOS 应用不可或缺的一部分。

本文将深入探讨 Grand Central Dispatch (GCD) 的工作原理和最佳实践，帮助你掌握 iOS 线程管理的核心技术。

## 一、GCD 基础概念

### 1. 什么是 GCD？

Grand Central Dispatch (GCD) 是 Apple 为多核处理器开发的线程管理技术，它提供了一种抽象的方式来处理并发操作，而无需手动管理线程生命周期。

GCD 的核心思想是：**将任务提交到队列，由系统管理线程池来执行这些任务**。这种方式极大地简化了多线程编程。

### 2. GCD 的核心组件

GCD 的基本结构包含两个核心组件：

* **队列（Queue）**：存放任务的容器
* **任务（Task）**：需要执行的代码块

## 二、队列类型与线程创建的关系

理解 GCD 队列与线程创建之间的关系是掌握 GCD 的关键。很多开发者对此存在误解，以下是详细说明：

### 1. 队列与线程的关系

首先，明确一个重要概念：**队列不等于线程**。

* **队列**是任务的容器，负责任务的组织和分发
* **线程**是实际执行任务的系统资源

GCD 维护了一个全局的线程池，根据系统负载动态调整线程数量。当你向队列提交任务时，GCD 会从线程池中选择合适的线程来执行任务，或在必要时创建新线程。

### 2. 队列类型对线程创建的影响

GCD 中有两种基本类型的队列：

#### 串行队列（Serial Queue）

* 一次只执行一个任务
* 任务按照先进先出（FIFO）的顺序执行
* **不一定只使用一个线程**，但同一时间只有一个任务在执行

```swift
let serialQueue = DispatchQueue(label: "com.example.serial")
```

#### 并发队列（Concurrent Queue）

* 可以同时执行多个任务
* 任务开始执行的顺序是 FIFO，但完成顺序不确定
* 可以利用多个线程并行执行任务

```swift
let concurrentQueue = DispatchQueue(label: "com.example.concurrent", 
                                   attributes: .concurrent)
```

### 3. 任务执行方式与线程创建

任务执行方式也会影响线程的创建和使用：

#### 同步执行（Sync）

* 阻塞当前线程，直到任务完成
* **不会创建新线程**，而是在当前线程执行任务
* 任务完成后，才会继续执行后续代码

```swift
queue.sync {
    // 在当前线程同步执行，不会创建新线程
}
```

#### 异步执行（Async）

* 不阻塞当前线程
* 可能会使用新线程（从线程池获取或创建）
* 提交任务后立即返回，任务在后台执行

```swift
queue.async {
    // 在后台线程异步执行，可能创建新线程
}
```

### 4. 线程创建的真相

以下是几个重要的线程创建规则：

1. **主队列（Main Queue）**：
   * 始终在主线程执行任务
   * 即使使用 `async`，也不会创建新线程

2. **全局队列（Global Queue）**：
   * 使用 `sync` 时：在当前线程执行
   * 使用 `async` 时：可能在新线程执行，但 GCD 会智能复用线程

3. **自定义串行队列**：
   * 使用 `sync` 时：在当前线程执行
   * 使用 `async` 时：可能创建新线程，但同一时间该队列只会有一个任务在执行

4. **自定义并发队列**：
   * 使用 `sync` 时：在当前线程执行
   * 使用 `async` 时：可能创建多个线程并行执行任务

### 5. 线程创建对照表

下表清晰展示了不同队列类型和执行方式对线程创建的影响：

| 队列类型 | 执行方式 | 是否创建新线程 | 在哪个线程执行 | 备注 |
|---------|---------|--------------|--------------|------|
| 主队列 | sync | ❌ | 主线程 | ⚠️ 如果在主线程调用会导致死锁 |
| 主队列 | async | ❌ | 主线程 | 常用于 UI 更新 |
| 全局队列 | sync | ❌ | 调用线程 | 会阻塞当前线程 |
| 全局队列 | async | ✅ | 后台线程 | GCD 会管理线程池 |
| 自定义串行队列 | sync | ❌ | 调用线程 | 会阻塞当前线程 |
| 自定义串行队列 | async | ✅ | 后台线程 | 同一时间只执行一个任务 |
| 自定义并发队列 | sync | ❌ | 调用线程 | 会阻塞当前线程 |
| 自定义并发队列 | async | ✅ | 后台线程 | 可以并行执行多个任务 |

### 6. 代码示例

以下代码演示了不同组合的实际效果：

```swift
// 主线程ID
print("Main thread: \(Thread.current)")

// 1. 主队列 + 异步执行：仍在主线程执行
DispatchQueue.main.async {
    print("Main queue async: \(Thread.current)")
    // 输出：Main thread (与主线程相同)
}

// 2. 全局队列 + 同步执行：在当前线程执行
DispatchQueue.global().sync {
    print("Global queue sync: \(Thread.current)")
    // 输出：Main thread (与主线程相同)
}

// 3. 全局队列 + 异步执行：在后台线程执行
DispatchQueue.global().async {
    print("Global queue async: \(Thread.current)")
    // 输出：Thread 2 或其他后台线程
}

// 4. 自定义串行队列 + 异步执行：可能在新线程执行
let serialQueue = DispatchQueue(label: "serial")
serialQueue.async {
    print("Serial queue async: \(Thread.current)")
    // 输出：可能是新线程
}

// 5. 自定义并发队列 + 异步执行：可能在多个新线程执行
let concurrentQueue = DispatchQueue(label: "concurrent", attributes: .concurrent)
for i in 1...3 {
    concurrentQueue.async {
        print("Concurrent task \(i): \(Thread.current)")
        // 输出：可能是不同的线程
    }
}
```

## 三、队列的类型与使用场景

### 1. 主队列（Main Queue）

主队列是一个特殊的串行队列，专门用于处理 UI 相关任务。

```swift
// 获取主队列
let mainQueue = DispatchQueue.main

// 在主队列上执行任务（更新 UI）
mainQueue.async {
    self.label.text = "数据加载完成"
}
```

**使用场景**：
- UI 更新
- 用户交互响应
- 轻量级的计算任务

### 2. 全局队列（Global Queue）

系统预定义的并发队列，有不同的服务质量等级（QoS）。

```swift
// 获取默认优先级的全局队列
let globalQueue = DispatchQueue.global()

// 获取指定 QoS 的全局队列
let highPriorityQueue = DispatchQueue.global(qos: .userInteractive)
let defaultPriorityQueue = DispatchQueue.global(qos: .userInitiated)
let lowPriorityQueue = DispatchQueue.global(qos: .utility)
let backgroundPriorityQueue = DispatchQueue.global(qos: .background)
```

**QoS 级别**：
- `.userInteractive`：用户交互相关，优先级最高
- `.userInitiated`：用户发起但可短暂等待，如打开文档
- `.default`：默认优先级
- `.utility`：长时间运行的任务，如下载文件
- `.background`：用户不直接关注的任务，如备份

**使用场景**：
- 网络请求
- 文件读写
- 图片处理
- 数据计算

### 3. 自定义队列

自定义队列可以更精细地控制任务执行。

```swift
// 创建串行队列
let serialQueue = DispatchQueue(label: "com.example.serial")

// 创建并发队列
let concurrentQueue = DispatchQueue(label: "com.example.concurrent", 
                                   attributes: .concurrent)

// 创建带有 QoS 的队列
let highPriorityCustomQueue = DispatchQueue(label: "com.example.priority",
                                           qos: .userInteractive)
```

**使用场景**：
- 串行队列：数据同步、顺序敏感的操作
- 并发队列：独立任务的并行处理

## 四、常见任务模式

### 1. 后台执行，主线程更新

最常见的模式是在后台处理数据，完成后在主线程更新 UI。

```swift
// 正确方式
DispatchQueue.global().async {
    // 后台处理数据
    let result = self.processData()
    
    // 主线程更新 UI
    DispatchQueue.main.async {
        self.label.text = result
    }
}
```

### 2. 延迟执行

需要延迟执行的任务可以使用 `asyncAfter`。

```swift
// 延迟2秒执行
DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
    // 延迟执行的代码
}
```

### 3. 一次性执行

使用 `DispatchOnce` 的替代方案：

```swift
// Swift 3.0+ 的一次性执行
let once: () = {
    // 初始化代码
}()
```

## 五、GCD 高级特性

### 1. DispatchGroup

DispatchGroup 用于等待一组任务完成后再执行后续操作。

#### DispatchGroup 的核心方法

DispatchGroup 提供了几个关键方法来管理任务组：

1. **enter() 和 leave()**

   这两个方法是 DispatchGroup 最核心的功能，用于手动管理任务的开始和结束：
   
   * `enter()`：告诉 Group 有一个新任务开始了，增加 Group 的任务计数
   * `leave()`：告诉 Group 一个任务结束了，减少 Group 的任务计数
   
   这对方法必须配对使用，每次调用 `enter()` 必须匹配一次 `leave()`，否则会导致 Group 永远不会触发完成事件，或者提前触发完成事件。

   ```swift
   let group = DispatchGroup()
   
   // 手动标记任务开始
   group.enter()
   
   performAsyncTask { result in
       // 处理结果...
       
       // 手动标记任务结束
       group.leave()
   }
   ```

   什么时候需要使用 `enter()/leave()` 对？主要在以下情况：
   
   * 当使用不直接支持 DispatchGroup 的异步 API 时
   * 当任务的完成时间不确定，需要在回调中手动标记完成时
   * 当需要更精细地控制任务的生命周期时

2. **notify(queue:execute:)**

   当 Group 中所有任务完成时，在指定队列上执行闭包：
   
   ```swift
   group.notify(queue: .main) {
       print("所有任务已完成")
       // 更新 UI 或执行后续操作
   }
   ```

3. **wait() 和 wait(timeout:)**

   同步等待 Group 中的所有任务完成，可以指定超时时间：
   
   ```swift
   // 无限期等待
   group.wait()
   
   // 等待最多 5 秒
   let result = group.wait(timeout: .now() + 5)
   if result == .timedOut {
       print("等待超时")
   }
   ```

#### 实际应用示例

```swift
let group = DispatchQueue.global()

// 添加多个任务到组
for url in urls {
    group.enter()
    downloadImage(url) { image in
        // 处理图片
        group.leave()
    }
}

// 方式1：等待所有任务完成后通知
group.notify(queue: .main) {
    print("所有图片下载完成")
}

// 方式2：同步等待（有超时）
if group.wait(timeout: .now() + 60) == .timedOut {
    print("下载超时")
}
```

#### 常见错误与避坑指南

1. **enter/leave 不匹配**
   
   最常见的错误是 `enter()` 和 `leave()` 调用次数不匹配：
   
   ```swift
   // 错误示例
   group.enter()
   networkCall { result in
       if result.isSuccess {
           // 只在成功时调用 leave，如果失败会导致 Group 永远等待
           group.leave()
       }
   }
   
   // 正确示例
   group.enter()
   networkCall { result in
       // 无论成功失败都调用 leave
       defer { group.leave() }
       
       if result.isSuccess {
           // 处理成功情况
       }
   }
   ```

2. **避免嵌套使用 enter/leave**
   
   嵌套使用可能导致计数错误：
   
   ```swift
   // 问题代码
   group.enter()
   networkCall { result in
       group.enter()  // 嵌套的 enter
       processData { 
           group.leave()  // 内层的 leave
       }
       group.leave()  // 外层的 leave
   }
   
   // 更好的方式
   group.enter()
   networkCall { result in
       self.processData(result) {
           group.leave()  // 只有一个 leave，对应外层的 enter
       }
   }
   ```

**应用场景**：多图片下载、多API请求、资源预加载、任何需要等待多个异步操作完成的场景

### 2. DispatchWorkItem

DispatchWorkItem 封装了可以取消的任务。

```swift
// 创建工作项
let workItem = DispatchWorkItem {
    // 耗时任务
}

// 提交到队列
DispatchQueue.global().async(execute: workItem)

// 任务完成后的回调
workItem.notify(queue: .main) {
    print("任务完成")
}

// 取消任务
workItem.cancel()
```

**应用场景**：可取消的网络请求、搜索操作、延迟执行的任务

### 3. DispatchSemaphore

信号量用于控制并发访问数量。

```swift
// 创建信号量，允许3个并发访问
let semaphore = DispatchSemaphore(value: 3)
let queue = DispatchQueue.global()

for i in 1...10 {
    queue.async {
        // 等待信号
        semaphore.wait()
        
        // 执行限制并发的代码
        print("任务 \(i) 开始")
        sleep(2)
        print("任务 \(i) 结束")
        
        // 释放信号
        semaphore.signal()
    }
}
```

**应用场景**：限制并发网络请求数、资源池管理、读写锁实现

## 六、线程安全

### 1. 串行队列作为锁

使用串行队列保护共享资源是最简单的线程安全方法。

```swift
class ThreadSafeCounter {
    private var count = 0
    private let queue = DispatchQueue(label: "com.example.counter")
    
    func increment() {
        queue.sync {
            count += 1
        }
    }
    
    func getCount() -> Int {
        return queue.sync { count }
    }
}
```

### 2. 并发队列 + 栅栏函数

对于读多写少的场景，可以使用并发队列加栅栏函数。

```swift
class ThreadSafeCache<Key: Hashable, Value> {
    private var cache: [Key: Value] = [:]
    private let queue = DispatchQueue(label: "com.example.cache", attributes: .concurrent)
    
    // 读操作：并发执行
    func value(for key: Key) -> Value? {
        return queue.sync {
            return cache[key]
        }
    }
    
    // 写操作：使用栅栏函数
    func set(value: Value, for key: Key) {
        queue.async(flags: .barrier) {
            self.cache[key] = value
        }
    }
}
```

### 3. 常见线程安全问题

#### 死锁

死锁发生在一个队列试图同步执行一个任务，而该任务又依赖于已经在该队列中等待的另一个任务。

```swift
// 死锁示例
DispatchQueue.main.sync {
    // 在主队列上同步执行，造成死锁
}

// 解决方法：使用异步执行
DispatchQueue.main.async {
    // 安全地在主队列执行
}
```

#### 竞态条件

当多个线程同时访问共享资源并且至少有一个线程进行写操作时，会发生竞态条件。

```swift
// 竞态条件示例
var array = [Int]()
DispatchQueue.concurrentPerform(iterations: 1000) { _ in
    array.append(1) // 不安全！
}

// 解决方法：使用同步访问
let queue = DispatchQueue(label: "com.example.array")
DispatchQueue.concurrentPerform(iterations: 1000) { _ in
    queue.sync {
        array.append(1) // 安全
    }
}
```

## 七、性能优化

### 1. 避免过度使用 GCD

虽然 GCD 强大，但并不是所有操作都需要放到后台线程：

* 简单的计算应该在当前线程完成
* 避免频繁地在线程间切换
* 合并小任务为大任务

### 2. 合理使用 QoS

根据任务的重要性选择适当的 QoS 级别：

```swift
// 重要任务：用户交互相关
DispatchQueue.global(qos: .userInteractive).async {
    // 立即需要的计算
}

// 不重要任务：后台处理
DispatchQueue.global(qos: .utility).async {
    // 耗时较长的操作
}
```

### 3. 使用 DispatchSourceTimer 替代 Timer

`DispatchSourceTimer` 比传统的 `Timer` 更精确且高效：

```swift
class PreciseTimer {
    private var timer: DispatchSourceTimer?
    
    func start(interval: TimeInterval, handler: @escaping () -> Void) {
        timer = DispatchSource.makeTimerSource(queue: .main)
        timer?.schedule(deadline: .now(), repeating: interval)
        timer?.setEventHandler(handler: handler)
        timer?.resume()
    }
    
    func stop() {
        timer?.cancel()
        timer = nil
    }
}
```

## 八、实际案例分析

### 1. 图片加载和缓存

```swift
class ImageLoader {
    private let downloadQueue = DispatchQueue(label: "com.example.download", attributes: .concurrent)
    private let processQueue = DispatchQueue(label: "com.example.process", attributes: .concurrent)
    private let cacheQueue = DispatchQueue(label: "com.example.cache")
    private var cache: [URL: UIImage] = [:]
    
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        // 1. 检查缓存
        if let cachedImage = getCachedImage(for: url) {
            DispatchQueue.main.async {
                completion(cachedImage)
            }
            return
        }
        
        // 2. 下载图片
        downloadQueue.async {
            guard let data = try? Data(contentsOf: url) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            // 3. 处理图片
            self.processQueue.async {
                guard let image = UIImage(data: data) else {
                    DispatchQueue.main.async { completion(nil) }
                    return
                }
                
                // 4. 缓存图片
                self.cacheImage(image, for: url)
                
                // 5. 回调主线程
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
    }
    
    private func getCachedImage(for url: URL) -> UIImage? {
        return cacheQueue.sync { cache[url] }
    }
    
    private func cacheImage(_ image: UIImage, for url: URL) {
        cacheQueue.sync {
            cache[url] = image
        }
    }
}
```

### 2. 数据批量处理

```swift
class DataProcessor {
    private let processingQueue = DispatchQueue(label: "com.example.processing", 
                                              attributes: .concurrent)
    private let resultQueue = DispatchQueue(label: "com.example.result")
    
    func processBatch(_ items: [Item], completion: @escaping ([Result]) -> Void) {
        let group = DispatchGroup()
        let semaphore = DispatchSemaphore(value: 8) // 限制最大并发数
        var results: [Int: Result] = [:] // 使用索引作为键保持顺序
        
        for (index, item) in items.enumerated() {
            group.enter()
            semaphore.wait()
            
            processingQueue.async {
                // 处理单个项目
                let result = self.processItem(item)
                
                // 存储结果（线程安全）
                self.resultQueue.sync {
                    results[index] = result
                }
                
                semaphore.signal()
                group.leave()
            }
        }
        
        // 所有处理完成后
        group.notify(queue: .main) {
            // 按原始顺序整理结果
            let orderedResults = items.indices.compactMap { results[$0] }
            completion(orderedResults)
        }
    }
    
    private func processItem(_ item: Item) -> Result {
        // 实际处理逻辑
        return Result()
    }
}
```

## 九、常见问题与最佳实践

### 1. 避免嵌套闭包

嵌套闭包会使代码难以阅读和维护。使用命名函数或拆分闭包：

```swift
// 不好的做法
DispatchQueue.global().async {
    // 任务1
    DispatchQueue.global().async {
        // 任务2
        DispatchQueue.main.async {
            // 任务3
        }
    }
}

// 更好的做法
func task1() {
    DispatchQueue.global().async {
        // 任务1
        self.task2()
    }
}

func task2() {
    // 任务2
    DispatchQueue.main.async {
        self.task3()
    }
}

func task3() {
    // 任务3
}

// 启动任务链
task1()
```

### 2. 取消长时间运行的任务

使用 `DispatchWorkItem` 实现任务取消：

```swift
class SearchManager {
    private var currentSearch: DispatchWorkItem?
    
    func search(query: String, completion: @escaping ([Result]) -> Void) {
        // 取消之前的搜索
        currentSearch?.cancel()
        
        // 创建新的搜索任务
        let newSearch = DispatchWorkItem {
            // 执行搜索
            let results = self.performSearch(query)
            if !newSearch.isCancelled {
                DispatchQueue.main.async {
                    completion(results)
                }
            }
        }
        
        currentSearch = newSearch
        DispatchQueue.global().async(execute: newSearch)
    }
}
```

### 3. 避免线程爆炸

使用信号量或操作队列限制并发数：

```swift
// 限制并发下载数为5
let semaphore = DispatchSemaphore(value: 5)
let queue = DispatchQueue.global()

for url in urls {
    queue.async {
        semaphore.wait()
        downloadFile(url) {
            semaphore.signal()
        }
    }
}
```

## 十、并发控制详解

在大型应用中，适当控制并发数量对于系统性能至关重要。过多的并发可能导致资源争用、内存占用过高甚至应用崩溃。以下是几种控制并发数量的方法：

### 1. 使用 DispatchSemaphore 控制并发数

DispatchSemaphore 是控制并发访问的最常用工具，它维护一个计数器，用于限制同时访问资源的线程数：

```swift
class DownloadManager {
    private let concurrentQueue = DispatchQueue(label: "com.example.download", attributes: .concurrent)
    private let semaphore: DispatchSemaphore
    
    init(maxConcurrentDownloads: Int) {
        // 设置最大并发数
        semaphore = DispatchSemaphore(value: maxConcurrentDownloads)
    }
    
    func download(urls: [URL], completion: @escaping ([Data]) -> Void) {
        let group = DispatchGroup()
        var results: [Int: Data] = [:]
        let resultsQueue = DispatchQueue(label: "com.example.results")
        
        for (index, url) in urls.enumerated() {
            group.enter()
            
            concurrentQueue.async {
                // 等待信号量，如果已达到最大并发数，这里会阻塞
                self.semaphore.wait()
                
                print("开始下载: \(url), 当前活跃下载数: \(maxConcurrentDownloads - self.semaphore.value)")
                
                self.downloadData(from: url) { data in
                    // 存储结果
                    if let data = data {
                        resultsQueue.sync {
                            results[index] = data
                        }
                    }
                    
                    // 完成后释放信号量
                    self.semaphore.signal()
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            // 按原始顺序整理结果
            let orderedResults = urls.indices.compactMap { results[$0] }
            completion(orderedResults)
        }
    }
    
    private func downloadData(from url: URL, completion: @escaping (Data?) -> Void) {
        // 实际下载实现
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data)
        }.resume()
    }
}

// 使用示例
let manager = DownloadManager(maxConcurrentDownloads: 3)
manager.download(urls: largeURLList) { results in
    print("所有下载完成，获取到 \(results.count) 个结果")
}
```

### 2. 使用 OperationQueue 控制并发数

NSOperationQueue 提供了更高级的并发控制：

```swift
class BatchProcessor {
    private let operationQueue: OperationQueue
    
    init(maxConcurrentOperations: Int) {
        operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = maxConcurrentOperations
    }
    
    func process(items: [Item], completion: @escaping ([Result]) -> Void) {
        var results = Array<Result?>(repeating: nil, count: items.count)
        let completionOperation = BlockOperation {
            let finalResults = results.compactMap { $0 }
            completion(finalResults)
        }
        
        for (index, item) in items.enumerated() {
            let operation = BlockOperation {
                let result = self.processItem(item)
                results[index] = result
            }
            
            // 添加依赖，确保完成操作在所有处理操作后执行
            completionOperation.addDependency(operation)
            operationQueue.addOperation(operation)
        }
        
        // 添加完成操作到主队列
        OperationQueue.main.addOperation(completionOperation)
    }
    
    private func processItem(_ item: Item) -> Result {
        // 处理单个项目的逻辑
        return Result()
    }
}

// 使用示例
let processor = BatchProcessor(maxConcurrentOperations: 4)
processor.process(items: largeItemList) { results in
    print("处理完成，获得 \(results.count) 个结果")
}
```

### 3. 使用自定义队列组合控制并发

更灵活的方式是组合使用不同队列和组：

```swift
class TaskScheduler {
    private let processingQueue: DispatchQueue
    private let resultQueue = DispatchQueue(label: "com.example.results")
    private let taskSemaphore: DispatchSemaphore
    private var activeTaskCount = 0
    
    init(label: String, maxConcurrentTasks: Int) {
        processingQueue = DispatchQueue(label: label, attributes: .concurrent)
        taskSemaphore = DispatchSemaphore(value: maxConcurrentTasks)
    }
    
    func submitTask<T>(_ task: @escaping () -> T, completion: @escaping (T) -> Void) {
        processingQueue.async { [weak self] in
            guard let self = self else { return }
            
            // 等待可用槽位
            self.taskSemaphore.wait()
            
            // 更新活跃任务计数
            self.resultQueue.sync {
                self.activeTaskCount += 1
                print("任务开始，当前活跃任务数: \(self.activeTaskCount)")
            }
            
            // 执行任务
            let result = task()
            
            // 更新计数并回调
            self.resultQueue.sync {
                self.activeTaskCount -= 1
                print("任务完成，当前活跃任务数: \(self.activeTaskCount)")
            }
            
            // 在主队列上调用完成回调
            DispatchQueue.main.async {
                completion(result)
            }
            
            // 释放信号量
            self.taskSemaphore.signal()
        }
    }
    
    func waitUntilAllTasksAreComplete() {
        // 创建一个完成标志
        let allTasksDone = DispatchSemaphore(value: 0)
        
        // 定期检查活跃任务数
        let checkQueue = DispatchQueue(label: "com.example.check")
        
        func checkActiveTasks() {
            resultQueue.sync {
                if activeTaskCount == 0 {
                    allTasksDone.signal()
                } else {
                    checkQueue.asyncAfter(deadline: .now() + 0.1) {
                        checkActiveTasks()
                    }
                }
            }
        }
        
        checkActiveTasks()
        
        // 等待所有任务完成
        allTasksDone.wait()
    }
}

// 使用示例
let scheduler = TaskScheduler(label: "com.example.tasks", maxConcurrentTasks: 5)

for i in 1...20 {
    scheduler.submitTask({
        // 模拟耗时操作
        Thread.sleep(forTimeInterval: Double.random(in: 0.5...2.0))
        return "任务 \(i) 的结果"
    }) { result in
        print(result)
    }
}

// 可选：等待所有任务完成
scheduler.waitUntilAllTasksAreComplete()
print("所有任务已完成")
```

### 4. 并发控制的最佳实践

1. **根据任务类型选择合适的并发数**
   - CPU 密集型任务：通常限制为核心数或核心数 + 1
   - IO 密集型任务：可以设置较高的并发数，如 10-20
   - 网络请求：通常限制在 4-8 个并发请求

2. **动态调整并发数**
   - 可以根据系统负载或网络状况动态调整并发数
   - 在电池电量低或热降频时降低并发数

3. **避免嵌套的并发控制**
   - 嵌套使用信号量可能导致死锁
   - 设计扁平的并发结构

4. **使用超时机制**
   - 为并发任务设置合理的超时时间
   - 处理超时情况以避免资源泄露

## 十一、总结

GCD 是 iOS 开发中不可或缺的多线程管理工具。本文讨论了 GCD 的核心概念、队列与线程的关系、常见任务模式以及性能优化策略。

记住以下关键点：

1. **队列不等于线程**：队列是任务的容器，线程是执行任务的资源
2. **异步不一定创建新线程**：是否创建新线程取决于队列类型和系统状态
3. **线程安全很重要**：使用合适的同步机制避免数据竞争
4. **性能优化**：选择合适的队列类型和 QoS 级别
5. **并发控制**：根据应用需求和资源情况，合理限制并发数量