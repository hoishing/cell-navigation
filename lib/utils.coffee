{ Range } = require 'atom'

module.exports =
  regex: /^# ?%%/gm

  editor: -> @testingEditor ? atom.workspace.getActiveTextEditor()

  cursorRowEnd: ->
    currentRow = @editor().getCursorBufferPosition().row
    @editor().buffer.rangeForRow(currentRow).end


  rowEnd: (row) -> @editor().buffer.rangeForRow(row).end

  cellRange: ->
    editor = @editor()
    bufferEnd = editor.buffer.getEndPosition()

    startRow = editor.getSelectedBufferRange().start.row
    upperRange = new Range [0,0], @rowEnd(startRow)

    endPos = editor.getSelectedBufferRange().end
    endPos = @rowEnd(endPos.row) if startRow == endPos.row
    lowerRange = new Range endPos, bufferEnd

    upperCellPos = [0,0]
    lowerCellPos = bufferEnd
    editor.backwardsScanInBufferRange @regex, upperRange, (match) =>
      upperCellPos = match.range.start
      match.stop()
    editor.scanInBufferRange @regex, lowerRange, (match) =>
      lowerCellPos = match.range.start
      match.stop()
    new Range upperCellPos, lowerCellPos

  getCellRows: (range, funcName) ->
    cellRows = []
    maxRow =
      'scanInBufferRange': 0
      'backwardsScanInBufferRange': 1
    @editor()[funcName] @regex, range, (match) =>
      cellRows.push match.range.start.row
      match.stop() if cellRows.length > maxRow[funcName]
    cellRows

  reverseSelect: (range) ->
    @editor().setSelectedBufferRange range, reversed: true
