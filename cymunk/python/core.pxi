
#: Version of Cymunk
__version__ = '0.1'

# init the library, whatever we will do.
cpInitChipmunk()


def moment_for_circle(mass, inner_radius, outer_radius, offset=(0, 0)):
    '''
    Calculate the moment of inertia for a circle
    '''
    return cpMomentForCircle(mass, inner_radius, outer_radius, cpv(offset.x, offset.y))


def moment_for_segment(mass, a, b):
    '''
    Calculate the moment of inertia for a segment
    '''
    return cpMomentForSegment(mass, cpv(a.x, a.y), cpv(b.x, b.y))


#def moment_for_poly(mass, vertices,  offset=(0, 0)):
#    verts = (Vec2d * len(vertices))
#    verts = verts(Vec2d(0, 0))
#    for (i, vertex) in enumerate(vertices):
#        verts[i].x = vertex[0]
#        verts[i].y = vertex[1]
#    return cpMomentForPoly(mass, len(verts), verts, offset)


def moment_for_box(mass, width, height):
    '''
    Calculate the moment of inertia for a box
    '''
    return cpMomentForBox(mass, width, height)


def reset_shapeid_counter():
    '''
    Reset the internal shape counter

    cymunk keeps a counter so that every new shape is given a unique hash value
    to be used in the spatial hash. Because this affects the order in which the
    collisions are found and handled, you should reset the shape counter every
    time you populate a space with new shapes. If you don't, there might be
    (very) slight differences in the simulation.
    '''
    cpResetShapeIdCounter()


cdef class Vec2d:
    cdef cpVect v

    def __cinit__(self, float x, float y):
        self.v = cpv(x, y)

    property x:
        def __get__(self):
            return self.v.x
        def __set__(self, value):
            self.v.x = value

    property y:
        def __get__(self):
            return self.v.y
        def __set__(self, value):
            self.v.y = value

    def __getitem__(self, index):
        if index == 0:
            return self.v.x
        elif index == 1:
            return self.v.y
        raise Exception('Invalid index %r, must be 0 or 1' % index)

    def __setitem__(self, index, value):
        if index == 0:
            self.v.x = value
        elif index == 1:
            self.v.y = value
        raise Exception('Invalid index %r, must be 0 or 1' % index)

cdef class Contact:
    '''
    Contact informations
    '''
    def __cinit__(self, _contact):
        self._point = _contact.point
        self._normal = _contact.normal
        self._dist = _contact.dist

    def __repr__(self):
        return 'Contact(%r, %r, %r)' % (
            self.position, self.normal, self.distance)

    property position:
        '''
        Contact position
        '''
        def __get__(self):
            return self._point

    property normal:
        '''
        Contact normal
        '''
        def __get__(self):
            return self._normal

    property distance:
        '''
        Contact distance
        '''
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
    '''
    Arbiters are collision pairs between shapes that are used with the collision
    callbacks.

    .. warning::

        Because arbiters are handled by the space you should never hold onto a
        reference to an arbiter as you don't know when it will be destroyed! Use
        them within the callback where they are given to you and then forget
        about them or copy out the information you need from them.
    '''

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
        '''
        Elasticity
        '''
        def __get__(self):
            return self._arbiter.e
        def __set__(self, value):
            self._arbiter.e = value

    property friction:
        '''
        Friction
        '''
        def __get__(self):
            return self._arbiter.u
        def __set__(self, value):
            self._arbiter.u = value

    property velocity:
        '''
        Velocity
        '''
        def __get__(self):
            return self._arbiter.surface_vr

    property total_impulse:
        '''
        Returns the impulse that was applied this step to resolve the collision
        '''
        def __get__(self):
            return cpArbiterTotalImpulse(self._arbiter)

    property total_impulse_with_friction:
        '''
        Returns the impulse with friction that was applied this step to resolve the collision
        '''
        def __get__(self):
            return cpArbiterTotalImpulseWithFriction(self._arbiter)

    #property stamp:
    #    '''
    #    Time stamp of the arbiter. (from the space)
    #    '''
    #    def __get__(self):
    #        return self._arbiter.stamp

    property is_first_contact:
        '''
        Returns true if this is the first step that an arbiter existed. You can
        use this from preSolve and postSolve to know if a collision between two
        shapes is new without needing to flag a boolean in your begin callback.
        '''
        def __get__(self):
            return cpArbiterIsFirstContact(self._arbiter)

