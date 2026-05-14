#import "@preview/elembic:1.1.1" as e

#let auto-length = e.types.union(auto, length)

#let gen-get-function(it, ..args) = {
  for (field, default) in args.pos() {
    it.insert(
      "get-" + field,
      () => if it.at(field) == auto {
        default
      } else { it.at(field) }
    )
  }
  it
}

#let split-content(it) = {
  if type(it) == array {
    return it
  }
  assert(type(it) == content)

  let replace-spaces-in-content(it) = {
    if it.has("children") {
      it.children.map(replace-spaces-in-content).flatten()
    } else if it.has("text") {
      it.text.split(" ").map(text).intersperse([ ])
    } else {
      (it,)
    }
  }

  replace-spaces-in-content(it).split([ ]).filter(it => it != ()).map([].func())
}

#let prefix = "eggs07"
