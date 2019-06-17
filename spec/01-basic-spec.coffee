describe 'Basic Test', ->
  beforeEach -> setSampleTxt()

  it 'has editor', ->
    expect(navi.editor()).toBe(editor)

  it 'can read sample text from buffer', ->
    txt = editor.lineTextForBufferRow(2)
    expect(txt).toBe('# %%')

  it 'can detect cell mark', ->
    matches = []
    editor.scan regex, (match) ->
      matches.push(match.matchText)
    expect(matches.includes('# %%')).toBe(true)
    expect(matches.includes('#%%')).toBe(true)
