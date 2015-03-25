define ['droplet-helper', 'droplet-model', 'droplet-parser'], (helper, model, parser) ->
  exports = {}
  exports.CsvParser = class CsvParser extends parser.Parser
    constructor: (@text, @opts = {}) ->
        console.log "OK"
        super
        
    CsvParser.empty = "\"\""
    
    markRoot: ->
      @tree = @parseText()
      for block in @tree
        @mark 0, block.block, 0
      console.log 'PROGRAAAAAAAAAAAM IS', JSON.stringify @tree, null, 2
    
    parseText: ->
      lines = @text.split '\n'
      tree = []
      for line,i in lines
        console.log line
        if line.length > 0
          tree.push block:
            type : "block"
            location:
              start:
                line: i
                column: 0
              end:
                line: i
                column: line.length
          tree[i].block.children = @parseBlock line, i
      return tree
    
    parseBlock: (line, lineNumber) ->
      sockets = []
      start = 0
      level = 0
      i = 1
      for character in line
        if character is "," or i == (line.length)
          name = if i == line.length then line.substr(start, i) else line.substr(start, i - 1)
          end = if i == line.length then i else i - 1
          sockets.push socket:
            type: "socket"
            name: name
            socketLevel: level
            location:
              start:
                line: lineNumber
                column: start
              end:
                line: lineNumber
                column: end
           start = i
           level += 1
        i += 1
      return sockets
    
    addCsvBlock: (bounds, depth) ->
      @addBlock
        bounds: bounds
        depth: depth
        precedence: 1
        color: 'command'
        classes: 'any-drop'
        socketLevel: helper.ANY_DROP
    
    addCsvSocket: (bounds, depth) ->
      console.log "ADDING SOCKET"
      @addSocket
        bounds: bounds
        depth: depth
        precedence: 0

    addCsvIndent: (bounds, depth) ->
      console.log "INDENTGED"
      @addIndent
        bounds: bounds
        depth: depth
      console.log "DONE INTEND"
     
    mark: (indentDepth, node, depth) ->
      console.log "MARKING ", node.type
      console.log 'BLOCK IS', JSON.stringify node, null, 2
      switch node.type
        when "block"
          @addCsvBlock node.location, depth
          for children in node.children
            @mark indentDepth + 1, children.socket, depth + 1 
        when "socket" 
          console.log "SOCKETING"
          @addCsvSocket node.location, depth
          #@addCsvIndent node.location, depth          
    isComment: (text) ->
      text.match(/^\s*\/\/.*$/)  
  
  return parser.wrapParser CsvParser
