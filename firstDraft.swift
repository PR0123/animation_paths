import SwiftUI
import PlaygroundSupport

struct MyView: View{
    @State var point: CGPoint = .zero
    @State var length: Double = 100
    @State var rotation: Double = 0
    @State var path: Path = Path(.zero)
    @State var bp: UIBezierPath = BasePath.wave.unitPath()
    
    func fitPath(to current: CGPoint) -> Path {
        length = point.distance(to: current)
        rotation = point.angle(to: current)
        var bp = UIBezierPath(cgPath: bp.cgPath)
        bp.apply(.init(translationX: point.x, y: point.y)
            .rotated(by: rotation)
            .scaledBy(x: length, y: length))
        point = current
        return Path(bp.cgPath)
    }
    
    var body: some View{
        ZStack{
            Path(path.cgPath).stroke()
            Circle()
            .frame(width: 20, height: 20)
            .animating(along: path)
            .frame(width: 640, height: 480) //animation space
            .onTapGesture(){ current in
                if let randomPath = BasePath.allCases.randomElement(){
                    bp = randomPath.unitPath()
                }
                path = fitPath(to: current)
            }
        }
    }
}

struct RepresentedView<Content>: UIViewRepresentable where Content: View {
    let path: Path
    let swiftuiview: Content

    func makeUIView(context: Context) -> UIView {
        let vc = UIHostingController(rootView: swiftuiview)
        vc.view.backgroundColor = .clear
        return vc.view
    }

    func updateUIView(_ view: UIView, context: UIViewRepresentableContext<RepresentedView>) {
        let animation = CAKeyframeAnimation(keyPath: #keyPath(CALayer.position))
        animation.path = path.cgPath
            animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        view.layer.add(animation, forKey: "animation")
    }
}

struct Animating: ViewModifier {
    var path: Path
    func body(content: Content) -> some View {
            RepresentedView(path: path, swiftuiview: content)
    }
}

extension View {
    func animating(along path: Path) -> some View {
        modifier(Animating(path: path))
    }
}

// Some example paths for a demo
enum BasePath: CaseIterable {
    case wave
    case zigzag
    case word(text: String)
    static var allCases = [wave, zigzag, word(text: "iOS")]

    func unitPath()->UIBezierPath{
        let path = UIBezierPath()
        switch self{
        case .wave:
            path.move(to: CGPoint(x: 0, y: 0))
            path.addCurve(
                to: CGPoint(x: 1, y: 0),
                controlPoint1: CGPoint(x: 0.5, y: 0.5),
                controlPoint2: CGPoint(x: 0.5, y: -0.5)
            )
            return path
        case .zigzag:
            path.move(to: CGPoint(x: 0, y: 0))
            var y = 0.1
            for x in stride(from: 0, through: 1, by: 0.1){
                path.addLine(to: CGPoint(x: x, y: y))
                y = -y
            }
            path.addLine(to: CGPoint(x: 1, y: 0))
            return path
        case .word(let text):
            text.prepare(for: path)
        }
        return path
    }
}

// Helper functions
extension CGPoint {
    func angle(to point: CGPoint) -> Double {
        let dx = point.x - x
        let dy = point.y - y
        return atan2(dy, dx)
    }
    
    func distance(to point: CGPoint) -> Double{
        let squared = (x - point.x) * (x - point.x) + (y - point.y) * (y - point.y)
        return sqrt(squared)
    }
}

extension String{
    /*
    Text to path convertion loosely based on: https://stackoverflow.com/questions/34465201/animating-the-drawing-of-letters-with-cgpaths-and-cashapelayers
    */
    func prepare(for path: UIBezierPath) -> UIBezierPath{
        
        var i = -count
        for letter in self {
            let newPath = getPathForLetter(letter: letter)
            let actualPathRect = path.cgPath.boundingBox
            let transform = CGAffineTransform(
                translationX: actualPathRect.width, y: 0)
            newPath.apply(transform)
            path.append(newPath)
            i += 1
        }
        
        func getPathForLetter(letter: Character) -> UIBezierPath {
            var path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y: 0))
            let font = CTFontCreateWithName("HelveticaNeue" as CFString, 1, nil)
            var unichars = [UniChar]("\(letter)".utf16)
            var glyphs = [UniChar](repeating: 0, count: unichars.count)
            let gotGlyphs = CTFontGetGlyphsForCharacters(font, &unichars, &glyphs, unichars.count)
            if gotGlyphs {
                let cgpath = CTFontCreatePathForGlyph(font, glyphs[0], nil)
                let letterpath = UIBezierPath(cgPath: cgpath!)
                path.append(letterpath)
            }
            path.apply(.init(scaleX: 1, y: -1))
            return path
        }
        
        let actualPathRect = path.cgPath.boundingBox
        let (w, h) = (actualPathRect.width, actualPathRect.height)
        let transform = CGAffineTransform(scaleX: 1/w, y: 1/h).translatedBy(x: 0, y: -path.currentPoint.y)
        path.apply(transform)
        path.addLine(to: CGPoint(x: 1, y: 0))
        return path
    }
}

PlaygroundPage.current.setLiveView(MyView())
