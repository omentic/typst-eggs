#import "@preview/elembic:1.1.1" as e

#import "utils.typ": auto-length, prefix, gen-get-function, split-line

/// Interlinear gloss grid.
///
/// - body (content): Any number of rows of equal length. Rows can be either contents where elements are separated by more than one space or lists.
///
///   *Required*
///
/// - word-spacing (length): Horizontal spacing between words in glosses.
///
///   *Default*: 1em
///
/// - line-spacing (length): Vertical spacing between lines in glosses.
///
///   *Default*: current `par.leading`.
///
/// - before-spacing (length): Vertical spacing above glosses (i.e. after the preamble).
///
///   *Default*: current `par.leading`.
///
/// - after-spacing (length): Vertical spacing below glosses (i.e. before the translation).
///
///   *Default*: current `par.leading`.
///
/// - styles (array): List of functions to be applied to each line of glosses.
///   Can be of any length. `gloss-styles[0]` is applied to the first line,
///   `gloss-styles[1]` --- to the second, etc.
///   E.g. ```typst (emph, it => it + [.])``` makes the first line italicized
///   and adds a period to the second line.
///
///   *Default*: ()
///
///
/// -> content
#let gloss = e.element.declare(
  "gloss",
  prefix: prefix,
  doc: "Interlinear gloss grid",
  labelable: false,

  fields: (
    e.field("body", array, required: true, doc: "Any number of rows of equal length. Rows can be either contents where elements are separated by more than one space or lists."),
    e.field("word-spacing", length, default: 1em, doc: "Horizontal spacing between words in glosses."),
    e.field("line-spacing", auto-length, doc: "Vertical spacing between lines in glosses. Defaults to `par.leading`."),
    e.field("before-spacing", auto-length, doc: "Vertical spacing above glosses (i.e. after the preamble). Defaults to `par.leading`."),
    e.field("after-spacing", auto-length, doc: "Vertical spacing below glosses (i.e. before the translation). Defaults to `par.leading`."),
    e.field("styles", array, doc: "List of functions to be applied to each line of glosses. Can be of any length. `gloss-styles[0]` is applied to the first line, `gloss-styles[1]` --- to the second, etc. E.g. ```typst (emph, it => it + [.])``` makes the first line italicized and adds a period to the second line."),

    e.field("get-line-spacing", function, synthesized: true, default: () => par.leading),
    e.field("get-before-spacing", function, synthesized: true, default: () => par.leading),
    e.field("get-after-spacing", function, synthesized: true, default: () => par.leading),
  ),

  parse-args: (default-parser, fields: none, typecheck: none) => (args, include-required: false) => {
    let args = if include-required {
      arguments(args.pos(), ..args.named())
    } else if args.pos() == () {
      args
    } else {
      return (false, "element 'sunk': unexpected positional arguments\n  hint: these can only be passed to the constructor")
    }

    default-parser(args, include-required: include-required)
  },

  synthesize: it => gen-get-function(
    it,
    ("line-spacing", par.leading),
    ("before-spacing", par.leading),
    ("after-spacing", par.leading)
  ),

  // error traces do not go through context (https://github.com/PgBiel/elembic/issues/84),
  // so we must put all example/gloss validation in the constructor.
  construct: constructor => (..args) => {
    let lines = args.pos().map(split-line)
    // this seems to always be true.
    assert(lines.len() > 0, message: "at least one gloss line must be present")

    // guard against invalid line lengths
    let length = lines.at(0).len()
    for line in lines {
      assert(line.len() == length, message: "gloss lines have different lengths. are the glossed words separated by two or more spaces?")
    }

    constructor(..lines)
  },

  display: elem => {
    // fill missing styles with defaults
    let styles = elem.styles
    if styles.len() < elem.body.len() {
      styles += (x => x,) * (elem.body.len() - styles.len())
    }

    let before-spacing = (elem.get-before-spacing)()
    let after-spacing = (elem.get-after-spacing)()
    let line-spacing = (elem.get-line-spacing)()
    let word-spacing = elem.word-spacing
    let length = elem.body.at(0).len()
    block(
      above: before-spacing,
      below: after-spacing,
      for word-index in range(0, length) {
        let words = elem.body.map(line => line.at(word-index))
        let args = words.zip(styles).map(((word, style)) => style(word))
        box(grid(row-gutter: line-spacing, ..args))
        h(word-spacing)
      }
    )
  }
)
