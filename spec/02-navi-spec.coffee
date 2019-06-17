# sub routines
naviPrevToRow = (row) ->
  it 'execute `previousCell`', ->
    navi.previousCell()
    expect(editor.getCursorBufferPosition().row).toEqual(row)

naviNextToRow = (row) ->
  it 'execute nextCell', ->
    navi.nextCell()
    expect(editor.getCursorBufferPosition().row).toEqual(row)

naviBothDirTo = (pre, next) ->
  naviPrevToRow(pre)
  naviNextToRow(next)

describeCursorInMiddle = ->
  describe 'cursor inside cell content', ->
    beforeEach -> setCursorPos [5,0]
    naviBothDirTo(3,8)

  describe 'cursor at cell mark start', ->
    beforeEach -> setCursorPos [4,0]
    naviBothDirTo(3,8)

  describe 'cursor inside cell mark', ->
    beforeEach -> setCursorPos [4,1]
    naviBothDirTo(3,8)

# test start
describe 'Cell Navigation', ->
  beforeEach ->
    setSampleTxt()
    atom.packages.loadPackage('cell-navigation').activationCommands = {}
    waitsForPromise => atom.packages.activatePackage('cell-navigation')

  describe 'original sample text', ->

    describe 'cursor in top cell', ->
      beforeEach -> setCursorPos [1,0]
      naviBothDirTo(1,3)

    describeCursorInMiddle()

    describe 'cursor at bottom cell', ->
      beforeEach -> setCursorPos [12,0]
      naviBothDirTo(8,12)

  describe 'top line is cell mark', ->
    beforeEach -> editor.buffer.insert([0,0], '# %%')

    describe 'cursor in top cell', ->
      beforeEach -> setCursorPos [1,0]
      naviBothDirTo(1,3)

    describeCursorInMiddle()

  describe 'bottom line has content', ->
    beforeEach -> editor.buffer.insert(editor.buffer.getEndPosition(), 'happy #%%')

    describeCursorInMiddle()

    describe 'cursor at bottom cell', ->
      beforeEach -> setCursorPos [12,0]
      naviBothDirTo(8,12)
