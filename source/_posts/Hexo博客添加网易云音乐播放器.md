---
title: Hexo博客添加网易云音乐播放器
date: 2018-06-07 13:13:27
categories:
- 博客
tags:
- Hexo
---
### 写在前面
> 之前一直在用QQ音乐，但直到看到周围的人都开始听网易云音乐，我开始接触这款产品。用了不到一个星期，我发现我开始喜欢上云音乐了。一直觉得，网易是比较会做产品的公司，喜欢它们产品的风格，有小清新范，第一感觉会让你觉得很干净、纯净，比如Lofter，考拉，蜗牛读书。首先产品的外观就吸引了我。

> 用了一段云音乐以后，喜欢上了它里面的各种个性化的歌单，里面集结了很多网络歌手，还让我初次接触了民谣，而且音乐下面还有评论功能，万千网友在这里畅所欲言， 讲述自己与音乐的不解之缘。这些特性让我深深迷恋着这款产品。

> 但是好景不长，ZF出台了音乐版权管理办法之后，云音乐的曲库版权开始逐渐减少，收藏的歌曲慢慢不能播放了，好多音乐下架了。自己也很无奈，喜欢的产品不再能更好的为广大网民服务，真正有情节的东西马上要像昙花一样，还没足够的品味它，就即将要走到它的垂暮之年……

---

### 添加网易云音乐
网音乐云音乐版权的丧失，让我不得不找到更稳定的外链播放器。
在此我还是依然要介绍下网易云音乐添加音乐的方式。
<!-- more -->
- 首先来到网易云音乐官网搜索需要添加的音乐

![](http://ww1.sinaimg.cn/large/ad274f89ly1g0u6kgfv75j211i0j9q72.jpg)

- 接着点击*生成外链播放器*，选择iframe插件方式，复制下面的HTML代码。

![](http://ww1.sinaimg.cn/large/ad274f89ly1g0u6kxu63kj211y0lcq4c.jpg)

- 接下来以hexo yilia主题为例。例如将网易云音乐插件插入到左侧导航最下面，编辑
**\blog\themes\yilia\layout\_partial**
目录下left-col.ejs文件，在下面插入如下代码即可。

```
<div style="position: absolute;bottom: -350px;">
    <iframe frameborder="no" border="0" marginwidth="0" marginheight="0" width="250" height="86" src="//music.163.com/outchain/player?type=2&amp;id=92305&amp;auto=1&amp;height=66"></iframe>
</div>
```