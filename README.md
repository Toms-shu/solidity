# solidity
一.任务一
  1. ✅ 创建一个名为Voting的合约，包含以下功能：
    一个mapping来存储候选人的得票数
    一个vote函数，允许用户投票给某个候选人
    一个getVotes函数，返回某个候选人的得票数
    一个resetVotes函数，重置所有候选人的得票数
  2. ✅ 反转字符串 (Reverse String)
    题目描述：反转一个字符串。输入 "abcde"，输出 "edcba"
  3. ✅ 用 solidity 实现整数转罗马数字
    题目描述在 https://leetcode.cn/problems/roman-to-integer/description/3.
  4. ✅ 用 solidity 实现罗马数字转数整数
    题目描述在 https://leetcode.cn/problems/integer-to-roman/description/
  5. ✅ 合并两个有序数组 (Merge Sorted Array)
    题目描述：将两个有序数组合并为一个有序数组。
  6. ✅ 二分查找 (Binary Search)
    题目描述：在一个有序数组中查找目标值。

二.任务二

  任务目标
  
  使用 Solidity 编写一个合约，允许用户向合约地址发送以太币。
  记录每个捐赠者的地址和捐赠金额。
  允许合约所有者提取所有捐赠的资金。
  任务步骤
  
  编写合约
  创建一个名为 BeggingContract 的合约。
  合约应包含以下功能：
  一个 mapping 来记录每个捐赠者的捐赠金额。
  一个 donate 函数，允许用户向合约发送以太币，并记录捐赠信息。
  一个 withdraw 函数，允许合约所有者提取所有资金。
  一个 getDonation 函数，允许查询某个地址的捐赠金额。
  使用 payable 修饰符和 address.transfer 实现支付和提款。
  额外挑战（可选）

捐赠事件：添加 Donation 事件，记录每次捐赠的地址和金额。
捐赠排行榜：实现一个功能，显示捐赠金额最多的前 3 个地址。
时间限制：添加一个时间限制，只有在特定时间段内才能捐赠。
