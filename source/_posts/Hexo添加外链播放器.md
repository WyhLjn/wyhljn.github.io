---
title: Hexo添加外链播放器
date: 2018-06-08 13:13:15
categories:
- 博客
tags:
- Hexo
---
想给博客添加一首音乐这么费劲，也是没谁了。有的没有版权，有的没有外链播放器，无奈之下还是Google吧，Google大法好，帮我解决了问题。

### 查找歌曲地址
从[http://www.170mv.com/song](http://www.170mv.com/song)可以获得外链地址
![](http://ww1.sinaimg.cn/large/ad274f89ly1g0u6eq1h64j20nx08qq2y.jpg)


### 使用APlayer插入音乐
在Markdown里插入如下代码片段即可

```
{% aplayer "是初恋吧" "IU" "http://other.web.rc01.sycdn.kuwo.cn/resource/n1/56/42/3309799366.mp3" "iu.jpg" %}
```
{% aplayer "是初恋吧" "IU" "http://other.web.rc01.sycdn.kuwo.cn/resource/n1/56/42/3309799366.mp3" "iu.jpg" "autoplay"%}

要插入图片的话，需要在_config.xml里将**post_asset_folder**设置为true，这样每次通过 `hexo new ""` 新增文章时，会在同级目录里创建同名的文件夹，用来保存资源文件。
具体介绍可参考
- [文章资源文件夹](https://hexo.io/zh-cn/docs/asset-folders.html#%E6%96%87%E7%AB%A0%E8%B5%84%E6%BA%90%E6%96%87%E4%BB%B6%E5%A4%B9)
- [APlayer](https://github.com/MoePlayer/hexo-tag-aplayer/blob/master/docs/README-zh_cn.md)
