{ CompositeDisposable, Disposable, Range } = require 'atom'

module.exports = Object.assign require('./utils'),

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'cell-navigation:next-cell': => @nextCell()
      'cell-navigation:previous-cell': => @previousCell()
      'cell-navigation:select-cell': => @selectCell()
      'cell-navigation:select-up': => @selectUp()
      'cell-navigation:select-down': => @selectDown()
      'cell-navigation:move-cell-up': => @moveCellUp()
      'cell-navigation:move-cell-down': => @moveCellDown()

  deactivate: -> @subscriptions.dispose()

  # commands

  selectCell: -> @reverseSelect @cellRange()

  selectDown: ->
    currentRange = @cellRange()
    @editor().setCursorBufferPosition(currentRange.end)
    # @nextCell()
    downRange = @cellRange()
    @editor().setSelectedBufferRange [currentRange.start, downRange.end]

  selectUp: ->
    currentRange = @cellRange()
    upRow = currentRange.start.row - 1
    upRow = 0 if upRow < 0
    @editor().setCursorBufferPosition [upRow, 0]
    upRange = @cellRange()
    @reverseSelect [upRange.start, currentRange.end]

  nextCell: ->
    bufferEnd = @editor().buffer.getEndPosition()
    range = new Range @cursorRowEnd(), bufferEnd
    cellRows = @getCellRows range, 'scanInBufferRange'
    return if cellRows.length == 0
    return if cellRows[0] == bufferEnd.row
    @editor().setCursorBufferPosition [cellRows[0] + 1, 0]


  previousCell: ->
    range = new Range [0,0], @cursorRowEnd()
    cellRows = @getCellRows range, 'backwardsScanInBufferRange'
    return if cellRows.length == 0
    if cellRows.length == 1
      if cellRows[0] == 0 then return else
        return @editor().setCursorBufferPosition [0,0]
    @editor().setCursorBufferPosition [cellRows[1] + 1, 0]

  moveCellUp: ->
    editor = @editor()
    cellRange = @cellRange()
    return @reverseSelect cellRange if cellRange.start.row == 0
    range = new Range [0,0], cellRange.start
    insertPos = [0,0]
    editor.backwardsScanInBufferRange @regex, range, (match) =>
      insertPos = match.range.start
      match.stop()
    editor.transact =>
      txt = editor.getTextInBufferRange cellRange
      # cell required to end with newline
      txt += '\n' unless txt.endsWith '\n'
      editor.buffer.delete cellRange
      # insert cell mark if the top cell doesn't have one
      if insertPos[0] == 0 and editor.buffer.lineForRow(0).search(@regex) != 0
        editor.buffer.insert insertPos, '# %%\n'
      editor.setCursorBufferPosition insertPos
      insertRanges = editor.insertText txt
      @reverseSelect insertRanges[0]

  moveCellDown: ->
    editor = @editor()
    cellRange = @cellRange()
    bufferEnd = editor.buffer.getEndPosition()
    if cellRange.end.row == bufferEnd.row
      return @reverseSelect cellRange
    searchStart = editor.buffer.rangeForRow(cellRange.end.row).end
    range = new Range searchStart, bufferEnd
    insertPos = bufferEnd
    editor.scanInBufferRange @regex, range, (match) =>
      insertPos = match.range.start
      match.stop()
    editor.transact =>
      txt = editor.getTextInBufferRange cellRange
      txt = '# %%\n' + txt if txt.search(@regex) != 0
      editor.setCursorBufferPosition insertPos
      # insert newline if bufferEnd doens't have it
      editor.buffer.append '\n' if bufferEnd.column != 0
      insertRanges = editor.insertText txt
      @reverseSelect insertRanges[0]
      editor.buffer.delete cellRange
