# 【译】Using unit tests to identify & avoid memory leaks in Swift

---

> 原文地址：[Using unit tests to identify & avoid memory leaks in Swift](https://www.swiftbysundell.com/posts/using-unit-tests-to-identify-avoid-memory-leaks-in-swift)
原文作者： John Sundell

>感谢原作者

内存管理和避免内存泄漏是所有编程中的重要内容。在许多场景中，Swift已经把内存管理和避免内存泄漏都做的非常好了，这得益于Apple的ARC(`Automatic Reference Counting`)设计。然而依然在一些场景中会容易犯造成内存泄漏的错误。

在Swift中内存泄漏主要是有“循环引用(retain cycle)”导致的，当一个对象强引用另一个对象，而另一个对象又强引用这个对象。所以出现 A `持有` B，而B也`持有`A。这种问题，有时候很难调试，且不容易复现。

这周，让我们看一下如何使用单元测试来帮助我们检查内存泄漏，同时帮助我们以后避免犯同样的导致内存泄漏的错误。

# Delegates

在Apple平台中，代理模式是非常常见的。代理模式是一个非常优雅的方式，它可以简单的组合起两个对象之间的联系，而且相互之间的调用也很简单。

假设在App中有一个view controller用来显示用户的朋友列表。为了让view controller能够发送事件给自己的owner（强引用该view controller），我们给view controller添加了一个delegate API，如下：

```
class FriendListViewController: UIViewController {
   var delegate: FriendListViewControllerDelegate?
}
```

乍一看没有任何问题，但是仔细看会发现delegate是一个强引用，这样最终会导致出现一个循环引用，因为`FriendListViewController`的owner可能就是这个delegate。

为了检验是否出现循环引用的问题，我们可以使用单元测试来检查：

```
class FriendListViewControllerTests: XCTestCase {
    func testDelegateNotRetained() {
        let controller = FriendListViewController()

        // 创建一个强引用的delegate
        var delegate = FriendListViewControllerDelegateMock()
        controller.delegate = delegate

        // 重新赋值delegate，同时这将导致原本的delegate被释放
        // 因此，view controller的delegate会被置为 nil
        delegate = FriendListViewControllerDelegateMock()
        XCTAssertNil(controller.delegate)
    }
}
```

上面的单元测试会测试失败，因为出现了循环引用。修改方法非常简单：

```
class FriendListViewController: UIViewController {
    weak var delegate: FriendListViewControllerDelegate?
}
```

再次运行单元测试，会发现测试通过。该单元测试不仅帮我们发现了内存泄漏，同时也提供了检查内存泄漏的方法，防止以后再次出现该bug（在重构代码中是十分有用的）。

另外一个检查方法，就是使用[SwiftLint](https://github.com/realm/SwiftLint)，当你定义了一个delegate且没有使用weak属性，SwiftLint会提示你。


# Observers

Observer模式也是一个非常常见的方法，主要用来让一个对象可以一次性通知各种事件给多个对象。和Delegate模式一样，所以我们也不希望去强引用observers，因为observers一般会强引用它们观察(observing)的对象本身。

假设我们有一个类UserManager，通过在数组中存储他的观察者们的方式，来持有所有他的观察者们：

```
class UserManager {
    private var observers = [UserManagerObserver]()

    func addObserver(_ observer: UserManagerObserver) {
        observers.append(observer)
    }
}
```

和delegate的实现一样，上面这种不经意间地存储observers的方式也会导致内存泄漏。

通过单元测试，以上问题也快复现：

```
class UserManagerTests: XCTestCase {
    func testObserversNotRetained() {
        let manager = UserManager()

        // 创建一个强引用的observer，加入到UserManager中
        // 同时创建一个弱引用observer来检查原始observer的释放
        var observer = UserManagerObserverMock()
        weak var weakObserver = observer
        manager.addObserver(observer)

        // 通过重新给observer赋值，我们期望让weakObserver等于nil
        // 因为observers不应该被强应用
        observer = UserManagerObserverMock()
        XCTAssertNil(weakObserver)
    }
}
```

同样地，以上测试方法无法通过。解决以上问题，我们可以创建一个封装类型，来弱引用observers（因为数组永远都是强引用他们的元素）：

```
private extension UserManager {
    struct ObserverWrapper {
        // 弱引用observer
        weak var observer: UserManagerObserver?
    }
}
```

然后我们更新UserManager的代码，使用ObserverWrapper来替换UserManagerObserver，这样测试方法就可以通过了。

```
class UserManager {
    private var observers = [ObserverWrapper]()

    func addObserver(_ observer: UserManagerObserver) {
        let wrapper = ObserverWrapper(observer: observer)
        observers.append(wrapper)
    }
}
```

当你想让集合存储弱引用的对象，通常可以使用以上方法来实现。但是以上方法还缺少清除数组中已经释放UserManagerObserver的ObserverWrapper。一个简单的方法就是在遍历数组时，通过filter方法来过滤已经失效的ObserverWrapper。

举个列子，当我们通知observers一个事件时，如下：

```
private func notifyObserversOfUserChange() {
    observers = observers.filter { wrapper in
        guard let observer = wrapper.observer else {
            return false
        }

        observer.userManager(self, userDidChange: user)
        return true
    }
}
```

# Closures

最后，让我们看一下如何使用单元测试来检查和预防在基于闭包的API中的内存泄漏。闭包通常是内存bug和内存泄漏问题的一个常见来源。因为他们每次都会强引用他们捕获的对象（这些对象被使用在闭包中），详见[Capturing objects in Swift closures](https://www.swiftbysundell.com/posts/capturing-objects-in-swift-closures)。

比如我们创建了一个ImageLoader的类，用来通过网络加载远程图片，并且当图片加载完成后，运行一个 completion handler：

```
class ImageLoader {
    func loadImage(from url: URL,
                   completionHandler: @escaping (UIImage) -> Void) {
        ...
    }
}
```

以上实现方式可能会引发一个常见的错误：当以上操作完成，completionHandler依然还被持有。比如，为了实现取消操作和批处理，我们可能会用一个集合来存储所有的completionHandler，然后忘记从集合中移除这些completionHandler，从而导致内存的过度使用和泄漏。

所以，如何通过单元测试来检查当completionHandler运行完成后，completionHandler是否被正常释放（即该闭包在执行完成后是否被释放）？在上面的场景中，我们可以弱引用delegate和observers，但是我们无法弱引用closures。

我们可以使用另一个方法，使用`对象捕获`把对象和闭包关联起来，然后使用该对象去验证闭包被释放了：

```
class ImageLoaderTests: XCTestCase {
    func testCompletionHandlersRemoved() {
        // 使用一个mock的网络请求来初始化image loader
        let networkManager = NetworkManagerMock()
        let loader = ImageLoader(networkManager: networkManager)

        // 创建URL的mock响应
        let url = URL(fileURLWithPath: "image")
        let data = UIImagePNGRepresentation(UIImage())
        let response = networkManager.mockResponse(for: url, with: data)

        // 创建一个对象，可以是任意类型；同时创建一个对应的强&弱引用
        var object = NSObject()
        weak var weakObject = object

        loader.loadImage(from: url) { [object] image in
            // 使用一个捕获列表捕获变量【使用捕获列表[object]捕获对象是为了使用值捕获（捕获当前值，后续被外部修改不影响），而不是被指针捕获（被外部修改会影响内部变量的值）】
            _ = object
        }

        // 发送mock的response，让上面的闭包执行和释放
        response.send()

        // 把强引用的变量重新赋值，弱引用应该会被置为nil
        // 因为此时闭包已经运行完，并且释放
        object = NSObject()
        XCTAssertNil(weakObject)
    }
}
```

测试方法运行通过，可以保证image loader没有持有闭包。

# Conclusion

当在以上的场景中使用单元测试时，一开始可能会觉得有点过度（重），但是当你想要重现一个内存泄漏的现象或者想增加额外的保护机制来防止进来意外地引入以上问题，单元测试就是一个非常nice的工具。

虽然单元测试不能完全保护你不受内存泄漏的影响，但是它可以潜在地降低你一些你苦苦寻找内存泄漏问题的时间。

---

> 自己修改的演示代码：[Github](https://github.com/Deerdev/iOSDemoCollection/tree/master/09_UnitTestForMemoryLeaks)

