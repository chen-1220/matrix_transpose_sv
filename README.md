# 矩阵转置的FPGA实现

```txt
matrix_trans_top.sv	：顶层模块
	-- wrd_manage.sv：管理读写操作的存储块
	-- wrd_ctrl.sv	：产生存储器的读写时序
		-- wr_ctrl.sv：写控制
		-- rd_ctrl.sv：读控制
	-- ultraRAM.sv	：使用Xlinx原语封装ultraRAM

ram_interface.sv：接口定义文件
		
```

实现框图：

<img src="README.assets/%E5%9F%BA%E4%BA%8ERAM%E5%AE%9E%E7%8E%B0%E7%9F%A9%E9%98%B5%E8%BD%AC%E7%BD%AE%E7%9A%84%E6%A1%86%E5%9B%BE.png" alt="基于RAM实现矩阵转置的框图" style="zoom:60%;" />

Modelsim仿真图：

<img src="README.assets/modelsim_result.png" alt="modelsim_resultl" style="zoom:75%;" />

