1. 训练音频/测试音频放在文件夹中。
2. test.m a.从音频中提取相应参数 b.从lbe文件中获得标注 c.选取有效数据与标注合并,再拼接
          得到: PLDA的A,mean,phi.
          -- 窗长度和重叠长度参照学长代码
3. train.m a.从音频中提取相应参数 b.合并有效数据 c.PLDA投影
          得到: bayesinput.txt
4. bayesCPD.exe 输入参数:输入输出路径 显变量var 隐变量mean/var 期望游程 数据点数量
5. evaluate.m 作图，与标注结果比较