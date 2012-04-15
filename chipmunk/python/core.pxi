
# init the library, whatever we will do.
cpInitChipmunk()

def moment_for_circle(mass, inner_radius, outer_radius, offset=(0, 0)):
    return cpMomentForCircle(mass, inner_radius, outer_radius, cpv(offset.x, offset.y))

def moment_for_segment(mass, a, b):
    return cpMomentForSegment(mass, cpv(a.x, a.y), cpv(b.x, b.y))

#def moment_for_poly(mass, vertices,  offset=(0, 0)):
#    verts = (Vec2d * len(vertices))
#    verts = verts(Vec2d(0, 0))
#    for (i, vertex) in enumerate(vertices):
#        verts[i].x = vertex[0]
#        verts[i].y = vertex[1]
#    return cpMomentForPoly(mass, len(verts), verts, offset)

def moment_for_box(mass, width, height):
    return cpMomentForBox(mass, width, height)

def reset_shapeid_counter():
    cpResetShapeIdCounter()

cdef class Contact:
    def __cinit__(self, _contact):
        self._point = _contact.point
        self._normal = _contact.normal
        self._dist = _contact.dist

    def __repr__(self):
        return 'Contact(%r, %r, %r)' % (
            self.position, self.normal, self.distance)

    property position:
        def __get__(self):
            return self._point

    property normal:
        def __get__(self):
            return self._normal

    property distance:
        def __get__(self):
            return self._dist


#cdef class BB:
    #def __cinit__(self, *args):
    #    if len(args) == 0:
    #        self._bb = cpBB()
    #    elif len(args) == 1:
    #        self._bb = args[0]
        #else:
        #    self._bb = cpBBNew(args[0], args[1], args[2], args[3])

    #def __repr__(self):
    #    return 'BB(%s, %s, %s, %s)' % (self.left, self.bottom, self.right, self.top)

    #def __eq__(self, other):
    #    return self.left == other.left and self.bottom == other.bottom and \
    #        self.right == other.right and self.top == other.top

    #def __ne__(self, other):
    #    return not self.__eq__(other)

    #def intersects(self, other):
    #    return cpBBIntersects(self._bb, other._bb)

    #def contains(self, other):
    #    return cpBBContainsBB(self._bb, other._bb)

    #def contains_vect(self, v):
    #    return cpBBContainsVect(self._bb, cpv(v.x, v.y))

    #def merge(self, other):
    #    return BB(cpBBMerge(self._bb, other._bb))

    #def expand(self, v):
    #    return BB(cpBBExpand(self._bb, cpv(v.x, v.y)))

    #left = property(lambda self: self._bb.l)
    #bottom = property(lambda self: self._bb.b)
    #right = property(lambda self: self._bb.r)
    #top = property(lambda self: self._bb.t)

    #def clamp_vect(self, v):
    #    return cpBBClampVect(self._bb, cpv(v.x, v.y))

    #def wrap_vect(self, v):
    #    return cpBBWrapVect(self._bb, cpv(v.x, v.y))


cdef class Arbiter:
    def __cinit__(self, space):
        self._arbiter = NULL
        self._space = space
        self._contacts = None

    #def _get_contacts(self):
    #    point_set = cpArbiterGetContactPointSet(self._arbiter)
    #    if self._contacts is None:
    #        self._contacts = []
    #        for i in range(point_set.count):
    #            self.contacts.append(Contact(point_set.points[i]))
    #    return self._contacts
    #contacts = property(_get_contacts)

    #def _get_shapes(self):
    #    cdef cpShape** shapeA_p
    #    cdef cpShape** shapeB_p
    #    cpArbiterGetShapes(self._arbiter, shapeA_p, shapeB_p)
    #    a, b = self._space._get_shape(shapeA_p), self._space._get_shape(shapeB_p)
    #    return a, b
    #shapes = property(_get_shapes)

    property elasticity:
        def __get__(self):
            return self._arbiter.e
        def __set__(self, value):
            self._arbiter.e = value

    property friction:
        def __get__(self):
            return self._arbiter.u
        def __set__(self, value):
            self._arbiter.u = value

    property velocity:
        def __get__(self):
            return self._arbiter.surface_vr

    property total_impulse:
        def __get__(self):
            return cpArbiterTotalImpulse(self._arbiter)

    property total_impulse_with_friction:
        def __get__(self):
            return cpArbiterTotalImpulseWithFriction(self._arbiter)

    #property stamp:
    #    def __get__(self):
    #        return self._arbiter.stamp

    property is_first_contact:
        def __get__(self):
            return cpArbiterIsFirstContact(self._arbiter)

