---
layout: post
title: "141.环形链表"
date: 2024-04-30
tags: "算法 链表 LeetCode"
category: 
---

## 题目说明
难度简单
给定一个链表，判断链表中是否有环。

如果链表中有某个节点，可以通过连续跟踪 `next` 指针再次到达，则链表中存在环。 为了表示给定链表中的环，我们使用整数 `pos` 来表示链表尾连接到链表中的位置（索引从 0 开始）。 如果 `pos` 是 `-1`，则在该链表中没有环。**注意：`pos` 不作为参数进行传递**，仅仅是为了标识链表的实际情况。

如果链表中存在环，则返回 `true` 。 否则，返回 `false` 。

**进阶：**

你能用 *O(1)*（即，常量）内存解决此问题吗？

**示例 1：**

![https://assets.leetcode-cn.com/aliyun-lc-upload/uploads/2018/12/07/circularlinkedlist.png](https://assets.leetcode-cn.com/aliyun-lc-upload/uploads/2018/12/07/circularlinkedlist.png)

```
输入：head = [3,2,0,-4], pos = 1
输出：true
解释：链表中有一个环，其尾部连接到第二个节点。

```

**示例 2：**

![https://assets.leetcode-cn.com/aliyun-lc-upload/uploads/2018/12/07/circularlinkedlist_test2.png](https://assets.leetcode-cn.com/aliyun-lc-upload/uploads/2018/12/07/circularlinkedlist_test2.png)

```
输入：head = [1,2], pos = 0
输出：true
解释：链表中有一个环，其尾部连接到第一个节点。

```

**示例 3：**

![https://assets.leetcode-cn.com/aliyun-lc-upload/uploads/2018/12/07/circularlinkedlist_test3.png](https://assets.leetcode-cn.com/aliyun-lc-upload/uploads/2018/12/07/circularlinkedlist_test3.png)

```
输入：head = [1], pos = -1
输出：false
解释：链表中没有环。
```

## 解题思路

1. 环形的链表最少需要2个节点
2. 构成环的前提是内部有两个节点相交

判断环形链表通常需要快慢指针，

- 快指针一次走两步
- 慢指针一次走一步

根据这里我们正常会写出如下的代码：

```swift
func hasCycle(_ head: ListNode?) -> Bool {
        var slow: ListNode? = head
        var fast: ListNode? = head?.next
        
        while fast != nil {
            guard let slow1 = slow else {
                return true
            }
            
            guard let fast1 = fast else {
                return true
            }
            if slow1 === fast1 {
                return true
            }
            slow = slow1.next            //慢指针 一次走一步
            fast = fast1.next?.next      //快指针 一次走两步
        }
        return false
    }
```

优化一下这个代码，根据完整的快慢指针

```swift
func hasCycle(_ head: ListNode?) -> Bool {
        var slow: ListNode? = head
        var fast: ListNode? = head?.next
        
        while fast !== slow {
            slow = slow?.next           //慢指针 一次走一步
            fast = fast?.next?.next     //快指针 一次走两步
        }
        return slow != nil
    }
```