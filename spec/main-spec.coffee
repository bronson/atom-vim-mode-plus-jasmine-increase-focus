requireFrom = (pack, path) ->
  packPath = atom.packages.resolvePackagePath(pack)
  require "#{packPath}/#{path}"

{getVimState} = requireFrom 'vim-mode-plus', 'spec/spec-helper'

describe "vim-mode-plus-jasmine-increase-focus", ->
  [set, ensure, keystroke, editor, editorElement, vimState] = []

  beforeEach ->
    atom.keymaps.add "test",
      'atom-text-editor.vim-mode-plus.normal-mode':
        '+': 'vim-mode-plus-user:jasmine-increase-focus'
        '-': 'vim-mode-plus-user:jasmine-decrease-focus'
      , 100

    waitsForPromise ->
      atom.packages.activatePackage('vim-mode-plus-jasmine-increase-focus')

  describe "increase/decrease", ->
    pack = 'language-coffee-script'

    getEnsureRowText = (row, cursor) ->
      (_keystroke, rowText) ->
        keystroke _keystroke
        expect(editor.lineTextForBufferRow(row)).toBe rowText
        ensure cursor: cursor

    beforeEach ->
      waitsForPromise ->
        atom.packages.activatePackage(pack)

      getVimState 'sample.coffee', (state, vim) ->
        vimState = state
        {editor, editorElement} = state
        {set, ensure, keystroke} = vim

    afterEach ->
      atom.packages.deactivatePackage(pack)

    it "[Case: describe] Change focus level without moving cursor", ->
      set cursor: (point = [2, 4])
      ensureRowText = getEnsureRowText(0, point)

      ensureRowText '+', 'fdescribe "test", ->'
      ensureRowText '+', 'xdescribe "test", ->'
      ensureRowText '+', 'describe "test", ->'

      ensureRowText '-', 'xdescribe "test", ->'
      ensureRowText '-', 'fdescribe "test", ->'
      ensureRowText '-', 'describe "test", ->'

    it "[Case: it] Change focus level without moving cursor", ->
      set cursor: (point = [23, 13])
      ensureRowText = getEnsureRowText(20, point)

      ensureRowText '+', '  fit "test", ->'
      ensureRowText '+', '  xit "test", ->'
      ensureRowText '+', '  it "test", ->'

      ensureRowText '-', '  xit "test", ->'
      ensureRowText '-', '  fit "test", ->'
      ensureRowText '-', '  it "test", ->'

    describe "focusTexts settings", ->
      beforeEach ->
        focusTexts = ["f", "ff", "fff"]
        atom.config.set('vim-mode-plus-jasmine-increase-focus.focusTexts', focusTexts)

      it "Change focus text based on settings", ->
        set cursor: (point = [23, 13])
        ensureRowText = getEnsureRowText(20, point)

        ensureRowText '+', '  fit "test", ->'
        ensureRowText '+', '  ffit "test", ->'
        ensureRowText '+', '  fffit "test", ->'
        ensureRowText '+', '  it "test", ->'

        ensureRowText '-', '  fffit "test", ->'
        ensureRowText '-', '  ffit "test", ->'
        ensureRowText '-', '  fit "test", ->'
        ensureRowText '-', '  it "test", ->'
