T = should.assert
F = (expr) -> T !expr

describe 'Smoke tests', ->
  it 'should pass the T test', ->
    T true
  it 'should pass the F test', ->
    F false
  it 'should throw an error in T', ->
    (-> T false).should.throw()
  it 'should throw an error in F', ->
    (-> F true).should.throw()
  it 'should be true', ->
    true.should.be.true
  it 'should be false', ->
    false.should.be.false
