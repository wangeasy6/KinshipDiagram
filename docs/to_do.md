## ToDo

关系显示界面：

1. 库合并
2. 关系删除检查；关系中调整子女排名联动；关系删除后，人员列表中可能需要重选类型才会出现刚刚删除的人；
3. 添加人员时的排名检查
4. 改添加连线的方式，从查找变为映射，提高执行速度
5. 删除子女后，其它子女的排名修改（低优先级，除非写错了，否则出生了就不会更改）
6. 删除老大之后，添加子女的排名预填有问题
7. 在启动时加入数据库检查，加载进度条。
8. 数据库版本、Check 数据库、迁移数据库。（前置：启动进度条）
9. 父母爷奶的多婚姻显示
10. **日期输入引导**：日期专用输入框 - 3框 + 农历时辰
11. 生日提醒功能
12. 优化用户指南：添加操作演示动画。
13. 屏幕自适应：不同分辨率/DPI
14. 增加输入导航引导
15. Mac系统编译发布
16. 日志处理，打印隐藏



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



**commit 流程：**

1. 格式化修改过的文件
2. 检查 HelpInfo 中的 版本号
3. 如果更新了 user_manual_zh-CN.md，更新 
   * user_manual_zh-CN.html
   * user_manual_zh-TW.md
   * user_manual_zh-TW.html
4. 如果跟新了提示，`lupdate.exe ../src ../content -ts KinshipDiagramApp_zh-CN.ts`、`lupdate.exe ../src ../content -ts KinshipDiagramApp_zh-TW.ts`，重新发布 `lrelease.exe KinshipDiagramApp_zh-*`。

**发布流程：**

1. 编译 Release 版本
2. 替换 data 中的软件（如果更新了 user_manual、language，更新到 docs、i18n 文件夹）
3. 修改 KinshipDiagram.nsi 中的 SOFTWARE_VERSION
4. 生成安装包（选中文件右键，"Compile NSIS Script"）

## commit

[0.17.1]

1. 添加了测试报告：KD-test-report-0.1a1-20250509-1635.xlsm
1. 修复 Bug：KD-003、007、013、015、016、021、029、034、048、050、058、059、062、072、078
1. 调整了新建图谱界面样式
1. 调整了添加人员/主人公界面 取消/保存 按钮位置
1. 添加了 KD-test-cases-0.1a2.xlsm

