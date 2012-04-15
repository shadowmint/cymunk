from chipmunk import *

space = Space()
space.iterations = 30
space.gravity = (0, -100)
space.sleep_time_threshold = 0.5
space.collision_slop = 0.5

body = Body(100, 1e9)
circle = Circle(body, 50)
circle.elasticity = 1.0
circle.friction = 1.0

space.add(body)

from time import time
start = time()
while time() - start < 5.:
    space.step(1 / 60.)
    print body.position

'''

space = cpSpaceNew()
cpSpaceSetIterations(space, 30)
cpSpaceSetGravity(space, cpv(0, -100))
cpSpaceSetSleepTimeThreshold(space, 0.5)
cpSpaceSetCollisionSlop(space, 0.5)

body, staticBody = cpSpaceGetStaticBody(space)
cpShape *shape

# Create segments around the edge of the screen.
shape = cpSpaceAddShape(space, cpSegmentShapeNew(staticBody, cpv(-320,-240), cpv(-320,240), 0.0))
cpShapeSetElasticity(shape, 1.0)
cpShapeSetFriction(shape, 1.0)
cpShapeSetLayers(shape, NOT_GRABABLE_MASK)

shape = cpSpaceAddShape(space, cpSegmentShapeNew(staticBody, cpv(320,-240), cpv(320,240), 0.0))
cpShapeSetElasticity(shape, 1.0)
cpShapeSetFriction(shape, 1.0)
cpShapeSetLayers(shape, NOT_GRABABLE_MASK)

shape = cpSpaceAddShape(space, cpSegmentShapeNew(staticBody, cpv(-320,-240), cpv(320,-240), 0.0))
cpShapeSetElasticity(shape, 1.0)
cpShapeSetFriction(shape, 1.0)
cpShapeSetLayers(shape, NOT_GRABABLE_MASK)
'''
