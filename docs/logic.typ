#let indent-width = 1.2em
#let comment-color = luma(80)
#let association-color = rgb("b16286")
#let attribute-color = rgb("98971a")
#let class-color = rgb("458588")
#let keyword-color = rgb("d79921")

#let to-string(it) = {
    if type(it) == str {
        it
    } else if type(it) != content {
        str(it)
    } else if it.has("text") {
        it.text
    } else if it.has("children") {
        it.children.map(to-string).join()
    } else if it.has("body") {
        to-string(it.body)
    } else if it == [] {
        " "
    }
}

#let indent-block(body) = box(inset: (x: indent-width), body)

#let regular(body) = text(weight: "regular", body)

#let world-keywords = ("true", "false", "result", "now", "max", "min", "argmax", "argmin", "this", "auth", "sorted")
#let logic-keywords = ("forall", "exists", "and", "or", "xor", "in")
#let logic-symbols = ("<->", "<=", "!=", "->")

#let logic(body) = {
    // show sym.space.nobreak: h(indent-width)
    show sym.space.nobreak: hide(`	`)
    show emph: set text(association-color, weight: 350)

    show regex("[\w_]+\("): set text(attribute-color, weight: 350)
    show regex("\("): set text(black, weight: "light")
    show regex("\b(" + world-keywords.join("|") + ")\b"): set text(keyword-color, weight: 350)
    show regex("\b(" + logic-keywords.join("|") + ")\b"): re => eval(re.text, mode: "math")
    show regex(logic-symbols.join("|")): re => eval(re.text, mode: "math")

    show regex("not"): $not #h(-.5em)$

    show regex("\$(.*?)\$"): re => eval(re.text, mode: "markup")
    show regex("[A-Z]\w+"): set text(class-color, weight: 350)
    show regex("\*(\S*)\*"): re => {
        show "*": ""
        emph(re.text)
    }

    // show raw: set text(font: "CaskaydiaCove NFM", lang: "it", weight: "light", size: 9pt)
    // set text(font: "CaskaydiaCove NFM", lang: "it", weight: "light", size: 9pt)

    body
}

#let sub-par(
    title,
    body,
) = {
    // strong(text(font: "New Computer Modern", size: 11pt, title))
    strong(title)
    linebreak()
    indent-block(logic(body))
}

#let constraint(
    name,
    body,
) = {
    highlight[
        #figure(kind: "constraint", supplement: to-string(name), logic(name))
        #label(to-string(name))
        #label("constraint")
    ]

    v(-.5em)

    par(indent-block(logic(body)))
}

#let operation(
    name,
    args: none,
    type: none,
    prec: none,
    post: none,
) = {
    highlight[
        #figure(
            kind: "operation",
            supplement: to-string(name),
            logic[#name\(#args)#if type != none [: #type]],
        )
        #label(to-string(name))
        #label("operation")
    ]

    if prec != none {
        v(-.5em)
        par(indent-block(sub-par([precondizioni:], prec)))
    }

    if post != none {
        v(-.5em)
        par(indent-block(sub-par([postcondizioni:], post)))
    }
}


#let extension(body: none, new-objects: none, old-objects: none, tuple-variations: none) = {
    sub-par(
        [modifiche al livello estensionale:],
        {
            if body != none {
                v(2pt)
                body
            }

            if new-objects != none {
                if body != none { v(-.5em) }
                par(sub-par(regular[nuovi oggetti:], new-objects))
            }

            if old-objects != none {
                if body != none or new-objects != none { v(-.5em) }
                par(sub-par(regular[oggetti rimossi:], old-objects))
            }

            if tuple-variations != none {
                if body != none or new-objects != none or old-objects != none { v(-.5em) }
                par(sub-par(regular[variazioni sulle tuple:], tuple-variations))
            }
        },
    )
}
