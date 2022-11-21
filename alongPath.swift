import SwiftUI
import PlaygroundSupport

/* based on:  https://stackoverflow.com/questions/59648676/is-it-possible-to-animate-view-on-a-certain-path-in-swiftui
 and
 https://stackoverflow.com/questions/34474274/how-to-create-a-wave-path-swift
*/

struct PathAnimatingView<Content>: UIViewRepresentable where Content: View {
    let path: Path
    let content: () -> Content

    func makeUIView(context: UIViewRepresentableContext<PathAnimatingView>) -> UIView {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false

        let animation = CAKeyframeAnimation(keyPath: #keyPath(CALayer.position))
            animation.duration = CFTimeInterval(3)
            animation.repeatCount = 10
            animation.path = path.cgPath
            animation.isRemovedOnCompletion = false
            animation.fillMode = .forwards
            animation.timingFunction = CAMediaTimingFunction(name: .linear)

        let sub = UIHostingController(rootView: content())
        sub.view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(sub.view)
        sub.view.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        sub.view.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        view.layer.add(animation, forKey: "someAnimationName")
        return view
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PathAnimatingView>) {
    }

    typealias UIViewType = UIView
}

struct Animating: ViewModifier {
    var path: Path
    func body(content: Content) -> some View {
        PathAnimatingView(path: path){
            content
        }
    }
}

extension View {
    func animating(along path: Path) -> some View {
        modifier(Animating(path: path))
    }
}

let bp = path(in: CGRect(origin: .zero, size: .init(width: 300, height: 300)), count: 30) { (sin($0 * .pi * 2.0) + 1.0) / 2.0 }

struct ContentView: View {
    @State var isOff = false
    
    var body: some View {
        HStack {
            Text("START")
            Circle()
                .offset(x: 125, y: 250)
                .animating(along: Path(bp.cgPath))
            Text("FINISH")
                
        }
        .onTapGesture { isOff.toggle() }
        .frame(width: 400, height: 400)
    }
}


/// Build path within rectangle
///
/// Given a `function` that converts values between zero and one to another values between zero and one, this method will create `UIBezierPath` within `rect` using that `function`.
///
/// - parameter rect:      The `CGRect` of points on the screen.
///
/// - parameter count:     How many points should be rendered. Defaults to `rect.size.width`.
///
/// - parameter function:  A closure that will be passed an floating point number between zero and one and should return a return value between zero and one as well.

private func path(in rect: CGRect, count: Int? = nil, function: (CGFloat) -> (CGFloat)) -> UIBezierPath {
    let numberOfPoints = count ?? Int(rect.size.width)

    let path = UIBezierPath()
    path.move(to: convert(point: CGPoint(x: 0, y: function(0)), in: rect))
    for i in 1 ..< numberOfPoints {
        let x = CGFloat(i) / CGFloat(numberOfPoints - 1)
        path.addLine(to: convert(point: CGPoint(x: x, y: function(x)), in: rect))
    }
    return path
}

/// Convert point with x and y values between 0 and 1 within the `CGRect`.
///
/// - parameter point:  A `CGPoint` value with x and y values between 0 and 1.
/// - parameter rect:   The `CGRect` within which that point should be converted.

private func convert(point: CGPoint, in rect: CGRect) -> CGPoint {
    return CGPoint(
        x: rect.origin.x + point.x * rect.size.width,
        y: rect.origin.y + rect.size.height - point.y * rect.size.height
    )
}

PlaygroundPage.current.setLiveView(ContentView())

