## ToDo

关系显示界面：

1. 库合并
2. 添加人员后的更新逻辑调整：刷新当前页面，留下更新标记，在切换到其它页面的时候刷新
3. 重选照片后，原照片删除
4. 关系删除检查；关系中调整子女排名联动；关系删除后，人员列表中可能需要重选类型才会出现刚刚删除的人；
5. 添加人员时的排名检查
6. 改添加连线的方式，从查找变为映射，提高执行速度
7. 平滑连线
8. 删除子女后，其它子女的排名修改（低优先级，除非写错了，否则出生了就不会更改）
9. 删除老大之后，添加子女的排名预填有问题
10. 在启动时加入数据库检查，加载进度条。
11. 数据库版本、Check 数据库、迁移数据库。（前置：启动进度条）
12. 父母爷奶的多婚姻显示
13. **日期输入引导**：日期专用输入框 - 3框 + 农历时辰
14. 生日提醒功能
15. 添加完人后，侧边人员还是上一次点击的人员
16. 新建之后，可能在当前页面不会显示，让人觉得没有新建成功。
17. 优化用户指南：添加操作演示动画。
18. 屏幕自适应：不同分辨率/DPI
19. **测试**
20. Mac系统编译发布
21. 日志处理，打印隐藏



### 快捷键支持

| 功能     | 快捷键 |
| -------- | ------ |
| 新建项目 | Ctrl+N |
| 打开项目 | Ctrl+O |
| 保存项目 | Ctrl+S |
| 添加人物 | Ctrl+A |
| 删除人物 | Del    |
| 编辑人物 | Ctrl+E |
| 显示帮助 | F1     |



## Bug

[0.14.2]

* 遗留Bug：不能叫 “主人公”；如果有同名，则搜索路径可能会有问题。

* 替换图片后侧边栏不刷新。

* 数据库操作失败显示提示：

  ```
  Failed add Person. "database is locked 无法获取行"
  qml: Add Person failed.
  ```

  



**commit 流程：**

1. 格式化修改过的文件
2. 检查 HelpInfo 中的 版本号
3. 如果更新了 user_manual_zh-CN.md，更新 
   * user_manual_zh-CN.html
   * user_manual_zh-TW.md
   * user_manual_zh-TW.html
4. 如果跟新了提示，`lupdate.exe ../content -ts KinshipDiagramApp_zh-CN.ts`、`lupdate.exe ../content -ts KinshipDiagramApp_zh-TW.ts`，重新发布 `lrelease.exe KinshipDiagramApp_zh-*`。

**发布流程：**

1. 编译 Release 版本
2. 替换 data 中的软件（如果更新了 user_manual、language，更新到 docs、i18n 文件夹）
3. 修改 KinshipDiagram.nsi 中的 SOFTWARE_VERSION
4. 生成安装包（选中文件右键，"Compile NSIS Script"）

## commit

[0.17.0]

1. 添加繁体中文支持，支持繁简切换
1. 添加了 KD-test-cases-0.1a1.xlsm

