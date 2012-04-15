import cymunk as cy
import pytest

def test_vec2d():
    v = cy.Vec2d(1, 2)
    assert(v is not None)
    assert(v.x == 1)
    assert(v.y == 2)
    assert(v[0] == 1)
    assert(v[1] == 2)

    v.x = 3
    v.y = 4
    assert(v.x == 3)
    assert(v.y == 4)
    assert(v[0] == 3)
    assert(v[1] == 4)

    v[0] = 5
    assert(v.x == 5)
    assert(v.y == 4)
    assert(v[0] == 5)
    assert(v[1] == 4)

    v[1] = 6
    assert(v.x == 5)
    assert(v.y == 6)
    assert(v[0] == 5)
    assert(v[1] == 6)

def test_vec2d_indexerror():
    v = cy.Vec2d(1, 2)
    with pytest.raises(IndexError):
        v[2] = 1
