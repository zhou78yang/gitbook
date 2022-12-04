# threading

> [!Note]
>  在CPython中，由于存在`全局解释器锁`(GIL)，同一时刻只有一个线程可以执行Python代码（虽然某些性能导向的库可能会去除此限制）。如果你想让你的应用更好地利用多核心计算机的计算资源，推荐你使用`multiprocessing`或`concurrent.futures.ProcessPoolExecutor`。 但是，如果你想要同时运行多个I/O密集型任务，则多线程仍然是一个合适的模型。

## 碎片
* threading.Thread创建一个子线程
* Thread.start: 开始执行
* Thread.join: 子线程加入到主线程
* 默认情况下主线程都会等待子线程完成，除非设置为后台线程daemon=True
* 主线程结束后也会杀死所有子线程
* Event通信
