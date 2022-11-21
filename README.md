# Animate position along the path in SwiftUI
In SwiftUI every animation would always take the shortest path. It is easy to imagine animating position along the path. Is lack of this option the design choice or just the current state of the framework?

# 
The code is just to ilustrate the concept, and is not solving the problem.
The path needs to be scalable, taking the |vector| of translation as one unit in X dimension and perpendicular Y dimension.
Such path defined in unit space can be used by the animation modifier.

