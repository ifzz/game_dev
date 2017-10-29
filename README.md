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
<br>           b.注意：skynet版本我只检出至c91efa513435e71f24fd869e15ef409e0caf6c86，往后有大修改，部分代码无法支持
<br>           c.编译skynet代码，期间会遇到一些库缺失的问题，安装完后编译即可
<br>
编译完成后,在skynet下我们会看到一份skynet/skynet的执行文件，skynet的启动流程可以通过
追踪skynet-src/skynet_main.c进行了解，在这里不在做具体的阐述。游戏的启动脚本我把他放
在了shell/gs_run.sh脚本下，通过执行该脚本我们可以将游戏服务器运行起来，当然你得先配置
好config/gs_config.lua文件，通过配置我们可以知道最终的启动工具是通过snlua bootstrap启
动bootstrap，然后通过bootstrap启动gs_launcher，gs_launcher.lua去启动游戏逻辑中需要的
各项服务内容

## 3.游戏后台搭建
<br> 游戏后台在这套框架中称之为dictator; dictator主要实现的是后台指令，区别游戏中的gm
指令,dictator主要用来实现在线更新,是否开放玩家登陆,关闭存盘等相关指令;每个服务的启动
都会向该服务注册一份各服务的地址信息，dictator做为一个指令的发起方，将指令根据地址传送
到各个服务上；根据这个机制可以实现各个服务代码的在线更新，启动这个服务后，我们会监听
本机器上的dictator_port端口(在config/gs_config.lua中配置)，通过nc localhost dictator_port
可以直连上后台，就可以输入相关的指令进行相关操作，如在线更新指令
update_code service/world/dictatorobj

与此同时，我们还启动了debug_console后台，用于监控各个服务的状态，相应代码位于
skynet/service/debug_console.lua下；

## 4.lua代码文件在线更新
<br> 参照云风博客：https://blog.codingnow.com/2008/03/hot_update.html
<br> 在这个系统中，载入一个文件我们使用了两种方式，一个是系统自带的require，另外一个是
自己实现的import；代码位于lualib/base/reload.lua下，这种划分相当于把文件按照能否在线更
新作为了标准；使用require的，我们默认认为此文件不能进行在线更新，使用import则是可以使用
lualib/base/reload.lua 下的reload文件进行在线更新
<br> 具体原理待阐述
在原生lua环境下，我们引用一个文件通常使用require，使用require后我们会把内容放置到package.loaded
下，如果我们要更新这个文件，首先我们会把package.loaded置控，然后重新require一次，但是这
种写法会使得一些地方无法更新到 如：local mod = require "mod"; 就算你重新require了一次，
这里的引用关系保持的还是旧的，除非我们把所有引用关系都遍历更新一次。而这个在线更新机制
在不解除旧有引用关系的前提下对内部数据进行了替换，详细实现参照代码：
lualib/base/reload.lua

## 5.关于多服务数据共享(sharedata)
<br> 在skynet中有一个叫做sharedatad的全局服务, 代码路径：skynet/lualib/sharedata.lua
支持new|query|update 三种方法；
sharedata.new(name, v, ...) 通过此方法可以创建一个新的sharedata数据块，v可以是字符串，table
sharedata.query(name) 通过此方法可以获得已经创建的sharedata数据块，但是我们发现实际美一次
query都会去创建一次新的table，实际上我们可以在上层的使用方法上去规避他
sharedata.update(name, v) 可以将名字为name的sharedata使用v进行一次更新

同时，在我的设想中，这个框架对于sharedata的数据应用应该只停留在读取游戏中的配置数据，一般来
讲只能是导表数据，停留在只读层面上， 我们不会去也不应该去改写sharedata上的数据，有数据需要
需要变动的时候，我们通过在线调用update的方式去更新这些数据

由上述分析可以知道，我们要实现这写功能，需要有一个专门的服务去启动sharedatad和在线更新
sharedata
同时还需要有个文件去做数据加载的功能，需要对query做一层封装，规避重复创建table问题
把sharedata设置为只读
