g = global
g.sample = require('fs').readFileSync(__dirname + '/sample_text.py')
g.editor = atom.workspace.buildTextEditor()
g.navi = require '../lib/main.coffee'
navi.testingEditor = editor
g.regex = /^# ?%%/gm

g.setCursorPos = (pos) -> editor.setCursorBufferPosition(pos)
g.setSampleTxt = -> editor.setText(sample)
