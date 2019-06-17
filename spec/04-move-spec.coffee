# sub routine
move_cell_in_dir_to_rows = (direction, startRow, endRow) ->
  it "move cell #{direction}", ->
    if direction == 'up' then navi.moveCellUp() else navi.moveCellDown()
    range = editor.getSelectedBufferRange()
    expect(range.start.row).toEqual(startRow)
    expect(range.end.row).toEqual(endRow)

move_cell_both_dir_to_rows = (upStart, upEnd, downStart, downEnd) ->
  move_cell_in_dir_to_rows('up', upStart, upEnd)
  move_cell_in_dir_to_rows('down', downStart, downEnd)

setSampleTxt_and_cursor = (pos) ->
  setSampleTxt()
  setCursorPos pos

setSampleTxt_and_range = (range) ->
  setSampleTxt()
  editor.setSelectedBufferRange range

# test
describe 'Move Cell', ->
  describe 'original sample text', ->
    describe 'cursor in top cell', ->
      beforeEach -> setSampleTxt_and_cursor [1,0]
      move_cell_in_dir_to_rows('up',0,2)

      it 'insert cell mark when moving down', ->
        navi.moveCellDown()
        range = editor.getSelectedBufferRange()
        startRow = range.start.row
        line = editor.buffer.lineForRow(startRow)
        expect(line.substr(0, 4)).toEqual('# %%')
        expect(startRow).toEqual(2)
        expect(range.end.row).toEqual(5)

    describe 'cursor in second cell', ->
      beforeEach -> setSampleTxt_and_cursor [2,0]
      it 'insert cell mark for previous cell after moving up', ->
        navi.moveCellUp()
        startRow = editor.getSelectedBufferRange().end.row
        line = editor.buffer.lineForRow(startRow)
        expect(line.substr(0, 4)).toEqual('# %%')

    describe 'cursor inside cell content', ->
      beforeEach -> setSampleTxt_and_cursor [5,0]
      move_cell_both_dir_to_rows(2,5,7,10)

    describe 'cursor at cell mark start', ->
      beforeEach -> setSampleTxt_and_cursor [4,0]
      move_cell_both_dir_to_rows(2,5,7,10)

    describe 'cursor inside cell mark', ->
      beforeEach -> setSampleTxt_and_cursor [4,1]
      move_cell_both_dir_to_rows(2,5,7,10)

    describe 'cursor at bottom cell', ->
      beforeEach -> setSampleTxt_and_cursor [12,0]
      move_cell_both_dir_to_rows(7,10,10,13)

    describe 'selected multi lines in middle', ->
      beforeEach -> setSampleTxt_and_range [[5,6], [8,6]]
      move_cell_both_dir_to_rows(2,8,7,13)

    describe 'selected multi lines on top', ->
      beforeEach -> setSampleTxt_and_range [[0,0], [3,5]]
      move_cell_both_dir_to_rows(0,4,3,8)

    describe 'selected multi lines at bottom', ->
      beforeEach -> setSampleTxt_and_range [[9,0], [14,0]]
      move_cell_both_dir_to_rows(4,10,7,13)

  describe 'top line is cell mark', ->
    beforeEach ->
      setSampleTxt()
      editor.buffer.insert([0,0], '# %%')

    describe 'cursor in top cell', ->
      beforeEach -> setCursorPos [1,0]
      move_cell_both_dir_to_rows(0,2,2,4)

  describe 'bottom line has content', ->
    beforeEach ->
      setSampleTxt()
      endPos = editor.buffer.getEndPosition()
      editor.buffer.insert(endPos, 'happy #%%')

    describe 'cursor at bottom cell', ->
      beforeEach -> setCursorPos [12,0]
      move_cell_in_dir_to_rows('up',7,11)

    describe 'cursor at second bottom cell', ->
      beforeEach -> setCursorPos [8,0]
      move_cell_in_dir_to_rows('down',11,14)
