---
title: Spring如何通过ClassPathXmlApplicationContext初始化Bean
date: 2018-04-22 20:57:11
categories:
- 工作
- 学习
tags:
- Spring
- Java
- 源码
---
>懒癌重症患者真是没得治，拖了这么久终于有勇气开始写了。之前对spring框架的理解都是一知半解、碎片化的，没有系统的真正了解过的spring知识体系，还是停留在使用的阶段。作为CRUD了几年的猿，水平这么菜也是没谁了（好多大学生已经对源码如数家珍了，而我才开始看spring源码。。。）。不管怎么样，从现在开始，总比从未来开始要好，现在即是起点（谁让之前那么懒了，希望这样能鼓励自己，坚持下去：）），希望自己的程序猿生涯能从现在开始开始不一样，即便是一点小小的改变。每个人的资质不一样，我属于笨的那种，记忆力还不好，这都不是理由，努力是自己的，未来也是自己的，生活是自己的。不怕自己的生涯如何，只希望能和以前不一样，不管别人取得多大的成就，不羡慕，不嫉妒，走好自己的路，过程和结果好或坏都是自己的，就酱……

---------------------------------------分割线----------------------------------------------------

> 本文主要介绍如何通过**ClassPathXmlApplicationContext**加载Spring Beans
- 什么是ClassPathXmlApplicationContext
>Standalone XML application context, taking the context definition files from the class path, interpreting plain paths as class path resource names that include the package path (e.g. "mypackage/myresource.txt"). Useful for test harnesses as well as for application contexts embedded within JARs.

这是spring源码里给出的定义。它是独立的XML应用上下文，从classpath里得到上下文定义文件，将纯路径解释为包含包路径的classpath路径名称
<!-- more -->
- 调用ClassPathXmlApplicationContext构造方法

先看下ClassPathXmlApplicationContext类的继承关系（不得不吐槽下有道云笔记，上传图片不能直接粘贴，还非得分享了才行）

![](http://ww1.sinaimg.cn/large/ad274f89ly1g0u6nkicy6j20rh07pt9n.jpg)

ClassPathXmlApplicationContext继承了AbstractXmlApplicationContext类，而AbstractXmlApplicationContext又继承了AbstractApplicationContext，refresh正是这个类的方法
```
public ClassPathXmlApplicationContext(String[] configLocations, boolean refresh, ApplicationContext parent)
			throws BeansException {

		super(parent);
		setConfigLocations(configLocations);
		// 为true会自动刷新上下文
		if (refresh) {
			refresh();
		}
	}
```
众所周知，refresh方法是关键，现在看下refresh方法干了啥

```
	@Override
	public void refresh() throws BeansException, IllegalStateException {
	    // refresh和destory共用一把同步锁
		synchronized (this.startupShutdownMonitor) {
			// Prepare this context for refreshing.
			prepareRefresh();

			// Tell the subclass to refresh the internal bean factory.
			ConfigurableListableBeanFactory beanFactory = obtainFreshBeanFactory();

			// Prepare the bean factory for use in this context.
			prepareBeanFactory(beanFactory);

			try {
				// Allows post-processing of the bean factory in context subclasses.
				postProcessBeanFactory(beanFactory);

				// Invoke factory processors registered as beans in the context.
				invokeBeanFactoryPostProcessors(beanFactory);

				// Register bean processors that intercept bean creation.
				registerBeanPostProcessors(beanFactory);

				// Initialize message source for this context.
				initMessageSource();

				// Initialize event multicaster for this context.
				initApplicationEventMulticaster();

				// Initialize other special beans in specific context subclasses.
				onRefresh();

				// Check for listener beans and register them.
				registerListeners();

				// Instantiate all remaining (non-lazy-init) singletons.
				finishBeanFactoryInitialization(beanFactory);

				// Last step: publish corresponding event.
				finishRefresh();
			}

			catch (BeansException ex) {
				logger.warn("Exception encountered during context initialization - cancelling refresh attempt", ex);

				// Destroy already created singletons to avoid dangling resources.
				destroyBeans();

				// Reset 'active' flag.
				cancelRefresh(ex);

				// Propagate exception to caller.
				throw ex;
			}
		}
	}
```
茫茫多的方法，一个一个看下每个方法都做了什么
1. prepareRefresh
 
这个方法简单，做了一些初始准备，设定开始时间，激活标识等
2. 第二步很重要，bean注册到factory就是在这里处理的，重点看下

```
	@Override
	protected final void refreshBeanFactory() throws BeansException {
	    // 如果已经初始化了bean factory，从内存中循环销毁bean，并清空bean factory
		if (hasBeanFactory()) {
			destroyBeans();
			closeBeanFactory();
		}
		try {
			DefaultListableBeanFactory beanFactory = createBeanFactory();
			beanFactory.setSerializationId(getId());
			customizeBeanFactory(beanFactory);
			// 加载beans
			loadBeanDefinitions(beanFactory);
			synchronized (this.beanFactoryMonitor) {
				this.beanFactory = beanFactory;
			}
		}
		catch (IOException ex) {
			throw new ApplicationContextException("I/O error parsing bean definition source for " + getDisplayName(), ex);
		}
	}
```
先创建了bean factory，类型是DefaultListableBeanFactory。接下来重头戏来了，先看代码

```
	@Override
	protected void loadBeanDefinitions(DefaultListableBeanFactory beanFactory) throws BeansException, IOException {
		// Create a new XmlBeanDefinitionReader for the given BeanFactory.
		// bean都是从xml文件加载的
		XmlBeanDefinitionReader beanDefinitionReader = new XmlBeanDefinitionReader(beanFactory);

		// Configure the bean definition reader with this context's
		// resource loading environment.
		beanDefinitionReader.setEnvironment(this.getEnvironment());
		beanDefinitionReader.setResourceLoader(this);
		beanDefinitionReader.setEntityResolver(new ResourceEntityResolver(this));

		// Allow a subclass to provide custom initialization of the reader,
		// then proceed with actually loading the bean definitions.
		// 注释已经说得很明白了，你要初始化bean，当然先要把xml reader准备好了，得先让给你干活的准备好了，人家才能帮你初始化。不过貌似也没干啥。。
		initBeanDefinitionReader(beanDefinitionReader);
		// 真正初始化在这
		loadBeanDefinitions(beanDefinitionReader);
	}
```
逐步揭开bean加载的神秘面纱，接着看

```
	protected void loadBeanDefinitions(XmlBeanDefinitionReader reader) throws BeansException, IOException {
		Resource[] configResources = getConfigResources();
		if (configResources != null) {
			reader.loadBeanDefinitions(configResources);
		}
		// 这里就是初始化ClassPathXmlApplicationContext时指定的xml文件
		String[] configLocations = getConfigLocations();
		if (configLocations != null) {
		    // reader开始加载bean了
			reader.loadBeanDefinitions(configLocations);
		}
	}
```
接着看吧，还没到具体如何加载的地方（外国人写的就是好，鼓掌）
关键的方法都在XmlBeanDefinitionReader里，接下来就是通过读xml的方式从指定的xml文件里读取bean

```
	@SuppressWarnings("deprecation")
	public int registerBeanDefinitions(Document doc, Resource resource) throws BeanDefinitionStoreException {
	    // 获得document reader时，需要获得spring namespace hander
		BeanDefinitionDocumentReader documentReader = createBeanDefinitionDocumentReader();
		documentReader.setEnvironment(getEnvironment());
		int countBefore = getRegistry().getBeanDefinitionCount();
		documentReader.registerBeanDefinitions(doc, createReaderContext(resource));
		return getRegistry().getBeanDefinitionCount() - countBefore;
	}
```
解析之前，需要获得指定的namespace handler，默认的handler在META-INF/spring.handlers路径下

```
	protected void doRegisterBeanDefinitions(Element root) {
		BeanDefinitionParserDelegate parent = this.delegate;
		this.delegate = createDelegate(getReaderContext(), root, parent);

		if (this.delegate.isDefaultNamespace(root)) {
			String profileSpec = root.getAttribute(PROFILE_ATTRIBUTE);
			if (StringUtils.hasText(profileSpec)) {
				String[] specifiedProfiles = StringUtils.tokenizeToStringArray(
						profileSpec, BeanDefinitionParserDelegate.MULTI_VALUE_ATTRIBUTE_DELIMITERS);
				if (!getReaderContext().getEnvironment().acceptsProfiles(specifiedProfiles)) {
					return;
				}
			}
		}

		preProcessXml(root);
		parseBeanDefinitions(root, this.delegate);
		postProcessXml(root);

		this.delegate = parent;
	}
```
在解析bean之前，会先创建delegate，delegate是用来解析xml bean的（后面会看见这个delegate有多重要）。创建delegate时，会初始化beans节点lazy-init、autowire等属性

```
	protected void parseBeanDefinitions(Element root, BeanDefinitionParserDelegate delegate) {
		if (delegate.isDefaultNamespace(root)) {
			NodeList nl = root.getChildNodes();
			for (int i = 0; i < nl.getLength(); i++) {
				Node node = nl.item(i);
				if (node instanceof Element) {
					Element ele = (Element) node;
					// handle spring namespace
					if (delegate.isDefaultNamespace(ele)) {
						parseDefaultElement(ele, delegate);
					}
					else {
						delegate.parseCustomElement(ele);
					}
				}
			}
		}
		else {
			delegate.parseCustomElement(root);
		}
	}
```
在这里会循环解析beans下的各个节点，每个节点都有自己的namespace，默认的namespace是http://www.springframework.org/schema/beans。先看下不是默认namespace的节点是如何解析的。

先获得节点对应的namespace，从**META-INF/spring.handlers**获得所有的mappings。然后取得namespace对应的handler。例如aop对应的handler是http\://www.springframework.org/schema/aop=org.springframework.aop.config.AopNamespaceHandler

```
	@Override
	public NamespaceHandler resolve(String namespaceUri) {
		Map<String, Object> handlerMappings = getHandlerMappings();
		Object handlerOrClassName = handlerMappings.get(namespaceUri);
		if (handlerOrClassName == null) {
			return null;
		}
		else if (handlerOrClassName instanceof NamespaceHandler) {
			return (NamespaceHandler) handlerOrClassName;
		}
		else {
			String className = (String) handlerOrClassName;
			try {
				Class<?> handlerClass = ClassUtils.forName(className, this.classLoader);
				if (!NamespaceHandler.class.isAssignableFrom(handlerClass)) {
					throw new FatalBeanException("Class [" + className + "] for namespace [" + namespaceUri +
							"] does not implement the [" + NamespaceHandler.class.getName() + "] interface");
				}
				NamespaceHandler namespaceHandler = (NamespaceHandler) BeanUtils.instantiateClass(handlerClass);
				// 为节点的每个element注册parser
				namespaceHandler.init();
				// 覆盖mapping，value改为经过parser解析的handler
				handlerMappings.put(namespaceUri, namespaceHandler);
				return namespaceHandler;
			}
			catch (ClassNotFoundException ex) {
				throw new FatalBeanException("NamespaceHandler class [" + className + "] for namespace [" +
						namespaceUri + "] not found", ex);
			}
			catch (LinkageError err) {
				throw new FatalBeanException("Invalid NamespaceHandler class [" + className + "] for namespace [" +
						namespaceUri + "]: problem with handler class file or dependent class", err);
			}
		}
	}
```


```
	public BeanDefinition parseCustomElement(Element ele, BeanDefinition containingBd) {
		String namespaceUri = getNamespaceURI(ele);
		// 找到namespace对应的handler
		NamespaceHandler handler = this.readerContext.getNamespaceHandlerResolver().resolve(namespaceUri);
		if (handler == null) {
			error("Unable to locate Spring NamespaceHandler for XML schema namespace [" + namespaceUri + "]", ele);
			return null;
		}
		return handler.parse(ele, new ParserContext(this.readerContext, this, containingBd));
	}
```
上面在namespaceHandler.init()的是时候已经注册了parser，现在只需根据element找到对应的parser。这块就先不说了，言归正传

下面看下spring 默认namespace下bean元素是如何解析的（终于要开始解析了。。）

```
	private void parseDefaultElement(Element ele, BeanDefinitionParserDelegate delegate) {
		if (delegate.nodeNameEquals(ele, IMPORT_ELEMENT)) {
			importBeanDefinitionResource(ele);
		}
		else if (delegate.nodeNameEquals(ele, ALIAS_ELEMENT)) {
			processAliasRegistration(ele);
		}
		// 解析bean类型的元素
		else if (delegate.nodeNameEquals(ele, BEAN_ELEMENT)) {
			processBeanDefinition(ele, delegate);
		}
		else if (delegate.nodeNameEquals(ele, NESTED_BEANS_ELEMENT)) {
			// recurse
			doRegisterBeanDefinitions(ele);
		}
	}
```
```
	protected void processBeanDefinition(Element ele, BeanDefinitionParserDelegate delegate) {
	    // 每个beanDefinition都被封装成了beanDefinitionHolder，beanDefinition就是在这里生成的
		BeanDefinitionHolder bdHolder = delegate.parseBeanDefinitionElement(ele);
		if (bdHolder != null) {
			bdHolder = delegate.decorateBeanDefinitionIfRequired(ele, bdHolder);
			try {
				// 在这里把bean注册到factory里
				BeanDefinitionReaderUtils.registerBeanDefinition(bdHolder, getReaderContext().getRegistry());
			}
			catch (BeanDefinitionStoreException ex) {
				getReaderContext().error("Failed to register bean definition with name '" +
						bdHolder.getBeanName() + "'", ele, ex);
			}
			// Send registration event.
			getReaderContext().fireComponentRegistered(new BeanComponentDefinition(bdHolder));
		}
	}
```

下面看下是如何生成beanDefiniitionHolder的

```
	public BeanDefinitionHolder parseBeanDefinitionElement(Element ele, BeanDefinition containingBean) {
		String id = ele.getAttribute(ID_ATTRIBUTE);
		String nameAttr = ele.getAttribute(NAME_ATTRIBUTE);

		List<String> aliases = new ArrayList<String>();
		if (StringUtils.hasLength(nameAttr)) {
			String[] nameArr = StringUtils.tokenizeToStringArray(nameAttr, MULTI_VALUE_ATTRIBUTE_DELIMITERS);
			aliases.addAll(Arrays.asList(nameArr));
		}

		String beanName = id;
		if (!StringUtils.hasText(beanName) && !aliases.isEmpty()) {
			beanName = aliases.remove(0);
			if (logger.isDebugEnabled()) {
				logger.debug("No XML 'id' specified - using '" + beanName +
						"' as bean name and " + aliases + " as aliases");
			}
		}

		if (containingBean == null) {
		    // 校验beanName 和别名是否用过，把当前beanName和alias加入usedNames集合
			checkNameUniqueness(beanName, aliases, ele);
		}

        // 在这里创建beanDefinition
		AbstractBeanDefinition beanDefinition = parseBeanDefinitionElement(ele, beanName, containingBean);
		if (beanDefinition != null) {
			if (!StringUtils.hasText(beanName)) {
				try {
				    // 生成beanName
					if (containingBean != null) {
						beanName = BeanDefinitionReaderUtils.generateBeanName(
								beanDefinition, this.readerContext.getRegistry(), true);
					}
					else {
						beanName = this.readerContext.generateBeanName(beanDefinition);
						// Register an alias for the plain bean class name, if still possible,
						// if the generator returned the class name plus a suffix.
						// This is expected for Spring 1.2/2.0 backwards compatibility.
						String beanClassName = beanDefinition.getBeanClassName();
						if (beanClassName != null &&
								beanName.startsWith(beanClassName) && beanName.length() > beanClassName.length() &&
								!this.readerContext.getRegistry().isBeanNameInUse(beanClassName)) {
							aliases.add(beanClassName);
						}
					}
					if (logger.isDebugEnabled()) {
						logger.debug("Neither XML 'id' nor 'name' specified - " +
								"using generated bean name [" + beanName + "]");
					}
				}
				catch (Exception ex) {
					error(ex.getMessage(), ele);
					return null;
				}
			}
			String[] aliasesArray = StringUtils.toStringArray(aliases);
			return new BeanDefinitionHolder(beanDefinition, beanName, aliasesArray);
		}

		return null;
	}
```
看下具体是如何创建beanDefinition的（终于找到你了），该方法在*BeanDefinitionParserDelegate*里。到这里就一目了然了，先初始化了beanDefinition，然后解析bean的元素，再一步一步解析child节点，比如配置文件properties的解析

```
	public AbstractBeanDefinition parseBeanDefinitionElement(
			Element ele, String beanName, BeanDefinition containingBean) {
        // 当前bean入栈
		this.parseState.push(new BeanEntry(beanName));

		String className = null;
		if (ele.hasAttribute(CLASS_ATTRIBUTE)) {
			className = ele.getAttribute(CLASS_ATTRIBUTE).trim();
		}

		try {
			String parent = null;
			if (ele.hasAttribute(PARENT_ATTRIBUTE)) {
				parent = ele.getAttribute(PARENT_ATTRIBUTE);
			}
			// 初始化beanDefinition，设定了bean class name和 parent name
			AbstractBeanDefinition bd = createBeanDefinition(className, parent);
            
            // 解析bean元素的各种属性，比如scope，lazyInit
			parseBeanDefinitionAttributes(ele, beanName, containingBean, bd);
			bd.setDescription(DomUtils.getChildElementValueByTagName(ele, DESCRIPTION_ELEMENT));

			parseMetaElements(ele, bd);
			parseLookupOverrideSubElements(ele, bd.getMethodOverrides());
			parseReplacedMethodSubElements(ele, bd.getMethodOverrides());

            // 解析构造函数
			parseConstructorArgElements(ele, bd);
			
			// 解析properties，经常用来加载配置文件
			parsePropertyElements(ele, bd);
			parseQualifierElements(ele, bd);

			bd.setResource(this.readerContext.getResource());
			bd.setSource(extractSource(ele));

			return bd;
		}
		catch (ClassNotFoundException ex) {
			error("Bean class [" + className + "] not found", ele, ex);
		}
		catch (NoClassDefFoundError err) {
			error("Class that bean class [" + className + "] depends on not found", ele, err);
		}
		catch (Throwable ex) {
			error("Unexpected failure during bean definition parsing", ele, ex);
		}
		finally {
		    // 解析完成从栈里弹出
			this.parseState.pop();
		}

		return null;
	}
```
最后再看下bean是如何注册factory的

```
	public static void registerBeanDefinition(
			BeanDefinitionHolder definitionHolder, BeanDefinitionRegistry registry)
			throws BeanDefinitionStoreException {

		// Register bean definition under primary name.
		String beanName = definitionHolder.getBeanName();
		registry.registerBeanDefinition(beanName, definitionHolder.getBeanDefinition());

		// Register aliases for bean name, if any.
		String[] aliases = definitionHolder.getAliases();
		if (aliases != null) {
			for (String alias : aliases) {
				registry.registerAlias(beanName, alias);
			}
		}
	}
```
注册到*DefaultListableBeanFactory*时需要校验当前beanName是否注册过了，如果注册过的话，能否支持覆盖。如果bean已经注册过，或者已经存在单例的话，需要清除单例和缓存

至此bean的注册过程已经完事了，后续文章再看下refresh的其他方法