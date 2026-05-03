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

#let prefix = "eggs07"

#let split-line(line, separator: [ ]) = {
  if type(line) == array {
    return line
  }
  assert(type(line) == content)

  // one-word line
  if not line.has("children") {
    return (line,)
  }

  line.children.split(separator).filter(it => it != ()).map([].func())
}
