# game_dev
基于skynet引擎的回合制游戏搭建

<br>这里我们介绍的是一种单服的游戏服务器结构，即我们在一台物理机上只运行一个服务器进程，所有的游戏内容都运行在此进程中
<br>影响服务器承载玩家上限的点主要有这么几点
<br>1.机器性能：主要在机器的主频，内存，cpu缓存上
<br>2.网络问题：带宽，IO读写
<br>3.游戏代码结构设计：单进程单线程的设计，所有的事务都需要等待上一条事务执行完毕才能开始处理
<br>4.游戏逻辑代码实现：游戏逻辑代码实现中需要注意编程语言的性能问题，以及一些玩法开发的耗时注意事项

<br>基于skynet的开发，我们将我们的游戏结构设计成一个单进程多线程的结构，对于比较耗时的服务，如场景，战斗，
<br>广播等一些功能我们可以另多开几条线程<lua虚拟机>去专门做这些处理，分散线程的压力。在此份代码中，可以看
<br>到在service下回出现war/scene/broadcast 等目录；这就是针对上述说表的具体实现

## 1.游戏代码目录结构
  <br>game_dev - 
  <br>           | - shell/     --存放常用的shell指令，如启动、关闭服务器等
  <br>           | - log/       --游戏日志输出
  <br>           | - service/   --游戏逻辑玩法服务
  <br>           | - config/    --游戏服务器基本配置信息
  <br>           | - skynet/    --skynet引擎源码以及执行文件
             
## 2.skynet引擎搭建
<br>           a.检出一份skynet源代码，地址：https://github.com/cloudwu/skynet.git
<br>           b.编译skynet代码，期间会遇到一些库缺失的问题，安装完后编译即可
<br>
编译完成后,在skynet下我们会看到一份skynet/skynet的执行文件，skynet的启动流程可以通过
追踪skynet-src/skynet_main.c进行了解，在这里不在做具体的阐述。游戏的启动脚本我把他放
在了shell/gs_run.sh脚本下，通过执行该脚本我们可以将游戏服务器运行起来，当然你得先配置
好config/gs_config.lua文件，通过配置我们可以知道最终的启动工具是通过snlua bootstrap启
动bootstrap，然后通过bootstrap启动gs_launcher，gs_launcher.lua去启动游戏逻辑中需要的
各项服务内容

