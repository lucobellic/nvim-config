return {
  get_notes = function(args)
    local notes = require('util.glab.notes').get_unresolved_discussions()
    return 'Here is a list of notes from Pull Request:\n' .. notes .. '\n'
  end,
}
