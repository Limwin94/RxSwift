## 비동기 처리

- **escaping**이 필요한 이유?
DispatchQueue.global.async()의 경우 다른 스레드에서 동작하기 때문에 해당 context를 건너 뛰고 동작하게 된다.

    ```swift
    func downloadJson(_ url: String, _ completion: (String?) -> Void) {
    		// 1. 시작
    		DispatchQueue.global.async() {
    			// json 다운로드 동작하는 코드
    			// 3. main.async() 는 downloadJson 함수가 끝나고 사용된다.
    			// 4. escaping 처리를 해주면 함수가 끝나고도 동작이 되는걸 보장한다.
    			// 5. 단 옵셔널인 경우는 escaping이 default로 적용된다.
    			DispatchQueue.main.async() {
    				completion(json)
    			}
    		}
    		// 2. 백그라운드 스레드이므로 바로 이곳으로 도달.
    }
    ```

- 비동기로 생기는 결과값을 completion이 아니라 return으로 받고 싶다?

    ```swift
    class 나중에생기는데이터<T> {
    		// 나중에 데이터가 오면 해야할 일들을 저장해놓고 있음.
    		private let task: (@escaping (T) -> Void) -> Void

    		// 함수를 인자로 받아버린다.
    		init(task: @escaping (@escaping (T) -> Void) -> Void) {
    				self.task = task
    		}

    		// 나중에 필요한 시점에 호출해서 사용.
    		func 나중에오면 (_ f: @escaping (T) -> Void) {
    				// task(@escaping (T) -> Void)
    				// task(@escaping (@escaping (T) -> Void) -> Void)
    				task(f)
    		}
    }
    ```

    이렇게 return으로 받게 해주는 유틸리티가 생겨남.
    1. Promise (then)
    2. Bolt (then)
    3. **RxSwift** (subscribe, observable)

## Observable, Subscribe

- **RxSwift**
    1. 비동기로 생기는 데이터를 Observable로 감싸서 리턴한다.
    **Observable** : 위에서 나중에 생기는 데이터와 같은 역할은 한다고 보면 된다.
    **Observable**에서 **onNext()**로 값을 전달하고
    2. Observable로 오는 데이터를 처리하는 방법
    **Subscribe** (=나중에오면)에서 **event**로 받는데, event에는 completed, next, error가 있다.
    값을 받을땐 next로 받음.

    **Disposable**은 dispose를 수행할 수 있음. 작업이 완료되지 않았더라도 작업을 취소 시킬때 사용한다.

    subscribe에서 받는 closure에서 순환참조가 일어날 수 있다.
    reference count가 complete나, error case로 넘어왔을때 다시 감소된다.

    그래서 **onNext()**로 값을 던져주고, **onCompleted()**로 끝났다고 알려주게 된다. (closure 종료를 위해)
    이로써 순환참조 문제를 해결해줌.

- **Observable의 생명주기**
1. **Create**
2. **Subscribe**
: 단순히 Create가 되었다고 동작하는게 아니라, Subscribe 되었을때 동작(실행)된다.
3. **onNext** / **onError**
4. **onCompleted**
5. **Disposed**

    동작이 끝난 Observable은 재사용을 하지 못한다.
    새로운 subscribe가 붙어야 동작한다.

## Operator

짧게 줄이고 간단하게 사용할 수 있도록 만들어 둔 것. (생성, subscribe, 데이터 변경, 스레드 변경 등)

- **Just**, **from**

```swift
Observable.create() { emitter in
		emitter.onNext("Hello World")
		emitter.onCompleted()
		return Disposables.create()
}

// 둘다 같은 표현. 단 하나의 데이터만 내려간다.
Observable.just("Hello World")

// 여러 데이터를 순서대로 '하나씩' 내보내고 싶을때는 from
Observable.from(["Hello", "World"])
```

```swift
// onNext만 처리하고 싶을때.
.subscribe(onNext: { print($0) })

// 이런식으로 필요한것만 처리하고 싶을때 해당 방식으로 구현할 수 있다.
.subscribe(onNext: { print($0) }, onCompleted: { print($0) })
```

- **observeOn, subscribeOn**

```swift
// 메인 스레드에서 동작하도록 설정한다. = DispatchQueue.main.async
// 변경된 스레드는 밑에 줄부터 적용된다.
.observeOn(MainScheduler.instance)
.subscribe()

// 어떤 스레드에서 시작할 것인지 정해주는 Operator.
// 위치가 상관이 없다.
.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
```

- **map**, **filter**
- map : 지정한 형식대로 데이터를 변환해서 내려보냄. 
처음부터 쓸 수 있는것이 아니라 이전 Observable과 다음 Observable을 연결해줄수 있을때 사용가능하다.

- filter : 조건에 해당하는 값만 내려보냄.

이외에도 많은 Operator가 있는데 ReactiveX 홈페이지에서 어떤식으로 동작하는지 확인이 가능하다.

크게는 
- 데이터 생성 
- 데이터 변형
- 데이터 필터링
- 여러가지 operator들을 combine(조합)
- 에러 헨들링
- 유틸리티
6개 분류로 나눌 수 있다.

## Stream의 분리, 병합

- **combine**
Merge, Zip, CombineLatest를 가장 많이 쓴다.
1. **Merge**
다수의 Observable의 데이터를 합친다. 
대신 Merge되는 데이터들은 type이 같아야 한다.
2. **Zip**
다수의 Observable의 데이터를 쌍으로 묶는다. 
쌍으로 묶기 때문에 데이터가 1개만 있을 경우 쌍으로 만들어 지지 않는다. (쌍으로 만들어지지 않는 데이터는 내려보내지 않는다.) 
**Merge**와는 다르게 type이 달라도 된다.
3. **CombineLatest**
Zip처럼 쌍으로 묶는다. 차이점은 쌍으로 묶을 데이터가 없으면 가장 최근 데이터를 사용해 쌍으로 만들어 내려보낸다.

## DisposeBag

dispose를 관리 할 수 있게 해준다.

```swift
var disposeBag = DisposeBag()

// stream 마지막에서 disposable이라는 DisposeBag에 deposed를 넣는다.
// deinit될때 프로퍼티가 메모리에서 해제되므로 disposeBag에 담겨 있던 Observable 전부 dispose 된다.
.disposed(by: disposeBag)
```

## Subject

Observable 외부에서 값을 컨트롤 할 수는 없을까?, Observable은 정해진 값을 내보내는 역할을 하지 외부에서 값을 받아서 넘겨주는 역할은 하지 않는다.

⇒ 외부 Action에 대해서 반응하면서 값에 대한 변경이 일어났을 경우 컨트롤 할 수 있는 경우?

**Subject**는 Observable처럼 subscribe로 값을 받아올 수 있지만, 외부에서도 값을 통제할 수 있다. (Observable과 달리 값을 주입시켜 줄 수 있음.)

```swift
// ViewModel
var totalPrice: PublishSubject<Int> = PublishSubject()

// Action
// 이럴 경우에 100을 보내는것뿐 누적은 되지 않음.
viewModel.totalPrice.onNext(100)
```

4가지 종류가 있다.
1. **AsyncSubject**
    : 여러 Observable이 subscribe을 하더라도 데이터를 내려보내주지 않는다. 그러다 complete되는 시점에서 가장 마지막에 있던 데이터를 내려보내준다.

2. **BehaviorSubject** ⭐︎
    : 기본값을 하나 가지고 있어 누군가 subscribe하면 기본값부터 먼저 내려준다. 이후에 subscribe가 발생하면        가장 최근의 데이터를 내려준다.

3. **PublishSubject** ⭐︎
    : subscribe하고 있는 모든 Observable에게 값을 내려줌.

4. **ReplaySubject**
    : 첫번째 subscibe까진 PublishSubject와 같으나, 다음 subscribe부터는 여태까지 발생했던 모든 데이터를 한번에 내려준다.

subscribe 한번만 해주면 UI가 업데이트될때마다 매번 관련된 함수나 로직을 부를 필요가 없이 계속해서 동작하는 코드를 만들수있다.

```swift
// Observable의 값이 바뀔때마다 totalPrice가 계산되서 리턴된다.
// onNext로 값이 들어갈때마다 subscribe한 Observable에 데이터가 전달된다.
lazy var menuObservable = PublishSubject<[Menu]>()

lazy var totalPrice = menuObservable.map { 
		$0.map { $0.price & $0.count }.reduce(0, +)
}
```

- **RxCocoa** : RxSwift의 기능을 UIKit의 Extension으로 추가한것.

```swift
viewModel.itemsCount
	.map { "\($0)" }
	.catchErrorJstReturn("")
	// 메인 스레드가 아닌 다른 스레드에서 데이터가 와도 변환해서 문제가 없어짐.
	.observeOn(MainScheduler.instance) 
	.bind(to: itemCountLabel.rx.text) // RxCocoa
	// bind와 밑의 subscribe는 같은 동작을 하는 코드.
	// .subscribe(onNext: {
	//		 self.totalPrice.text = $0
	// })
	.disposed(by: disposeBag)
```

onNext로 closure를 사용하면 순환참조 문제를 걱정해야 하나,
bind를 사용하면 순환참조 문제가 없어짐.

```swift
// 각각 순서대로 에러처리, 스레드 설정, label.text에 값 설정
// 처리 로직에서 에러가 나더라도 UI는 살아있어야 한다.
.catchErrorJustReturn("") // 에러가 있을시 ""처리
.observeOn(MainScheduler.instance) // UI업데이트는 무조건 메인 스레드.
.bind(to: itemCountLabel.rx.text)

// 같은 로직
.asDriver(onErrorJustReturn: "") //Driver는 무조건 메인 스레드에서 실행된다.
.drive(itemCountLabel.rx.text) //bind 역할.
```

- +, - 버튼 로직

```swift
// cell
var onChange: ((Int) -> Void)?

// plus Button Action
@IBOutlet func onIncreasCount() {
		onChange?(+1)
}

// ViewController
cell.onChange = { increase in
		self.viewModel.changeCount(item, increase)
}

// ViewModel
func changeCount(item: Menu, increase: Int) {
  // 현재 Menu array에서 값들을 하나씩 받아서 count를 설정
	menuObservable
		.map { menus in
				menus.map { m in
						if m.id == item.id {
								Menu(id: m.id, name: m.name, price: m.price, count: m.count + increase)
						} else {
								// Menu 내부 값은 똑같이
						}
				}
		}
		.take(1) // 한번만 동작할 수 있도록(계속 observable 생성 안되게)
		.subscribe(onNext: { //onNext로 보냄으로써 subscribe 하고 있는 observable들이 받아서 새로 변경.
				self.menuObservable.onNext($0)
		}
}
```

**ViewController**에서는 **View**에 어떻게 보여지게 되는것만 설정해주지 뷰에 관한 로직은 가지고 있지 않음.

뷰에 대한 로직, 클릭이나 이벤트에 대한 처리 로직은 전부 **ViewModel**이 가지고 있음.

View → ViewController → ViewModel(데이터 처리)
테스트케이스를 생각해보면 ViewModel만 따로 분리해서 테스트하는 방법이 훨씬 쉽다.

- 델마와 **의문점**
APIService에서 fetchAllMenus를 굳이 Rx로 한번 감싸서 사용하는 이유는? 단순히 Rx를 사용하기 위해?
내부에서 레거시를 사용하지 않는것도 아니고, 레거시를 사용하면서 까지 다시 Rx로 랩핑하는 이유를 모르겠음.. 비동기처리가 안되는것도 아니고.
그렇다고 Decoding할때 비동기 처리가 안되는것도 아님. 클로져로도 충분히 가능하다고 생각함.

## MVVM 아키텍쳐

1. **MVC**
- Controller : Input에 대한 Action을 여기서 받고, View 세팅 및 출력도 여기서 이루어짐.
- Model(testable) :  View에 보여주기 위한 데이터는 여기서 관리.
- View : 화면.
2. **MVP**
- View : ViewController, Input에 대한  Action을 받음.
- Presenter(testable) : VC에 있던 로직을 가져옴. 로직을 계산해 View에 주입. View를 테스트를 할 필요가 없게 만들어버림.
- Model(testable) : View에 보여지기 위한 데이터.

    공통으로 쓰이는 Presenter가 없이 1:1 관계라 View가 조금만 달라져도 새로운 Presenter가 필요해짐.

3. **MVVM**
- ViewModel : Presenter와 달리 View에 직접 지시하지 않음. View에서 ViewModel로 단방향으로 바라보고 있음. ViewModel의 값이 바뀌면 스스로 변경된다.
- View : 보여줘야하는 요소를 지켜보고 있다가 값이 변경되면 바꿈.

    같은 데이터를 기반으로 한다면 보여주는 형식이 달라지더라도 같은  ViewModel를 보고 있으면 된다.

## RxRelay

- stream이 끊어지지 않게 하기 위해 사용된다.
- UI 작업의 특성상 1. 메인 스레드에서 돌아가야함. 2. 에러가 나더라도 Stream이 끊어지면 안된다.
- Observable → Driver(UI용)
- Subject → Relay(UI용)
