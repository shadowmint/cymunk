cdef class Space:
    '''
    Spaces are the basic unit of simulation. You add rigid bodies, shapes and
    joints to it and then step them all forward together through time.
    '''

    def __init__(self, int iterations=10):
        '''
        Create a new instace of the Space

        Its usually best to keep the elastic_iterations setting to 0. Only
        change if you have problem with stacking elastic objects on each other.
        If that is the case, try to raise it. However, a value other than 0 will
        affect other parts, most importantly you wont get reliable total_impulse
        readings from the Arbiter object in collsion callbacks!
        '''
        self._space = cpSpaceNew()
        self._space.iterations = iterations
        self._static_body = Body()
        self._static_body._body = self._space.staticBody

        #self._handlers = {}
        #self._default_handler = None
        self._post_step_callbacks = {}
        self._shapes = {}
        self._static_shapes = {}
        self._bodies = []
        self._constraints = []
        #self._bodies = set()
        #self._constraints = set()

    def __dealloc__(self):
        self._static_body = None
        cpSpaceFree(self._space)

    property shapes:
        '''
        A list of the shapes added to this space
        '''
        def __get__(self):
            return list(self._shapes.values())

    property static_shapes:
        '''
        A list of the static shapes added to this space
        '''
        def __get__(self):
            return list(self._static_shapes.values())

    property bodies:
        '''
        A list of the bodies added to this space
        '''
        def __get__(self):
            return list(self._bodies)

    property constraints:
        '''
        A list of the constraints added to this space
        '''
        def __get__(self):
            return self._constraints

    property static_body:
        '''
        A convenience static body already added to the space
        '''
        def __get__(self):
            return self._static_body

    property iterations:
        '''
        Number of iterations to use in the impulse solver to solve contacts.
        '''
        def __get__(self):
            return self._space.iterations
        def __set__(self, int iterations):
            self._space.iterations = iterations

    property gravity:
        '''
        Default gravity to supply when integrating rigid body motions.
        '''
        def __get__(self):
            return Vec2d(self._space.gravity.x, self._space.gravity.y)
        def __set__(self, gravity):
            cdef Vec2d vec
            if isinstance(gravity, Vec2d):
                vec = gravity
                self._space.gravity = vec.v
            else:
                self._space.gravity = cpv(gravity[0], gravity[1])

    property damping:
        '''
        Damping rate expressed as the fraction of velocity bodies retain each second.
        '''
        def __get__(self):
            return self._space.damping
        def __set__(self, damping):
            self._space.damping = damping

    property idle_speed_threshold:
        '''
        Speed threshold for a body to be considered idle. The default value of 0
        means to let the space guess a good threshold based on gravity.
        '''
        def __get__(self):
            return self._space.idleSpeedThreshold
        def __set__(self, idle_speed_threshold):
            self._space.idleSpeedThreshold = idle_speed_threshold

    property sleep_time_threshold:
        '''
        Time a group of bodies must remain idle in order to fall asleep.
        '''
        def __get__(self):
            return self._space.sleepTimeThreshold
        def __set__(self, sleep_time_threshold):
            self._space.sleepTimeThreshold = sleep_time_threshold

    property collision_slop:
        '''
        Amount of allowed penetration.
        '''
        def __get__(self):
            return self._space.collisionSlop
        def __set__(self, collision_slop):
            self._space.collisionSlop = collision_slop

    property collision_bias:
        '''
        Determines how fast overlapping shapes are pushed apart.
        '''
        def __get__(self):
            return self._space.collisionBias
        def __set__(self, collision_bias):
            self._space.collisionBias = collision_bias

    property collision_persistence:
        '''
        Number of frames that contact information should persist.
        '''
        def __get__(self):
            return self._space.collisionPersistence
        def __set__(self, collision_persistence):
            self._space.collisionPersistence = collision_persistence

    property enable_contact_graph:
        '''
        Rebuild the contact graph during each step.
        '''
        def __get__(self):
            return self._space.enableContactGraph
        def __set__(self, enable_contact_graph):
            self._space.enableContactGraph = enable_contact_graph


    def add(self, *objs):
        '''
        Add one or many shapes, bodies or joints to the space
        '''
        for o in objs:
            if isinstance(o, Body):
                if o.is_static:
                    raise Exception('Cannot add a static Body in Space')
                self.add_body(o)
            elif isinstance(o, Shape):
                self.add_shape(o)
            #elif isinstance(o, Constraint):
            #    self.add_constraint(o)
            else:
                for oo in o:
                    self.add(oo)

    def add_static(self, *objs):
        '''
        Add one or many static shapes to the space
        '''
        for o in objs:
            if isinstance(o, Shape):
                self.add_static_shape(o)
            else:
                for oo in o:
                    self.add_static(oo)

    def add_shape(self, Shape shape):
        assert shape._hashid_private not in self._shapes, "shape already added to space"
        self._shapes[shape._hashid_private] = shape
        cpSpaceAddShape(self._space, shape._shape)
        return shape

    def add_static_shape(self, Shape static_shape):
        assert static_shape._hashid_private not in self._static_shapes, "shape already added to space"
        self._static_shapes[static_shape._hashid_private] = static_shape
        cpSpaceAddStaticShape(self._space, static_shape._shape)
        return static_shape

    def add_body(self, Body body):
        assert body not in self._bodies, "body already added to space"
        self._bodies.append(body)
        cpSpaceAddBody(self._space, body._body)
        return body

    def add_constraint(self, constraint):
        assert constraint not in self._constraints, "constraint already added to space"
        self._constraints.add(constraint)
    #    cpSpaceAddConstraint(self._space, constraint._constraint)
        return constraint


    def remove(self, *objs):
        '''
        Remove one or many shapes, bodies or constraints from the space
        '''
        for o in objs:
            if isinstance(o, Body):
                self._remove_body(o)
            elif isinstance(o, Shape):
                self._remove_shape(o)
            #elif isinstance(o, Constraint):
            #    self._remove_constraint(o)
            else:
                for oo in o:
                    self.remove(oo)

    def remove_static(self, *objs):
        '''
        Remove one or many static shapes from the space
        '''
        for o in objs:
            if isinstance(o, Shape):
                self._remove_static_shape(o)
            else:
                for oo in o:
                    self.remove_static(oo)

    def _remove_shape(self, Shape shape):
        del self._shapes[shape._hashid_private]
        cpSpaceRemoveShape(self._space, shape._shape)

    def _remove_static_shape(self, Shape static_shape):
        del self._static_shapes[static_shape._hashid_private]
        cpSpaceRemoveStaticShape(self._space, static_shape._shape)

    def _remove_body(self, Body body):
        self._bodies.remove(body)
        cpSpaceRemoveBody(self._space, body._body)

    def _remove_constraint(self, constraint):
        self._constraints.remove(constraint)
    #    cpSpaceRemoveConstraint(self._space, constraint._constraint)


    def reindex_static(self):
        '''
        Update the collision detection info for the static shapes in the space.
        You only need to call this if you move one of the static shapes.
        '''
        cpSpaceReindexStatic(self._space)

    def reindex_shape(self, Shape shape):
        '''
        Update the collision detection data for a specific shape in the space.
        '''
        cpSpaceReindexShape(self._space, shape._shape)

    def step(self, dt):
        '''
        Update the space for the given time step. Using a fixed time step is
        highly recommended. Doing so will increase the efficiency of the contact
        persistence, requiring an order of magnitude fewer iterations to resolve
        the collisions in the usual case.
        '''
        cpSpaceStep(self._space, dt)
        for obj, (func, args, kwargs) in self._post_step_callbacks.items():
            func(obj, *args, **kwargs)
        self._post_step_callbacks = {}

    #def add_collision_handler(self, a, b, begin=None, pre_solve=None, post_solve=None, separate=None, *args, **kwargs):
    #    _functions = self._collision_function_helper(begin, pre_solve, post_solve, separate, *args, **kwargs)
    #    self._handlers[(a, b)] = _functions
    #    cpSpaceAddCollisionHandler(self._space, a, b,
    #        _functions[0], _functions[1], _functions[2], _functions[3], None)

    #def set_default_collision_handler(self, begin=None, pre_solve=None, post_solve=None, separate=None, *args, **kwargs):
    #    _functions = self._collision_function_helper(
    #        begin, pre_solve, post_solve, separate, *args, **kwargs
    #        )
    #    self._default_handler = _functions
    #    cpSpaceSetDefaultCollisionHandler(self._space,
    #        _functions[0], _functions[1], _functions[2], _functions[3], None)
