# sub routine

selectAndExpect= (startRow, endRow, direction) ->
  switch direction
    when 'up' then navi.selectUp()
    when 'down' then navi.selectDown()
    else navi.selectCell()
  selectedRange = editor.getSelectedBufferRange()
  expect(selectedRange.start.row).toEqual(startRow)
  expect(selectedRange.end.row).toEqual(endRow)

selectCellExpectRows = (startRow, endRow) ->
  it 'select current cell', ->
    selectAndExpect(startRow, endRow)

selectDownwardsReturnsRows = (startRow, endRow) ->
  it 'select downwards', ->
    selectAndExpect(startRow, endRow, 'down')

selectUpwardsReturnsRows = (startRow, endRow) ->
  it 'select upwards', ->
    selectAndExpect(startRow, endRow, 'up')

select_all_direction_expect = (start, end, upStart, upEnd, downStart, downEnd) ->
  selectCellExpectRows(start, end)
  selectUpwardsReturnsRows(upStart, upEnd)
  selectDownwardsReturnsRows(downStart, downEnd)

# test
describe 'Select Cells', ->
  beforeEach -> setSampleTxt()

  describe 'original sample text', ->

    describe 'cursor in top cell', ->
      beforeEach -> setCursorPos [1,0]
      select_all_direction_expect 0,2,0,2,0,4

    describe 'cursor inside cell content', ->
      beforeEach -> setCursorPos [5,0]
      select_all_direction_expect 4,7,2,7,4,10

    describe 'cursor at cell mark start', ->
      beforeEach -> setCursorPos [4,0]
      select_all_direction_expect 4,7,2,7,4,10

    describe 'cursor inside cell mark', ->
      beforeEach -> setCursorPos [4,1]
      select_all_direction_expect 4,7,2,7,4,10

    describe 'cursor at bottom cell', ->
      beforeEach -> setCursorPos [12,0]
      select_all_direction_expect 10,13,7,13,10,13

    describe 'selected multi lines in middle', ->
      beforeEach -> editor.setSelectedBufferRange [[5,3], [8,4]]
      select_all_direction_expect 4,10,2,10,4,13

    describe 'selected multi lines on top', ->
      beforeEach -> editor.setSelectedBufferRange [[1,5], [5,7]]
      select_all_direction_expect 0,7,0,7,0,10

    describe 'selected multi lines at bottom', ->
      beforeEach -> editor.setSelectedBufferRange [[9,5], [11,4]]
      select_all_direction_expect 7,13,4,13,7,13

  describe 'top line is cell mark', ->
    beforeEach -> editor.buffer.insert([0,0], '# %%')

    describe 'cursor in top cell', ->
      beforeEach -> setCursorPos [1,0]
      select_all_direction_expect 0,2,0,2,0,4

  describe 'bottom line has content', ->
    beforeEach -> editor.buffer.insert(editor.buffer.getEndPosition(), 'happy #%%')

    describe 'cursor at bottom cell', ->
      beforeEach -> setCursorPos [12,0]
      select_all_direction_expect 10,13,7,13,10,13
